import 'package:test/test.dart';
import 'package:kotlinish/src/scope_functions/also.dart';

class TestUser {
  final String name;
  final int age;

  TestUser(this.name, this.age);

  @override
  String toString() => 'User($name, $age)';
}

void main() {
  group('also extension', () {
    test('should return the same object after side effect', () {
      final list = [1, 2, 3];
      final logs = <String>[];

      final result = list.also((it) {
        logs.add('Processing list with ${it.length} items');
      });

      expect(result, same(list));
      expect(result, equals([1, 2, 3]));
      expect(logs, equals(['Processing list with 3 items']));
    });

    test('should work with logging side effects', () {
      final logs = <String>[];
      final user = TestUser('John', 30)
          .also((it) => logs.add('Created: ${it.name}'))
          .also((it) => logs.add('Age: ${it.age}'));

      expect(user.name, equals('John'));
      expect(user.age, equals(30));
      expect(logs, equals(['Created: John', 'Age: 30']));
    });

    test('should work in method chaining', () {
      final logs = <String>[];
      final result = [1, 2, 3]
          .also((it) => logs.add('Original: $it'))
          .map((x) => x * 2)
          .toList()
          .also((it) => logs.add('Doubled: $it'));

      expect(result, equals([2, 4, 6]));
      expect(logs, equals([
        'Original: [1, 2, 3]',
        'Doubled: [2, 4, 6]'
      ]));
    });

    test('should work with debugging and validation', () {
      final validationResults = <String>[];
      final config = {'timeout': 30, 'retries': 3}
          .also((it) {
        if (it['timeout'] as int > 0) {
          validationResults.add('timeout: valid');
        }
        if (it['retries'] as int > 0) {
          validationResults.add('retries: valid');
        }
      });

      expect(config['timeout'], equals(30));
      expect(config['retries'], equals(3));
      expect(validationResults, equals(['timeout: valid', 'retries: valid']));
    });

    test('should work with nullable objects', () {
      final logs = <String>[];
      TestUser? user = TestUser('Jane', 25);

      final result = user?.also((it) {
        logs.add('Processing user: ${it.name}');
      });

      expect(result, isNotNull);
      expect(result?.name, equals('Jane'));
      expect(logs, equals(['Processing user: Jane']));
    });

    test('should handle null receiver gracefully', () {
      final logs = <String>[];
      TestUser? nullUser;

      final result = nullUser?.also((it) {
        logs.add('This should not execute');
      });

      expect(result, isNull);
      expect(logs, isEmpty);
    });

    test('should work with performance monitoring', () {
      final metrics = <String, int>{};
      final data = List.generate(1000, (i) => i);

      final result = data
          .also((it) => metrics['input_size'] = it.length)
          .where((x) => x % 2 == 0)
          .toList()
          .also((it) => metrics['output_size'] = it.length);

      expect(metrics['input_size'], equals(1000));
      expect(metrics['output_size'], equals(500));
      expect(result.length, equals(500));
    });

    test('should work with multiple side effects', () {
      final events = <String>[];
      final user = TestUser('Alice', 28)
          .also((it) => events.add('audit: user_created'))
          .also((it) => events.add('cache: user_${it.name}_stored'))
          .also((it) => events.add('notify: welcome_${it.name}'));

      expect(user.name, equals('Alice'));
      expect(events, equals([
        'audit: user_created',
        'cache: user_Alice_stored',
        'notify: welcome_Alice'
      ]));
    });

    test('should maintain object identity through operations', () {
      final original = StringBuffer('Hello');
      final result = original
          .also((it) => it.write(' World'))
          .also((it) => it.write('!'));

      expect(result, same(original));
      expect(result.toString(), equals('Hello World!'));
    });

    test('should work with error handling side effects', () {
      final errors = <String>[];
      final data = {'value': null};

      final result = data.also((it) {
        if (it['value'] == null) {
          errors.add('Warning: null value detected');
        }
      });

      expect(result['value'], isNull);
      expect(errors, equals(['Warning: null value detected']));
    });

    test('should work with conditional side effects', () {
      final logs = <String>[];
      final score = 95;

      final result = score
          .also((it) {
        if (it >= 90) logs.add('Excellent performance');
      })
          .also((it) {
        if (it > 80) logs.add('Above average');
      });

      expect(result, equals(95));
      expect(logs, equals(['Excellent performance', 'Above average']));
    });

    test('should preserve type information', () {
      final numbers = <int>[1, 2, 3];
      final result = numbers.also((it) {
        expect(it, isA<List<int>>());
        expect(it.first, isA<int>());
      });

      expect(result, isA<List<int>>());
      expect(result, same(numbers));
    });
  });
}