/// Extensions that provide fluent transformation pipelines for collections.
extension TransformationPipelinesExtension<T> on Iterable<T> {
  /// Returns a new iterable with elements that satisfy the given [predicate],
  /// but as a List for better performance in chaining.
  ///
  /// This is similar to [where] but returns a List instead of an Iterable.
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 5, 6];
  /// final evens = numbers.filter((n) => n.isEven); // [2, 4, 6]
  /// ```
  List<T> filter(bool Function(T element) predicate) {
    return where(predicate).toList();
  }

  /// Transforms each element using [transform] and returns a List.
  ///
  /// This is similar to [map] but returns a List instead of an Iterable.
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3];
  /// final squared = numbers.mapToList((n) => n * n); // [1, 4, 9]
  /// ```
  List<R> mapToList<R>(R Function(T element) transform) {
    return map(transform).toList();
  }

  /// Transforms each element to an iterable and flattens the result.
  ///
  /// Example:
  /// ```dart
  /// final words = ['hello', 'world'];
  /// final chars = words.flatMap((word) => word.split('')); // ['h','e','l','l','o','w','o','r','l','d']
  ///
  /// final numbers = [1, 2, 3];
  /// final ranges = numbers.flatMap((n) => List.generate(n, (i) => i)); // [0, 0, 1, 0, 1, 2]
  /// ```
  List<R> flatMap<R>(Iterable<R> Function(T element) transform) {
    return expand(transform).toList();
  }

  /// Returns elements that are not null after applying [transform].
  ///
  /// Useful for filtering and transforming in one step.
  ///
  /// Example:
  /// ```dart
  /// final strings = ['1', 'abc', '2', 'def', '3'];
  /// final numbers = strings.mapNotNull((s) => int.tryParse(s)); // [1, 2, 3]
  ///
  /// final users = [user1, user2, user3];
  /// final emails = users.mapNotNull((user) => user.email); // Non-null emails only
  /// ```
  List<R> mapNotNull<R>(R? Function(T element) transform) {
    final result = <R>[];
    for (final element in this) {
      final transformed = transform(element);
      if (transformed != null) {
        result.add(transformed);
      }
    }
    return result;
  }

  /// Returns the first [count] elements.
  ///
  /// If [count] is greater than the length, returns all elements.
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 5];
  /// final first3 = numbers.take(3); // [1, 2, 3]
  /// final all = numbers.take(10); // [1, 2, 3, 4, 5]
  /// ```
  List<T> takeList(int count) {
    return take(count).toList();
  }

  /// Returns elements while [predicate] is true.
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 3, 2, 1];
  /// final ascending = numbers.takeWhileList((n) => n <= 3); // [1, 2, 3]
  /// ```
  List<T> takeWhileList(bool Function(T element) predicate) {
    return takeWhile(predicate).toList();
  }

  /// Skips the first [count] elements and returns the rest.
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 5];
  /// final last3 = numbers.drop(2); // [3, 4, 5]
  /// ```
  List<T> drop(int count) {
    return skip(count).toList();
  }

  /// Skips elements while [predicate] is true and returns the rest.
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 3, 2, 1];
  /// final afterPeak = numbers.dropWhile((n) => n <= 3); // [4, 3, 2, 1]
  /// ```
  List<T> dropWhile(bool Function(T element) predicate) {
    return skipWhile(predicate).toList();
  }

  /// Returns a list of pairs where each element is paired with its index.
  ///
  /// Example:
  /// ```dart
  /// final letters = ['a', 'b', 'c'];
  /// final indexed = letters.withIndex(); // [(0, 'a'), (1, 'b'), (2, 'c')]
  /// ```
  List<(int, T)> withIndex() {
    final result = <(int, T)>[];
    int index = 0;
    for (final element in this) {
      result.add((index, element));
      index++;
    }
    return result;
  }

  /// Returns a list with elements in reverse order.
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 5];
  /// final reversed = numbers.reversed(); // [5, 4, 3, 2, 1]
  /// ```
  List<T> reversedList() {
    return toList().reversed.toList();
  }

  /// Returns a sorted list using the natural ordering of elements.
  ///
  /// Elements must implement [Comparable].
  ///
  /// Example:
  /// ```dart
  /// final numbers = [3, 1, 4, 1, 5];
  /// final sorted = numbers.sorted(); // [1, 1, 3, 4, 5]
  /// ```
  List<T> sorted() {
    final list = toList();
    list.sort();
    return list;
  }

  /// Returns a sorted list using a custom [comparator].
  ///
  /// Example:
  /// ```dart
  /// final words = ['apple', 'pie', 'banana'];
  /// final byLength = words.sortedBy((a, b) => a.length.compareTo(b.length));
  /// // Result: ['pie', 'apple', 'banana']
  /// ```
  List<T> sortedBy(int Function(T a, T b) comparator) {
    final list = toList();
    list.sort(comparator);
    return list;
  }

  /// Returns a sorted list using a key selector.
  ///
  /// Example:
  /// ```dart
  /// final users = [user1, user2, user3];
  /// final byAge = users.sortedWith((user) => user.age);
  /// final byName = users.sortedWith((user) => user.name);
  /// ```
  List<T> sortedWith<K extends Comparable<K>>(K Function(T element) keySelector) {
    final list = toList();
    list.sort((a, b) => keySelector(a).compareTo(keySelector(b)));
    return list;
  }

  /// Applies [action] to each element and returns the original iterable.
  ///
  /// Useful for side effects in the middle of a pipeline.
  ///
  /// Example:
  /// ```dart
  /// final result = numbers
  ///     .filter((n) => n > 0)
  ///     .onEach((n) => print('Processing: $n'))
  ///     .mapToList((n) => n * 2);
  /// ```
  Iterable<T> onEach(void Function(T element) action) {
    return map((element) {
      action(element);
      return element;
    });
  }

  /// Returns the sum of all elements.
  ///
  /// Elements must be numbers (int, double, or num).
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 5];
  /// final total = numbers.sum(); // 15
  /// ```
  T sum() {
    if (isEmpty) {
      final zero = (0.0 is T) ? 0.0 : 0;
      return zero as T;
    }
    return reduce((a, b) => ((a as num) + (b as num)) as T);
  }

  /// Returns the average of all elements.
  ///
  /// Elements must be numbers. Returns null for empty collections.
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 5];
  /// final avg = numbers.average(); // 3.0
  /// ```
  double? average() {
    if (isEmpty) return null;
    final total = fold(0.0, (sum, element) => sum + (element as num));
    return total / length;
  }

  /// Returns the minimum element, or null if empty.
  ///
  /// Elements must implement [Comparable].
  ///
  /// Example:
  /// ```dart
  /// final numbers = [3, 1, 4, 1, 5];
  /// final min = numbers.minOrNull(); // 1
  /// ```
  T? minOrNull() {
    if (isEmpty) return null;
    return reduce((a, b) => (a as Comparable).compareTo(b as Comparable) <= 0 ? a : b);
  }

  /// Returns the maximum element, or null if empty.
  ///
  /// Example:
  /// ```dart
  /// final numbers = [3, 1, 4, 1, 5];
  /// final max = numbers.maxOrNull(); // 5
  /// ```
  T? maxOrNull() {
    if (isEmpty) return null;
    return reduce((a, b) => (a as Comparable).compareTo(b as Comparable) >= 0 ? a : b);
  }
}