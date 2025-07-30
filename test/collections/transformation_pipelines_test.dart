import 'package:test/test.dart';
import 'package:kotlinish/src/collections/transformation_pipelines.dart';

class TestUser {
  final String name;
  final int age;
  final String? email;

  TestUser(this.name, this.age, [this.email]);

  @override
  String toString() => 'User($name, $age, $email)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TestUser && name == other.name && age == other.age && email == other.email;

  @override
  int get hashCode => Object.hash(name, age, email);
}

void main() {
  group('Transformation Pipelines Extension', () {
    group('filter', () {
      test('should filter elements and return List', () {
        final numbers = [1, 2, 3, 4, 5, 6];
        final evens = numbers.filter((n) => n.isEven);

        expect(evens, isA<List<int>>());
        expect(evens, equals([2, 4, 6]));
      });

      test('should work with empty results', () {
        final numbers = [1, 3, 5];
        final evens = numbers.filter((n) => n.isEven);
        expect(evens, isEmpty);
      });
    });

    group('mapToList', () {
      test('should transform elements and return List', () {
        final numbers = [1, 2, 3];
        final squared = numbers.mapToList((n) => n * n);

        expect(squared, isA<List<int>>());
        expect(squared, equals([1, 4, 9]));
      });

      test('should work with type transformations', () {
        final numbers = [1, 2, 3];
        final strings = numbers.mapToList((n) => n.toString());

        expect(strings, isA<List<String>>());
        expect(strings, equals(['1', '2', '3']));
      });
    });

    group('flatMap', () {
      test('should flatten transformed iterables', () {
        final words = ['hello', 'world'];
        final chars = words.flatMap((word) => word.split(''));

        expect(chars, equals(['h', 'e', 'l', 'l', 'o', 'w', 'o', 'r', 'l', 'd']));
      });

      test('should work with number ranges', () {
        final numbers = [1, 2, 3];
        final ranges = numbers.flatMap((n) => List.generate(n, (i) => i));

        expect(ranges, equals([0, 0, 1, 0, 1, 2]));
      });

      test('should handle empty results', () {
        final numbers = [1, 2, 3];
        final empty = numbers.flatMap((n) => <int>[]);
        expect(empty, isEmpty);
      });
    });

    group('mapNotNull', () {
      test('should filter and transform in one step', () {
        final strings = ['1', 'abc', '2', 'def', '3'];
        final numbers = strings.mapNotNull((s) => int.tryParse(s));

        expect(numbers, equals([1, 2, 3]));
      });

      test('should work with custom objects', () {
        final users = [
          TestUser('john', 25, 'john@example.com'),
          TestUser('jane', 30), // no email
          TestUser('bob', 28, 'bob@example.com'),
        ];

        final emails = users.mapNotNull((user) => user.email);
        expect(emails, equals(['john@example.com', 'bob@example.com']));
      });

      test('should handle all null results', () {
        final strings = ['abc', 'def', 'ghi'];
        final numbers = strings.mapNotNull((s) => int.tryParse(s));
        expect(numbers, isEmpty);
      });
    });

    group('takeList', () {
      test('should take first n elements', () {
        final numbers = [1, 2, 3, 4, 5];
        final first3 = numbers.takeList(3);

        expect(first3, equals([1, 2, 3]));
        expect(first3, isA<List<int>>());
      });

      test('should handle count larger than length', () {
        final numbers = [1, 2, 3];
        final all = numbers.takeList(10);
        expect(all, equals([1, 2, 3]));
      });

      test('should handle zero count', () {
        final numbers = [1, 2, 3];
        final none = numbers.takeList(0);
        expect(none, isEmpty);
      });
    });

    group('takeWhileList', () {
      test('should take while predicate is true', () {
        final numbers = [1, 2, 3, 4, 3, 2, 1];
        final ascending = numbers.takeWhileList((n) => n <= 3);

        expect(ascending, equals([1, 2, 3]));
      });

      test('should stop at first false', () {
        final numbers = [2, 4, 6, 7, 8, 10];
        final evens = numbers.takeWhileList((n) => n.isEven);
        expect(evens, equals([2, 4, 6]));
      });
    });

    group('drop', () {
      test('should skip first n elements', () {
        final numbers = [1, 2, 3, 4, 5];
        final last3 = numbers.drop(2);

        expect(last3, equals([3, 4, 5]));
      });

      test('should handle count larger than length', () {
        final numbers = [1, 2, 3];
        final none = numbers.drop(10);
        expect(none, isEmpty);
      });
    });

    group('dropWhile', () {
      test('should skip while predicate is true', () {
        final numbers = [1, 2, 3, 4, 3, 2, 1];
        final afterPeak = numbers.dropWhile((n) => n <= 3);

        expect(afterPeak, equals([4, 3, 2, 1]));
      });

      test('should include all if predicate never true', () {
        final numbers = [4, 5, 6];
        final all = numbers.dropWhile((n) => n <= 3);
        expect(all, equals([4, 5, 6]));
      });
    });

    group('withIndex', () {
      test('should pair elements with indices', () {
        final letters = ['a', 'b', 'c'];
        final indexed = letters.withIndex();

        expect(indexed, equals([(0, 'a'), (1, 'b'), (2, 'c')]));
      });

      test('should work with empty collection', () {
        final empty = <String>[];
        final indexed = empty.withIndex();
        expect(indexed, isEmpty);
      });
    });

    group('reversedList', () {
      test('should reverse elements', () {
        final numbers = [1, 2, 3, 4, 5];
        final reversed = numbers.reversedList();

        expect(reversed, equals([5, 4, 3, 2, 1]));
        expect(reversed, isA<List<int>>());
      });

      test('should not modify original', () {
        final original = [1, 2, 3];
        final reversed = original.reversedList();

        expect(original, equals([1, 2, 3])); // unchanged
        expect(reversed, equals([3, 2, 1]));
      });
    });

    group('sorted', () {
      test('should sort comparable elements', () {
        final numbers = [3, 1, 4, 1, 5, 9, 2, 6];
        final sorted = numbers.sorted();

        expect(sorted, equals([1, 1, 2, 3, 4, 5, 6, 9]));
      });

      test('should work with strings', () {
        final words = ['banana', 'apple', 'cherry'];
        final sorted = words.sorted();

        expect(sorted, equals(['apple', 'banana', 'cherry']));
      });
    });

    group('sortedBy', () {
      test('should sort with custom comparator', () {
        final words = ['apple', 'pie', 'banana'];
        final byLength = words.sortedBy((a, b) => a.length.compareTo(b.length));

        expect(byLength, equals(['pie', 'apple', 'banana']));
      });

      test('should sort in reverse order', () {
        final numbers = [1, 2, 3, 4, 5];
        final descending = numbers.sortedBy((a, b) => b.compareTo(a));

        expect(descending, equals([5, 4, 3, 2, 1]));
      });
    });

    group('sortedWith', () {
      test('should sort by key selector', () {
        final users = [
          TestUser('charlie', 25),
          TestUser('alice', 30),
          TestUser('bob', 20),
        ];

        final byAge = users.sortedWith((user) => user.age);
        expect(byAge.map((u) => u.age), equals([20, 25, 30]));

        final byName = users.sortedWith((user) => user.name);
        expect(byName.map((u) => u.name), equals(['alice', 'bob', 'charlie']));
      });
    });

    group('onEach', () {
      test('should apply action and return original', () {
        final numbers = [1, 2, 3];
        final sideEffects = <int>[];

        final result = numbers
            .onEach((n) => sideEffects.add(n * 2))
            .toList();

        expect(result, equals([1, 2, 3])); // Original unchanged
        expect(sideEffects, equals([2, 4, 6])); // Side effects captured
      });

      test('should work in pipeline', () {
        final logs = <String>[];
        final result = [1, 2, 3, 4, 5]
            .filter((n) => n.isOdd)
            .onEach((n) => logs.add('Processing: $n'))
            .mapToList((n) => n * 2);

        expect(result, equals([2, 6, 10]));
        expect(logs, equals(['Processing: 1', 'Processing: 3', 'Processing: 5']));
      });
    });

    group('arithmetic operations', () {
      group('sum', () {
        test('should sum integers', () {
          final numbers = [1, 2, 3, 4, 5];
          final total = numbers.sum();
          expect(total, equals(15));
        });

        test('should sum doubles', () {
          final numbers = [1.5, 2.5, 3.0];
          final total = numbers.sum();
          expect(total, closeTo(7.0, 0.001));
        });

        test('should handle empty list', () {
          final empty = <int>[];
          final total = empty.sum();
          expect(total, equals(0));
        });
      });

      group('average', () {
        test('should calculate average', () {
          final numbers = [1, 2, 3, 4, 5];
          final avg = numbers.average();
          expect(avg, equals(3.0));
        });

        test('should return null for empty', () {
          final empty = <int>[];
          final avg = empty.average();
          expect(avg, isNull);
        });

        test('should work with doubles', () {
          final numbers = [1.0, 2.0, 3.0];
          final avg = numbers.average();
          expect(avg, equals(2.0));
        });
      });

      group('minOrNull', () {
        test('should find minimum', () {
          final numbers = [3, 1, 4, 1, 5];
          final min = numbers.minOrNull();
          expect(min, equals(1));
        });

        test('should return null for empty', () {
          final empty = <int>[];
          final min = empty.minOrNull();
          expect(min, isNull);
        });

        test('should work with strings', () {
          final words = ['banana', 'apple', 'cherry'];
          final min = words.minOrNull();
          expect(min, equals('apple'));
        });
      });

      group('maxOrNull', () {
        test('should find maximum', () {
          final numbers = [3, 1, 4, 1, 5];
          final max = numbers.maxOrNull();
          expect(max, equals(5));
        });

        test('should return null for empty', () {
          final empty = <int>[];
          final max = empty.maxOrNull();
          expect(max, isNull);
        });
      });
    });

    group('complex pipelines', () {
      test('should chain multiple operations', () {
        final numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

        final result = numbers
            .filter((n) => n.isOdd)
            .mapToList((n) => n * n)
            .takeList(3)
            .sorted();

        expect(result, equals([1, 9, 25])); // [1², 3², 5²] first 3, sorted
      });

      test('should work with user data pipeline', () {
        final users = [
          TestUser('john', 25, 'john@example.com'),
          TestUser('jane', 30),
          TestUser('bob', 20, 'bob@example.com'),
          TestUser('alice', 35, 'alice@example.com'),
        ];

        final adultEmails = users
            .filter((user) => user.age >= 25)
            .mapNotNull((user) => user.email)
            .sortedWith((email) => email.length);

        expect(adultEmails, equals(['john@example.com', 'alice@example.com']));
      });

      test('should perform statistical analysis', () {
        final scores = [85, 92, 78, 94, 88, 76, 89, 95, 83, 91];

        final highScores = scores.filter((score) => score >= 85);
        final average = highScores.average();
        final max = highScores.maxOrNull();
        final count = highScores.length;

        expect(count, equals(7));
        expect(average, closeTo(90.57, 0.01));
        expect(max, equals(95));
      });

      test('should handle data processing with side effects', () {
        final processLog = <String>[];
        final errorLog = <String>[];

        final data = ['1', '2', 'invalid', '3', '4', 'bad'];

        final validNumbers = data
            .onEach((item) => processLog.add('Processing: $item'))
            .mapNotNull((item) {
          final number = int.tryParse(item);
          if (number == null) {
            errorLog.add('Invalid: $item');
          }
          return number;
        })
            .filter((n) => n > 1)
            .sorted();

        expect(validNumbers, equals([2, 3, 4]));
        expect(processLog.length, equals(6)); // All items processed
        expect(errorLog, equals(['Invalid: invalid', 'Invalid: bad']));
      });
    });
  });
}