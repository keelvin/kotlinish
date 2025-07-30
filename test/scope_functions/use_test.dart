import 'package:test/test.dart';
import 'package:kotlinish/src/scope_functions/use.dart';

class TestBuilder {
  final List<String> _parts = [];

  void add(String part) => _parts.add(part);
  void addAll(List<String> parts) => _parts.addAll(parts);
  String build() => _parts.join(' ');
  int get length => _parts.length;
}

void main() {
  group('use function', () {
    group('top-level use function', () {
      test('should execute block with receiver and return result', () {
        final buffer = StringBuffer();
        final result = use(buffer, (it) {
          it.write('Hello');
          it.write(' World');
          return it.toString();
        });

        expect(result, equals('Hello World'));
      });

      test('should work with calculations', () {
        final numbers = [1, 2, 3, 4, 5];
        final sum = use(numbers, (it) =>
            it.fold(0, (acc, element) => acc + element)
        );
        expect(sum, equals(15));
      });

      test('should work with boolean expressions', () {
        final user = {'name': 'John', 'age': 30};
        final isValid = use(user, (it) =>
        (it['name'] as String?)?.isNotEmpty == true && (it['age'] as int) > 0
        );
        expect(isValid, isTrue);
      });

      test('should work with custom objects', () {
        final builder = TestBuilder();
        final result = use(builder, (it) {
          it.add('Hello');
          it.add('Kotlin');
          it.add('World');
          return it.build();
        });

        expect(result, equals('Hello Kotlin World'));
      });

      test('should work with nested operations', () {
        final config = <String, dynamic>{};
        final isConfigured = use(config, (it) {
          it['database'] = use(<String, String>{}, (db) {
            db['host'] = 'localhost';
            db['port'] = '5432';
            return db;
          });
          it['cache'] = {'enabled': true, 'ttl': 300};
          return it.isNotEmpty;
        });

        expect(isConfigured, isTrue);
        expect(config['database']['host'], equals('localhost'));
      });

      test('should preserve type information', () {
        final list = <int>[1, 2, 3];
        final result = use(list, (it) {
          expect(it, isA<List<int>>());
          return it.map((x) => x.toString()).toList();
        });

        expect(result, isA<List<String>>());
        expect(result, equals(['1', '2', '3']));
      });
    });

    group('use extension', () {
      test('should work as extension method', () {
        final result = StringBuffer().use((it) {
          it.write('Extension');
          it.write(' Method');
          return it.toString();
        });

        expect(result, equals('Extension Method'));
      });

      test('should work in method chaining', () {
        final result = [1, 2, 3]
            .use((it) => it.map((x) => x * 2).toList())
            .use((it) => it.fold(0, (sum, element) => sum + element));

        expect(result, equals(12)); // [2, 4, 6] -> 12
      });

      test('should work with nullable receivers', () {
        StringBuffer? buffer = StringBuffer();
        final result = buffer?.use((it) {
          it.write('Nullable');
          return it.toString();
        });

        expect(result, equals('Nullable'));
      });

      test('should handle null receiver gracefully', () {
        StringBuffer? nullBuffer;
        final result = nullBuffer?.use((it) {
          it.write('Should not execute');
          return it.toString();
        });

        expect(result, isNull);
      });

      test('should work with complex transformations', () {
        final data = {'items': [1, 2, 3, 4, 5]};
        final stats = data.use((it) {
          final items = it['items'] as List<int>;
          return {
            'count': items.length,
            'sum': items.fold(0, (sum, element) => sum + element),
            'average': items.fold(0, (sum, element) => sum + element) / items.length,
          };
        });

        expect(stats['count'], equals(5));
        expect(stats['sum'], equals(15));
        expect(stats['average'], equals(3.0));
      });

      test('should work with builder pattern', () {
        final message = TestBuilder().use((it) {
          it.add('Building');
          it.add('with');
          it.addAll(['Kotlin', 'style']);
          return it.build();
        });

        expect(message, equals('Building with Kotlin style'));
      });

      test('should work with conditional logic', () {
        final score = 85;
        final feedback = score.use((it) {
          if (it >= 90) return 'Excellent!';
          if (it >= 80) return 'Good job!';
          if (it >= 70) return 'Not bad';
          return 'Needs improvement';
        });

        expect(feedback, equals('Good job!'));
      });

      test('should work with side effects and return values', () {
        final logs = <String>[];
        final result = 'processing'.use((it) {
          logs.add('Started: $it');
          final processed = it.toUpperCase();
          logs.add('Finished: $processed');
          return processed.length;
        });

        expect(result, equals(10));
        expect(logs, equals([
          'Started: processing',
          'Finished: PROCESSING'
        ]));
      });

      test('should work with nested use calls', () {
        final result = 'hello'.use((outer) =>
            outer.toUpperCase().use((inner) =>
                inner.split('').use((chars) => chars.length)
            )
        );

        expect(result, equals(5));
      });
    });

    group('comparison with other scope functions', () {
      test('use vs let behavior should be similar', () {
        final value = 'test';

        // Both should work similarly for simple transformations
        final useResult = value.use((it) => it.toUpperCase());
        expect(useResult, equals('TEST'));

        // use should work identically to let for most cases
        final lengthResult = value.use((it) => it.length);
        expect(lengthResult, equals(4));
      });

      test('top-level use should work without extension context', () {
        // This is where use shines - no need for extension context
        final externalBuffer = StringBuffer('Start');
        final result = use(externalBuffer, (it) {
          it.write(' Middle');
          it.write(' End');
          return it.toString();
        });

        expect(result, equals('Start Middle End'));
      });
    });
  });
}