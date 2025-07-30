import 'package:test/test.dart';
import 'package:kotlinish/src/scope_functions/apply.dart';

class TestPerson {
  String? name;
  int? age;
  List<String> hobbies = [];
}

void main() {
  group('apply extension', () {
    test('should return the same object after applying changes', () {
      final list = <String>[];
      final result = list.apply((it) {
        it.add('item1');
        it.add('item2');
      });

      expect(result, same(list));
      expect(result, equals(['item1', 'item2']));
    });

    test('should configure object properties', () {
      final person = TestPerson().apply((it) {
        it.name = 'John';
        it.age = 30;
        it.hobbies.addAll(['reading', 'coding']);
      });

      expect(person.name, equals('John'));
      expect(person.age, equals(30));
      expect(person.hobbies, equals(['reading', 'coding']));
    });

    test('should work with primitive types', () {
      final buffer = StringBuffer().apply((it) {
        it.write('Hello');
        it.write(' ');
        it.write('World');
      });

      expect(buffer.toString(), equals('Hello World'));
    });

    test('should work with maps', () {
      final config = <String, dynamic>{}.apply((it) {
        it['debug'] = true;
        it['timeout'] = 30;
        it['retries'] = 3;
      });

      expect(config['debug'], isTrue);
      expect(config['timeout'], equals(30));
      expect(config['retries'], equals(3));
    });

    test('should work with sets', () {
      final tags = <String>{}.apply((it) {
        it.add('flutter');
        it.add('dart');
        it.add('kotlin');
      });

      expect(tags, equals({'flutter', 'dart', 'kotlin'}));
    });

    test('should allow chaining with other methods', () {
      final result = <int>[]
          .apply((it) {
        it.addAll([1, 2, 3]);
      })
          .map((x) => x * 2)
          .toList();

      expect(result, equals([2, 4, 6]));
    });

    test('should work with nullable objects', () {
      TestPerson? person = TestPerson();
      final result = person?.apply((it) {
        it.name = 'Jane';
        it.age = 25;
      });

      expect(result, isNotNull);
      expect(result?.name, equals('Jane'));
      expect(result?.age, equals(25));
    });

    test('should handle null receiver gracefully', () {
      TestPerson? nullPerson;
      final result = nullPerson?.apply((it) {
        it.name = 'Should not execute';
      });

      expect(result, isNull);
    });

    test('should support nested apply calls', () {
      final outerList = <List<String>>[];
      final result = outerList.apply((outer) {
        outer.add(
          <String>[].apply((inner) {
            inner.add('nested1');
            inner.add('nested2');
          }),
        );
      });

      expect(result.length, equals(1));
      expect(result.first, equals(['nested1', 'nested2']));
    });

    test('should maintain object identity through multiple operations', () {
      final original = <String>['initial'];
      final result = original
          .apply((it) => it.add('second'))
          .apply((it) => it.add('third'));

      expect(result, same(original));
      expect(result, equals(['initial', 'second', 'third']));
    });
  });
}