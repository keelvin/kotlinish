import 'dart:async';
import 'async_core.dart';

/// Kotlin-style async builders for elegant concurrent programming.

/// Launches a task in a new isolate and returns a Future.
///
/// This is a top-level convenience function that wraps [AsyncScope.launch].
///
/// Example:
/// ```dart
/// final result = await launch(() => heavyComputation());
/// final data = await launch(() => fetchDataFromApi());
/// ```
Future<T> launch<T>(FutureOr<T> Function() task, {String? name}) {
  return AsyncScope.launch(task, name: name);
}

/// Executes multiple tasks concurrently and returns when all complete.
///
/// Example:
/// ```dart
/// final results = await async(() => [
///   launch(() => task1()),
///   launch(() => task2()),
///   launch(() => task3()),
/// ]);
/// ```
Future<List<T>> async<T>(List<Future<T>> Function() futureBuilder) async {
  final futures = futureBuilder();
  return Future.wait(futures);
}

/// Runs multiple tasks with controlled concurrency.
///
/// Example:
/// ```dart
/// final results = await concurrent(
///   tasks: urls.map((url) => () => fetchData(url)).toList(),
///   limit: 5,
/// );
/// ```
Future<List<T>> concurrent<T>(
    List<FutureOr<T> Function()> tasks, {
      int limit = 10,
    }) {
  return AsyncScope.launchWithLimit(tasks, concurrency: limit);
}

/// Runs tasks in parallel and returns the first successful result.
///
/// Example:
/// ```dart
/// final fastest = await race([
///   () => fetchFromPrimaryServer(),
///   () => fetchFromBackupServer(),
///   () => fetchFromCache(),
/// ]);
/// ```
Future<T> race<T>(List<FutureOr<T> Function()> tasks) {
  return AsyncScope.race(tasks);
}

/// Creates a delay (like Kotlin's delay).
///
/// Example:
/// ```dart
/// await delay(Duration(seconds: 2));
/// print('Executed after 2 seconds');
/// ```
Future<void> delay(Duration duration) {
  return Future.delayed(duration);
}

/// Executes a task with a timeout.
///
/// Throws [TimeoutException] if the task takes longer than [timeout].
///
/// Example:
/// ```dart
/// try {
///   final result = await withTimeout(
///     () => longRunningTask(),
///     timeout: Duration(seconds: 10),
///   );
/// } on TimeoutException {
///   print('Task timed out!');
/// }
/// ```
Future<T> withTimeout<T>(
    FutureOr<T> Function() task, {
      required Duration timeout,
      String? name,
    }) async {
  return launch(task, name: name).timeout(timeout);
}

/// Retries a task up to [maxRetries] times with exponential backoff.
///
/// Example:
/// ```dart
/// final result = await retry(
///   () => unreliableNetworkCall(),
///   maxRetries: 3,
///   backoff: Duration(milliseconds: 500),
/// );
/// ```
Future<T> retry<T>(
    Future<T> Function() task, {
      int maxRetries = 3,
      Duration backoff = const Duration(milliseconds: 1000),
      bool Function(Object error)? retryIf,
    }) async {
  int attempts = 0;

  while (attempts <= maxRetries) {
    try {
      return await task();
    } catch (error) {
      attempts++;

      if (attempts > maxRetries) rethrow;

      if (retryIf != null && !retryIf(error)) rethrow;

      // Exponential backoff
      final waitTime = Duration(
        milliseconds: backoff.inMilliseconds * (1 << (attempts - 1)),
      );

      await delay(waitTime);
    }
  }

  throw StateError('Retry logic error'); // Should never reach here
}

/// Executes tasks in sequence (one after another).
///
/// Example:
/// ```dart
/// final results = await sequence([
///   () => step1(),
///   () => step2(),
///   () => step3(),
/// ]);
/// ```
Future<List<T>> sequence<T>(List<Future<T> Function()> tasks) async {
  final results = <T>[];

  for (final task in tasks) {
    results.add(await task());
  }

  return results;
}

/// Extension methods for Future to add Kotlin-style operators
extension FutureExtensions<T> on Future<T> {
  /// Transforms the result when the Future completes successfully.
  ///
  /// Example:
  /// ```dart
  /// final upperCase = fetchString().map((s) => s.toUpperCase());
  /// ```
  Future<R> map<R>(R Function(T value) transform) {
    return then(transform);
  }

  /// Flattens nested Futures.
  ///
  /// Example:
  /// ```dart
  /// final result = fetchUserId()
  ///   .flatMap((id) => fetchUserData(id));
  /// ```
  Future<R> flatMap<R>(Future<R> Function(T value) transform) {
    return then(transform);
  }

  /// Provides a fallback value if the Future fails.
  ///
  /// Example:
  /// ```dart
  /// final result = riskyOperation().orElse('default');
  /// ```
  Future<T> orElse(T fallback) {
    return catchError((_) => fallback);
  }

  /// Executes side effect without changing the result.
  ///
  /// Example:
  /// ```dart
  /// final result = fetchData()
  ///   .also((data) => print('Received: $data'));
  /// ```
  Future<T> also(void Function(T value) sideEffect) {
    return then((value) {
      sideEffect(value);
      return value;
    });
  }

  /// Filters the result based on a predicate.
  ///
  /// Throws [StateError] if predicate returns false.
  ///
  /// Example:
  /// ```dart
  /// final validResult = fetchNumber()
  ///   .filter((n) => n > 0);
  /// ```
  Future<T> filter(bool Function(T value) predicate) {
    return then((value) {
      if (predicate(value)) {
        return value;
      } else {
        throw StateError('Filter predicate failed');
      }
    });
  }

  /// Returns the result if predicate is true, otherwise returns null.
  ///
  /// Example:
  /// ```dart
  /// final validResult = fetchNumber()
  ///   .takeIf((n) => n > 0);
  /// ```
  Future<T?> takeIf(bool Function(T value) predicate) {
    return then((value) => predicate(value) ? value : null);
  }
}