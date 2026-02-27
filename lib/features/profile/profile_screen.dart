import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api_client.dart';
import 'package:dio/dio.dart' as dio;

class ProfileController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  var isLoading = true.obs;
  var username = ''.obs;
  var isOfflineMode = false.obs; // متغیر تشخیص حالت آفلاین

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading(true);
      
      // ۱. بررسی توکن برای نمایش برچسب آفلاین در UI و محدود کردن کلیک‌ها
      String? token = await _storage.read(key: 'api_token');
      isOfflineMode.value = (token == 'offline_admin_token');

      // ۲. درخواست به سرور (اگر آفلاین باشیم، ApiClient خودش این درخواست را به فایل محلی می‌فرستد!)
      final formData = dio.FormData.fromMap({'action': 'get_dashboard_info'});
      final response = await _apiClient.dio.post('app_api.php', data: formData);
      
      if (response.data['success'] == true) {
        username.value = response.data['data']['username'] ?? 'دلبر';
      }
    } catch (e) {
      // خطا در پس‌زمینه نادیده گرفته می‌شود
    } finally {
      isLoading(false);
    }
  }

  void copyRazgoLink() {
    if (isOfflineMode.value) {
      Get.snackbar('حالت آفلاین', 'در حالت تستی امکان کپی لینک وجود ندارد.', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    if (username.value.isNotEmpty) {
      final link = "https://dlbr.ir/razgo.php?u=${username.value}";
      Clipboard.setData(ClipboardData(text: link));
      Get.snackbar('کپی شد!', 'لینک پیام ناشناس شما کپی شد. حالا می‌تونی توی اینستاگرام یا تلگرام قرارش بدی 💌', 
          backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white, duration: const Duration(seconds: 4));
    }
  }

  Future<void> logout() async {
    Get.defaultDialog(
      title: 'خروج از حساب',
      middleText: 'آیا مطمئنی می‌خوای از حساب کاربریت خارج بشی؟ 🥺',
      textConfirm: 'بله، خارج میشم',
      textCancel: 'نه، می‌مونم',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFF72585),
      cancelTextColor: const Color(0xFF5C3A3A),
      onConfirm: () async {
        await _storage.delete(key: 'api_token');
        Get.offAllNamed('/login');
      }
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryPink = Color(0xFFF72585);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        title: const Text('پروفایل من', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryPink,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: primaryPink,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Obx(() => Text(
              controller.isLoading.value ? 'در حال بارگذاری...' : '@${controller.username.value}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF5C3A3A)),
            )),
            
            // نمایش برچسب در صورت فعال بودن حالت آفلاین
            Obx(() => controller.isOfflineMode.value 
              ? Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.orange.shade700, borderRadius: BorderRadius.circular(12)),
                  child: const Text('حالت آزمایشی (آفلاین)', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                )
              : const SizedBox.shrink()
            ),

            const SizedBox(height: 40),
            
            // دکمه ویرایش
            ListTile(
              onTap: () async {
                if (controller.isOfflineMode.value) {
                  Get.snackbar('حالت آفلاین', 'در این حالت نمیشه پروفایل رو ویرایش کرد.', backgroundColor: Colors.orange, colorText: Colors.white);
                  return;
                }
                final result = await Get.toNamed('/edit_profile');
                if (result == true) controller.fetchProfile();
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: Colors.white,
              leading: const Icon(Icons.edit, color: primaryPink),
              title: const Text('ویرایش اطلاعات و عکس', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // دکمه کپی لینک
            ListTile(
              onTap: controller.copyRazgoLink,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: Colors.white,
              leading: const Icon(Icons.link, color: primaryPink),
              title: const Text('کپی لینک پیام ناشناس (رازگو)', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.copy, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // دکمه خروج
            ListTile(
              onTap: controller.logout,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: Colors.white,
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('خروج از حساب کاربری', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );
  }
}