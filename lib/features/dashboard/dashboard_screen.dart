import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api_client.dart';

class DashboardController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  var isLoading = true.obs;
  var userName = ''.obs;
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
      
      // فراخوانی API داشبورد (نیاز به ساخت این هندلر در سمت سرور داریم که در گام بعدی انجام می‌دهیم)
      // در حال حاضر یک درخواست تستی می‌فرستیم که ببینیم توکن کار می‌کند یا خیر
      final formData = {'action': 'get_dashboard_info'};
      
      final response = await _apiClient.dio.post('handler.php', data: formData);
      
      if (response.data['success'] == true) {
        // فرض می‌کنیم سرور نام کاربر را برمی‌گرداند
        userName.value = response.data['data']['username'] ?? 'دلبر جان';
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: controller.logout,
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
                  child: const Text('تلاش مجدد'),
                )
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: primaryPink,
                        child: Icon(Icons.person, size: 40, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'خوش اومدی، ${controller.userName.value} 🌸',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'امکانات شما',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5C3A3A)),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildFeatureCard('خاطرات', Icons.book, () { Get.toNamed('/memories'); }),
                    _buildFeatureCard('صندوقچه امن', Icons.lock, () { /* هدایت به صندوقچه */ }),
                    _buildFeatureCard('رازگو', Icons.message, () { /* هدایت به رازگو */ }),
                    _buildFeatureCard('تنظیمات', Icons.settings, () { /* هدایت به تنظیمات */ }),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: const Color(0xFFF72585)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF5C3A3A))),
          ],
        ),
      ),
    );
  }
}