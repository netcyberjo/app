import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/api_client.dart';
import 'package:dio/dio.dart' as dio;

class RazgoController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  var isLoading = true.obs;
  var messages = [].obs;
  var nickname = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    try {
      isLoading(true);
      final formData = dio.FormData.fromMap({'action': 'get_razgo_messages'});
      final response = await _apiClient.dio.post('handler.php', data: formData);
      
      if (response.data['success'] == true) {
        messages.value = response.data['data'];
        nickname.value = response.data['nickname'] ?? 'ناشناس';
      }
    } catch (e) {
      Get.snackbar('خطا', 'مشکل در دریافت پیام‌های رازگو 🥺');
    } finally {
      isLoading(false);
    }
  }
}

class RazgoScreen extends StatelessWidget {
  final RazgoController controller = Get.put(RazgoController());

  RazgoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryPink = Color(0xFFF72585);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        title: const Text('پیام‌های رازگو 💌', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryPink,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: primaryPink));
        }

        if (controller.messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mail_outline, size: 80, color: primaryPink.withOpacity(0.3)),
                const SizedBox(height: 16),
                const Text('هنوز هیچ پیام ناشناسی برات نیومده دلبر جان 🌸', style: TextStyle(color: Color(0xFF5C3A3A))),
              ],
            )
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.messages.length,
          itemBuilder: (context, index) {
            final msg = controller.messages[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('فرستنده: ${controller.nickname.value}', style: const TextStyle(fontWeight: FontWeight.bold, color: primaryPink)),
                        Text(msg['created_at'].toString().substring(0, 10), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(msg['message_text'] ?? '', style: const TextStyle(color: Color(0xFF5C3A3A), height: 1.5)),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}