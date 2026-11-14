# rwin_core

[![pub.dev](https://img.shields.io/pub/v/rwin_core)](https://pub.dev/packages/rwin_core)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

Clean Architecture foundation for Flutter apps — the same core that powers production HRIS at scale.

## What's inside

| Layer | What you get |
|---|---|
| **Error** | `APIException`, `Failure`, `APIFailure`, `MessageTreatment` |
| **Domain** | `ResultFuture<T>`, `VoidFuture`, `DataMap`, 4 use-case base classes |
| **Network** | `RemoteHandler` with token-refresh mutex, `RemoteHandlerConfig` |
| **Theme** | `AppTheme` (light + dark), `AppColors`, `AppTypography` |
| **Extensions** | `StringEx`, `DateTimeEx`, `ContextEx` |
| **Helpers** | `CubitHelper` (parallel fetch), `StorageHandler`, `FormStatus` |

## Installation

```yaml
dependencies:
  rwin_core: ^0.1.0
```

## Quick start

### 1 — Bootstrap in `main.dart`

```dart
import 'package:rwin_core/rwin_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Provide the current access token to RemoteHandler
  RemoteHandlerConfig.tokenProvider = () =>
      StorageHandler.get<String>(StorageKey.token);

  // Handle token refresh (return true = refreshed, false = session expired)
  RemoteHandlerConfig.onRefreshToken = (client) async {
    // Call your refresh endpoint, store new tokens, return result
    return await MyAuthRepository.refresh(client);
  };

  // Navigate to sign-in when session expires
  RemoteHandlerConfig.onSessionExpired = () async {
    await StorageHandler.clearSession();
    router.go('/sign-in');
  };

  runApp(const MyApp());
}
```

### 2 — Apply the theme

```dart
MaterialApp.router(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
);
```

Custom font (bundle it in `pubspec.yaml` first):

```dart
AppTheme.fontFamily = 'YourFont'; // set before runApp
```

### 3 — Use the network layer

```dart
class UserImplementation implements UserRepository {
  final http.Client _client;
  final String _baseUrl;

  UserImplementation(this._client, this._baseUrl);

  @override
  ResultFuture<UserEntity> getUser(String id) =>
      RemoteHandler.call<UserEntity>(
        client: _client,
        baseUrl: _baseUrl,
        pathUrl: '/users/$id',
        method: HttpMethod.get,
        fromJson: (body) => UserEntity.fromJson(body),
      );
}
```

### 4 — Write a use case

```dart
class GetUserUseCase extends UsecaseWithParams<UserEntity, String> {
  final UserRepository _repo;
  GetUserUseCase(this._repo);

  @override
  ResultFuture<UserEntity> call(String id) => _repo.getUser(id);
}
```

### 5 — Parallel fetch in a Cubit

```dart
class ProfileCubit extends Cubit<ProfileState> with CubitHelper {
  Future<void> load() async {
    final results = await fetchParallel([
      () => _getUserUseCase(),
      () => _getCompaniesUseCase(),
    ]);

    final failure = findFirstFailure(results);
    if (failure != null) { emit(ProfileError(failure.message)); return; }

    final user      = getResult<UserEntity>(results, 0);
    final companies = getResult<List<Company>>(results, 1);
    emit(ProfileLoaded(user: user!, companies: companies ?? []));
  }
}
```

### 6 — Handy extensions

```dart
// StringEx
'hello world'.toTitleCase()   // "Hello World"
'test@email.com'.isValidEmail() // true
'abc'.hasValue                 // true

// DateTimeEx
DateTime.now().format()                            // "14 Nov 2026"
DateTime.now().format(pattern: RwinDateFormat.time)  // "14:30"

// ContextEx
context.primaryColor
context.isDark
context.screenWidth
context.bodyMedium
```

## Architecture conventions

`rwin_core` follows strict Clean Architecture:

```
data/
  implementations/   ← implement Repository, call RemoteHandler
domain/
  repositories/      ← abstract contracts
  usecases/          ← extend UsecaseWithParams / UsecaseWithoutParams
  model/entities/    ← pure Dart, no Flutter
presentation/
  cubits/            ← extend Cubit, mix in CubitHelper
```

## License

MIT © rwin
