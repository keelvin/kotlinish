import 'package:test/test.dart';
import 'package:kotlinish/src/collections/grouping_utilities.dart';

class TestUser {
  final String name;
  final int age;
  final String department;
  final bool isActive;

  TestUser(this.name, this.age, this.department, {this.isActive = true});

  @override
  String toString() => 'User($name, $age, $department)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TestUser &&
              name == other.name &&
              age == other.age &&
              department == other.department &&
              isActive == other.isActive;

  @override
  int get hashCode => Object.hash(name, age, department, isActive);
}

void main() {
  group('Grouping Utilities Extension', () {
    group('groupBy', () {
      test('should group elements by key selector', () {
        final words = ['apple', 'banana', 'cherry', 'apricot', 'blueberry'];
        final grouped = words.groupBy((word) => word[0]);

        expect(grouped['a'], equals(['apple', 'apricot']));
        expect(grouped['b'], equals(['banana', 'blueberry']));
        expect(grouped['c'], equals(['cherry']));
        expect(grouped.length, equals(3));
      });

      test('should group numbers by even/odd', () {
        final numbers = [1, 2, 3, 4, 5, 6, 7, 8];
        final grouped = numbers.groupBy((n) => n.isEven ? 'even' : 'odd');

        expect(grouped['even'], equals([2, 4, 6, 8]));
        expect(grouped['odd'], equals([1, 3, 5, 7]));
      });

      test('should group custom objects', () {
        final users = [
          TestUser('john', 25, 'engineering'),
          TestUser('jane', 30, 'design'),
          TestUser('bob', 25, 'engineering'),
          TestUser('alice', 28, 'marketing'),
        ];

        final byDepartment = users.groupBy((user) => user.department);
        expect(byDepartment['engineering']?.length, equals(2));
        expect(byDepartment['design']?.length, equals(1));
        expect(byDepartment['marketing']?.length, equals(1));

        final byAge = users.groupBy((user) => user.age);
        expect(byAge[25]?.length, equals(2));
        expect(byAge[30]?.length, equals(1));
        expect(byAge[28]?.length, equals(1));
      });

      test('should handle empty collections', () {
        final empty = <String>[];
        final grouped = empty.groupBy((s) => s.length);
        expect(grouped, isEmpty);
      });

      test('should handle single element', () {
        final single = ['hello'];
        final grouped = single.groupBy((s) => s.length);
        expect(grouped[5], equals(['hello']));
        expect(grouped.length, equals(1));
      });
    });

    group('partition', () {
      test('should partition numbers by even/odd', () {
        final numbers = [1, 2, 3, 4, 5, 6, 7, 8];
        final (evens, odds) = numbers.partition((n) => n.isEven);

        expect(evens, equals([2, 4, 6, 8]));
        expect(odds, equals([1, 3, 5, 7]));
      });

      test('should partition users by active status', () {
        final users = [
          TestUser('john', 25, 'dev', isActive: true),
          TestUser('jane', 30, 'design', isActive: false),
          TestUser('bob', 25, 'dev', isActive: true),
          TestUser('alice', 28, 'marketing', isActive: false),
        ];

        final (active, inactive) = users.partition((user) => user.isActive);
        expect(active.length, equals(2));
        expect(inactive.length, equals(2));
        expect(active.every((user) => user.isActive), isTrue);
        expect(inactive.every((user) => !user.isActive), isTrue);
      });

      test('should handle empty collections', () {
        final empty = <int>[];
        final (trueList, falseList) = empty.partition((n) => n > 0);
        expect(trueList, isEmpty);
        expect(falseList, isEmpty);
      });

      test('should handle all true predicate', () {
        final numbers = [2, 4, 6, 8];
        final (evens, odds) = numbers.partition((n) => n.isEven);
        expect(evens, equals([2, 4, 6, 8]));
        expect(odds, isEmpty);
      });

      test('should handle all false predicate', () {
        final numbers = [1, 3, 5, 7];
        final (evens, odds) = numbers.partition((n) => n.isEven);
        expect(evens, isEmpty);
        expect(odds, equals([1, 3, 5, 7]));
      });
    });

    group('associateBy', () {
      test('should create map with custom key and value selectors', () {
        final users = [
          TestUser('john', 25, 'dev'),
          TestUser('jane', 30, 'design'),
          TestUser('bob', 28, 'marketing'),
        ];

        final nameToAge = users.associateBy(
              (user) => user.name,
              (user) => user.age,
        );

        expect(nameToAge['john'], equals(25));
        expect(nameToAge['jane'], equals(30));
        expect(nameToAge['bob'], equals(28));
        expect(nameToAge.length, equals(3));
      });

      test('should handle duplicate keys - last wins', () {
        final items = [
          ('key1', 'value1'),
          ('key2', 'value2'),
          ('key1', 'value3'), // This should overwrite the first key1
        ];

        final map = items.associateBy(
              (item) => item.$1,
              (item) => item.$2,
        );

        expect(map['key1'], equals('value3'));
        expect(map['key2'], equals('value2'));
        expect(map.length, equals(2));
      });

      test('should work with different types', () {
        final words = ['apple', 'banana', 'cherry'];
        final lengthToWord = words.associateBy(
              (word) => word.length,
              (word) => word.toUpperCase(),
        );

        expect(lengthToWord[5], equals('APPLE'));
        expect(lengthToWord[6], equals('CHERRY'));
      });
    });

    group('associateWith', () {
      test('should create map with elements as keys', () {
        final names = ['john', 'jane', 'bob'];
        final nameToLength = names.associateWith((name) => name.length);

        expect(nameToLength['john'], equals(4));
        expect(nameToLength['jane'], equals(4));
        expect(nameToLength['bob'], equals(3));
      });

      test('should work with numbers', () {
        final numbers = [1, 2, 3, 4, 5];
        final numberToSquare = numbers.associateWith((n) => n * n);

        expect(numberToSquare[1], equals(1));
        expect(numberToSquare[2], equals(4));
        expect(numberToSquare[3], equals(9));
        expect(numberToSquare[4], equals(16));
        expect(numberToSquare[5], equals(25));
      });

      test('should handle complex transformations', () {
        final users = [
          TestUser('john', 25, 'dev'),
          TestUser('jane', 30, 'design'),
        ];

        final userToInfo = users.associateWith(
              (user) => '${user.name} (${user.age}) - ${user.department}',
        );

        expect(userToInfo[users[0]], equals('john (25) - dev'));
        expect(userToInfo[users[1]], equals('jane (30) - design'));
      });
    });

    group('distinctBy', () {
      test('should return distinct elements by selector', () {
        final users = [
          TestUser('john', 25, 'dev'),
          TestUser('jane', 30, 'design'),
          TestUser('bob', 25, 'marketing'), // Same age as john
          TestUser('alice', 30, 'dev'), // Same age as jane
        ];

        final distinctByAge = users.distinctBy((user) => user.age);
        expect(distinctByAge.length, equals(2));
        expect(distinctByAge[0].name, equals('john')); // First with age 25
        expect(distinctByAge[1].name, equals('jane')); // First with age 30
      });

      test('should work with strings', () {
        final words = ['apple', 'banana', 'apricot', 'cherry', 'blueberry'];
        final distinctByFirstLetter = words.distinctBy((word) => word[0]);

        expect(distinctByFirstLetter.length, equals(3));
        expect(distinctByFirstLetter, contains('apple')); // First 'a'
        expect(distinctByFirstLetter, contains('banana')); // First 'b'
        expect(distinctByFirstLetter, contains('cherry')); // First 'c'
        expect(distinctByFirstLetter, isNot(contains('apricot'))); // Second 'a'
        expect(distinctByFirstLetter, isNot(contains('blueberry'))); // Second 'b'
      });

      test('should preserve order of first occurrences', () {
        final numbers = [1, 2, 1, 3, 2, 4, 1, 5];
        final distinct = numbers.distinctBy((n) => n);

        expect(distinct, equals([1, 2, 3, 4, 5]));
      });

      test('should handle empty collections', () {
        final empty = <String>[];
        final distinct = empty.distinctBy((s) => s.length);
        expect(distinct, isEmpty);
      });
    });

    group('chunked', () {
      test('should split collection into equal chunks', () {
        final numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9];
        final chunks = numbers.chunked(3);

        expect(chunks.length, equals(3));
        expect(chunks[0], equals([1, 2, 3]));
        expect(chunks[1], equals([4, 5, 6]));
        expect(chunks[2], equals([7, 8, 9]));
      });

      test('should handle remainder in last chunk', () {
        final numbers = [1, 2, 3, 4, 5, 6, 7, 8];
        final chunks = numbers.chunked(3);

        expect(chunks.length, equals(3));
        expect(chunks[0], equals([1, 2, 3]));
        expect(chunks[1], equals([4, 5, 6]));
        expect(chunks[2], equals([7, 8])); // Remainder
      });

      test('should handle chunk size larger than collection', () {
        final numbers = [1, 2, 3];
        final chunks = numbers.chunked(5);

        expect(chunks.length, equals(1));
        expect(chunks[0], equals([1, 2, 3]));
      });

      test('should handle empty collection', () {
        final empty = <int>[];
        final chunks = empty.chunked(3);
        expect(chunks, isEmpty);
      });

      test('should throw on invalid chunk size', () {
        final numbers = [1, 2, 3];
        expect(() => numbers.chunked(0), throwsArgumentError);
        expect(() => numbers.chunked(-1), throwsArgumentError);
      });

      test('should work with chunk size of 1', () {
        final numbers = [1, 2, 3];
        final chunks = numbers.chunked(1);

        expect(chunks.length, equals(3));
        expect(chunks[0], equals([1]));
        expect(chunks[1], equals([2]));
        expect(chunks[2], equals([3]));
      });
    });

    group('chunkedTransform', () {
      test('should transform chunks and return results', () {
        final numbers = [1, 2, 3, 4, 5, 6];
        final sums = numbers.chunkedTransform(
          2,
              (chunk) => chunk.fold(0, (sum, n) => sum + n),
        );

        expect(sums, equals([3, 7, 11])); // [1+2, 3+4, 5+6]
      });

      test('should work with string transformations', () {
        final letters = ['a', 'b', 'c', 'd', 'e'];
        final joined = letters.chunkedTransform(
          2,
              (chunk) => chunk.join('-'),
        );

        expect(joined, equals(['a-b', 'c-d', 'e']));
      });

      test('should handle complex transformations', () {
        final users = [
          TestUser('john', 25, 'dev'),
          TestUser('jane', 30, 'design'),
          TestUser('bob', 28, 'dev'),
          TestUser('alice', 32, 'marketing'),
        ];

        final avgAges = users.chunkedTransform(
          2,
              (chunk) => chunk.map((u) => u.age).reduce((a, b) => a + b) / chunk.length,
        );

        expect(avgAges[0], equals(27.5)); // (25 + 30) / 2
        expect(avgAges[1], equals(30.0)); // (28 + 32) / 2
      });
    });

    group('real-world scenarios', () {
      test('data analysis pipeline', () {
        final sales = [
          ('Q1', 1000),
          ('Q2', 1500),
          ('Q3', 1200),
          ('Q4', 1800),
          ('Q1', 1100), // Next year
          ('Q2', 1600),
        ];

        // Group by quarter and calculate totals
        final quarterlyTotals = <String, int>{};
        for (final entry in sales.groupBy((sale) => sale.$1).entries) {
          quarterlyTotals[entry.key] = entry.value.fold(0, (sum, sale) => sum + sale.$2);
        }

        expect(quarterlyTotals['Q1'], equals(2100)); // 1000 + 1100
        expect(quarterlyTotals['Q2'], equals(3100)); // 1500 + 1600
      });

      test('user management workflow', () {
        final users = [
          TestUser('john', 25, 'dev', isActive: true),
          TestUser('jane', 30, 'design', isActive: false),
          TestUser('bob', 25, 'dev', isActive: true),
          TestUser('alice', 28, 'marketing', isActive: true),
          TestUser('charlie', 30, 'design', isActive: false),
        ];

        // Partition by status, group active users by department
        final (active, inactive) = users.partition((u) => u.isActive);
        final activeByDept = active.groupBy((u) => u.department);
        final uniqueAges = users.distinctBy((u) => u.age);

        expect(active.length, equals(3));
        expect(inactive.length, equals(2));
        expect(activeByDept['dev']?.length, equals(2));
        expect(uniqueAges.length, equals(3)); // 25, 30, 28
      });

      test('batch processing simulation', () {
        final items = List.generate(10, (i) => i + 1); // [1, 2, 3, ..., 10]

        // Process in batches of 3, calculate batch sums
        final batchSums = items.chunkedTransform(
          3,
              (batch) => batch.fold(0, (sum, item) => sum + item),
        );

        expect(batchSums, equals([6, 15, 24, 10])); // [1+2+3, 4+5+6, 7+8+9, 10]
      });
    });
  });
}