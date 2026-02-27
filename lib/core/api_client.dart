import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'mock_api_handler.dart'; // اضافه کردن فایل دیتای آفلاین

class ApiClient {
  static const String baseUrl = 'https://dlbr.ir/api/';
  final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient()
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Accept': 'application/json'}, 
        )),
        _storage = const FlutterSecureStorage() {
    _initializeInterceptors();
  }

  void _initializeInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'api_token');
        
        // =======================================================
        // سیستم هوشمند رهگیری حالت آفلاین (Offline Mocking)
        // =======================================================
        if (token == 'offline_admin_token') {
          String action = '';
          
          // پیدا کردن نام اکشن از داخل اطلاعات ارسال شده
          if (options.data is FormData) {
            final formData = options.data as FormData;
            final actionField = formData.fields.firstWhere(
                (e) => e.key == 'action', 
                orElse: () => const MapEntry('action', ''));
            action = actionField.value;
          } else if (options.data is Map) {
            action = options.data['action'] ?? '';
          }

          // دریافت پاسخ از فایل محلی به جای اینترنت
          final mockResponse = await MockApiHandler.getResponse(action, options.data);
          
          // تولید یک پاسخ موفقیت‌آمیز مجازی و بازگرداندن آن به صفحه بدون اتصال به اینترنت!
          return handler.resolve(Response(
            requestOptions: options,
            data: mockResponse,
            statusCode: 200,
          ));
        }
        // =======================================================

        // اگر توکن عادی بود، روند طبیعی ادامه پیدا می‌کند
        if (token != null && token != 'offline_admin_token') {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
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