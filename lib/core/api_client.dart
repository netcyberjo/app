import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// این کلاس وظیفه ارسال درخواست‌ها به فایل‌های PHP شما را دارد
class ApiClient {
  static const String baseUrl = 'https://dlbr.ir/api/';
  final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient()
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          // این هدر برای تشخیص کلاینت موبایل در سمت سرور مفید است
          headers: {'Accept': 'application/json'}, 
        )),
        _storage = const FlutterSecureStorage() {
    _initializeInterceptors();
  }

  void _initializeInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // در هر درخواست، توکن ذخیره شده را خوانده و به هدر اضافه می‌کند
        final token = await _storage.read(key: 'api_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        // اطمینان از اینکه همه درخواست‌های موبایل فلگ is_mobile را دارند
        if (options.data is FormData) {
          (options.data as FormData).fields.add(const MapEntry('is_mobile', 'true'));
        } else if (options.data is Map<String, dynamic>) {
          options.data['is_mobile'] = 'true';
        }

        return handler.next(options);
      },
    ));
  }

  Dio get dio => _dio;
}