/// Extensions that provide safe access to collection elements.
extension SafeAccessorsExtension<T> on Iterable<T> {
  /// Returns the first element, or `null` if the collection is empty.
  ///
  /// Unlike [first], this method doesn't throw an exception when called
  /// on an empty collection.
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3];
  /// final first = numbers.firstOrNull; // 1
  ///
  /// final empty = <int>[];
  /// final firstEmpty = empty.firstOrNull; // null
  ///
  /// final filtered = numbers.where((x) => x > 10).firstOrNull; // null
  /// ```
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }

  /// Returns the last element, or `null` if the collection is empty.
  ///
  /// Unlike [last], this method doesn't throw an exception when called
  /// on an empty collection.
  ///
  /// Example:
  /// ```dart
  /// final numbers = [1, 2, 3];
  /// final last = numbers.lastOrNull; // 3
  ///
  /// final empty = <int>[];
  /// final lastEmpty = empty.lastOrNull; // null
  ///
  /// final filtered = numbers.where((x) => x > 10).lastOrNull; // null
  /// ```
  T? get lastOrNull {
    if (isEmpty) return null;

    T? lastElement;
    for (final element in this) {
      lastElement = element;
    }
    return lastElement;
  }

  /// Returns the single element, or `null` if the collection is empty
  /// or contains more than one element.
  ///
  /// Unlike [single], this method doesn't throw an exception when called
  /// on an empty collection or a collection with multiple elements.
  ///
  /// Example:
  /// ```dart
  /// final single = [42].singleOrNull; // 42
  /// final empty = <int>[].singleOrNull; // null
  /// final multiple = [1, 2, 3].singleOrNull; // null
  ///
  /// final filtered = numbers.where((x) => x == 2).singleOrNull; // 2
  /// ```
  T? get singleOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null; // Empty

    final first = iterator.current;
    if (iterator.moveNext()) return null; // More than one element

    return first;
  }
}