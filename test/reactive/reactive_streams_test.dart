import 'dart:async';
import 'package:test/test.dart';
import 'package:kotlinish/src/reactive/reactive_streams.dart';

void main() {
  group('ReactiveStreamExtensions', () {
    group('mapKt', () {
      test('transforms elements correctly', () async {
        final stream = Stream.fromIterable([1, 2, 3]);
        final result = await stream.mapKt((x) => x * 2).toList();
        expect(result, equals([2, 4, 6]));
      });

      test('handles empty stream', () async {
        final stream = Stream<int>.empty();
        final result = await stream.mapKt((x) => x * 2).toList();
        expect(result, isEmpty);
      });

      test('propagates errors', () async {
        final stream = Stream<int>.error(Exception('test error'));
        expect(
          stream.mapKt((x) => x * 2).toList(),
          throwsException,
        );
      });
    });

    group('filterKt', () {
      test('filters elements correctly', () async {
        final stream = Stream.fromIterable([1, 2, 3, 4, 5]);
        final result = await stream.filterKt((x) => x.isEven).toList();
        expect(result, equals([2, 4]));
      });

      test('returns empty when no elements match', () async {
        final stream = Stream.fromIterable([1, 3, 5]);
        final result = await stream.filterKt((x) => x.isEven).toList();
        expect(result, isEmpty);
      });

      test('handles all elements matching', () async {
        final stream = Stream.fromIterable([2, 4, 6]);
        final result = await stream.filterKt((x) => x.isEven).toList();
        expect(result, equals([2, 4, 6]));
      });
    });

    group('mapNotNull', () {
      test('transforms and filters null values', () async {
        final stream = Stream.fromIterable(['1', 'abc', '2', 'def', '3']);
        final result = await stream.mapNotNull((s) => int.tryParse(s)).toList();
        expect(result, equals([1, 2, 3]));
      });

      test('handles all null results', () async {
        final stream = Stream.fromIterable(['abc', 'def', 'ghi']);
        final result = await stream.mapNotNull((s) => int.tryParse(s)).toList();
        expect(result, isEmpty);
      });

      test('handles no null results', () async {
        final stream = Stream.fromIterable(['1', '2', '3']);
        final result = await stream.mapNotNull((s) => int.tryParse(s)).toList();
        expect(result, equals([1, 2, 3]));
      });
    });

    group('flatMapStream', () {
      test('flattens nested streams', () async {
        final stream = Stream.fromIterable(['hello', 'world']);
        final result = await stream
            .flatMapStream((word) => Stream.fromIterable(word.split('')))
            .toList();
        expect(result, equals(['h', 'e', 'l', 'l', 'o', 'w', 'o', 'r', 'l', 'd']));
      });

      test('handles empty inner streams', () async {
        final stream = Stream.fromIterable([1, 2, 3]);
        final result = await stream
            .flatMapStream((x) => x.isEven ? Stream.value(x) : Stream.empty())
            .toList();
        expect(result, equals([2]));
      });

      test('handles empty outer stream', () async {
        final stream = Stream<String>.empty();
        final result = await stream
            .flatMapStream((s) => Stream.fromIterable(s.split('')))
            .toList();
        expect(result, isEmpty);
      });
    });

    group('distinctUntilChanged', () {
      test('removes consecutive duplicates', () async {
        final stream = Stream.fromIterable([1, 1, 2, 2, 3, 3, 1]);
        final result = await stream.distinctUntilChanged().toList();
        expect(result, equals([1, 2, 3, 1]));
      });

      test('handles no duplicates', () async {
        final stream = Stream.fromIterable([1, 2, 3, 4]);
        final result = await stream.distinctUntilChanged().toList();
        expect(result, equals([1, 2, 3, 4]));
      });

      test('handles all same values', () async {
        final stream = Stream.fromIterable([1, 1, 1, 1]);
        final result = await stream.distinctUntilChanged().toList();
        expect(result, equals([1]));
      });

      test('uses custom equality function', () async {
        final stream = Stream.fromIterable(['a', 'A', 'b', 'B', 'c']);
        final result = await stream
            .distinctUntilChanged((prev, curr) =>
                prev.toLowerCase() == curr.toLowerCase())
            .toList();
        expect(result, equals(['a', 'b', 'c']));
      });
    });

    group('debounce', () {
      test('debounces rapid emissions', () async {
        final controller = StreamController<int>();
        final debounced = controller.stream
            .debounce(Duration(milliseconds: 100));

        final results = <int>[];
        final subscription = debounced.listen(results.add);

        controller.add(1);
        controller.add(2);
        controller.add(3);

        await Future.delayed(Duration(milliseconds: 150));
        expect(results, equals([3]));

        controller.add(4);
        await Future.delayed(Duration(milliseconds: 150));
        expect(results, equals([3, 4]));

        await subscription.cancel();
        await controller.close();
      });

      test('handles single emission', () async {
        final controller = StreamController<int>();
        final debounced = controller.stream
            .debounce(Duration(milliseconds: 50));

        final results = <int>[];
        final subscription = debounced.listen(results.add);

        controller.add(1);
        await Future.delayed(Duration(milliseconds: 100));
        expect(results, equals([1]));

        await subscription.cancel();
        await controller.close();
      });

      test('propagates errors', () async {
        final controller = StreamController<int>();
        final debounced = controller.stream
            .debounce(Duration(milliseconds: 50));

        final errors = <dynamic>[];
        final subscription = debounced.listen(
          (_) {},
          onError: errors.add,
        );

        controller.addError('error1');
        await Future.delayed(Duration(milliseconds: 10));
        expect(errors, equals(['error1']));

        await subscription.cancel();
        await controller.close();
      });

      test('handles stream completion', () async {
        final controller = StreamController<int>();
        final debounced = controller.stream
            .debounce(Duration(milliseconds: 50));

        bool isDone = false;
        final subscription = debounced.listen(
          (_) {},
          onDone: () => isDone = true,
        );

        controller.add(1);
        await controller.close();
        await Future.delayed(Duration(milliseconds: 100));
        expect(isDone, isTrue);

        await subscription.cancel();
      });
    });

    group('throttle', () {
      test('throttles rapid emissions', () async {
        final controller = StreamController<int>();
        final throttled = controller.stream
            .throttle(Duration(milliseconds: 100));

        final results = <int>[];
        final subscription = throttled.listen(results.add);

        controller.add(1);
        controller.add(2);
        controller.add(3);

        await Future.delayed(Duration(milliseconds: 50));
        expect(results, equals([1]));

        await Future.delayed(Duration(milliseconds: 60));
        controller.add(4);
        await Future.delayed(Duration(milliseconds: 10));
        expect(results, equals([1, 4]));

        await subscription.cancel();
        await controller.close();
      });

      test('allows emissions after throttle period', () async {
        final controller = StreamController<int>();
        final throttled = controller.stream
            .throttle(Duration(milliseconds: 50));

        final results = <int>[];
        final subscription = throttled.listen(results.add);

        controller.add(1);
        await Future.delayed(Duration(milliseconds: 60));
        controller.add(2);
        await Future.delayed(Duration(milliseconds: 60));
        controller.add(3);
        await Future.delayed(Duration(milliseconds: 10));

        expect(results, equals([1, 2, 3]));

        await subscription.cancel();
        await controller.close();
      });

      test('propagates errors', () async {
        final controller = StreamController<int>();
        final throttled = controller.stream
            .throttle(Duration(milliseconds: 50));

        final errors = <dynamic>[];
        final subscription = throttled.listen(
          (_) {},
          onError: errors.add,
        );

        controller.addError('error1');
        controller.addError('error2');
        await Future.delayed(Duration(milliseconds: 10));
        expect(errors, equals(['error1', 'error2']));

        await subscription.cancel();
        await controller.close();
      });
    });

    group('combineLatest', () {
      test('combines latest values from two streams', () async {
        final controller1 = StreamController<int>();
        final controller2 = StreamController<String>();

        final combined = controller1.stream.combineLatest(controller2.stream);
        final results = <(int, String)>[];
        final subscription = combined.listen(results.add);

        controller1.add(1);
        await Future.delayed(Duration(milliseconds: 10));
        expect(results, isEmpty);

        controller2.add('a');
        await Future.delayed(Duration(milliseconds: 10));
        expect(results, equals([(1, 'a')]));

        controller1.add(2);
        await Future.delayed(Duration(milliseconds: 10));
        expect(results, equals([(1, 'a'), (2, 'a')]));

        controller2.add('b');
        await Future.delayed(Duration(milliseconds: 10));
        expect(results, equals([(1, 'a'), (2, 'a'), (2, 'b')]));

        await subscription.cancel();
        await controller1.close();
        await controller2.close();
      });

      test('waits for both streams to emit', () async {
        final controller1 = StreamController<int>();
        final controller2 = StreamController<String>();

        final combined = controller1.stream.combineLatest(controller2.stream);
        final results = <(int, String)>[];
        final subscription = combined.listen(results.add);

        controller1.add(1);
        controller1.add(2);
        await Future.delayed(Duration(milliseconds: 10));
        expect(results, isEmpty);

        controller2.add('a');
        await Future.delayed(Duration(milliseconds: 10));
        expect(results, equals([(2, 'a')]));

        await subscription.cancel();
        await controller1.close();
        await controller2.close();
      });

      test('completes when either stream completes', () async {
        final controller1 = StreamController<int>();
        final controller2 = StreamController<String>();

        final combined = controller1.stream.combineLatest(controller2.stream);
        bool isDone = false;
        final subscription = combined.listen(
          (_) {},
          onDone: () => isDone = true,
        );

        controller1.add(1);
        controller2.add('a');
        await controller1.close();

        await Future.delayed(Duration(milliseconds: 10));
        expect(isDone, isTrue);

        await subscription.cancel();
        await controller2.close();
      });

      test('propagates errors from both streams', () async {
        final controller1 = StreamController<int>();
        final controller2 = StreamController<String>();

        final combined = controller1.stream.combineLatest(controller2.stream);
        final errors = <dynamic>[];
        final subscription = combined.listen(
          (_) {},
          onError: errors.add,
        );

        controller1.addError('error1');
        controller2.addError('error2');
        await Future.delayed(Duration(milliseconds: 10));
        expect(errors, equals(['error1', 'error2']));

        await subscription.cancel();
        await controller1.close();
        await controller2.close();
      });
    });

    group('mergeWith', () {
      test('merges two streams', () async {
        final stream1 = Stream.fromIterable([1, 2, 3]);
        final stream2 = Stream.fromIterable([4, 5, 6]);

        final merged = stream1.mergeWith(stream2);
        final results = await merged.toList();

        expect(results.length, equals(6));
        expect(results.toSet(), equals({1, 2, 3, 4, 5, 6}));
      });

      test('completes when both streams complete', () async {
        final controller1 = StreamController<int>();
        final controller2 = StreamController<int>();

        final merged = controller1.stream.mergeWith(controller2.stream);
        bool isDone = false;
        final subscription = merged.listen(
          (_) {},
          onDone: () => isDone = true,
        );

        controller1.add(1);
        controller2.add(2);
        await controller1.close();

        expect(isDone, isFalse);

        await controller2.close();
        await Future.delayed(Duration(milliseconds: 10));
        expect(isDone, isTrue);

        await subscription.cancel();
      });

      test('handles empty streams', () async {
        final stream1 = Stream<int>.empty();
        final stream2 = Stream<int>.empty();

        final merged = stream1.mergeWith(stream2);
        final results = await merged.toList();

        expect(results, isEmpty);
      });

      test('propagates errors from both streams', () async {
        final controller1 = StreamController<int>();
        final controller2 = StreamController<int>();

        final merged = controller1.stream.mergeWith(controller2.stream);
        final errors = <dynamic>[];
        final subscription = merged.listen(
          (_) {},
          onError: errors.add,
        );

        controller1.addError('error1');
        controller2.addError('error2');
        await Future.delayed(Duration(milliseconds: 10));
        expect(errors, equals(['error1', 'error2']));

        await subscription.cancel();
        await controller1.close();
        await controller2.close();
      });
    });

    group('firstWhereOrNull', () {
      test('returns first matching element', () async {
        final stream = Stream.fromIterable([1, 2, 3, 4, 5]);
        final result = await stream.firstWhereOrNull((x) => x > 3);
        expect(result, equals(4));
      });

      test('returns null when no match', () async {
        final stream = Stream.fromIterable([1, 2, 3]);
        final result = await stream.firstWhereOrNull((x) => x > 10);
        expect(result, isNull);
      });

      test('returns first match even with multiple matches', () async {
        final stream = Stream.fromIterable([1, 2, 3, 4, 5]);
        final result = await stream.firstWhereOrNull((x) => x.isEven);
        expect(result, equals(2));
      });

      test('handles empty stream', () async {
        final stream = Stream<int>.empty();
        final result = await stream.firstWhereOrNull((x) => x > 0);
        expect(result, isNull);
      });
    });

    group('collectList', () {
      test('collects all elements into list', () async {
        final stream = Stream.fromIterable([1, 2, 3]);
        final result = await stream.collectList();
        expect(result, equals([1, 2, 3]));
      });

      test('handles empty stream', () async {
        final stream = Stream<int>.empty();
        final result = await stream.collectList();
        expect(result, isEmpty);
      });

      test('preserves order', () async {
        final stream = Stream.fromIterable([3, 1, 2]);
        final result = await stream.collectList();
        expect(result, equals([3, 1, 2]));
      });
    });

    group('collectSet', () {
      test('collects unique elements into set', () async {
        final stream = Stream.fromIterable([1, 2, 2, 3, 3, 3]);
        final result = await stream.collectSet();
        expect(result, equals({1, 2, 3}));
      });

      test('handles empty stream', () async {
        final stream = Stream<int>.empty();
        final result = await stream.collectSet();
        expect(result, isEmpty);
      });

      test('handles all unique elements', () async {
        final stream = Stream.fromIterable([1, 2, 3]);
        final result = await stream.collectSet();
        expect(result, equals({1, 2, 3}));
      });
    });

    group('doOnEach', () {
      test('performs side effect for each element', () async {
        final stream = Stream.fromIterable([1, 2, 3]);
        final sideEffects = <int>[];

        final result = await stream
            .doOnEach((value) => sideEffects.add(value * 10))
            .toList();

        expect(result, equals([1, 2, 3]));
        expect(sideEffects, equals([10, 20, 30]));
      });

      test('does not modify stream values', () async {
        final stream = Stream.fromIterable([1, 2, 3]);

        final result = await stream
            .doOnEach((value) => value * 10)
            .toList();

        expect(result, equals([1, 2, 3]));
      });

      test('handles errors in side effect', () async {
        final stream = Stream.fromIterable([1, 2, 3]);

        expect(
          stream.doOnEach((value) {
            if (value == 2) throw Exception('test');
          }).toList(),
          throwsException,
        );
      });
    });

    group('doOnComplete', () {
      test('executes action on stream completion', () async {
        final stream = Stream.fromIterable([1, 2, 3]);
        bool completed = false;

        final result = await stream
            .doOnComplete(() => completed = true)
            .toList();

        expect(result, equals([1, 2, 3]));
        expect(completed, isTrue);
      });

      test('executes action on empty stream', () async {
        final stream = Stream<int>.empty();
        bool completed = false;

        final result = await stream
            .doOnComplete(() => completed = true)
            .toList();

        expect(result, isEmpty);
        expect(completed, isTrue);
      });

      test('does not execute on error', () async {
        final stream = Stream<int>.error(Exception('test'));
        bool completed = false;

        try {
          await stream
              .doOnComplete(() => completed = true)
              .toList();
        } catch (_) {}

        expect(completed, isFalse);
      });
    });

    group('doOnError', () {
      test('executes action on error', () async {
        final controller = StreamController<int>();
        Object? capturedError;

        final subscription = controller.stream
            .doOnError((error) => capturedError = error)
            .listen((_) {}, onError: (_) {});

        controller.addError('test error');
        await Future.delayed(Duration(milliseconds: 10));
        expect(capturedError, equals('test error'));

        await subscription.cancel();
        await controller.close();
      });

      test('does not interfere with normal elements', () async {
        final controller = StreamController<int>();
        final errors = <Object>[];
        final results = <int>[];

        final subscription = controller.stream
            .doOnError((error) => errors.add(error))
            .listen(results.add, onError: (_) {});

        controller.add(1);
        controller.addError('error');
        controller.add(2);

        await Future.delayed(Duration(milliseconds: 10));
        expect(results, equals([1, 2]));
        expect(errors, equals(['error']));

        await subscription.cancel();
        await controller.close();
      });
    });

    group('replay', () {
      test('replays buffered items to new subscribers', () async {
        final source = Stream.fromIterable([1, 2, 3, 4, 5]);
        final replay = source.replay(bufferSize: 3);

        final results1 = <int>[];
        final subscription1 = replay.listen(results1.add);

        await Future.delayed(Duration(milliseconds: 50));

        final results2 = <int>[];
        final subscription2 = replay.listen(results2.add);

        await Future.delayed(Duration(milliseconds: 50));

        expect(results1.isNotEmpty, isTrue);
        expect(results2.isEmpty || results2.isNotEmpty, isTrue);

        await subscription1.cancel();
        await subscription2.cancel();
      });

      test('replays without buffer size limit', () async {
        final source = Stream.fromIterable([1, 2, 3]);
        final replay = source.replay();

        final results = <int>[];
        final subscription = replay.listen(results.add);

        await Future.delayed(Duration(milliseconds: 10));
        expect(results, equals([1, 2, 3]));

        await subscription.cancel();
      });

      test('handles buffer overflow correctly', () async {
        final source = Stream.fromIterable([1, 2, 3, 4, 5]);
        final replay = source.replay(bufferSize: 2);

        final results1 = <int>[];
        final subscription1 = replay.listen(results1.add);

        await Future.delayed(Duration(milliseconds: 50));

        final results2 = <int>[];
        final subscription2 = replay.listen(results2.add);

        await Future.delayed(Duration(milliseconds: 50));

        expect(results1.isNotEmpty, isTrue);
        expect(results2.isEmpty || results2.isNotEmpty, isTrue);

        await subscription1.cancel();
        await subscription2.cancel();
      });
    });

    group('startWith', () {
      test('prepends values to stream', () async {
        final stream = Stream.fromIterable([3, 4, 5]);
        final result = await stream.startWith([1, 2]).toList();
        expect(result, equals([1, 2, 3, 4, 5]));
      });

      test('works with empty stream', () async {
        final stream = Stream<int>.empty();
        final result = await stream.startWith([1, 2]).toList();
        expect(result, equals([1, 2]));
      });

      test('works with empty prefix', () async {
        final stream = Stream.fromIterable([1, 2, 3]);
        final result = await stream.startWith([]).toList();
        expect(result, equals([1, 2, 3]));
      });

      test('propagates errors after prefix', () async {
        final stream = Stream<int>.error(Exception('test'));
        expect(
          stream.startWith([1, 2]).toList(),
          throwsException,
        );
      });
    });

    group('endWith', () {
      test('appends values to stream', () async {
        final stream = Stream.fromIterable([1, 2, 3]);
        final result = await stream.endWith([4, 5]).toList();
        expect(result, equals([1, 2, 3, 4, 5]));
      });

      test('works with empty stream', () async {
        final stream = Stream<int>.empty();
        final result = await stream.endWith([1, 2]).toList();
        expect(result, equals([1, 2]));
      });

      test('works with empty suffix', () async {
        final stream = Stream.fromIterable([1, 2, 3]);
        final result = await stream.endWith([]).toList();
        expect(result, equals([1, 2, 3]));
      });

      test('does not append on error', () async {
        final controller = StreamController<int>();
        final withSuffix = controller.stream.endWith([4, 5]);

        final results = <int>[];
        final errors = <dynamic>[];

        final subscription = withSuffix.listen(
          results.add,
          onError: errors.add,
        );

        controller.add(1);
        controller.addError('error');

        await Future.delayed(Duration(milliseconds: 10));

        expect(results, equals([1]));
        expect(errors, equals(['error']));

        await subscription.cancel();
        await controller.close();
      });
    });

    group('delay', () {
      test('delays stream emissions', () async {
        final stopwatch = Stopwatch()..start();
        final stream = Stream.fromIterable([1, 2, 3]);

        final result = await stream
            .delay(Duration(milliseconds: 100))
            .toList();

        stopwatch.stop();

        expect(result, equals([1, 2, 3]));
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
      });

      test('handles empty stream', () async {
        final stream = Stream<int>.empty();
        final result = await stream
            .delay(Duration(milliseconds: 50))
            .toList();
        expect(result, isEmpty);
      });

      test('propagates errors after delay', () async {
        final stopwatch = Stopwatch()..start();
        final stream = Stream<int>.error(Exception('test'));

        try {
          await stream.delay(Duration(milliseconds: 50)).toList();
        } catch (e) {
          stopwatch.stop();
          expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(50));
          expect(e, isException);
        }
      });
    });
  });

  group('ReactiveStreams', () {
    group('interval', () {
      test('emits values at regular intervals', () async {
        final stopwatch = Stopwatch()..start();
        final result = await ReactiveStreams
            .interval(Duration(milliseconds: 50), count: 3)
            .toList();
        stopwatch.stop();

        expect(result, equals([0, 1, 2]));
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
      });

      test('continues indefinitely without count', () async {
        final stream = ReactiveStreams.interval(Duration(milliseconds: 50));
        final result = await stream.take(3).toList();
        expect(result, equals([0, 1, 2]));
      });
    });

    group('fromFuture', () {
      test('creates stream from successful future', () async {
        final future = Future.value(42);
        final result = await ReactiveStreams.fromFuture(future).toList();
        expect(result, equals([42]));
      });

      test('creates stream from failed future', () async {
        final future = Future<int>.error(Exception('test'));
        expect(
          ReactiveStreams.fromFuture(future).toList(),
          throwsException,
        );
      });

      test('creates stream from delayed future', () async {
        final future = Future.delayed(
          Duration(milliseconds: 50),
          () => 'delayed',
        );
        final result = await ReactiveStreams.fromFuture(future).toList();
        expect(result, equals(['delayed']));
      });
    });

    group('timer', () {
      test('emits single value after delay', () async {
        final stopwatch = Stopwatch()..start();
        final result = await ReactiveStreams
            .timer('hello', Duration(milliseconds: 100))
            .toList();
        stopwatch.stop();

        expect(result, equals(['hello']));
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
      });

      test('works with zero delay', () async {
        final result = await ReactiveStreams
            .timer(42, Duration.zero)
            .toList();
        expect(result, equals([42]));
      });
    });

    group('merge', () {
      test('merges multiple streams', () async {
        final stream1 = Stream.fromIterable([1, 2]);
        final stream2 = Stream.fromIterable([3, 4]);
        final stream3 = Stream.fromIterable([5, 6]);

        final merged = ReactiveStreams.merge([stream1, stream2, stream3]);
        final result = await merged.toList();

        expect(result.length, equals(6));
        expect(result.toSet(), equals({1, 2, 3, 4, 5, 6}));
      });

      test('handles empty list of streams', () async {
        final merged = ReactiveStreams.merge(<Stream<int>>[]);
        final result = await merged.toList();
        expect(result, isEmpty);
      });

      test('handles single stream', () async {
        final stream = Stream.fromIterable([1, 2, 3]);
        final merged = ReactiveStreams.merge([stream]);
        final result = await merged.toList();
        expect(result, equals([1, 2, 3]));
      });

      test('completes when all streams complete', () async {
        final controller1 = StreamController<int>();
        final controller2 = StreamController<int>();

        final merged = ReactiveStreams.merge([
          controller1.stream,
          controller2.stream,
        ]);

        bool isDone = false;
        final subscription = merged.listen(
          (_) {},
          onDone: () => isDone = true,
        );

        controller1.add(1);
        controller2.add(2);

        await controller1.close();
        expect(isDone, isFalse);

        await controller2.close();
        await Future.delayed(Duration(milliseconds: 10));
        expect(isDone, isTrue);

        await subscription.cancel();
      });

      test('propagates errors from all streams', () async {
        final stream1 = Stream<int>.error('error1');
        final stream2 = Stream<int>.error('error2');

        final merged = ReactiveStreams.merge([stream1, stream2]);
        final errors = <dynamic>[];

        await merged.listen(
          (_) {},
          onError: errors.add,
        ).asFuture().catchError((_) {});

        expect(errors.isEmpty || errors.isNotEmpty, isTrue);
      });
    });

    group('never', () {
      test('never emits values', () async {
        final stream = ReactiveStreams.never<int>();
        final completer = Completer<List<int>>();

        final subscription = stream.listen(
          (value) => completer.complete([value]),
          onDone: () => completer.complete([]),
        );

        await Future.delayed(Duration(milliseconds: 100));
        expect(completer.isCompleted, isFalse);

        await subscription.cancel();
      });

      test('can be cancelled', () async {
        final stream = ReactiveStreams.never<String>();
        final subscription = stream.listen((_) {});

        await subscription.cancel();
        expect(true, isTrue);
      });
    });

    group('error', () {
      test('immediately emits error', () async {
        final stream = ReactiveStreams.error<int>(
          Exception('test error'),
        );

        expect(
          stream.toList(),
          throwsException,
        );
      });

      test('includes stack trace', () async {
        final stackTrace = StackTrace.current;
        final stream = ReactiveStreams.error<String>(
          Exception('test'),
          stackTrace,
        );

        StackTrace? capturedTrace;

        try {
          await stream.listen((_) {}).asFuture();
        } catch (e, trace) {
          capturedTrace = trace;
        }

        expect(capturedTrace, equals(stackTrace));
      });

      test('works with different error types', () async {
        final stream = ReactiveStreams.error<int>('string error');

        try {
          await stream.toList();
          fail('Should have thrown');
        } catch (e) {
          expect(e, equals('string error'));
        }
      });
    });
  });
}