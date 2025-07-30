/// Extensions that provide grouping and partitioning utilities for collections.
extension GroupingUtilitiesExtension<T> on Iterable<T> {
  /// Groups elements by the result of applying the given [keySelector] function
  /// to each element.
  ///
  /// Returns a map where keys are the results of [keySelector] and values are
  /// lists of elements that produced that key.
  ///
  /// Example:
  /// ```dart
  /// final words = ['apple', 'banana', 'cherry', 'apricot'];
  /// final grouped = words.groupBy((word) => word[0]); // Group by first letter
  /// // Result: {'a': ['apple', 'apricot'], 'b': ['banana'], 'c': ['cherry']}
  ///
  /// final numbers = [1, 2, 3, 4, 5, 6];
  /// final evenOdd = numbers.groupBy((n) => n.isEven ? 'even' : 'odd');
  /// // Result: {'odd': [1, 3, 5], 'even': [2, 4, 6]}
  /// ```
  Map<K, List<T>> groupBy<K>(K Function(T element) keySelector) {
    final map = <K, List<T>>{};
    for (final element in this) {
      final key = keySelector(element);
      map.putIfAbsent(key, () => <T>[]).add(element);
    }
    return map;
  }

  /// Partitions elements into two lists based on the given [predicate].
  ///
  /// Returns a record with two lists: the first contains elements for which
  /// [predicate] returns true, the second contains elements for which it returns false.
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 5, 6];
  /// final (evens, odds) = numbers.partition((n) => n.isEven);
  /// // evens: [2, 4, 6], odds: [1, 3, 5]
  ///
  /// final users = [user1, user2, user3];
  /// final (active, inactive) = users.partition((user) => user.isActive);
  /// ```
  (List<T>, List<T>) partition(bool Function(T element) predicate) {
    final trueList = <T>[];
    final falseList = <T>[];

    for (final element in this) {
      if (predicate(element)) {
        trueList.add(element);
      } else {
        falseList.add(element);
      }
    }

    return (trueList, falseList);
  }

  /// Creates a map from elements where keys are produced by [keySelector]
  /// and values are produced by [valueSelector].
  ///
  /// If multiple elements produce the same key, the last one wins.
  ///
  /// Example:
  /// ```dart
  /// final users = [User('john', 25), User('jane', 30)];
  /// final nameToAge = users.associateBy(
  ///   (user) => user.name,
  ///   (user) => user.age,
  /// );
  /// // Result: {'john': 25, 'jane': 30}
  /// ```
  Map<K, V> associateBy<K, V>(
      K Function(T element) keySelector,
      V Function(T element) valueSelector,
      ) {
    final map = <K, V>{};
    for (final element in this) {
      final key = keySelector(element);
      final value = valueSelector(element);
      map[key] = value;
    }
    return map;
  }

  /// Creates a map where keys are elements and values are produced by [valueSelector].
  ///
  /// Example:
  /// ```dart
  /// final names = ['john', 'jane', 'bob'];
  /// final nameToLength = names.associateWith((name) => name.length);
  /// // Result: {'john': 4, 'jane': 4, 'bob': 3}
  /// ```
  Map<T, V> associateWith<V>(V Function(T element) valueSelector) {
    final map = <T, V>{};
    for (final element in this) {
      map[element] = valueSelector(element);
    }
    return map;
  }

  /// Returns a list containing only distinct elements based on the result
  /// of applying [selector] to each element.
  ///
  /// The first occurrence of each distinct value is preserved.
  ///
  /// Example:
  /// ```dart
  /// final users = [
  ///   User('john', 25, 'dev'),
  ///   User('jane', 30, 'design'),
  ///   User('bob', 25, 'dev'),
  /// ];
  /// final distinctByAge = users.distinctBy((user) => user.age);
  /// // Result: [User('john', 25, 'dev'), User('jane', 30, 'design')]
  ///
  /// final words = ['apple', 'banana', 'apricot', 'cherry'];
  /// final distinctByFirstLetter = words.distinctBy((word) => word[0]);
  /// // Result: ['apple', 'banana', 'cherry']
  /// ```
  List<T> distinctBy<K>(K Function(T element) selector) {
    final seen = <K>{};
    final result = <T>[];

    for (final element in this) {
      final key = selector(element);
      if (seen.add(key)) {
        result.add(element);
      }
    }

    return result;
  }

  /// Splits the collection into chunks of the specified [size].
  ///
  /// The last chunk may have fewer elements if the collection size
  /// is not evenly divisible by [size].
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  /// final chunks = numbers.chunked(3);
  /// // Result: [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
  ///
  /// final items = [1, 2, 3, 4, 5];
  /// final pairs = items.chunked(2);
  /// // Result: [[1, 2], [3, 4], [5]]
  /// ```
  List<List<T>> chunked(int size) {
    if (size <= 0) throw ArgumentError('Size must be positive');

    final result = <List<T>>[];
    final iterator = this.iterator;

    while (iterator.moveNext()) {
      final chunk = <T>[iterator.current];

      for (int i = 1; i < size && iterator.moveNext(); i++) {
        chunk.add(iterator.current);
      }

      result.add(chunk);
    }

    return result;
  }

  /// Splits the collection into chunks using a [transform] function
  /// that is applied to each chunk.
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3, 4, 5, 6];
  /// final sums = numbers.chunked(2).map((chunk) =>
  ///   chunk.fold(0, (sum, n) => sum + n)
  /// ).toList();
  /// // Result: [3, 7, 11] (1+2, 3+4, 5+6)
  /// ```
  List<R> chunkedTransform<R>(int size, R Function(List<T> chunk) transform) {
    return chunked(size).map(transform).toList();
  }
}