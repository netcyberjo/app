import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api_client.dart';

class AuthController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  var isLoading = false.obs;
  var isLoginMode = true.obs; // NEW:تعیین می‌کند در حالت ورود هستیم یا ثبت‌نام
  var isOtpSent = false.obs;

  // کنترلرهای فرم ثبت‌نام
  final phoneController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();

  // کنترلرهای فرم ورود
  final loginIdentifierController = TextEditingController();
  final loginPasswordController = TextEditingController();

  // جابجایی بین حالت ورود و ثبت‌نام
  void toggleMode() {
    isLoginMode.value = !isLoginMode.value;
    isOtpSent.value = false;
  }

  // --- متد ورود (جدید) ---
  Future<void> login() async {
    if (loginIdentifierController.text.isEmpty || loginPasswordController.text.isEmpty) {
      Get.snackbar('خطا', 'لطفاً نام کاربری و رمز عبور را وارد کنید 🌸', 
          backgroundColor: Colors.redAccent.withOpacity(0.8), colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final formData = dio.FormData.fromMap({
        'action': 'login',
        'login_identifier': loginIdentifierController.text.trim(),
        'password': loginPasswordController.text.trim(),
      });

      final response = await _apiClient.dio.post('auth_handler.php', data: formData);

      if (response.data['success'] == true) {
        String token = response.data['api_token'];
        await _storage.write(key: 'api_token', value: token);
        
        Get.snackbar('خوش اومدی!', response.data['message'], 
            backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white);
            
        Get.offAllNamed('/main');
      } else {
        Get.snackbar('خطا', response.data['error'] ?? 'اطلاعات ورود اشتباه است.', 
            backgroundColor: Colors.redAccent.withOpacity(0.8), colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('خطای شبکه', 'نمی‌تونم به سرور وصل بشم 🥺');
    } finally {
      isLoading.value = false;
    }
  }

  // --- متدهای ثبت‌نام (از قبل موجود) ---
  Future<void> sendOtp() async {
    if (phoneController.text.isEmpty || usernameController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('خطا', 'لطفاً تمامی فیلدها را پر کنید عزیزم 🌸', 
          backgroundColor: Colors.redAccent.withOpacity(0.8), colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final formData = dio.FormData.fromMap({
        'action': 'register_send_otp',
        'phone_number': phoneController.text.trim(),
        'username': usernameController.text.trim(),
        'password': passwordController.text.trim(),
      });

      final response = await _apiClient.dio.post('auth_handler.php', data: formData);
      
      if (response.data['success'] == true) {
        isOtpSent.value = true;
        Get.snackbar('موفق', response.data['message'] ?? 'کد ارسال شد.', 
            backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white);
      } else {
        Get.snackbar('خطا', response.data['error'] ?? 'خطایی رخ داد.', 
            backgroundColor: Colors.redAccent.withOpacity(0.8), colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('خطای شبکه', 'نمی‌تونم به سرور وصل بشم 🥺');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    if (otpController.text.length < 6) {
      Get.snackbar('خطا', 'کد تایید باید ۶ رقم باشه.', 
          backgroundColor: Colors.redAccent.withOpacity(0.8), colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final formData = dio.FormData.fromMap({
        'action': 'register_verify_otp',
        'phone_number': phoneController.text.trim(),
        'otp': otpController.text.trim(),
      });

      final response = await _apiClient.dio.post('auth_handler.php', data: formData);

      if (response.data['success'] == true) {
        String token = response.data['api_token'];
        await _storage.write(key: 'api_token', value: token);
        Get.snackbar('خوش اومدی!', response.data['message'], backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white);
        Get.offAllNamed('/main');
      } else {
        Get.snackbar('خطا', response.data['error'] ?? 'کد اشتباهه.', backgroundColor: Colors.redAccent.withOpacity(0.8), colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('خطای شبکه', 'مشکلی پیش اومده 🥺');
    } finally {
      isLoading.value = false;
    }
  }
}
