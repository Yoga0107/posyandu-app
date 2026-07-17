import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ApiClient {
  static ApiClient? _instance;
  late Dio _dio;

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.addAll([
      _AuthInterceptor(_dio),
      PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        compact: true,
      ),
    ]);
  }

  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  Dio get dio => _dio;

  // ─── GET ───
  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    return _dio.get(path, queryParameters: params);
  }

  // ─── POST ───
  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post(path, data: data);
  }

  // ─── PUT ───
  Future<Response> put(String path, {dynamic data}) async {
    return _dio.put(path, data: data);
  }

  // ─── PATCH ───
  Future<Response> patch(String path, {dynamic data}) async {
    return _dio.patch(path, data: data);
  }

  // ─── DELETE ───
  Future<Response> delete(String path) async {
    return _dio.delete(path);
  }

  // ─── Upload multipart ───
  Future<Response> upload(String path, FormData formData, {String method = 'POST'}) async {
    if (method == 'PUT') {
      return _dio.put(path, data: formData);
    }
    return _dio.post(path, data: formData);
  }
}

class _AuthInterceptor extends Interceptor {
  final Dio _dio;
  bool _isRefreshing = false;

  _AuthInterceptor(this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final prefs = await SharedPreferences.getInstance();
        final refreshToken = prefs.getString(AppConstants.refreshTokenKey);
        if (refreshToken != null) {
          final response = await _dio.post(
            '/auth/refresh-token',
            data: {'refreshToken': refreshToken},
            options: Options(headers: {'Authorization': null}),
          );
          final newToken = response.data['data']['accessToken'];
          final newRefresh = response.data['data']['refreshToken'];
          await prefs.setString(AppConstants.tokenKey, newToken);
          await prefs.setString(AppConstants.refreshTokenKey, newRefresh);

          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse = await _dio.fetch(err.requestOptions);
          handler.resolve(retryResponse);
          return;
        }
      } catch (_) {
        // Token refresh gagal - clear storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      } finally {
        _isRefreshing = false;
      }
    }
    handler.next(err);
  }
}

// Helper untuk parse error message dari API
String parseApiError(dynamic error) {
  if (error is DioException) {
    if (error.response?.data is Map) {
      return error.response?.data['message'] ?? 'Terjadi kesalahan';
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Koneksi timeout. Periksa jaringan internet Anda';
    }
    if (error.type == DioExceptionType.connectionError) {
      return 'Tidak dapat terhubung ke server';
    }
  }
  return error.toString();
}
