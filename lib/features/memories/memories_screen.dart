import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/api_client.dart';

class MemoriesController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  var isLoading = true.obs;
  var memories = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMemories();
  }

  Future<void> fetchMemories() async {
    try {
      isLoading(true);
      final response = await _apiClient.dio.post('handler.php', data: {'action': 'get_memories'});
      if (response.data['success'] == true) {
        memories.value = response.data['data'];
      } else {
        Get.snackbar('خطا', response.data['error'] ?? 'خطا در دریافت خاطرات');
      }
    } catch (e) {
      Get.snackbar('خطا', 'مشکل در ارتباط با سرور');
    } finally {
      isLoading(false);
    }
  }
}

class MemoriesScreen extends StatelessWidget {
  final MemoriesController controller = Get.put(MemoriesController());

  MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryPink = Color(0xFFF72585);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        title: const Text('خاطرات من', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryPink,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: primaryPink));
        }

        if (controller.memories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book, size: 80, color: primaryPink.withOpacity(0.3)),
                const SizedBox(height: 16),
                const Text('هنوز خاطره‌ای ثبت نکردی دلبر جان 🌸', style: TextStyle(color: Color(0xFF5C3A3A))),
              ],
            )
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.memories.length,
          itemBuilder: (context, index) {
            final memory = controller.memories[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            memory['title'] ?? 'بدون عنوان', 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF5C3A3A)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(memory['memory_date'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      memory['content'] ?? '',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF745151), height: 1.6),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.snackbar('به زودی', 'امکان افزودن خاطره جدید در مراحل بعد اضافه میشه! 💖', 
              backgroundColor: Colors.white, colorText: primaryPink);
        },
        backgroundColor: primaryPink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}