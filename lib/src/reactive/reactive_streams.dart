import 'dart:async';
import 'dart:collection';

/// Kotlin-style reactive extensions for Dart Streams.
extension ReactiveStreamExtensions<T> on Stream<T> {
  /// Transforms each element using [transform].
  ///
  /// Example:
  /// ```dart
  /// final numbers = Stream.fromIterable([1, 2, 3]);
  /// final doubled = numbers.mapKt((x) => x * 2);
  /// ```
  Stream<R> mapKt<R>(R Function(T value) transform) {
    return map(transform);
  }

  /// Filters elements based on [predicate].
  ///
  /// Example:
  /// ```dart
  /// final numbers = Stream.fromIterable([1, 2, 3, 4, 5]);
  /// final evens = numbers.filterKt((x) => x.isEven);
  /// ```
  Stream<T> filterKt(bool Function(T value) predicate) {
    return where(predicate);
  }

  /// Transforms elements and filters out nulls.
  ///
  /// Example:
  /// ```dart
  /// final strings = Stream.fromIterable(['1', 'abc', '2']);
  /// final numbers = strings.mapNotNull((s) => int.tryParse(s));
  /// ```
  Stream<R> mapNotNull<R>(R? Function(T value) transform) {
    return map(transform).where((value) => value != null).cast<R>();
  }

  /// Flattens nested streams.
  ///
  /// Example:
  /// ```dart
  /// final words = Stream.fromIterable(['hello', 'world']);
  /// final chars = words.flatMapStream((word) => Stream.fromIterable(word.split('')));
  /// ```
  Stream<R> flatMapStream<R>(Stream<R> Function(T value) transform) {
    return asyncExpand(transform);
  }

  /// Emits only distinct consecutive elements.
  ///
  /// Example:
  /// ```dart
  /// final stream = Stream.fromIterable([1, 1, 2, 2, 3, 1]);
  /// final distinct = stream.distinctUntilChanged(); // [1, 2, 3, 1]
  /// ```
  Stream<T> distinctUntilChanged([bool Function(T previous, T current)? equals]) {
    T? previous;
    bool isFirst = true;

    return where((current) {
      if (isFirst) {
        isFirst = false;
        previous = current;
        return true;
      }

      final isDifferent = equals != null
          ? !equals(previous as T, current)
          : previous != current;

      if (isDifferent) {
        previous = current;
        return true;
      }

      return false;
    });
  }

  /// Debounces the stream by the given duration.
  ///
  /// Example:
  /// ```dart
  /// final searchInput = controller.stream;
  /// final debounced = searchInput.debounce(Duration(milliseconds: 300));
  /// ```
  Stream<T> debounce(Duration duration) {
    late StreamController<T> controller;
    Timer? timer;
    late StreamSubscription<T> subscription;

    controller = StreamController<T>(
      onListen: () {
        subscription = listen(
              (value) {
            timer?.cancel();
            timer = Timer(duration, () {
              controller.add(value);
            });
          },
          onError: controller.addError,
          onDone: () {
            timer?.cancel();
            controller.close();
          },
        );
      },
      onCancel: () {
        timer?.cancel();
        subscription.cancel();
      },
    );

    return controller.stream;
  }

  /// Throttles the stream by the given duration.
  ///
  /// Example:
  /// ```dart
  /// final clicks = buttonClicks.stream;
  /// final throttled = clicks.throttle(Duration(seconds: 1));
  /// ```
  Stream<T> throttle(Duration duration) {
    late StreamController<T> controller;
    Timer? timer;
    late StreamSubscription<T> subscription;
    bool canEmit = true;

    controller = StreamController<T>(
      onListen: () {
        subscription = listen(
              (value) {
            if (canEmit) {
              controller.add(value);
              canEmit = false;
              timer = Timer(duration, () {
                canEmit = true;
              });
            }
          },
          onError: controller.addError,
          onDone: () {
            timer?.cancel();
            controller.close();
          },
        );
      },
      onCancel: () {
        timer?.cancel();
        subscription.cancel();
      },
    );

    return controller.stream;
  }

  /// Combines the latest values from this stream and [other].
  ///
  /// Example:
  /// ```dart
  /// final stream1 = Stream.periodic(Duration(seconds: 1), (i) => i);
  /// final stream2 = Stream.periodic(Duration(seconds: 2), (i) => 'msg$i');
  /// final combined = stream1.combineLatest(stream2);
  /// ```
  Stream<(T, R)> combineLatest<R>(Stream<R> other) {
    late StreamController<(T, R)> controller;
    late StreamSubscription<T> subscription1;
    late StreamSubscription<R> subscription2;

    T? latestT;
    R? latestR;
    bool hasT = false;
    bool hasR = false;

    void tryEmit() {
      if (hasT && hasR) {
        controller.add((latestT as T, latestR as R));
      }
    }

    controller = StreamController<(T, R)>(
      onListen: () {
        subscription1 = listen(
              (value) {
            latestT = value;
            hasT = true;
            tryEmit();
          },
          onError: controller.addError,
          onDone: () => controller.close(),
        );

        subscription2 = other.listen(
              (value) {
            latestR = value;
            hasR = true;
            tryEmit();
          },
          onError: controller.addError,
          onDone: () => controller.close(),
        );
      },
      onCancel: () {
        subscription1.cancel();
        subscription2.cancel();
      },
    );

    return controller.stream;
  }

