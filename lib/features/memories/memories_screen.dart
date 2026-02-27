import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio; // جلوگیری از تداخل نام FormData
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
      // فقط زمانی که صفحه بار اول باز می‌شود یا خالی است لودینگ وسط صفحه نشان می‌دهیم
      if (memories.isEmpty) isLoading(true); 
      
      final formData = dio.FormData.fromMap({'action': 'get_memories'});
      final response = await _apiClient.dio.post('app_api.php', data: formData);
      
      if (response.data['success'] == true) {
        memories.value = response.data['data'];
      } else {
        Get.snackbar('خطا', response.data['error'] ?? 'خطا در دریافت خاطرات');
      }
    } catch (e) {
      Get.snackbar('خطا', 'مشکل در ارتباط با سرور 🥺');
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
        if (controller.isLoading.value && controller.memories.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: primaryPink));
        }

        // اضافه شدن قابلیت کشیدن به پایین برای رفرش
        return RefreshIndicator(
          onRefresh: controller.fetchMemories,
          color: primaryPink,
          backgroundColor: Colors.white,
          child: controller.memories.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    Icon(Icons.menu_book, size: 80, color: primaryPink.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    const Text('هنوز خاطره‌ای ثبت نکردی دلبر جان 🌸\n(برای رفرش صفحه رو بکش پایین)', 
                        textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF5C3A3A))),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.memories.length,
                  itemBuilder: (context, index) {
                    final memory = controller.memories[index];
                    
                    return GestureDetector(
                      onTap: () async {
                        // منتظر می‌مانیم تا اگر خاطره در صفحه بعد حذف شد، لیست اینجا هم رفرش شود
                        final result = await Get.toNamed('/memory_detail', arguments: memory);
                        if (result == true) {
                          controller.fetchMemories();
                        }
                      },
                      child: Card(
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
                      ),
                    );
                  },
                ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.toNamed('/add_memory');
          if (result == true) {
            controller.fetchMemories();
          }
        },
        backgroundColor: primaryPink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}