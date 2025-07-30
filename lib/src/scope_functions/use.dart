/// Provides Kotlin-style `use` scope function.
///
/// Calls the specified function [block] with the given [receiver] value
/// and returns its result.
///
/// Unlike other scope functions, `use` is a top-level function that takes
/// the receiver as a parameter, making it useful when you want to operate
/// on an object without extending it.
///
/// Example:
/// ```dart
/// final result = use(stringBuffer, (it) {
///   it.write('Hello');
///   it.write(' World');
///   return it.toString();
/// });
///
/// final isValid = use(user, (it) =>
///   it.name.isNotEmpty && it.age > 0);
/// ```
R use<T, R>(T receiver, R Function(T it) block) => block(receiver);

/// Extension version of `use` for fluent chaining.
extension UseExtension<T> on T {
  /// Calls the specified function [block] with `this` value as its argument
  /// and returns its result.
  ///
  /// This is equivalent to the top-level `use` function but allows for
  /// method chaining.
  ///
  /// Example:
  /// ```dart
  /// final result = stringBuffer.use((it) {
  ///   it.write('Hello');
  ///   return it.length;
  /// });
  /// ```
  R use<R>(R Function(T it) block) => block(this);
}