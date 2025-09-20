import 'dart:math' as math;
import 'dart:math';
import 'package:test/test.dart';

// Copy the required extensions directly for testing
typedef Random = math.Random;

/// Advanced collection operations inspired by Kotlin collections.
extension EnhancedCollectionOperations<T> on Iterable<T> {
  /// Returns the element at the given [index] or null if the index is out of bounds.
  T? getOrNull(int index) {
    if (index < 0) return null;
    final iterator = this.iterator;
    for (int i = 0; i <= index; i++) {
      if (!iterator.moveNext()) return null;
      if (i == index) return iterator.current;
    }
    return null;
  }

  /// Returns the element at the given [index] or the result of calling [defaultValue].
  T getOrElse(int index, T Function() defaultValue) {
    return getOrNull(index) ?? defaultValue();
  }

  /// Returns a list containing elements at specified [indices].
  List<T> slice(List<int> indices) {
    final list = toList();
    return indices
        .where((index) => index >= 0 && index < list.length)
        .map((index) => list[index])
        .toList();
  }

  /// Returns a list containing elements from [start] to [end] (exclusive).
  List<T> subList(int start, [int? end]) {
    final list = toList();
    final endIndex = end ?? list.length;
    if (start < 0 || start > list.length) return [];
    if (endIndex <= start) return [];

    return list.sublist(start, endIndex.clamp(0, list.length));
  }

  /// Returns a map grouping elements by the results of applying [keySelector] and [valueSelector].
  Map<K, List<V>> groupByTransform<K, V>(
      K Function(T element) keySelector,
      V Function(T element) valueSelector,
      ) {
    final map = <K, List<V>>{};
    for (final element in this) {
      final key = keySelector(element);
      final value = valueSelector(element);
      map.putIfAbsent(key, () => <V>[]).add(value);
    }
    return map;
  }

  /// Finds the first element matching [predicate] or null if none found.
  T? findFirst(bool Function(T element) predicate) {
    for (final element in this) {
      if (predicate(element)) return element;
    }
    return null;
  }

  /// Finds the last element matching [predicate] or null if none found.
  T? findLast(bool Function(T element) predicate) {
    T? result;
    for (final element in this) {
      if (predicate(element)) result = element;
    }
    return result;
  }

  /// Returns true if all elements are distinct.
  bool isDistinct() {
    final seen = <T>{};
    for (final element in this) {
      if (!seen.add(element)) return false;
    }
    return true;
  }

  /// Returns a new list with elements shuffled randomly.
  List<T> shuffled([Random? random]) {
    final list = toList();
    list.shuffle(random);
    return list;
  }

  /// Returns a random element from the collection.
  T? random([Random? random]) {
    if (this.isEmpty) return null;
    final list = toList();
    final rng = random ?? Random();
    return list[rng.nextInt(list.length)];
  }

  /// Splits the collection at positions where [predicate] returns true.
  List<List<T>> splitWhere(bool Function(T element) predicate) {
    final result = <List<T>>[];
    final current = <T>[];

    for (final element in this) {
      if (predicate(element)) {
        if (current.isNotEmpty) {
          result.add(List.from(current));
          current.clear();
        }
      } else {
        current.add(element);
      }
    }

    if (current.isNotEmpty) {
      result.add(current);
    }

    return result;
  }

  /// Returns elements with their indices as a Map.
  Map<int, T> indexedMap() {
    final map = <int, T>{};
    int index = 0;
    for (final element in this) {
      map[index++] = element;
    }
    return map;
  }

  /// Returns a sliding window of elements of the specified [size].
  List<List<T>> windowed(int size, {int step = 1}) {
    if (size <= 0) throw ArgumentError('Size must be positive');
    if (step <= 0) throw ArgumentError('Step must be positive');

    final list = toList();
    final result = <List<T>>[];

    for (int i = 0; i <= list.length - size; i += step) {
      result.add(list.sublist(i, i + size));
    }

    return result;
  }

