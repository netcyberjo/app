import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import '../../core/api_client.dart';

class MemoryDetailController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  var isDeleting = false.obs;

  Future<void> deleteMemory(int memoryId) async {
    Get.defaultDialog(
      title: 'حذف خاطره',
      middleText: 'آیا از حذف این خاطره مطمئن هستی؟ 🥺 این کار قابل بازگشت نیست.',
      textConfirm: 'بله، حذف کن',
      textCancel: 'نه، منصرف شدم',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      cancelTextColor: const Color(0xFF5C3A3A),
      onConfirm: () async {
        Get.back(); // بستن دیالوگ
        isDeleting(true);
        try {
          final formData = dio.FormData.fromMap({
            'action': 'delete_memory',
            'memory_id': memoryId,
            'id': memoryId, // برای اطمینان از سازگاری با API شما
          });
          final response = await _apiClient.dio.post('handler.php', data: formData);
          
          if (response.data['success'] == true) {
            Get.snackbar('موفق', 'خاطره با موفقیت پاک شد 🗑️', 
                backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white);
            Get.back(result: true); // بازگشت به صفحه قبل و ارسال سیگنال برای رفرش
          } else {
            Get.snackbar('خطا', response.data['error'] ?? 'خطا در حذف خاطره');
          }
        } catch (e) {
          Get.snackbar('خطا', 'مشکل در ارتباط با سرور');
        } finally {
          isDeleting(false);
        }
      }
    );
  }
}

class MemoryDetailScreen extends StatelessWidget {
  final MemoryDetailController controller = Get.put(MemoryDetailController());

  MemoryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final memory = Get.arguments ?? {};
    const Color primaryPink = Color(0xFFF72585);
    const Color lightPink = Color(0xFFFFF0F5);

    String getMoodEmoji(String? mood) {
      switch (mood) {
        case 'happy': return '🥰';
        case 'sad': return '😢';
        case 'angry': return '😡';
        case 'surprised': return '😱';
        case 'tired': return '😴';
        default: return '🌸';
      }
    }

    return Scaffold(
      backgroundColor: lightPink,
      appBar: AppBar(
        title: const Text('خاطره من', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryPink,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          // دکمه سطل زباله
          Obx(() => controller.isDeleting.value 
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
              )
            : IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  if (memory['id'] != null) {
                    controller.deleteMemory(int.parse(memory['id'].toString()));
                  }
                },
              )
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: primaryPink.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      memory['title'] ?? 'بدون عنوان',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF5C3A3A)),
                    ),
                  ),
                  Text(getMoodEmoji(memory['mood']), style: const TextStyle(fontSize: 32)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(memory['memory_date'] ?? 'تاریخ نامشخص', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              const Divider(height: 32, color: lightPink, thickness: 2),
              Text(
                memory['content'] ?? 'متنی برای این خاطره ثبت نشده است.',
                style: const TextStyle(fontSize: 16, color: Color(0xFF5C3A3A), height: 1.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}