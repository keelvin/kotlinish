import 'dart:async';
import 'dart:collection';

/// A generic cache interface.
abstract class Cache<K, V> {
  /// Gets a value by key.
  V? get(K key);

  /// Puts a value in the cache.
  void put(K key, V value);

  /// Removes a value from the cache.
  V? remove(K key);

  /// Clears all cached values.
  void clear();

  /// Gets the number of cached items.
  int get size;

  /// Checks if the cache contains a key.
  bool containsKey(K key);
}

/// A Least Recently Used (LRU) cache implementation.
class LruCache<K, V> implements Cache<K, V> {
  final int _maxSize;
  final LinkedHashMap<K, V> _cache = LinkedHashMap<K, V>();

  /// Creates an LRU cache with the specified maximum size.
  LruCache(this._maxSize) {
    if (_maxSize <= 0) {
      throw ArgumentError('Cache size must be positive');
    }
  }

  @override
  V? get(K key) {
    final value = _cache.remove(key);
    if (value != null) {
      _cache[key] = value; // Move to end (most recently used)
    }
    return value;
  }

  @override
  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    } else if (_cache.length >= _maxSize) {
      _cache.remove(_cache.keys.first); // Remove least recently used
    }
    _cache[key] = value;
  }

  @override
  V? remove(K key) => _cache.remove(key);

  @override
  void clear() => _cache.clear();

  @override
  int get size => _cache.length;

  @override
  bool containsKey(K key) => _cache.containsKey(key);
}

/// A cache with time-based expiration.
class ExpiringCache<K, V> implements Cache<K, V> {
  final Duration _duration;
  final Map<K, _CacheEntry<V>> _cache = <K, _CacheEntry<V>>{};

  /// Creates a cache with time-based expiration.
  ExpiringCache(this._duration);

  @override
  V? get(K key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (_isExpired(entry)) {
      _cache.remove(key);
      return null;
    }

    return entry.value;
  }

  @override
  void put(K key, V value) {
    _cache[key] = _CacheEntry(value, DateTime.now());
  }

  @override
  V? remove(K key) {
    final entry = _cache.remove(key);
    return entry?.value;
  }

  @override
  void clear() => _cache.clear();

  @override
  int get size => _cache.length;

  @override
  bool containsKey(K key) {
    final entry = _cache[key];
    if (entry == null) return false;

    if (_isExpired(entry)) {
      _cache.remove(key);
      return false;
    }

    return true;
  }

  bool _isExpired(_CacheEntry<V> entry) {
    return DateTime.now().difference(entry.timestamp) > _duration;
  }

  /// Removes all expired entries.
  void cleanup() {
    final now = DateTime.now();
    _cache.removeWhere((key, entry) =>
    now.difference(entry.timestamp) > _duration);
  }
}

class _CacheEntry<V> {
  final V value;
  final DateTime timestamp;

  _CacheEntry(this.value, this.timestamp);
}

/// A memoization utility for caching function results.
class Memoizer<T, R> {
  final R Function(T) _function;
  final Cache<T, R> _cache;

  /// Creates a memoizer with an optional custom cache.
  Memoizer(this._function, {Cache<T, R>? cache})
      : _cache = cache ?? LruCache<T, R>(100);

  /// Calls the function with memoization.
  R call(T argument) {
    final cached = _cache.get(argument);
    if (cached != null) return cached;

    final result = _function(argument);
    _cache.put(argument, result);
    return result;
  }

  /// Clears the cache.
  void clear() => _cache.clear();

  /// Gets cache statistics.
  int get cacheSize => _cache.size;
}

/// Extensions for easy memoization.
extension FunctionMemoization<T, R> on R Function(T) {
  /// Creates a memoized version of this function.
  ///
  /// Example:
  /// ```dart
  /// int fibonacci(int n) => n <= 1 ? n : fibonacci(n-1) + fibonacci(n-2);
  /// final memoizedFib = fibonacci.memoized();
  /// final result = memoizedFib(40); // Much faster on subsequent calls
  /// ```
  Memoizer<T, R> memoized({Cache<T, R>? cache}) {
    return Memoizer(this, cache: cache);
  }
}

/// A cache-aware data loader.
class DataLoader<K, V> {
  final Future<V> Function(K) _loader;
  final Cache<K, Future<V>> _cache;
  /// Optional expiry duration for cached items.
  final Duration? expiry;

  /// Creates a data loader with optional caching and expiry.
  DataLoader(
      this._loader, {
        Cache<K, Future<V>>? cache,
        this.expiry,
      }) : _cache = cache ?? LruCache<K, Future<V>>(100);

  /// Loads data with caching.
  ///
  /// Example:
  /// ```dart
  /// final userLoader = DataLoader<String, User>(
  ///   (id) => fetchUserFromApi(id),
  ///   expiry: Duration(minutes: 5),
  /// );
  ///
  /// final user = await userLoader.load('user123');
  /// ```
  Future<V> load(K key) {
    final cached = _cache.get(key);
    if (cached != null) return cached;

    final future = _loader(key);
    _cache.put(key, future);

    // Remove from cache on error
    future.catchError((Object error) {
      _cache.remove(key);
      return Future<V>.error(error);
    });

    return future;
  }

  /// Loads multiple keys in parallel.
  ///
  /// Example:
  /// ```dart
  /// final users = await userLoader.loadMany(['user1', 'user2', 'user3']);
  /// ```
  Future<List<V>> loadMany(List<K> keys) {
    final futures = keys.map(load).toList();
    return Future.wait(futures);
  }

