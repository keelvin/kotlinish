import 'package:test/test.dart';
import 'package:kotlinish/src/scope_functions/let.dart';

void main() {
  group('let extension', () {
    test('should transform string to uppercase', () {
      final result = 'hello'.let((it) => it.toUpperCase());
      expect(result, equals('HELLO'));
    });

    test('should transform string to length', () {
      final result = 'hello world'.let((it) => it.length);
      expect(result, equals(11));
    });

    test('should work with null values', () {
      String? nullString;
      final result = nullString?.let((it) => it.toUpperCase());
      expect(result, isNull);
    });

    test('should work with non-null values in nullable context', () {
      String? nullableString = 'test';
      final result = nullableString?.let((it) => it.length) ?? 0;
      expect(result, equals(4));
    });

    test('should work with complex transformations', () {
      final user = {'name': 'John', 'age': 30};
      final result = user.let((it) => '${it['name']} is ${it['age']} years old');
      expect(result, equals('John is 30 years old'));
    });

    test('should work with different return types', () {
      final stringResult = 42.let((it) => it.toString());
      expect(stringResult, equals('42'));
      expect(stringResult, isA<String>());

      final boolResult = 'test'.let((it) => it.isNotEmpty);
      expect(boolResult, isTrue);
      expect(boolResult, isA<bool>());
    });

    test('should preserve original value type in closure', () {
      final numbers = [1, 2, 3];
      final result = numbers.let((it) {
        expect(it, isA<List<int>>());
        return it.fold(0, (sum, element) => sum + element);
      });
      expect(result, equals(6));
    });

    test('should work with nested let calls', () {
      final result = 'hello'
          .let((it) => it.toUpperCase())
          .let((it) => it.split(''))
          .let((it) => it.length);
      expect(result, equals(5));
    });
  });
}