  /// Creates pairs of adjacent elements.
  List<(T, T)> zipWithNext() {
    final list = toList();
    final result = <(T, T)>[];

    for (int i = 0; i < list.length - 1; i++) {
      result.add((list[i], list[i + 1]));
    }

    return result;
  }

  /// Combines elements with the next element using [transform].
  List<R> zipWithNextTransform<R>(R Function(T current, T next) transform) {
    final list = toList();
    final result = <R>[];

    for (int i = 0; i < list.length - 1; i++) {
      result.add(transform(list[i], list[i + 1]));
    }

    return result;
  }
}

/// Extensions for numeric collections.
extension NumericCollectionOperations<T extends num> on Iterable<T> {
  /// Returns the median value.
  double? median() {
    if (this.isEmpty) return null;

    final sorted = toList()..sort();
    final middle = sorted.length ~/ 2;

    if (sorted.length.isOdd) {
      return sorted[middle].toDouble();
    } else {
      return (sorted[middle - 1] + sorted[middle]) / 2;
    }
  }

  /// Returns the mode (most frequent value).
  T? mode() {
    if (this.isEmpty) return null;

    final counts = <T, int>{};
    for (final element in this) {
      counts[element] = (counts[element] ?? 0) + 1;
    }

    int maxCount = 0;
    T? modeValue;

    for (final entry in counts.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        modeValue = entry.key;
      }
    }

    return modeValue;
  }

  /// Returns the standard deviation.
  double? standardDeviation() {
    if (this.isEmpty) return null;

    final mean = _average()!;
    final variance = map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / length;
    return sqrt(variance);
  }

  /// Returns the range (max - min).
  num? range() {
    if (this.isEmpty) return null;
    final min = _minOrNull();
    final max = _maxOrNull();
    if (min == null || max == null) return null;
    return max - min;
  }

  double _average() {
    return fold<num>(0, (sum, element) => sum + element) / length;
  }

  T? _minOrNull() {
    if (this.isEmpty) return null;
    return reduce((a, b) => a < b ? a : b);
  }

  T? _maxOrNull() {
    if (this.isEmpty) return null;
    return reduce((a, b) => a > b ? a : b);
  }
}