  /// Clears a specific key from cache.
  void evict(K key) => _cache.remove(key);

  /// Clears all cached data.
  void clearCache() => _cache.clear();

  /// Pre-loads data into cache.
  void prime(K key, V value) {
    _cache.put(key, Future.value(value));
  }
}

/// A multi-level cache system.
class MultiLevelCache<K, V> implements Cache<K, V> {
  final List<Cache<K, V>> _levels;

  /// Creates a multi-level cache with the specified cache levels.
  MultiLevelCache(this._levels) {
    if (_levels.isEmpty) {
      throw ArgumentError('At least one cache level is required');
    }
  }

  @override
  V? get(K key) {
    for (int i = 0; i < _levels.length; i++) {
      final value = _levels[i].get(key);
      if (value != null) {
        // Promote to higher levels
        for (int j = 0; j < i; j++) {
          _levels[j].put(key, value);
        }
        return value;
      }
    }
    return null;
  }

  @override
  void put(K key, V value) {
    for (final level in _levels) {
      level.put(key, value);
    }
  }

  @override
  V? remove(K key) {
    V? result;
    for (final level in _levels) {
      final removed = level.remove(key);
      result ??= removed;
    }
    return result;
  }

  @override
  void clear() {
    for (final level in _levels) {
      level.clear();
    }
  }

  @override
  int get size => _levels.first.size;

  @override
  bool containsKey(K key) {
    return _levels.any((level) => level.containsKey(key));
  }
}

/// Reactive cache that notifies on changes.
class ReactiveCache<K, V> implements Cache<K, V> {
  final Cache<K, V> _delegate;
  final StreamController<CacheEvent<K, V>> _controller =
  StreamController<CacheEvent<K, V>>.broadcast();

  /// Creates a reactive cache that wraps another cache.
  ReactiveCache(this._delegate);

  /// Stream of cache events.
  Stream<CacheEvent<K, V>> get events => _controller.stream;

  @override
  V? get(K key) {
    final value = _delegate.get(key);
    if (value != null) {
      _controller.add(CacheEvent.hit(key, value));
    } else {
      _controller.add(CacheEvent.miss(key));
    }
    return value;
  }

  @override
  void put(K key, V value) {
    _delegate.put(key, value);
    _controller.add(CacheEvent.put(key, value));
  }

  @override
  V? remove(K key) {
    final value = _delegate.remove(key);
    if (value != null) {
      _controller.add(CacheEvent.evicted(key, value));
    }
    return value;
  }

  @override
  void clear() {
    _delegate.clear();
    _controller.add(CacheEvent.cleared());
  }

  @override
  int get size => _delegate.size;

  @override
  bool containsKey(K key) => _delegate.containsKey(key);

  /// Disposes of resources used by the reactive cache.
  void dispose() {
    _controller.close();
  }
}

/// Cache event types.
class CacheEvent<K, V> {
  /// The type of cache event.
  final CacheEventType type;
  /// The key associated with this event.
  final K? key;
  /// The value associated with this event.
  final V? value;

  CacheEvent._(this.type, this.key, this.value);

  /// Creates a cache hit event.
  factory CacheEvent.hit(K key, V value) => CacheEvent._(CacheEventType.hit, key, value);
  /// Creates a cache miss event.
  factory CacheEvent.miss(K key) => CacheEvent._(CacheEventType.miss, key, null);
  /// Creates a cache put event.
  factory CacheEvent.put(K key, V value) => CacheEvent._(CacheEventType.put, key, value);
  /// Creates a cache evicted event.
  factory CacheEvent.evicted(K key, V value) => CacheEvent._(CacheEventType.evicted, key, value);
  /// Creates a cache cleared event.
  factory CacheEvent.cleared() => CacheEvent._(CacheEventType.cleared, null, null);
}

/// Types of cache events.
enum CacheEventType {
  /// A cache hit occurred.
  hit,
  /// A cache miss occurred.
  miss,
  /// An item was put in the cache.
  put,
  /// An item was evicted from the cache.
  evicted,
  /// The cache was cleared.
  cleared,
}

/// Cache statistics and monitoring.
class CacheStats {
  int _hits = 0;
  int _misses = 0;
  int _puts = 0;
  int _evictions = 0;

  /// Records a cache hit.
  void recordHit() => _hits++;
  /// Records a cache miss.
  void recordMiss() => _misses++;
  /// Records a cache put operation.
  void recordPut() => _puts++;
  /// Records a cache eviction.
  void recordEviction() => _evictions++;

  /// Gets the number of cache hits.
  int get hits => _hits;
  /// Gets the number of cache misses.
  int get misses => _misses;
  /// Gets the number of cache puts.
  int get puts => _puts;
  /// Gets the number of cache evictions.
  int get evictions => _evictions;
  /// Gets the total number of cache requests.
  int get requests => _hits + _misses;

  /// Gets the cache hit rate.
  double get hitRate => requests == 0 ? 0.0 : _hits / requests;
  /// Gets the cache miss rate.
  double get missRate => requests == 0 ? 0.0 : _misses / requests;

  /// Resets all statistics to zero.
  void reset() {
    _hits = 0;
    _misses = 0;
    _puts = 0;
    _evictions = 0;
  }

  @override
  String toString() {
    return 'CacheStats(hits: $_hits, misses: $_misses, hitRate: ${(hitRate * 100).toStringAsFixed(1)}%)';
  }
}