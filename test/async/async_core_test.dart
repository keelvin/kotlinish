import 'dart:math';
import 'package:test/test.dart';
import 'package:kotlinish/src/async/async_core.dart';

// Heavy computation functions for testing
int fibonacci(int n) {
  if (n <= 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
}

int factorial(int n) {
  if (n <= 1) return 1;
  return n * factorial(n - 1);
}

List<int> generatePrimes(int limit) {
  if (limit < 2) return [];

  final sieve = List.filled(limit + 1, true);
  sieve[0] = sieve[1] = false;

  for (int i = 2; i * i <= limit; i++) {
    if (sieve[i]) {
      for (int j = i * i; j <= limit; j += i) {
        sieve[j] = false;
      }
    }
  }

  return [for (int i = 2; i <= limit; i++) if (sieve[i]) i];
}

String processString(String input) {
  // Simulate some processing
  return input.toUpperCase().split('').reversed.join();
}

void main() {
  group('AsyncScope', () {
    tearDown(() {
      // Clean up after each test
      AsyncScope.killAll();
    });

    group('launch', () {
      test('should execute task in isolate and return result', () async {
        final result = await AsyncScope.launch(() => fibonacci(10));
        expect(result, equals(55));
      });

      test('should handle multiple concurrent tasks', () async {
        final start = DateTime.now();

        final futures = [
          AsyncScope.launch(() => fibonacci(20)),
          AsyncScope.launch(() => factorial(10)),
          AsyncScope.launch(() => generatePrimes(100).length),
        ];

        final results = await Future.wait(futures);
        final duration = DateTime.now().difference(start);

        expect(results[0], equals(6765)); // fibonacci(20)
        expect(results[1], equals(3628800)); // factorial(10)
        expect(results[2], equals(25)); // primes up to 100

        // Should be faster than sequential execution
        print('Concurrent execution took: ${duration.inMilliseconds}ms');
      });

      test('should handle task errors properly', () async {
        expect(
              () => AsyncScope.launch(() => throw Exception('Test error')),
          throwsA(isA<Exception>()),
        );
      });

      test('should clean up isolates after completion', () async {
        expect(AsyncScope.activeIsolateCount, equals(0));

        final result = await AsyncScope.launch(() => 42);
        expect(result, equals(42));

        // Give time for cleanup
        await Future.delayed(Duration(milliseconds: 100));
        expect(AsyncScope.activeIsolateCount, equals(0));
      });

      test('should support named isolates', () async {
        final future = AsyncScope.launch(() async {
          // Simulate longer task with actual delay
          await Future.delayed(Duration(milliseconds: 100));
          return 'done';
        }, name: 'test-isolate');

        // Check that named isolate appears in active list
        await Future.delayed(Duration(milliseconds: 10));
        expect(AsyncScope.activeIsolateNames, contains('test-isolate'));

        final result = await future;
        expect(result, equals('done'));
      });
    });

    group('launchAll', () {
      test('should execute all tasks concurrently', () async {
        final tasks = [
              () => fibonacci(15),
              () => factorial(8),
              () => processString('hello'),
        ];

        final results = await AsyncScope.launchAll(tasks);

        expect(results[0], equals(610)); // fibonacci(15)
        expect(results[1], equals(40320)); // factorial(8)
        expect(results[2], equals('OLLEH')); // reversed uppercase
      });

      test('should handle empty task list', () async {
        final results = await AsyncScope.launchAll<int>([]);
        expect(results, isEmpty);
      });

      test('should propagate errors from any task', () async {
        final tasks = [
              () => 42,
              () => throw Exception('Task failed'),
              () => 24,
        ];

        expect(
              () => AsyncScope.launchAll(tasks),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('launchWithLimit', () {
      test('should limit concurrent execution', () async {
        final tasks = List.generate(10, (i) => () => i * 2);

        final results = await AsyncScope.launchWithLimit(
          tasks,
          concurrency: 3,
        );

        expect(results.length, equals(10));
        expect(results, equals([0, 2, 4, 6, 8, 10, 12, 14, 16, 18]));
      });

      test('should handle concurrency limit of 1', () async {
        // Test that concurrency limit works by measuring timing
        final startTime = DateTime.now();

        final tasks = List.generate(3, (i) => () async {
          // Each task takes ~50ms
          await Future.delayed(Duration(milliseconds: 50));
          return i;
        });

        final results = await AsyncScope.launchWithLimit(tasks, concurrency: 1);

        final duration = DateTime.now().difference(startTime);

        // With concurrency 1, tasks should run sequentially (~150ms total)
        expect(results, equals([0, 1, 2]));
        expect(duration.inMilliseconds, greaterThan(120)); // Should take at least 120ms

        print('Sequential execution took: ${duration.inMilliseconds}ms');
      });

      test('should throw on invalid concurrency', () async {
        expect(
              () => AsyncScope.launchWithLimit([() => 42], concurrency: 0),
          throwsArgumentError,
        );

        expect(
              () => AsyncScope.launchWithLimit([() => 42], concurrency: -1),
          throwsArgumentError,
        );
      });
    });

    group('race', () {
      test('should return first successful result', () async {
        final tasks = [
              () {
            // Slow task
            for (int i = 0; i < 10000000; i++) {}
            return 'slow';
          },
              () => 'fast', // Fast task
              () {
            // Another slow task
            for (int i = 0; i < 5000000; i++) {}
            return 'medium';
          },
        ];

        final result = await AsyncScope.race(tasks);
        expect(result, equals('fast'));
      });

      test('should handle empty task list', () async {
        expect(
              () => AsyncScope.race<int>([]),
          throwsArgumentError,
        );
      });

      test('should handle all tasks failing', () async {
        final tasks = [
              () => throw Exception('Task 1 failed'),
              () => throw Exception('Task 2 failed'),
              () => throw Exception('Task 3 failed'),
        ];

        expect(
              () => AsyncScope.race(tasks),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('resource management', () {
      test('should track active isolate count', () async {
        expect(AsyncScope.activeIsolateCount, equals(0));

        // Start some long-running tasks
        final futures = List.generate(3, (i) =>
            AsyncScope.launch(() async {
              await Future.delayed(Duration(milliseconds: 50));
              return i;
            })
        );

        // Check active count during execution
        await Future.delayed(Duration(milliseconds: 10));
        expect(AsyncScope.activeIsolateCount, greaterThan(0));

        // Wait for completion
        await Future.wait(futures);

        // Give time for cleanup
        await Future.delayed(Duration(milliseconds: 100));
        expect(AsyncScope.activeIsolateCount, equals(0));
      });

      test('should kill all isolates on demand', () async {
        // Start some tasks
        final futures = List.generate(5, (i) =>
            AsyncScope.launch(() {
              // Very long task that we'll interrupt
              for (int j = 0; j < 100000000; j++) {}
              return i;
            })
        );

        await Future.delayed(Duration(milliseconds: 10));
        expect(AsyncScope.activeIsolateCount, greaterThan(0));

        // Kill all
        AsyncScope.killAll();
        expect(AsyncScope.activeIsolateCount, equals(0));

        // Futures should complete with errors or be killed
        for (final future in futures) {
          try {
            await future;
          } catch (e) {
            // Expected - isolates were killed
          }
        }
      });
    });
  });

  group('Semaphore', () {
    test('should limit concurrent access', () async {
      final semaphore = Semaphore(2);
      int concurrentCount = 0;
      int maxConcurrent = 0;

      final tasks = List.generate(5, (i) => () async {
        await semaphore.acquire();
        try {
          concurrentCount++;
          maxConcurrent = max(maxConcurrent, concurrentCount);
          await Future.delayed(Duration(milliseconds: 50));
          concurrentCount--;
        } finally {
          semaphore.release();
        }
        return i;
      });

      final futures = tasks.map((task) => task()).toList();
      await Future.wait(futures);

      expect(maxConcurrent, lessThanOrEqualTo(2));
    });

    test('should queue requests when limit is reached', () async {
      final semaphore = Semaphore(1);
      final executionOrder = <int>[];

      final tasks = List.generate(3, (i) => () async {
        await semaphore.acquire();
        try {
          executionOrder.add(i);
          await Future.delayed(Duration(milliseconds: 10));
        } finally {
          semaphore.release();
        }
      });

      final futures = tasks.map((task) => task()).toList();
      await Future.wait(futures);

      // Should execute in order due to semaphore limit of 1
      expect(executionOrder, equals([0, 1, 2]));
    });
  });
}