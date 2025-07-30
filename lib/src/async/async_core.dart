import 'dart:async';
import 'dart:collection';
import 'dart:isolate';

/// A lightweight wrapper around Dart isolates that provides
/// Kotlin Coroutines-inspired API for concurrent programming.
class AsyncScope {
  static final Map<String, Isolate> _isolates = {};
  static final Map<String, SendPort> _sendPorts = {};
  static int _counter = 0;

  /// Launches a new isolate to execute the given [task] concurrently.
  ///
  /// Returns a [Future] that completes with the result of the task.
  /// The isolate is automatically cleaned up after completion.
  ///
  /// The [task] can be either synchronous or asynchronous.
  ///
  /// Example:
  /// ```dart
  /// final result = await launch(() => heavyComputation(data));
  /// final asyncResult = await launch(() async => await fetchData());
  /// print('Result: $result');
  ///
  /// // Parallel execution
  /// final future1 = launch(() => fetchUserData());
  /// final future2 = launch(() => fetchSettings());
  /// final results = await Future.wait([future1, future2]);
  /// ```
  static Future<T> launch<T>(FutureOr<T> Function() task, {String? name}) async {
    final isolateName = name ?? 'isolate_${_counter++}';
    final completer = Completer<T>();

    try {
      // Create receive port for communication
      final receivePort = ReceivePort();

      // Launch isolate
      final isolate = await Isolate.spawn(
        _isolateEntryPoint<T>,
        _IsolateMessage<T>(task, receivePort.sendPort),
        debugName: isolateName,
      );

      _isolates[isolateName] = isolate;

      // Listen for result
      receivePort.listen((data) {
        if (data is _IsolateResult<T>) {
          if (data.isError) {
            completer.completeError(data.error!, data.stackTrace);
          } else {
            completer.complete(data.result);
          }
        }

        // Cleanup
        receivePort.close();
        isolate.kill();
        _isolates.remove(isolateName);
      });

    } catch (error, stackTrace) {
      completer.completeError(error, stackTrace);
    }

    return completer.future;
  }

  /// Launches multiple tasks concurrently and waits for all to complete.
  ///
  /// Returns a list of results in the same order as the input tasks.
  ///
  /// Example:
  /// ```dart
  /// final results = await launchAll([
  ///   () => computeFactorial(10),
  ///   () => computeFibonacci(20),
  ///   () => computePrimes(100),
  /// ]);
  /// ```
  static Future<List<T>> launchAll<T>(List<FutureOr<T> Function()> tasks) async {
    final futures = tasks.map((task) => launch(task)).toList();
    return Future.wait(futures);
  }

  /// Executes tasks with a maximum concurrency limit.
  ///
  /// Useful for controlling resource usage when processing many tasks.
  ///
  /// Example:
  /// ```dart
  /// final urls = ['url1', 'url2', 'url3', ...]; // 100 URLs
  /// final results = await launchWithLimit(
  ///   urls.map((url) => () => fetchData(url)).toList(),
  ///   concurrency: 5, // Max 5 concurrent requests
  /// );
  /// ```
  static Future<List<T>> launchWithLimit<T>(
      List<FutureOr<T> Function()> tasks, {
        required int concurrency,
      }) async {
    if (concurrency <= 0) throw ArgumentError('Concurrency must be positive');

    final results = <T?>[]..length = tasks.length;
    final semaphore = Semaphore(concurrency);

    final futures = <Future<void>>[];

    for (int i = 0; i < tasks.length; i++) {
      final future = semaphore.acquire().then((_) async {
        try {
          results[i] = await launch(tasks[i]);
        } finally {
          semaphore.release();
        }
      });
      futures.add(future);
    }

    await Future.wait(futures);
    return results.cast<T>();
  }

  /// Runs multiple tasks concurrently and returns the result of the first
  /// one to complete successfully.
  ///
  /// Example:
  /// ```dart
  /// final fastestResult = await race([
  ///   () => fetchFromServer1(),
  ///   () => fetchFromServer2(),
  ///   () => fetchFromCache(),
  /// ]);
  /// ```
  static Future<T> race<T>(List<FutureOr<T> Function()> tasks) async {
    if (tasks.isEmpty) throw ArgumentError('Tasks cannot be empty');

    final completer = Completer<T>();
    final futures = tasks.map((task) => launch(task)).toList();
    int errorCount = 0;
    Object? lastError;

    for (final future in futures) {
      future.then((result) {
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      }).catchError((error) {
        errorCount++;
        lastError = error;

        // Only complete with error if all tasks fail
        if (!completer.isCompleted && errorCount == futures.length) {
          completer.completeError(lastError!);
        }
      });
    }

    return completer.future;
  }

  /// Kills all active isolates and cleans up resources.
  ///
  /// Useful for cleanup when shutting down the application.
  static void killAll() {
    for (final isolate in _isolates.values) {
      isolate.kill();
    }
    _isolates.clear();
    _sendPorts.clear();
  }

  /// Returns the number of currently active isolates.
  static int get activeIsolateCount => _isolates.length;

  /// Returns the names of all active isolates.
  static List<String> get activeIsolateNames => _isolates.keys.toList();
}

/// Entry point for isolate execution
void _isolateEntryPoint<T>(_IsolateMessage<T> message) async {
  try {
    final result = message.task();
    // If the result is a Future, await it
    final finalResult = result is Future ? await result : result;
    message.sendPort.send(_IsolateResult<T>.success(finalResult as T));
  } catch (error, stackTrace) {
    message.sendPort.send(_IsolateResult<T>.error(error, stackTrace));
  }
}

/// Message passed to isolate
class _IsolateMessage<T> {
  final FutureOr<T> Function() task;
  final SendPort sendPort;

  _IsolateMessage(this.task, this.sendPort);
}

/// Result returned from isolate
class _IsolateResult<T> {
  final T? result;
  final Object? error;
  final StackTrace? stackTrace;
  final bool isError;

  _IsolateResult.success(this.result)
      : error = null, stackTrace = null, isError = false;

  _IsolateResult.error(this.error, this.stackTrace)
      : result = null, isError = true;
}

/// A semaphore implementation for controlling concurrency
class Semaphore {
  final int maxCount;
  int _currentCount;
  final Queue<Completer<void>> _waitQueue = Queue();

  Semaphore(this.maxCount) : _currentCount = maxCount;

  Future<void> acquire() async {
    if (_currentCount > 0) {
      _currentCount--;
      return;
    }

    final completer = Completer<void>();
    _waitQueue.add(completer);
    return completer.future;
  }

  void release() {
    if (_waitQueue.isNotEmpty) {
      final completer = _waitQueue.removeFirst();
      completer.complete();
    } else {
      _currentCount++;
    }
  }
}