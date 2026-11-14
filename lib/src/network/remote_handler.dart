import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' show Client, Response;
import 'package:rwin_core/src/error/exceptions.dart';
import 'package:rwin_core/src/error/failure.dart';
import 'package:rwin_core/src/domain/typedef.dart';
import 'package:rwin_core/src/network/remote_handler_config.dart';

/// Generic HTTP client for Clean Architecture data layers.
///
/// All methods return `Either<Failure, T>` — never throw.
/// Register side-effect callbacks via [RemoteHandlerConfig] in `main()`.
///
/// Usage:
/// ```dart
/// final result = await RemoteHandler.call<MyEntity>(
///   client: _client,
///   baseUrl: 'https://api.example.com',
///   pathUrl: '/users',
///   method: HttpMethod.get,
///   fromJson: (body) => MyEntity.fromJson(body),
/// );
/// ```
sealed class RemoteHandler {
  RemoteHandler._();

  static bool _isRefreshing = false;
  static Completer<bool>? _refreshTokenCompleter;

  /// Execute an HTTP request and map the response to [Either<Failure, T?>].
  ///
  /// - [baseUrl] — full base URL including scheme (e.g. `https://api.example.com`).
  /// - [pathUrl] — path segment (e.g. `/users/1`).
  /// - [method] — HTTP verb.
  /// - [fromJson] — deserializer; omit for void responses.
  /// - [body] — request body (GET uses this as query params).
  /// - [queryParams] — explicit query params (overrides body for non-GET).
  /// - [useToken] — whether to inject the Authorization header.
  static Future<Either<Failure, T?>> call<T>({
    required Client client,
    required String baseUrl,
    required String pathUrl,
    required HttpMethod method,
    T Function(String body)? fromJson,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    bool useToken = true,
  }) async {
    try {
      final response = await _execute(
        client: client,
        baseUrl: baseUrl,
        pathUrl: pathUrl,
        method: method,
        body: body,
        queryParams: queryParams,
        headers: headers,
        useToken: useToken,
      );

      // Empty JSON array — treat as null (empty list handled by caller)
      if (response.body.trim() == '[]') return const Right(null);

      if (fromJson != null) return Right(fromJson(response.body));
      return const Right(null);
    } on APIException catch (e) {
      return Left(APIFailure.fromException(e));
    } catch (e, stack) {
      log('REMOTE_HANDLER ERROR: $e');
      log('REMOTE_HANDLER STACKTRACE: $stack');
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('socketexception') ||
          errStr.contains('failed host lookup') ||
          errStr.contains('clientexception')) {
        return Left(APIFailure(
          message: RemoteHandlerConfig.messageConnection,
          statusCode: 503,
        ));
      }
      return Left(
          APIFailure(message: RemoteHandlerConfig.messageGeneric, statusCode: 505));
    }
  }

  // ─── Internal ─────────────────────────────────────────────────────────────

  static Future<Response> _execute({
    required Client client,
    required String baseUrl,
    required String pathUrl,
    required HttpMethod method,
    Object? body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    bool useToken = true,
  }) async {
    final qParam = method == HttpMethod.get
        ? (queryParams ?? (body is Map<String, dynamic> ? body : null))
        : queryParams;

    final uri = _buildUri(baseUrl, pathUrl, qParam);
    var header = await _buildHeaders(useToken: useToken);
    if (headers != null) header.addAll(headers);

    var response = await _callHttp(
      client: client,
      uri: uri,
      header: header,
      body: body,
      method: method,
    );

    // 401 → attempt token refresh once
    if (response.statusCode == 401 && useToken) {
      final refreshed = await _doRefreshToken(client);
      if (refreshed) {
        var retryHeader = await _buildHeaders(useToken: useToken);
        if (headers != null) retryHeader.addAll(headers);
        response = await _callHttp(
          client: client,
          uri: uri,
          header: retryHeader,
          body: body,
          method: method,
        );
        return _validateResponse(response);
      } else {
        throw APIException(
          statusCode: 401,
          message: RemoteHandlerConfig.messageSessionExpired,
        );
      }
    }

    return _validateResponse(response);
  }

  static Response _validateResponse(Response response) {
    if (response.statusCode == 403) {
      RemoteHandlerConfig.onForbidden?.call();
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    // Parse error message from response body
    String message = RemoteHandlerConfig.messageGeneric;
    if (response.body.isNotEmpty) {
      try {
        final map = jsonDecode(response.body);
        if (map is Map) {
          message = (map['message'] ?? map['error'] ?? map['msg'] ?? message)
              .toString();
        }
      } catch (_) {}
    }

    throw APIException(statusCode: response.statusCode, message: message);
  }

  /// Token refresh with mutex — concurrent 401s share one refresh attempt.
  static Future<bool> _doRefreshToken(Client client) async {
    if (_isRefreshing) {
      return _refreshTokenCompleter?.future ?? Future.value(false);
    }

    _isRefreshing = true;
    _refreshTokenCompleter = Completer<bool>();

    try {
      final refreshed =
          await RemoteHandlerConfig.onRefreshToken?.call(client) ?? false;

      _isRefreshing = false;
      _refreshTokenCompleter?.complete(refreshed);
      _refreshTokenCompleter = null;

      if (!refreshed) {
        await RemoteHandlerConfig.onSessionExpired?.call();
      }

      return refreshed;
    } on SocketException {
      // Network down → don't logout
      debugPrint('[RemoteHandler] Token refresh failed: offline');
      _isRefreshing = false;
      _refreshTokenCompleter?.complete(false);
      _refreshTokenCompleter = null;
      return false;
    } on TimeoutException {
      debugPrint('[RemoteHandler] Token refresh timed out');
      _isRefreshing = false;
      _refreshTokenCompleter?.complete(false);
      _refreshTokenCompleter = null;
      return false;
    } catch (e) {
      _isRefreshing = false;
      _refreshTokenCompleter?.complete(false);
      _refreshTokenCompleter = null;
      await RemoteHandlerConfig.onSessionExpired?.call();
      return false;
    }
  }

  static Future<Map<String, String>> _buildHeaders({
    bool useToken = true,
  }) async {
    final token = await RemoteHandlerConfig.tokenProvider?.call() ?? '';
    final extra = await RemoteHandlerConfig.extraHeaders?.call() ?? {};
    return {
      'Content-Type': 'application/json',
      if (useToken && token.isNotEmpty) 'Authorization': 'Bearer $token',
      ...extra,
    };
  }

  static Uri _buildUri(
    String baseUrl,
    String pathUrl,
    Map<String, dynamic>? queryParams,
  ) {
    String normalized = baseUrl.trim();
    if (!normalized.startsWith('http://') &&
        !normalized.startsWith('https://')) {
      normalized = 'https://$normalized';
    }
    final base = Uri.parse(normalized);
    final cleanPath = pathUrl.startsWith('/') ? pathUrl : '/$pathUrl';
    final basePath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;

    Map<String, String>? stringParams;
    if (queryParams != null && queryParams.isNotEmpty) {
      stringParams = {};
      queryParams.forEach((k, v) {
        if (v != null) stringParams![k] = v.toString();
      });
    }

    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: '$basePath$cleanPath',
      queryParameters:
          (stringParams != null && stringParams.isNotEmpty) ? stringParams : null,
    );
  }

  static Future<Response> _callHttp({
    required Client client,
    required Uri uri,
    required Map<String, String> header,
    required HttpMethod method,
    Object? body,
  }) async {
    final encodedBody =
        body != null && method != HttpMethod.get ? jsonEncode(body) : null;

    switch (method) {
      case HttpMethod.get:
        return client.get(uri, headers: header);
      case HttpMethod.post:
        return client.post(uri, headers: header, body: encodedBody);
      case HttpMethod.put:
        return client.put(uri, headers: header, body: encodedBody);
      case HttpMethod.patch:
        return client.patch(uri, headers: header, body: encodedBody);
      case HttpMethod.delete:
        return client.delete(uri, headers: header, body: encodedBody);
    }
  }
}

/// HTTP verbs supported by [RemoteHandler].
enum HttpMethod { get, post, put, patch, delete }

/// Convenience typedef — same as [ResultFuture] but explicit for data layers.
typedef ApiResult<T> = ResultFuture<T>;
