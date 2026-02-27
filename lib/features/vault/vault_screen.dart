import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/api_client.dart';
import 'package:dio/dio.dart' as dio;

class VaultController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  var isLoading = false.obs;
  var isUnlocked = false.obs;
  var vaultMemories = [].obs;
  
  final passwordController = TextEditingController();

  Future<void> unlockVault() async {
    if (passwordController.text.isEmpty) {
      Get.snackbar('خطا', 'رمز عبور رو وارد کن عزیزم 🌸', backgroundColor: Colors.redAccent.withOpacity(0.8), colorText: Colors.white);
      return;
    }

    isLoading(true);
    try {
      final formData = dio.FormData.fromMap({
        'action': 'unlock_vault_mobile',
        'vault_password': passwordController.text.trim()
      });
      final response = await _apiClient.dio.post('handler.php', data: formData);
      
      if (response.data['success'] == true) {
        vaultMemories.value = response.data['data'];
        isUnlocked(true);
        passwordController.clear();
      } else {
         Get.snackbar('خطا', response.data['error'], backgroundColor: Colors.redAccent.withOpacity(0.8), colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('خطا', 'مشکل در باز کردن صندوقچه 🥺');
    } finally {
      isLoading(false);
    }
  }

  void lockVault() {
    isUnlocked(false);
    vaultMemories.clear();
  }
}

class VaultScreen extends StatelessWidget {
  final VaultController controller = Get.put(VaultController());

  VaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4A00E0); // رنگ متفاوت برای صندوقچه (بنفش تیره)

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('صندوقچه امن 🔒', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        centerTitle: true,
        actions: [
          Obx(() => controller.isUnlocked.value 
            ? IconButton(icon: const Icon(Icons.lock_outline, color: Colors.white), onPressed: controller.lockVault)
            : const SizedBox.shrink()
          )
        ],
      ),
      body: Obx(() {
        if (!controller.isUnlocked.value) {
          return _buildLockScreen(primaryColor);
        }
        return _buildVaultContent(primaryColor);
      }),
    );
  }

  Widget _buildLockScreen(Color primaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 80, color: primaryColor),
            const SizedBox(height: 24),
            const Text('اینجا امن‌ترین جای دنیاست...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            const Text('برای مشاهده خاطراتت، کلید صندوقچه رو وارد کن.', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            TextField(
              controller: controller.passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'رمز صندوقچه',
                prefixIcon: Icon(Icons.vpn_key, color: primaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.unlockVault,
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('باز کردن قفل', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaultContent(Color primaryColor) {
    if (controller.vaultMemories.isEmpty) {
      return const Center(child: Text('صندوقچه شما خالیه 🌸', style: TextStyle(fontSize: 16)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.vaultMemories.length,
      itemBuilder: (context, index) {
        final item = controller.vaultMemories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.black87, // بک‌گراند تیره برای خاطرات امن
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title'] ?? '', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                Text(item['content'] ?? '', style: const TextStyle(color: Colors.white, height: 1.6)),
              ],
            ),
          ),
        );
      },
    );
  }
}