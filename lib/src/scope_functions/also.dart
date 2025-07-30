/// Extension that provides Kotlin-style `also` scope function.
extension AlsoExtension<T> on T {
  /// Calls the specified function [block] with `this` value as its argument
  /// and returns `this` value.
  ///
  /// Perfect for performing side effects without changing the object.
  /// Similar to `apply` but the object is passed as a parameter instead
  /// of being the receiver.
  ///
  /// Example:
  /// ```dart
  /// final user = User('John')
  ///   .also((it) => print('Created user: ${it.name}'))
  ///   .also((it) => logger.info('User logged: $it'));
  ///
  /// final list = [1, 2, 3]
  ///   .also((it) => print('List size: ${it.length}'))
  ///   .map((x) => x * 2)
  ///   .toList();
  /// ```
  T also(void Function(T it) block) {
    block(this);
    return this;
  }
}