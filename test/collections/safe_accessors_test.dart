import 'package:test/test.dart';
import 'package:kotlinish/src/collections/safe_accessors.dart';

void main() {
  group('Safe Accessors Extension', () {
    group('firstOrNull', () {
      test('should return first element for non-empty list', () {
        final numbers = [1, 2, 3, 4, 5];
        expect(numbers.firstOrNull, equals(1));
      });

      test('should return null for empty list', () {
        final empty = <int>[];
        expect(empty.firstOrNull, isNull);
      });

      test('should work with single element list', () {
        final single = [42];
        expect(single.firstOrNull, equals(42));
      });

      test('should work with sets', () {
        final numberSet = {3, 1, 4, 1, 5}; // Note: sets remove duplicates
        expect(numberSet.firstOrNull, isNotNull);
        expect(numberSet.firstOrNull, isA<int>());
      });

      test('should work with where clauses', () {
        final numbers = [1, 2, 3, 4, 5];
        final evenFirst = numbers.where((x) => x.isEven).firstOrNull;
        expect(evenFirst, equals(2));

        final bigFirst = numbers.where((x) => x > 10).firstOrNull;
        expect(bigFirst, isNull);
      });

      test('should work with map transformations', () {
        final numbers = [1, 2, 3];
        final squaredFirst = numbers.map((x) => x * x).firstOrNull;
        expect(squaredFirst, equals(1));
      });

      test('should work with different types', () {
        final strings = ['hello', 'world'];
        expect(strings.firstOrNull, equals('hello'));

        final bools = [true, false, true];
        expect(bools.firstOrNull, isTrue);
      });

      test('should work with nullable element types', () {
        final nullableNumbers = <int?>[null, 1, 2];
        expect(nullableNumbers.firstOrNull, isNull);

        final nullableStrings = <String?>[null, 'test'];
        expect(nullableStrings.firstOrNull, isNull);
      });
    });

    group('lastOrNull', () {
      test('should return last element for non-empty list', () {
        final numbers = [1, 2, 3, 4, 5];
        expect(numbers.lastOrNull, equals(5));
      });

      test('should return null for empty list', () {
        final empty = <int>[];
        expect(empty.lastOrNull, isNull);
      });

      test('should work with single element list', () {
        final single = [42];
        expect(single.lastOrNull, equals(42));
      });

      test('should work with sets', () {
        final numberSet = {1, 2, 3};
        expect(numberSet.lastOrNull, isNotNull);
        expect(numberSet.lastOrNull, isA<int>());
      });

      test('should work with where clauses', () {
        final numbers = [1, 2, 3, 4, 5];
        final evenLast = numbers.where((x) => x.isEven).lastOrNull;
        expect(evenLast, equals(4));

        final bigLast = numbers.where((x) => x > 10).lastOrNull;
        expect(bigLast, isNull);
      });

      test('should work with map transformations', () {
        final numbers = [1, 2, 3];
        final squaredLast = numbers.map((x) => x * x).lastOrNull;
        expect(squaredLast, equals(9));
      });

      test('should work with different types', () {
        final strings = ['hello', 'world'];
        expect(strings.lastOrNull, equals('world'));

        final bools = [true, false, true];
        expect(bools.lastOrNull, isTrue);
      });

      test('should work with nullable element types', () {
        final nullableNumbers = <int?>[1, 2, null];
        expect(nullableNumbers.lastOrNull, isNull);
      });
    });

    group('singleOrNull', () {
      test('should return element for single-element collection', () {
        final single = [42];
        expect(single.singleOrNull, equals(42));
      });

      test('should return null for empty collection', () {
        final empty = <int>[];
        expect(empty.singleOrNull, isNull);
      });

      test('should return null for multi-element collection', () {
        final multiple = [1, 2, 3];
        expect(multiple.singleOrNull, isNull);
      });

      test('should work with where clauses - single match', () {
        final numbers = [1, 2, 3, 4, 5];
        final singleEven = numbers.where((x) => x == 2).singleOrNull;
        expect(singleEven, equals(2));
      });

      test('should work with where clauses - no match', () {
        final numbers = [1, 2, 3, 4, 5];
        final noMatch = numbers.where((x) => x > 10).singleOrNull;
        expect(noMatch, isNull);
      });

      test('should work with where clauses - multiple matches', () {
        final numbers = [1, 2, 3, 4, 5];
        final multipleMatches = numbers.where((x) => x.isEven).singleOrNull;
        expect(multipleMatches, isNull);
      });

      test('should work with sets', () {
        final singleSet = {42};
        expect(singleSet.singleOrNull, equals(42));

        final multipleSet = {1, 2, 3};
        expect(multipleSet.singleOrNull, isNull);
      });

      test('should work with different types', () {
        final singleString = ['hello'];
        expect(singleString.singleOrNull, equals('hello'));

        final singleBool = [true];
        expect(singleBool.singleOrNull, isTrue);
      });

      test('should work with nullable element types', () {
        final singleNull = <int?>[null];
        expect(singleNull.singleOrNull, isNull);

        final singleValue = <int?>[42];
        expect(singleValue.singleOrNull, equals(42));
      });
    });

    group('edge cases and performance', () {
      test('should handle large collections efficiently', () {
        final large = List.generate(100000, (i) => i);

        expect(large.firstOrNull, equals(0));
        expect(large.lastOrNull, equals(99999));
        expect(large.singleOrNull, isNull); // More than one element
      });

      test('should work with lazy iterables', () {
        final lazy = Iterable.generate(5, (i) => i * 2);

        expect(lazy.firstOrNull, equals(0));
        expect(lazy.lastOrNull, equals(8));
        expect(lazy.singleOrNull, isNull);
      });

      test('should maintain type safety', () {
        final numbers = <int>[1, 2, 3];
        final first = numbers.firstOrNull;
        expect(first, isA<int?>());

        final strings = <String>['a', 'b'];
        final last = strings.lastOrNull;
        expect(last, isA<String?>());
      });
    });
  });
}