void main() {
  group('EnhancedCollectionOperations', () {
    group('getOrNull', () {
      test('returns element at valid index', () {
        final list = [1, 2, 3, 4, 5];
        expect(list.getOrNull(0), equals(1));
        expect(list.getOrNull(2), equals(3));
        expect(list.getOrNull(4), equals(5));
      });

      test('returns null for negative index', () {
        final list = [1, 2, 3];
        expect(list.getOrNull(-1), isNull);
        expect(list.getOrNull(-5), isNull);
      });

      test('returns null for index out of bounds', () {
        final list = [1, 2, 3];
        expect(list.getOrNull(3), isNull);
        expect(list.getOrNull(10), isNull);
      });

      test('handles empty collection', () {
        final list = <int>[];
        expect(list.getOrNull(0), isNull);
        expect(list.getOrNull(1), isNull);
      });

      test('works with different collection types', () {
        final set = {1, 2, 3};
        expect(set.getOrNull(1), equals(2));
        expect(set.getOrNull(5), isNull);

        final iterable = [1, 2, 3].where((x) => x > 1);
        expect(iterable.getOrNull(0), equals(2));
        expect(iterable.getOrNull(1), equals(3));
        expect(iterable.getOrNull(2), isNull);
      });
    });

    group('getOrElse', () {
      test('returns element at valid index', () {
        final list = [1, 2, 3];
        expect(list.getOrElse(1, () => -1), equals(2));
      });

      test('returns default value for invalid index', () {
        final list = [1, 2, 3];
        expect(list.getOrElse(5, () => -1), equals(-1));
        expect(list.getOrElse(-1, () => 42), equals(42));
      });

      test('calls default function only when needed', () {
        final list = [1, 2, 3];
        bool called = false;
        final result = list.getOrElse(1, () {
          called = true;
          return -1;
        });
        expect(result, equals(2));
        expect(called, isFalse);
      });

      test('calls default function for out of bounds', () {
        final list = [1, 2, 3];
        bool called = false;
        final result = list.getOrElse(10, () {
          called = true;
          return -1;
        });
        expect(result, equals(-1));
        expect(called, isTrue);
      });

      test('handles empty collection', () {
        final list = <int>[];
        expect(list.getOrElse(0, () => 42), equals(42));
      });
    });

    group('slice', () {
      test('returns elements at specified indices', () {
        final list = ['a', 'b', 'c', 'd', 'e'];
        expect(list.slice([0, 2, 4]), equals(['a', 'c', 'e']));
        expect(list.slice([1, 3]), equals(['b', 'd']));
      });

      test('handles empty indices list', () {
        final list = [1, 2, 3];
        expect(list.slice([]), isEmpty);
      });

      test('ignores invalid indices', () {
        final list = [1, 2, 3];
        expect(list.slice([-1, 0, 2, 5]), equals([1, 3]));
      });

      test('handles duplicate indices', () {
        final list = [1, 2, 3];
        expect(list.slice([0, 1, 1, 2]), equals([1, 2, 2, 3]));
      });

      test('preserves order of indices', () {
        final list = [1, 2, 3, 4];
        expect(list.slice([3, 1, 0]), equals([4, 2, 1]));
      });

      test('handles empty collection', () {
        final list = <int>[];
        expect(list.slice([0, 1]), isEmpty);
      });
    });

    group('subList', () {
      test('returns sublist with start and end', () {
        final list = [1, 2, 3, 4, 5];
        expect(list.subList(1, 4), equals([2, 3, 4]));
        expect(list.subList(0, 2), equals([1, 2]));
      });

      test('returns sublist from start to end when end is null', () {
        final list = [1, 2, 3, 4, 5];
        expect(list.subList(2), equals([3, 4, 5]));
        expect(list.subList(0), equals([1, 2, 3, 4, 5]));
      });

      test('handles start at collection end', () {
        final list = [1, 2, 3];
        expect(list.subList(3), isEmpty);
      });

      test('returns empty for negative start', () {
        final list = [1, 2, 3];
        expect(list.subList(-1), isEmpty);
      });

      test('returns empty when start > collection length', () {
        final list = [1, 2, 3];
        expect(list.subList(5), isEmpty);
      });

      test('returns empty when end <= start', () {
        final list = [1, 2, 3, 4, 5];
        expect(list.subList(2, 2), isEmpty);
        expect(list.subList(3, 1), isEmpty);
      });

      test('clamps end to collection length', () {
        final list = [1, 2, 3];
        expect(list.subList(1, 10), equals([2, 3]));
      });

      test('handles empty collection', () {
        final list = <int>[];
        expect(list.subList(0), isEmpty);
        expect(list.subList(0, 1), isEmpty);
      });
    });

    group('groupByTransform', () {
      test('groups elements by key and transforms values', () {
        final users = [
          {'name': 'john', 'age': 25},
          {'name': 'jane', 'age': 30},
          {'name': 'bob', 'age': 25},
        ];

        final result = users.groupByTransform(
          (user) => user['age'],
          (user) => user['name'],
        );

        expect(result[25], equals(['john', 'bob']));
        expect(result[30], equals(['jane']));
      });

      test('handles empty collection', () {
        final list = <int>[];
        final result = list.groupByTransform((x) => x % 2, (x) => x * 2);
        expect(result, isEmpty);
      });

      test('handles single element', () {
        final list = [5];
        final result = list.groupByTransform((x) => x % 2, (x) => x * 2);
        expect(result[1], equals([10]));
      });

      test('groups all elements to same key', () {
        final list = [1, 2, 3, 4];
        final result = list.groupByTransform((x) => 'same', (x) => x * x);
        expect(result['same'], equals([1, 4, 9, 16]));
      });

      test('handles complex transformations', () {
        final words = ['hello', 'world', 'hi', 'dart'];
        final result = words.groupByTransform(
          (word) => word.length,
          (word) => word.toUpperCase(),
        );

        expect(result[2], equals(['HI']));
        expect(result[4], equals(['DART']));
        expect(result[5], equals(['HELLO', 'WORLD']));
      });
    });

    group('findFirst', () {
      test('finds first matching element', () {
        final list = [1, 2, 3, 4, 5];
        expect(list.findFirst((x) => x > 3), equals(4));
        expect(list.findFirst((x) => x.isEven), equals(2));
      });

      test('returns null when no match found', () {
        final list = [1, 2, 3];
        expect(list.findFirst((x) => x > 10), isNull);
      });

      test('handles empty collection', () {
        final list = <int>[];
        expect(list.findFirst((x) => x > 0), isNull);
      });

      test('returns first match even with multiple matches', () {
        final list = [1, 2, 3, 4, 5];
        expect(list.findFirst((x) => x.isOdd), equals(1));
      });

      test('works with different types', () {
        final words = ['apple', 'banana', 'cherry'];
        expect(words.findFirst((w) => w.startsWith('b')), equals('banana'));
        expect(words.findFirst((w) => w.length > 6), isNull);
      });
    });

    group('findLast', () {
      test('finds last matching element', () {
        final list = [1, 2, 3, 4, 5];
        expect(list.findLast((x) => x > 3), equals(5));
        expect(list.findLast((x) => x.isEven), equals(4));
      });

      test('returns null when no match found', () {
        final list = [1, 2, 3];
        expect(list.findLast((x) => x > 10), isNull);
      });

      test('handles empty collection', () {
        final list = <int>[];
        expect(list.findLast((x) => x > 0), isNull);
      });

      test('returns last match with multiple matches', () {
        final list = [1, 2, 3, 4, 5];
        expect(list.findLast((x) => x.isOdd), equals(5));
      });

      test('returns same element when only one match', () {
        final list = [1, 2, 3, 4, 5];
        expect(list.findLast((x) => x == 3), equals(3));
      });
    });

    group('isDistinct', () {
      test('returns true for distinct elements', () {
        expect([1, 2, 3, 4].isDistinct(), isTrue);
        expect(['a', 'b', 'c'].isDistinct(), isTrue);
        expect(<int>[].isDistinct(), isTrue);
      });

      test('returns false for duplicate elements', () {
        expect([1, 2, 2, 3].isDistinct(), isFalse);
        expect(['a', 'b', 'a'].isDistinct(), isFalse);
        expect([1, 1].isDistinct(), isFalse);
      });

      test('handles single element', () {
        expect([42].isDistinct(), isTrue);
      });

      test('works with different types', () {
        expect([true, false].isDistinct(), isTrue);
        expect([true, true].isDistinct(), isFalse);
      });
    });

    group('shuffled', () {
      test('returns list of same length', () {
        final list = [1, 2, 3, 4, 5];
        final shuffled = list.shuffled();
        expect(shuffled.length, equals(list.length));
      });

      test('contains same elements', () {
        final list = [1, 2, 3, 4, 5];
        final shuffled = list.shuffled();
        expect(shuffled.toSet(), equals(list.toSet()));
      });

      test('does not modify original list', () {
        final list = [1, 2, 3, 4, 5];
        final original = List.from(list);
        list.shuffled();
        expect(list, equals(original));
      });

      test('handles empty list', () {
        final list = <int>[];
        expect(list.shuffled(), isEmpty);
      });

      test('handles single element', () {
        final list = [42];
        expect(list.shuffled(), equals([42]));
      });

      test('uses provided random generator', () {
        final list = [1, 2, 3, 4, 5];
        final random = math.Random(42);
        final shuffled1 = list.shuffled(random);

        final random2 = math.Random(42);
        final shuffled2 = list.shuffled(random2);

        expect(shuffled1, equals(shuffled2));
      });
    });

    group('random', () {
      test('returns element from collection', () {
        final list = [1, 2, 3, 4, 5];
        final random = list.random();
        expect(list.contains(random), isTrue);
      });

      test('returns null for empty collection', () {
        final list = <int>[];
        expect(list.random(), isNull);
      });

      test('returns same element for single element collection', () {
        final list = [42];
        expect(list.random(), equals(42));
      });

      test('uses provided random generator', () {
        final list = [1, 2, 3, 4, 5];
        final random = math.Random(42);
        final result1 = list.random(random);

        final random2 = math.Random(42);
        final result2 = list.random(random2);

        expect(result1, equals(result2));
      });

      test('works with different collection types', () {
        final set = {1, 2, 3};
        final random = set.random();
        expect(set.contains(random), isTrue);
      });
    });

    group('splitWhere', () {
      test('splits at positions where predicate is true', () {
        final list = [1, 2, 0, 3, 4, 0, 5];
        final parts = list.splitWhere((n) => n == 0);
        expect(parts, equals([[1, 2], [3, 4], [5]]));
      });

      test('handles no splits', () {
        final list = [1, 2, 3, 4];
        final parts = list.splitWhere((n) => n == 0);
        expect(parts, equals([[1, 2, 3, 4]]));
      });

      test('handles consecutive separators', () {
        final list = [1, 0, 0, 2, 3];
        final parts = list.splitWhere((n) => n == 0);
        expect(parts, equals([[1], [2, 3]]));
      });

      test('handles separator at start', () {
        final list = [0, 1, 2, 3];
        final parts = list.splitWhere((n) => n == 0);
        expect(parts, equals([[1, 2, 3]]));
      });

      test('handles separator at end', () {
        final list = [1, 2, 3, 0];
        final parts = list.splitWhere((n) => n == 0);
        expect(parts, equals([[1, 2, 3]]));
      });

      test('handles only separators', () {
        final list = [0, 0, 0];
        final parts = list.splitWhere((n) => n == 0);
        expect(parts, isEmpty);
      });

      test('handles empty collection', () {
        final list = <int>[];
        final parts = list.splitWhere((n) => n == 0);
        expect(parts, isEmpty);
      });

      test('works with string splitting', () {
        final chars = ['h', 'e', 'l', 'l', 'o', ' ', 'w', 'o', 'r', 'l', 'd'];
        final words = chars.splitWhere((c) => c == ' ');
        expect(words, equals([['h', 'e', 'l', 'l', 'o'], ['w', 'o', 'r', 'l', 'd']]));
      });
    });

    group('indexedMap', () {
      test('creates map with indices as keys', () {
        final list = ['a', 'b', 'c'];
        final indexed = list.indexedMap();
        expect(indexed, equals({0: 'a', 1: 'b', 2: 'c'}));
      });

      test('handles empty collection', () {
        final list = <String>[];
        expect(list.indexedMap(), isEmpty);
      });

      test('handles single element', () {
        final list = [42];
        expect(list.indexedMap(), equals({0: 42}));
      });

      test('preserves order', () {
        final list = [3, 1, 4, 1, 5];
        final indexed = list.indexedMap();
        final keys = indexed.keys.toList();
        expect(keys, equals([0, 1, 2, 3, 4]));
        expect(indexed.values.toList(), equals([3, 1, 4, 1, 5]));
      });

      test('works with different types', () {
        final list = [true, false, true];
        final indexed = list.indexedMap();
        expect(indexed, equals({0: true, 1: false, 2: true}));
      });
    });

    group('windowed', () {
      test('creates sliding windows of specified size', () {
        final list = [1, 2, 3, 4, 5];
        final windows = list.windowed(3);
        expect(windows, equals([[1, 2, 3], [2, 3, 4], [3, 4, 5]]));
      });

      test('handles window size equal to collection size', () {
        final list = [1, 2, 3];
        final windows = list.windowed(3);
        expect(windows, equals([[1, 2, 3]]));
      });

      test('handles window size larger than collection', () {
        final list = [1, 2];
        final windows = list.windowed(3);
        expect(windows, isEmpty);
      });

      test('uses custom step size', () {
        final list = [1, 2, 3, 4, 5, 6];
        final windows = list.windowed(2, step: 2);
        expect(windows, equals([[1, 2], [3, 4], [5, 6]]));
      });

      test('handles step larger than window size', () {
        final list = [1, 2, 3, 4, 5, 6, 7];
        final windows = list.windowed(2, step: 3);
        expect(windows, equals([[1, 2], [4, 5]]));
      });

      test('throws error for non-positive size', () {
        final list = [1, 2, 3];
        expect(() => list.windowed(0), throwsArgumentError);
        expect(() => list.windowed(-1), throwsArgumentError);
      });

      test('throws error for non-positive step', () {
        final list = [1, 2, 3];
        expect(() => list.windowed(2, step: 0), throwsArgumentError);
        expect(() => list.windowed(2, step: -1), throwsArgumentError);
      });

      test('handles empty collection', () {
        final list = <int>[];
        expect(list.windowed(2), isEmpty);
      });

      test('handles single element collection', () {
        final list = [42];
        expect(list.windowed(2), isEmpty);
        expect(list.windowed(1), equals([[42]]));
      });
    });

    group('zipWithNext', () {
      test('creates pairs of adjacent elements', () {
        final list = [1, 2, 3, 4];
        final pairs = list.zipWithNext();
        expect(pairs, equals([(1, 2), (2, 3), (3, 4)]));
      });

      test('handles empty collection', () {
        final list = <int>[];
        expect(list.zipWithNext(), isEmpty);
      });

      test('handles single element', () {
        final list = [42];
        expect(list.zipWithNext(), isEmpty);
      });

      test('handles two elements', () {
        final list = [1, 2];
        expect(list.zipWithNext(), equals([(1, 2)]));
      });

      test('works with different types', () {
        final chars = ['a', 'b', 'c'];
        final pairs = chars.zipWithNext();
        expect(pairs, equals([('a', 'b'), ('b', 'c')]));
      });
    });

    group('zipWithNextTransform', () {
      test('transforms adjacent pairs', () {
        final list = [1, 2, 3, 4];
        final sums = list.zipWithNextTransform((a, b) => a + b);
        expect(sums, equals([3, 5, 7]));
      });

      test('handles empty collection', () {
        final list = <int>[];
        final result = list.zipWithNextTransform((a, b) => a + b);
        expect(result, isEmpty);
      });

      test('handles single element', () {
        final list = [42];
        final result = list.zipWithNextTransform((a, b) => a + b);
        expect(result, isEmpty);
      });

      test('works with string concatenation', () {
        final words = ['hello', 'world', 'dart'];
        final combined = words.zipWithNextTransform((a, b) => '$a-$b');
        expect(combined, equals(['hello-world', 'world-dart']));
      });

      test('works with complex transformations', () {
        final numbers = [1, 2, 3, 4];
        final products = numbers.zipWithNextTransform((a, b) => a * b);
        expect(products, equals([2, 6, 12]));
      });
    });
  });

  group('NumericCollectionOperations', () {
    group('median', () {
      test('calculates median for odd length', () {
        final numbers = [1, 3, 5, 7, 9];
        expect(numbers.median(), equals(5.0));
      });

      test('calculates median for even length', () {
        final numbers = [1, 2, 3, 4];
        expect(numbers.median(), equals(2.5));
      });

      test('handles single element', () {
        final numbers = [42];
        expect(numbers.median(), equals(42.0));
      });

      test('returns null for empty collection', () {
        final numbers = <int>[];
        expect(numbers.median(), isNull);
      });

      test('sorts unsorted collection', () {
        final numbers = [5, 1, 9, 3, 7];
        expect(numbers.median(), equals(5.0));
      });

      test('works with doubles', () {
        final numbers = [1.5, 2.5, 3.5, 4.5];
        expect(numbers.median(), equals(3.0));
      });

      test('handles negative numbers', () {
        final numbers = [-3, -1, 1, 3];
        expect(numbers.median(), equals(0.0));
      });

      test('handles duplicate values', () {
        final numbers = [1, 2, 2, 3];
        expect(numbers.median(), equals(2.0));
      });
    });

    group('mode', () {
      test('finds most frequent value', () {
        final numbers = [1, 2, 2, 3, 2, 4];
        expect(numbers.mode(), equals(2));
      });

      test('returns first mode when tied', () {
        final numbers = [1, 1, 2, 2, 3];
        final mode = numbers.mode();
        expect([1, 2].contains(mode), isTrue);
      });

      test('handles single element', () {
        final numbers = [42];
        expect(numbers.mode(), equals(42));
      });

      test('returns null for empty collection', () {
        final numbers = <int>[];
        expect(numbers.mode(), isNull);
      });

      test('handles all unique values', () {
        final numbers = [1, 2, 3, 4, 5];
        final mode = numbers.mode();
        expect([1, 2, 3, 4, 5].contains(mode), isTrue);
      });

      test('works with doubles', () {
        final numbers = [1.5, 2.5, 1.5, 3.5];
        expect(numbers.mode(), equals(1.5));
      });

      test('handles negative numbers', () {
        final numbers = [-1, -2, -1, 0];
        expect(numbers.mode(), equals(-1));
      });
    });

    group('standardDeviation', () {
      test('calculates standard deviation', () {
        final numbers = [1, 2, 3, 4, 5];
        final stdDev = numbers.standardDeviation()!;
        expect(stdDev, closeTo(1.4142, 0.001));
      });

      test('returns 0 for identical values', () {
        final numbers = [5, 5, 5, 5];
        expect(numbers.standardDeviation(), equals(0.0));
      });

      test('handles single element', () {
        final numbers = [42];
        expect(numbers.standardDeviation(), equals(0.0));
      });

      test('returns null for empty collection', () {
        final numbers = <int>[];
        expect(numbers.standardDeviation(), isNull);
      });

      test('works with doubles', () {
        final numbers = [1.0, 2.0, 3.0];
        final stdDev = numbers.standardDeviation()!;
        expect(stdDev, closeTo(0.8165, 0.001));
      });

      test('handles negative numbers', () {
        final numbers = [-2, -1, 0, 1, 2];
        final stdDev = numbers.standardDeviation()!;
        expect(stdDev, closeTo(1.4142, 0.001));
      });

      test('handles large numbers', () {
        final numbers = [100, 200, 300];
        final stdDev = numbers.standardDeviation()!;
        expect(stdDev, closeTo(81.65, 0.1));
      });
    });

    group('range', () {
      test('calculates range (max - min)', () {
        final numbers = [1, 5, 3, 9, 2];
        expect(numbers.range(), equals(8));
      });

      test('returns 0 for identical values', () {
        final numbers = [5, 5, 5];
        expect(numbers.range(), equals(0));
      });

      test('handles single element', () {
        final numbers = [42];
        expect(numbers.range(), equals(0));
      });

      test('returns null for empty collection', () {
        final numbers = <int>[];
        expect(numbers.range(), isNull);
      });

      test('works with doubles', () {
        final numbers = [1.5, 2.5, 4.0];
        expect(numbers.range(), equals(2.5));
      });

      test('handles negative numbers', () {
        final numbers = [-5, -1, 3];
        expect(numbers.range(), equals(8));
      });

      test('handles large range', () {
        final numbers = [1, 1000000];
        expect(numbers.range(), equals(999999));
      });

      test('preserves number type', () {
        final integers = [1, 5];
        expect(integers.range().runtimeType, equals(int));

        final doubles = [1.0, 5.0];
        expect(doubles.range().runtimeType, equals(double));
      });
    });
  });
}