/// Extension that provides Kotlin-style `let` scope function.
extension LetExtension<T> on T {
  /// Calls the specified function [block] with `this` value as its argument
  /// and returns its result.
  ///
  /// Useful for executing a code block on an object and returning a transformed result.
  ///
  /// Example:
  /// ```dart
  /// final result = "Hello".let((it) => it.toUpperCase());
  /// print(result); // "HELLO"
  ///
  /// final length = user.name?.let((name) => name.length) ?? 0;
  /// ```
  R let<R>(R Function(T it) block) => block(this);
}