  /// Merges this stream with [other].
  ///
  /// Example:
  /// ```dart
  /// final stream1 = Stream.fromIterable([1, 2, 3]);
  /// final stream2 = Stream.fromIterable([4, 5, 6]);
  /// final merged = stream1.mergeWith(stream2);
  /// ```
  Stream<T> mergeWith(Stream<T> other) {
    late StreamController<T> controller;
    late StreamSubscription<T> subscription1;
    late StreamSubscription<T> subscription2;
    int activeSources = 2;

    void checkComplete() {
      activeSources--;
      if (activeSources == 0) {
        controller.close();
      }
    }

    controller = StreamController<T>(
      onListen: () {
        subscription1 = listen(
          controller.add,
          onError: controller.addError,
          onDone: checkComplete,
        );

        subscription2 = other.listen(
          controller.add,
          onError: controller.addError,
          onDone: checkComplete,
        );
      },
      onCancel: () {
        subscription1.cancel();
        subscription2.cancel();
      },
    );

    return controller.stream;
  }

  /// Returns the first element that matches [predicate].
  ///
  /// Example:
  /// ```dart
  /// final numbers = Stream.fromIterable([1, 2, 3, 4, 5]);
  /// final firstEven = await numbers.firstWhere((x) => x.isEven); // 2
  /// ```
  Future<T?> firstWhereOrNull(bool Function(T element) predicate) async {
    await for (final element in this) {
      if (predicate(element)) {
        return element;
      }
    }
    return null;
  }

  /// Collects stream elements into a list.
  ///
  /// Example:
  /// ```dart
  /// final stream = Stream.fromIterable([1, 2, 3]);
  /// final list = await stream.collectList(); // [1, 2, 3]
  /// ```
  Future<List<T>> collectList() {
    return toList();
  }

  /// Collects stream elements into a set.
  ///
  /// Example:
  /// ```dart
  /// final stream = Stream.fromIterable([1, 2, 2, 3]);
  /// final set = await stream.collectSet(); // {1, 2, 3}
  /// ```
  Future<Set<T>> collectSet() async {
    final set = <T>{};
    await forEach(set.add);
    return set;
  }

  /// Performs a side effect for each element without changing the stream.
  ///
  /// Example:
  /// ```dart
  /// final stream = Stream.fromIterable([1, 2, 3]);
  /// final logged = stream.doOnEach((x) => print('Value: $x'));
  /// ```
  Stream<T> doOnEach(void Function(T value) action) {
    return map((value) {
      action(value);
      return value;
    });
  }

  /// Executes an action when the stream completes.
  ///
  /// Example:
  /// ```dart
  /// final stream = Stream.fromIterable([1, 2, 3]);
  /// final withCompletion = stream.doOnComplete(() => print('Done!'));
  /// ```
  Stream<T> doOnComplete(void Function() action) {
    late StreamController<T> controller;
    late StreamSubscription<T> subscription;

    controller = StreamController<T>(
      onListen: () {
        subscription = listen(
          controller.add,
          onError: controller.addError,
          onDone: () {
            action();
            controller.close();
          },
        );
      },
      onCancel: () => subscription.cancel(),
    );

    return controller.stream;
  }

  /// Executes an action when an error occurs.
  ///
  /// Example:
  /// ```dart
  /// final stream = errorProneStream();
  /// final withErrorHandling = stream.doOnError((error) => log.error(error));
  /// ```
  Stream<T> doOnError(void Function(Object error) action) {
    return handleError((Object error, StackTrace stackTrace) {
      action(error);
    });
  }

  /// Creates a hot stream that replays the last [bufferSize] elements to new subscribers.
  ///
  /// Example:
  /// ```dart
  /// final source = Stream.periodic(Duration(seconds: 1), (i) => i);
  /// final replay = source.replay(bufferSize: 3);
  /// ```
  Stream<T> replay({int? bufferSize}) {
    late StreamController<T> controller;
    final buffer = Queue<T>();

    controller = StreamController<T>.broadcast(
      onListen: () {
        // Replay buffered items to new subscribers
        for (final item in buffer) {
          controller.add(item);
        }
      },
    );

    listen(
          (value) {
        if (bufferSize != null) {
          buffer.add(value);
          if (buffer.length > bufferSize) {
            buffer.removeFirst();
          }
        }
        controller.add(value);
      },
      onError: controller.addError,
      onDone: controller.close,
    );

    return controller.stream;
  }

