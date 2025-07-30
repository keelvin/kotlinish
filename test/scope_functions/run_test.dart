import 'package:test/test.dart';
import 'package:kotlinish/src/scope_functions/run.dart';

class TestConfig {
  bool debugEnabled = false;
  int timeout = 0;
  String? environment;

  void enableDebug() => debugEnabled = true;
  void setTimeout(int seconds) => timeout = seconds;
  void setEnvironment(String env) => environment = env;

  bool get isValid => timeout > 0 && environment != null;
}

void main() {
  group('run extension', () {
    test('should execute block and return result', () {
      final result = 'Hello World'.run((self) => self.length);
      expect(result, equals(11));
    });

    test('should work with boolean expressions', () {
      final user = {'name': 'John', 'age': 30};
      final isValid = user.run((self) =>
      (self['name'] as String?)?.isNotEmpty == true &&
          (self['age'] as int) > 0
      );
      expect(isValid, isTrue);
    });

    test('should allow complex operations with return value', () {
      final config = TestConfig().run((self) {
        self.enableDebug();
        self.setTimeout(30);
        self.setEnvironment('production');
        return self.isValid;
      });

      expect(config, isTrue);
    });

    test('should work with calculations', () {
      final numbers = [1, 2, 3, 4, 5];
      final average = numbers.run((self) =>
      self.fold(0, (sum, element) => sum + element) / self.length
      );
      expect(average, equals(3.0));
    });

    test('should work with string operations', () {
      final formatted = 'hello world'.run((self) =>
          self.split(' ')
              .map((word) => word[0].toUpperCase() + word.substring(1))
              .join(' ')
      );
      expect(formatted, equals('Hello World'));
    });

    test('should work with null values', () {
      String? nullString;
      final result = nullString?.run((self) => self.toUpperCase());
      expect(result, isNull);
    });

    test('should work with non-null values in nullable context', () {
      String? nullableString = 'test';
      final result = nullableString?.run((self) => self.length) ?? 0;
      expect(result, equals(4));
    });

    test('should work with different return types', () {
      final stringResult = 42.run((self) => self.toString());
      expect(stringResult, equals('42'));
      expect(stringResult, isA<String>());

      final listResult = 'abc'.run((self) => self.split(''));
      expect(listResult, equals(['a', 'b', 'c']));
      expect(listResult, isA<List<String>>());
    });

    test('should preserve original value type in closure', () {
      final map = {'a': 1, 'b': 2, 'c': 3};
      final result = map.run((self) {
        expect(self, isA<Map<String, int>>());
        return self.values.reduce((sum, value) => sum + value);
      });
      expect(result, equals(6));
    });

    test('should work with nested run calls', () {
      final result = 'hello'
          .run((self) => self.toUpperCase())
          .run((self) => self.split(''))
          .run((self) => self.length);
      expect(result, equals(5));
    });

    test('should work with conditional logic', () {
      final score = 85;
      final grade = score.run((self) {
        if (self >= 90) return 'A';
        if (self >= 80) return 'B';
        if (self >= 70) return 'C';
        if (self >= 60) return 'D';
        return 'F';
      });
      expect(grade, equals('B'));
    });

    test('should handle side effects and return values', () {
      final logs = <String>[];
      final result = 'processing'.run((self) {
        logs.add('Started processing: $self');
        final processed = self.toUpperCase();
        logs.add('Finished processing: $processed');
        return processed;
      });

      expect(result, equals('PROCESSING'));
      expect(logs, equals([
        'Started processing: processing',
        'Finished processing: PROCESSING'
      ]));
    });
  });
}