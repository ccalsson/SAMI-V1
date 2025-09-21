import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../errors/app_error.dart';
import '../logging/app_logger.dart';
import '../security/token_storage.dart';

const _retryKey = 'sami.retry.count';
const _refreshKey = 'sami.refresh.inflight';

/// Contract used by [AppHttpClient] to interact with the auth layer for
/// attaching/refreshing tokens during requests.
abstract class AuthTokenManager {
  Future<AuthTokens?> readTokens();

  Future<bool> refreshToken();

  void handleUnauthorized();
}

class AppHttpClient {
  AppHttpClient({
    required AppConfig config,
    AppLogger logger = AppLogger.instance,
    Duration connectTimeout = const Duration(seconds: 5),
    Duration receiveTimeout = const Duration(seconds: 20),
    int maxRetries = 3,
  })  : _config = config,
        _logger = logger,
        _maxRetries = maxRetries {
    final baseOptions = BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
    dio = Dio(baseOptions);
    _configureInterceptors();
  }

  final AppConfig _config;
  final AppLogger _logger;
  final int _maxRetries;
  AuthTokenManager? _tokenManager;

  late final Dio dio;

  final _metrics = NetworkMetrics();

  NetworkMetrics get metrics => _metrics;

  void attachTokenManager(AuthTokenManager manager) {
    _tokenManager = manager;
  }

  void _configureInterceptors() {
    dio.interceptors.add(QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_tokenManager == null || _config.isDemoMode) {
          handler.next(options);
          return;
        }
        try {
          final tokens = await _tokenManager!.readTokens();
          final token = tokens?.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (error, stackTrace) {
          _logger.warn('Failed to inject token', error, stackTrace);
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (_tokenManager == null || _config.isDemoMode) {
          handler.next(error);
          return;
        }
        if (error.response?.statusCode == 401 &&
            error.requestOptions.extra[_refreshKey] != true) {
          error.requestOptions.extra[_refreshKey] = true;
          final refreshed = await _tokenManager!.refreshToken();
          if (refreshed) {
            try {
              final cloned = _cloneRequest(error.requestOptions);
              final response = await dio.fetch(cloned);
              handler.resolve(response);
              return;
            } catch (retryError, stackTrace) {
              _logger.error('Retry after refresh failed', retryError, stackTrace);
            }
          } else {
            _tokenManager!.handleUnauthorized();
          }
        }
        handler.next(error);
      },
    ));

    dio.interceptors.add(_RetryInterceptor(dio, _maxRetries, _logger));

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (value) => _logger.debug(value.toString()),
      ));
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return _run<T>(
      () => dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _run<T>(
      () => dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
      ),
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _run<T>(
      () => dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _run<T>(
      () => dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<Response<T>> _run<T>(
    Future<Response<T>> Function() call,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await call();
      stopwatch.stop();
      _metrics.recordSuccess(response.requestOptions, stopwatch.elapsed);
      return response;
    } on DioException catch (error) {
      stopwatch.stop();
      _metrics.recordFailure(error.requestOptions, stopwatch.elapsed);
      throw _mapDioError(error);
    }
  }

  AppError _mapDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const AppError(
        AppErrorCode.networkTimeout,
        'La conexión tardó demasiado, por favor intentá nuevamente.',
      );
    }

    if (error.type == DioExceptionType.badCertificate ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown) {
      return AppError(
        AppErrorCode.networkUnreachable,
        'No se pudo conectar con el servidor.',
        cause: error,
      );
    }

    final response = error.response;
    final status = response?.statusCode ?? 0;
    final message = _extractMessage(response?.data) ??
        'Ocurrió un error inesperado. ($status)';

    switch (status) {
      case 401:
        return AppError(AppErrorCode.unauthorized, message, cause: error);
      case 403:
        return AppError(AppErrorCode.forbidden, message, cause: error);
      case 404:
        return AppError(AppErrorCode.notFound, message, cause: error);
      case 409:
      case 422:
        return AppError(AppErrorCode.validation, message, cause: error);
      case 500:
      case 501:
      case 503:
        return AppError(AppErrorCode.serverError, message, cause: error);
      default:
        return AppError(AppErrorCode.unknown, message, cause: error);
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String) {
        return message;
      }
      final error = data['error'];
      if (error is String) {
        return error;
      }
    }
    return null;
  }

  RequestOptions _cloneRequest(RequestOptions options) {
    return RequestOptions(
      path: options.path,
      method: options.method,
      headers: Map<String, dynamic>.from(options.headers),
      data: options.data,
      queryParameters: Map<String, dynamic>.from(options.queryParameters),
      extra: Map<String, dynamic>.from(options.extra),
      baseUrl: options.baseUrl,
      connectTimeout: options.connectTimeout,
      receiveTimeout: options.receiveTimeout,
      sendTimeout: options.sendTimeout,
      responseType: options.responseType,
      contentType: options.contentType,
      followRedirects: options.followRedirects,
      validateStatus: options.validateStatus,
      receiveDataWhenStatusError: options.receiveDataWhenStatusError,
      listFormat: options.listFormat,
      requestEncoder: options.requestEncoder,
      responseDecoder: options.responseDecoder,
    );
  }
}

class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this._dio, this._maxRetries, this._logger);

  final Dio _dio;
  final int _maxRetries;
  final AppLogger _logger;
  final Random _random = Random();

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final shouldRetry = _shouldRetry(err);
    if (!shouldRetry) {
      handler.next(err);
      return;
    }

    final attempt = (err.requestOptions.extra[_retryKey] as int? ?? 0) + 1;
    if (attempt > _maxRetries) {
      handler.next(err);
      return;
    }

    err.requestOptions.extra[_retryKey] = attempt;
    final delay = _computeBackoff(attempt);
    _logger.warn('Retrying request ${err.requestOptions.uri} in $delay');
    await Future<void>.delayed(delay);
    try {
      final response = await _dio.fetch(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (error) {
      handler.next(error);
    }
  }

  bool _shouldRetry(DioException error) {
    if (error.type == DioExceptionType.badResponse) {
      final status = error.response?.statusCode ?? 0;
      return status >= 500;
    }
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout;
  }

  Duration _computeBackoff(int attempt) {
    final base = pow(2, attempt - 1).toInt();
    final jitter = _random.nextInt(400);
    return Duration(milliseconds: base * 500 + jitter);
  }
}

class NetworkMetrics {
  final ValueNotifier<int> _successCount = ValueNotifier<int>(0);
  final ValueNotifier<int> _failureCount = ValueNotifier<int>(0);
  final ValueNotifier<Duration> _lastDuration =
      ValueNotifier<Duration>(Duration.zero);

  ValueListenable<int> get successCount => _successCount;
  ValueListenable<int> get failureCount => _failureCount;
  ValueListenable<Duration> get lastDuration => _lastDuration;

  void recordSuccess(RequestOptions options, Duration duration) {
    _successCount.value++;
    _lastDuration.value = duration;
  }

  void recordFailure(RequestOptions options, Duration duration) {
    _failureCount.value++;
    _lastDuration.value = duration;
  }
}
