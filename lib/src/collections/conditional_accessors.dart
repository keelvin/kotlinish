/// Extensions that provide conditional access to values.
extension ConditionalAccessorsExtension<T> on T {
  /// Returns `this` value if it satisfies the given [predicate],
  /// or `null` otherwise.
  ///
  /// This is useful for conditional transformations and null-safe operations.
  ///
  /// Example:
  /// ```dart
  /// final positiveNumber = number.takeIf((it) => it > 0);
  /// final validEmail = email.takeIf((it) => it.contains('@'));
  ///
  /// final user = fetchUser()
  ///     .takeIf((it) => it.isActive)
  ///     ?.let((it) => it.name) ?? 'Unknown';
  /// ```
  T? takeIf(bool Function(T it) predicate) {
    return predicate(this) ? this : null;
  }

  /// Returns `this` value if it does NOT satisfy the given [predicate],
  /// or `null` otherwise.
  ///
  /// This is the inverse of [takeIf] - useful when you want to filter out
  /// values that match a condition.
  ///
  /// Example:
  /// ```dart
  /// final nonEmptyString = text.takeUnless((it) => it.isEmpty);
  /// final validAge = age.takeUnless((it) => it < 0);
  ///
  /// final errorMessage = response
  ///     .takeUnless((it) => it.isSuccess)
  ///     ?.let((it) => it.errorMessage);
  /// ```
  T? takeUnless(bool Function(T it) predicate) {
    return predicate(this) ? null : this;
  }
}

/// Extensions specific to collections for conditional operations.
extension ConditionalCollectionExtension<T> on Iterable<T> {
  /// Returns this collection if it's not empty, or `null` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final items = list.takeIfNotEmpty()?.map((x) => x.toString());
  /// final count = users.takeIfNotEmpty()?.length ?? 0;
  /// ```
  Iterable<T>? takeIfNotEmpty() => takeIf((it) => it.isNotEmpty);

  /// Returns this collection if it's empty, or `null` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final defaultMessage = list.takeIfEmpty()?.let((_) => 'No items found');
  /// ```
  Iterable<T>? takeIfEmpty() => takeIf((it) => it.isEmpty);

  /// Returns this collection if it has exactly [count] elements,
  /// or `null` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final pair = list.takeIfSize(2)?.let((it) => Pair(it.first, it.last));
  /// final single = filtered.takeIfSize(1)?.single;
  /// ```
  Iterable<T>? takeIfSize(int count) => takeIf((it) => it.length == count);

  /// Returns this collection if all elements satisfy the [predicate],
  /// or `null` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final allPositive = numbers.takeIfAll((x) => x > 0);
  /// final allValid = emails.takeIfAll((email) => email.contains('@'));
  /// ```
  Iterable<T>? takeIfAll(bool Function(T element) predicate) =>
      takeIf((it) => it.every(predicate));

  /// Returns this collection if any element satisfies the [predicate],
  /// or `null` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final hasAdmin = users.takeIfAny((user) => user.isAdmin);
  /// final hasError = responses.takeIfAny((r) => r.hasError);
  /// ```
  Iterable<T>? takeIfAny(bool Function(T element) predicate) =>
      takeIf((it) => it.any(predicate));
}