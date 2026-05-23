# Dart Design Patterns

## State Management
- **Riverpod** (preferred for new projects): `@riverpod` annotation + `ref.watch()` for reactive state
- **Bloc/Cubit**: `Cubit<State>` for simple state, `Bloc<Event, State>` for complex event-driven
- **Provider**: acceptable for small apps; avoid for new features in large apps
- **setState**: only for local, UI-only state in a single widget

## Repository Pattern
```dart
abstract class UserRepository {
  Future<User?> findById(String id);
  Future<void> save(User user);
}

class SupabaseUserRepository implements UserRepository { ... }
```

## Result Type (no exceptions for domain errors)
```dart
sealed class Result<T> {
  const factory Result.ok(T value) = Ok<T>;
  const factory Result.err(String message) = Err<T>;
}
```

## Dependency Injection
- Use Riverpod providers for DI: `final repoProvider = Provider((ref) => UserRepo());`
- Avoid service locators (GetIt) in new code — hard to test
- Pass dependencies as constructor parameters in pure Dart (non-Flutter) code

## Immutability
- Use `freezed` package for data classes: `@freezed class User with _$User`
- `copyWith` for updates, never mutate fields
- Sealed classes for discriminated unions (state machines, result types)