  /// Starts with the given values.
  ///
  /// Example:
  /// ```dart
  /// final stream = Stream.fromIterable([3, 4, 5]);
  /// final withPrefix = stream.startWith([1, 2]); // [1, 2, 3, 4, 5]
  /// ```
  Stream<T> startWith(Iterable<T> values) {
    late StreamController<T> controller;
    late StreamSubscription<T> subscription;

    controller = StreamController<T>(
      onListen: () {
        // Emit starting values first
        for (final value in values) {
          controller.add(value);
        }

        // Then emit from original stream
        subscription = listen(
          controller.add,
          onError: controller.addError,
          onDone: controller.close,
        );
      },
      onCancel: () => subscription.cancel(),
    );

    return controller.stream;
  }

  /// Ends with the given values.
  ///
  /// Example:
  /// ```dart
  /// final stream = Stream.fromIterable([1, 2, 3]);
  /// final withSuffix = stream.endWith([4, 5]); // [1, 2, 3, 4, 5]
  /// ```
  Stream<T> endWith(Iterable<T> values) {
    late StreamController<T> controller;
    late StreamSubscription<T> subscription;

    controller = StreamController<T>(
      onListen: () {
        subscription = listen(
          controller.add,
          onError: controller.addError,
          onDone: () {
            // Emit ending values after original stream completes
            for (final value in values) {
              controller.add(value);
            }
            controller.close();
          },
        );
      },
      onCancel: () => subscription.cancel(),
    );

    return controller.stream;
  }

  /// Delays the emission of items from this stream by a given duration.
  ///
  /// Example:
  /// ```dart
  /// final stream = Stream.fromIterable([1, 2, 3]);
  /// final delayed = stream.delay(Duration(seconds: 1));
  /// ```
  Stream<T> delay(Duration duration) {
    late StreamController<T> controller;
    late StreamSubscription<T> subscription;

    controller = StreamController<T>(
      onListen: () {
        Future.delayed(duration, () {
          subscription = listen(
            controller.add,
            onError: controller.addError,
            onDone: controller.close,
          );
        });
      },
      onCancel: () => subscription.cancel(),
    );

    return controller.stream;
  }
}

/// Utility class for creating reactive streams.
class ReactiveStreams {
  /// Creates a stream that emits values at regular intervals.
  ///
  /// Example:
  /// ```dart
  /// final timer = ReactiveStreams.interval(Duration(seconds: 1));
  /// ```
  static Stream<int> interval(Duration period, {int? count}) {
    return Stream.periodic(period, (i) => i).take(count ?? double.maxFinite.toInt());
  }

  /// Creates a stream from a future.
  ///
  /// Example:
  /// ```dart
  /// final future = fetchData();
  /// final stream = ReactiveStreams.fromFuture(future);
  /// ```
  static Stream<T> fromFuture<T>(Future<T> future) {
    return Stream.fromFuture(future);
  }

  /// Creates a stream that emits a single value after a delay.
  ///
  /// Example:
  /// ```dart
  /// final delayed = ReactiveStreams.timer('Hello', Duration(seconds: 2));
  /// ```
  static Stream<T> timer<T>(T value, Duration delay) {
    return Future.delayed(delay, () => value).asStream();
  }

  /// Merges multiple streams into one.
  ///
  /// Example:
  /// ```dart
  /// final stream1 = Stream.fromIterable([1, 2]);
  /// final stream2 = Stream.fromIterable([3, 4]);
  /// final merged = ReactiveStreams.merge([stream1, stream2]);
  /// ```
  static Stream<T> merge<T>(Iterable<Stream<T>> streams) {
    if (streams.isEmpty) return Stream.empty();

    late StreamController<T> controller;
    final subscriptions = <StreamSubscription<T>>[];
    int activeStreams = streams.length;

    void checkComplete() {
      activeStreams--;
      if (activeStreams == 0) {
        controller.close();
      }
    }

    controller = StreamController<T>(
      onListen: () {
        for (final stream in streams) {
          final subscription = stream.listen(
            controller.add,
            onError: controller.addError,
            onDone: checkComplete,
          );
          subscriptions.add(subscription);
        }
      },
      onCancel: () {
        for (final subscription in subscriptions) {
          subscription.cancel();
        }
      },
    );

    return controller.stream;
  }

  /// Creates a stream that never emits any values.
  ///
  /// Example:
  /// ```dart
  /// final never = ReactiveStreams.never<String>();
  /// ```
  static Stream<T> never<T>() {
    return StreamController<T>().stream;
  }

  /// Creates a stream that immediately emits an error.
  ///
  /// Example:
  /// ```dart
  /// final error = ReactiveStreams.error(Exception('Something went wrong'));
  /// ```
  static Stream<T> error<T>(Object error, [StackTrace? stackTrace]) {
    return Stream.error(error, stackTrace);
  }
}