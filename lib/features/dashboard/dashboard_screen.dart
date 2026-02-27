import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api_client.dart';

class DashboardController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  var isLoading = true.obs;
  var userName = ''.obs;
  var profilePic = ''.obs; // NEW: متغیر برای نگهداری آدرس عکس پروفایل
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading(true);
      errorMessage('');
      
      final formData = {'action': 'get_dashboard_info'};
      // ویرایش مهم: درخواست به API اختصاصی موبایل ارسال می‌شود
      final response = await _apiClient.dio.post('app_api.php', data: formData);
      
      if (response.data['success'] == true) {
        userName.value = response.data['data']['username'] ?? 'دلبر جان';
        profilePic.value = response.data['data']['profile_pic'] ?? '';
      } else {
        errorMessage.value = response.data['error'] ?? 'خطا در دریافت اطلاعات';
      }
    } catch (e) {
      errorMessage.value = 'خطای ارتباط با سرور 🥺';
    } finally {
      isLoading(false);
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'api_token');
    Get.offAllNamed('/login');
  }

  // پیام خوش‌آمدگویی هوشمند بر اساس ساعت
  String get greeting {
    var hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'صبح بخیر';
    if (hour >= 12 && hour < 17) return 'ظهر بخیر';
    if (hour >= 17 && hour < 20) return 'عصر بخیر';
    return 'شب بخیر';
  }
}

class DashboardScreen extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());

  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryPink = Color(0xFFF72585);
    const Color lightPink = Color(0xFFFFF0F5);

    return Scaffold(
      backgroundColor: lightPink,
      appBar: AppBar(
        title: const Text('داشبورد دلبر', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryPink,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: controller.logout,
            tooltip: 'خروج',
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: primaryPink));
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMessage.value, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchDashboardData,
                  style: ElevatedButton.styleFrom(backgroundColor: primaryPink),
                  child: const Text('تلاش مجدد', style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchDashboardData,
          color: primaryPink,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // کارت خوش‌آمدگویی و پروفایل
                Card(
                  elevation: 6,
                  shadowColor: primaryPink.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: [Colors.white, lightPink.withOpacity(0.6)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      children: [
                        // نمایش عکس واقعی از سرور
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryPink.withOpacity(0.5), width: 3),
                          ),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white,
                            backgroundImage: controller.profilePic.value.isNotEmpty && !controller.profilePic.value.contains('default-avatar')
                                ? NetworkImage('https://dlbr.ir/${controller.profilePic.value}')
                                : null,
                            child: controller.profilePic.value.isEmpty || controller.profilePic.value.contains('default-avatar')
                                ? const Icon(Icons.person, size: 45, color: primaryPink)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${controller.greeting}، ${controller.userName.value} 🌸',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF5C3A3A)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'آماده‌ای تا امروز رو به یه روز فراموش‌نشدنی تبدیل کنی؟',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                const Row(
                  children: [
                    Icon(Icons.dashboard_customize_rounded, color: primaryPink),
                    SizedBox(width: 8),
                    Text(
                      'امکانات سریع',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5C3A3A)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // گرید امکانات با سایه و طراحی جدید
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildFeatureCard('خاطرات من', Icons.book_rounded, () { Get.toNamed('/memories'); }),
                    _buildFeatureCard('اهداف روزانه', Icons.check_circle_rounded, () { Get.toNamed('/daily'); }),
                    _buildFeatureCard('پیام‌های رازگو', Icons.mark_email_unread_rounded, () { 
                      final mainController = Get.find<GetxController>(tag: 'MainController'); 
                      // برای رفتن به تب رازگو در BottomNav
                    }),
                    _buildFeatureCard('صندوقچه امن', Icons.lock_rounded, () { }),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF0F5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: const Color(0xFFF72585)),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF5C3A3A))),
          ],
        ),
      ),
    );
  }
}