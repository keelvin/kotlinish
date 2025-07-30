/// Extension that provides Kotlin-style `run` scope function.
extension RunExtension<T> on T {
  /// Calls the specified function [block] with `this` value as its receiver
  /// and returns its result.
  ///
  /// Similar to `let` but the object is available as `this` context instead
  /// of being passed as a parameter.
  ///
  /// Example:
  /// ```dart
  /// final result = "Hello World".run((self) => self.length);
  ///
  /// final isValid = user.run((self) =>
  ///   self.name.isNotEmpty && self.age > 0);
  ///
  /// final config = AppConfig().run((self) {
  ///   self.enableDebug();
  ///   self.setTimeout(30);
  ///   return self.isValid;
  /// });
  /// ```
  R run<R>(R Function(T self) block) => block(this);
}