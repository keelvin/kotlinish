/// Extension that provides Kotlin-style `apply` scope function.
extension ApplyExtension<T> on T {
  /// Calls the specified function [block] with `this` value as its receiver
  /// and returns `this` value.
  ///
  /// Useful for configuring an object in a fluent way.
  ///
  /// Example:
  /// ```dart
  /// final list = <String>[]
  ///   .apply((it) {
  ///     it.add('item1');
  ///     it.add('item2');
  ///   });
  ///
  /// final person = Person()
  ///   .apply((it) {
  ///     it.name = 'John';
  ///     it.age = 30;
  ///   });
  /// ```
  T apply(void Function(T it) block) {
    block(this);
    return this;
  }
}