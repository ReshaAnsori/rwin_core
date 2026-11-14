import 'package:http/http.dart';

/// Configuration and callbacks for [RemoteHandler] behaviour.
///
/// Register all callbacks once in `main()` before `runApp()`. This keeps
/// [RemoteHandler] free of any Flutter / navigation dependencies.
///
/// ```dart
/// // main.dart
/// RemoteHandlerConfig.tokenProvider = () async =>
///     await StorageHandler.get<String>(StorageKey.token);
///
/// RemoteHandlerConfig.onRefreshToken = (client) async {
///   // call your refresh endpoint, store new tokens, return true/false
///   return await AuthRepository.refresh(client);
/// };
///
/// RemoteHandlerConfig.onSessionExpired = () async {
///   await StorageHandler.clearSession();
///   router.go('/sign-in');
/// };
/// ```
class RemoteHandlerConfig {
  RemoteHandlerConfig._();

  // ─── Token management ─────────────────────────────────────────────────────

  /// Provides the current access token for the Authorization header.
  /// Return an empty string when no token is available.
  static Future<String> Function()? tokenProvider;

  /// Called when a 401 is received. Should refresh the access + refresh tokens,
  /// persist them, and return `true` on success or `false` on failure.
  /// [RemoteHandler] handles the mutex — this callback is called at most once
  /// per concurrent batch of failing requests.
  static Future<bool> Function(Client client)? onRefreshToken;

  // ─── Navigation side-effects ───────────────────────────────────────────────

  /// Called when the session expires (refresh token rejected or missing).
  /// Should clear session data and navigate to the login screen.
  static Future<void> Function()? onSessionExpired;

  /// Called when the server returns 403 Forbidden.
  static void Function()? onForbidden;

  // ─── Extra headers ─────────────────────────────────────────────────────────

  /// Optional factory for extra request headers (e.g. User-Agent, X-Device-Id).
  /// Merged after the default Content-Type / Authorization headers.
  static Future<Map<String, String>> Function()? extraHeaders;

  // ─── Error messages ────────────────────────────────────────────────────────

  /// Shown when a network connectivity error (SocketException) is detected.
  static String messageConnection =
      'No internet connection. Please check your network.';

  /// Shown when the session has expired after a failed token refresh.
  static String messageSessionExpired =
      'Your session has expired. Please sign in again.';

  /// Fallback message for unexpected server errors.
  static String messageGeneric =
      'Something went wrong. Please try again later.';
}
