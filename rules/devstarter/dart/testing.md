# Dart Testing Rules

## Test Structure
- Unit tests: `test/` directory, mirrors `lib/` structure
- Widget tests: in `test/` with `_test.dart` suffix
- Integration tests: `integration_test/` directory
- Run all: `flutter test` / `dart test`

## Unit Tests
```dart
import 'package:test/test.dart';

void main() {
  group('UserService', () {
    late UserService sut;
    late MockUserRepository repo;

    setUp(() {
      repo = MockUserRepository();
      sut = UserService(repo);
    });

    test('returns null when user not found', () async {
      when(repo.findById('123')).thenAnswer((_) async => null);
      expect(await sut.getUser('123'), isNull);
    });
  });
}
```

## Widget Tests
- Use `WidgetTester` and `pumpWidget` to mount components
- `pump()` for single frame, `pumpAndSettle()` for animations to complete
- Find widgets with `find.byType`, `find.byKey`, `find.text`
- Assert with `expect(finder, findsOneWidget)` / `findsNWidgets(n)`

## Mocking
- Use `mockito` with `@GenerateMocks([ClassName])` and `build_runner`
- Or `mocktail` for a no-codegen alternative
- Mock only external dependencies: repositories, HTTP clients, platform channels

## Integration Tests
- Test real device/emulator flows end-to-end
- Use `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`
- Keep integration tests to critical user journeys — they're slow
