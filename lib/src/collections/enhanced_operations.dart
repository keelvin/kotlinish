import 'dart:math' hide Random;
import 'dart:math' as math show Random;

import 'package:kotlinish/kotlinish.dart';
typedef Random = math.Random;

/// Advanced collection operations inspired by Kotlin collections.
extension EnhancedCollectionOperations<T> on Iterable<T> {
  /// Returns the element at the given [index] or null if the index is out of bounds.
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3];
  /// final second = numbers.getOrNull(1); // 2
  /// final outOfBounds = numbers.getOrNull(10); // null
  /// ```
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
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3];
  /// final value = numbers.getOrElse(10, () => -1); // -1
  /// ```
  T getOrElse(int index, T Function() defaultValue) {
    return getOrNull(index) ?? defaultValue();
  }

  /// Returns a list containing elements at specified [indices].
  ///
  /// Example:
  /// ```dart
  /// final letters = ['a', 'b', 'c', 'd', 'e'];
  /// final selected = letters.slice([0, 2, 4]); // ['a', 'c', 'e']
  /// ```
  List<T> slice(List<int> indices) {
    final list = toList();
    return indices
        .where((index) => index >= 0 && index < list.length)
        .map((index) => list[index])
        .toList();
  }

  /// Returns a list containing elements from [start] to [end] (exclusive).
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 5];
  /// final middle = numbers.subList(1, 4); // [2, 3, 4]
  /// ```
  List<T> subList(int start, [int? end]) {
    final list = toList();
    final endIndex = end ?? list.length;
    if (start < 0 || start > list.length) return [];
    if (endIndex <= start) return [];

    return list.sublist(start, endIndex.clamp(0, list.length));
  }

  /// Returns a map grouping elements by the results of applying [keySelector] and [valueSelector].
  ///
  /// Example:
  /// ```dart
  /// final users = [User('john', 25), User('jane', 30)];
  /// final ageToNames = users.groupByTransform(
  ///   (user) => user.age > 25 ? 'senior' : 'junior',
  ///   (user) => user.name,
  /// );
  /// ```
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
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 5];
  /// final firstEven = numbers.findFirst((n) => n.isEven); // 2
  /// final firstBig = numbers.findFirst((n) => n > 10); // null
  /// ```
  T? findFirst(bool Function(T element) predicate) {
    for (final element in this) {
      if (predicate(element)) return element;
    }
    return null;
  }

  /// Finds the last element matching [predicate] or null if none found.
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 5];
  /// final lastOdd = numbers.findLast((n) => n.isOdd); // 5
  /// ```
  T? findLast(bool Function(T element) predicate) {
    T? result;
    for (final element in this) {
      if (predicate(element)) result = element;
    }
    return result;
  }

  /// Returns true if all elements are distinct.
  ///
  /// Example:
  /// ```dart
  /// final unique = [1, 2, 3].isDistinct(); // true
  /// final duplicate = [1, 2, 2].isDistinct(); // false
  /// ```
  bool isDistinct() {
    final seen = <T>{};
    for (final element in this) {
      if (!seen.add(element)) return false;
    }
    return true;
  }

  /// Returns a new list with elements shuffled randomly.
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 5];
  /// final shuffled = numbers.shuffled(); // Random order
  /// ```
  List<T> shuffled([Random? random]) {
    final list = toList();
    list.shuffle(random);
    return list;
  }

  /// Returns a random element from the collection.
  ///
  /// Example:
  /// ```dart
  /// final colors = ['red', 'green', 'blue'];
  /// final randomColor = colors.random(); // Random color
  /// ```
  T? random([Random? random]) {
    if (isEmpty) return null;
    final list = toList();
    final rng = random ?? Random();
    return list[rng.nextInt(list.length)];
  }

  /// Splits the collection at positions where [predicate] returns true.
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 0, 3, 4, 0, 5];
  /// final parts = numbers.splitWhere((n) => n == 0);
  /// // Result: [[1, 2], [3, 4], [5]]
  /// ```
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
  ///
  /// Example:
  /// ```dart
  /// final letters = ['a', 'b', 'c'];
  /// final indexed = letters.indexedMap(); // {0: 'a', 1: 'b', 2: 'c'}
  /// ```
  Map<int, T> indexedMap() {
    final map = <int, T>{};
    int index = 0;
    for (final element in this) {
      map[index++] = element;
    }
    return map;
  }

  /// Returns a sliding window of elements of the specified [size].
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 5];
  /// final windows = numbers.windowed(3);
  /// // Result: [[1, 2, 3], [2, 3, 4], [3, 4, 5]]
  /// ```
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
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4];
  /// final pairs = numbers.zipWithNext(); // [(1, 2), (2, 3), (3, 4)]
  /// ```
  List<(T, T)> zipWithNext() {
    final list = toList();
    final result = <(T, T)>[];

    for (int i = 0; i < list.length - 1; i++) {
      result.add((list[i], list[i + 1]));
    }

    return result;
  }

  /// Combines elements with the next element using [transform].
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4];
  /// final sums = numbers.zipWithNextTransform((a, b) => a + b); // [3, 5, 7]
  /// ```
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
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 5];
  /// final median = numbers.median(); // 3.0
  /// ```
  double? median() {
    if (isEmpty) return null;

    final sorted = toList()..sort();
    final middle = sorted.length ~/ 2;

    if (sorted.length.isOdd) {
      return sorted[middle].toDouble();
    } else {
      return (sorted[middle - 1] + sorted[middle]) / 2;
    }
  }

  /// Returns the mode (most frequent value).
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 2, 3, 2];
  /// final mode = numbers.mode(); // 2
  /// ```
  T? mode() {
    if (isEmpty) return null;

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
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 5];
  /// final stdDev = numbers.standardDeviation(); // ~1.58
  /// ```
  double? standardDeviation() {
    if (isEmpty) return null;

    final mean = average()!;
    final variance = map((x) => pow(x - mean, 2)).average()!;
    return sqrt(variance);
  }

  /// Returns the range (max - min).
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 5, 3, 9, 2];
  /// final range = numbers.range(); // 8 (9 - 1)
  /// ```
  num? range() {
    if (isEmpty) return null;
    final min = minOrNull();
    final max = maxOrNull();
    if (min == null || max == null) return null;
    return max - min;
  }
}
