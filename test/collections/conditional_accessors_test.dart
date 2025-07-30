import 'package:test/test.dart';
import 'package:kotlinish/src/collections/conditional_accessors.dart';

class TestUser {
  final String name;
  final int age;
  final bool isActive;
  final bool isAdmin;

  TestUser(this.name, this.age, {this.isActive = true, this.isAdmin = false});
}

void main() {
  group('Conditional Accessors Extension', () {
    group('takeIf', () {
      test('should return value when predicate is true', () {
        final number = 42;
        final result = number.takeIf((it) => it > 0);
        expect(result, equals(42));
      });

      test('should return null when predicate is false', () {
        final number = -5;
        final result = number.takeIf((it) => it > 0);
        expect(result, isNull);
      });

      test('should work with strings', () {
        final email = 'test@example.com';
        final validEmail = email.takeIf((it) => it.contains('@'));
        expect(validEmail, equals('test@example.com'));

        final invalidEmail = 'invalid-email';
        final result = invalidEmail.takeIf((it) => it.contains('@'));
        expect(result, isNull);
      });

      test('should work with custom objects', () {
        final activeUser = TestUser('John', 30, isActive: true);
        final result = activeUser.takeIf((it) => it.isActive);
        expect(result, same(activeUser));

        final inactiveUser = TestUser('Jane', 25, isActive: false);
        final nullResult = inactiveUser.takeIf((it) => it.isActive);
        expect(nullResult, isNull);
      });

      test('should work in chaining scenarios', () {
        final user = TestUser('Admin', 35, isActive: true, isAdmin: true);
        final adminName = user
            .takeIf((it) => it.isActive)
            ?.takeIf((it) => it.isAdmin)
            ?.name;
        expect(adminName, equals('Admin'));

        final regularUser = TestUser('User', 25, isActive: true, isAdmin: false);
        final noAdminName = regularUser
            .takeIf((it) => it.isActive)
            ?.takeIf((it) => it.isAdmin)
            ?.name;
        expect(noAdminName, isNull);
      });

      test('should work with nullable types', () {
        String? nullableString = 'test';
        final result = nullableString?.takeIf((it) => it.isNotEmpty);
        expect(result, equals('test'));

        nullableString = null;
        final nullResult = nullableString?.takeIf((it) => it.isNotEmpty);
        expect(nullResult, isNull);
      });
    });

    group('takeUnless', () {
      test('should return null when predicate is true', () {
        final emptyString = '';
        final result = emptyString.takeUnless((it) => it.isEmpty);
        expect(result, isNull);
      });

      test('should return value when predicate is false', () {
        final text = 'Hello World';
        final result = text.takeUnless((it) => it.isEmpty);
        expect(result, equals('Hello World'));
      });

      test('should work with numbers', () {
        final negativeAge = -5;
        final result = negativeAge.takeUnless((it) => it < 0);
        expect(result, isNull);

        final validAge = 25;
        final validResult = validAge.takeUnless((it) => it < 0);
        expect(validResult, equals(25));
      });

      test('should work with custom objects', () {
        final inactiveUser = TestUser('Jane', 25, isActive: false);
        final result = inactiveUser.takeUnless((it) => it.isActive);
        expect(result, same(inactiveUser));

        final activeUser = TestUser('John', 30, isActive: true);
        final nullResult = activeUser.takeUnless((it) => it.isActive);
        expect(nullResult, isNull);
      });

      test('should work in error handling scenarios', () {
        final response = {'status': 'error', 'message': 'Something went wrong'};
        final errorMessage = response
            .takeUnless((it) => it['status'] == 'success')
        ?['message'];
        expect(errorMessage, equals('Something went wrong'));

        final successResponse = {'status': 'success', 'data': 'result'};
        final noError = successResponse
            .takeUnless((it) => it['status'] == 'success')
        ?['message'];
        expect(noError, isNull);
      });
    });

    group('collection conditional extensions', () {
      group('takeIfNotEmpty', () {
        test('should return collection when not empty', () {
          final numbers = [1, 2, 3];
          final result = numbers.takeIfNotEmpty();
          expect(result, equals([1, 2, 3]));
        });

        test('should return null when empty', () {
          final empty = <int>[];
          final result = empty.takeIfNotEmpty();
          expect(result, isNull);
        });

        test('should work in chaining', () {
          final numbers = [1, 2, 3];
          final sum = numbers
              .takeIfNotEmpty()
              ?.fold(0, (sum, element) => sum + element);
          expect(sum, equals(6));

          final empty = <int>[];
          final emptySum = empty
              .takeIfNotEmpty()
              ?.fold(0, (sum, element) => sum + element);
          expect(emptySum, isNull);
        });
      });

      group('takeIfEmpty', () {
        test('should return collection when empty', () {
          final empty = <int>[];
          final result = empty.takeIfEmpty();
          expect(result, equals([]));
        });

        test('should return null when not empty', () {
          final numbers = [1, 2, 3];
          final result = numbers.takeIfEmpty();
          expect(result, isNull);
        });
      });

      group('takeIfSize', () {
        test('should return collection when size matches', () {
          final pair = [1, 2];
          final result = pair.takeIfSize(2);
          expect(result, equals([1, 2]));
        });

        test('should return null when size does not match', () {
          final triple = [1, 2, 3];
          final result = triple.takeIfSize(2);
          expect(result, isNull);

          final single = [1];
          final result2 = single.takeIfSize(2);
          expect(result2, isNull);
        });

        test('should work with sets', () {
          final numberSet = {1, 2, 3};
          final result = numberSet.takeIfSize(3);
          expect(result, isNotNull);
          expect(result!.length, equals(3));
        });
      });

      group('takeIfAll', () {
        test('should return collection when all elements satisfy predicate', () {
          final positiveNumbers = [1, 2, 3, 4, 5];
          final result = positiveNumbers.takeIfAll((x) => x > 0);
          expect(result, equals([1, 2, 3, 4, 5]));
        });

        test('should return null when not all elements satisfy predicate', () {
          final mixedNumbers = [1, -2, 3, 4, 5];
          final result = mixedNumbers.takeIfAll((x) => x > 0);
          expect(result, isNull);
        });

        test('should work with empty collections', () {
          final empty = <int>[];
          final result = empty.takeIfAll((x) => x > 0);
          expect(result, equals([])); // every() returns true for empty
        });

        test('should work with strings', () {
          final emails = ['test1@example.com', 'test2@example.com'];
          final result = emails.takeIfAll((email) => email.contains('@'));
          expect(result, equals(emails));

          final mixedEmails = ['test@example.com', 'invalid-email'];
          final invalidResult = mixedEmails.takeIfAll((email) => email.contains('@'));
          expect(invalidResult, isNull);
        });
      });

      group('takeIfAny', () {
        test('should return collection when any element satisfies predicate', () {
          final numbers = [1, 2, 3, 4, 5];
          final result = numbers.takeIfAny((x) => x > 3);
          expect(result, equals([1, 2, 3, 4, 5]));
        });

        test('should return null when no element satisfies predicate', () {
          final numbers = [1, 2, 3];
          final result = numbers.takeIfAny((x) => x > 10);
          expect(result, isNull);
        });

        test('should work with empty collections', () {
          final empty = <int>[];
          final result = empty.takeIfAny((x) => x > 0);
          expect(result, isNull); // any() returns false for empty
        });

        test('should work with custom objects', () {
          final users = [
            TestUser('User1', 25, isAdmin: false),
            TestUser('Admin', 30, isAdmin: true),
            TestUser('User2', 28, isAdmin: false),
          ];

          final hasAdmin = users.takeIfAny((user) => user.isAdmin);
          expect(hasAdmin, equals(users));

          final regularUsers = [
            TestUser('User1', 25, isAdmin: false),
            TestUser('User2', 28, isAdmin: false),
          ];

          final noAdmin = regularUsers.takeIfAny((user) => user.isAdmin);
          expect(noAdmin, isNull);
        });
      });
    });

    group('real-world scenarios', () {
      test('validation pipeline', () {
        final userInput = 'valid@example.com';
        final validatedEmail = userInput
            .takeUnless((it) => it.isEmpty)
            ?.takeIf((it) => it.contains('@'))
            ?.takeIf((it) => it.length > 5);
        expect(validatedEmail, equals('valid@example.com'));

        final invalidInput = 'x';
        final invalidEmail = invalidInput
            .takeUnless((it) => it.isEmpty)
            ?.takeIf((it) => it.contains('@'))
            ?.takeIf((it) => it.length > 5);
        expect(invalidEmail, isNull);
      });

      test('configuration with fallbacks', () {
        final config = {'timeout': 30, 'retries': 3};
        final validTimeout = config['timeout']
            ?.takeIf((it) => it > 0)
            ?.takeIf((it) => it <= 60) ?? 10;
        expect(validTimeout, equals(30));

        final invalidConfig = {'timeout': -5};
        final fallbackTimeout = invalidConfig['timeout']
            ?.takeIf((it) => it > 0)
            ?.takeIf((it) => it <= 60) ?? 10;
        expect(fallbackTimeout, equals(10));
      });

      test('data processing with conditions', () {
        final numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        final evenNumbers = numbers
            .where((x) => x.isEven)
            .takeIfNotEmpty()
            ?.takeIfAll((x) => x > 0)
            ?.map((x) => x * 2)
            .toList();
        expect(evenNumbers, equals([4, 8, 12, 16, 20]));

        final bigNumbers = numbers
            .where((x) => x > 100)
            .takeIfNotEmpty()
            ?.map((x) => x * 2)
            .toList();
        expect(bigNumbers, isNull);
      });
    });
  });
}