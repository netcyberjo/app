import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import '../../core/api_client.dart';

class DailyController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  var isLoading = true.obs;
  var goals = [].obs;
  var notes = [].obs;

  final goalController = TextEditingController();
  final noteController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchDailyData();
  }

  Future<void> fetchDailyData() async {
    try {
      isLoading(true);
      final formData = dio.FormData.fromMap({'action': 'get_daily_features'});
      final response = await _apiClient.dio.post('app_api.php', data: formData);

      if (response.data['success'] == true) {
        goals.value = response.data['data']['goals'] ?? [];
        notes.value = response.data['data']['notes'] ?? [];
      }
    } catch (e) {
      Get.snackbar('خطا', 'مشکل در دریافت اطلاعات روزانه 🥺');
    } finally {
      isLoading(false);
    }
  }

  // --- مدیریت اهداف ---
  Future<void> addGoal() async {
    if (goalController.text.isEmpty) return;
    try {
      final formData = dio.FormData.fromMap({'action': 'add_goal', 'goal_text': goalController.text.trim()});
      final res = await _apiClient.dio.post('app_api.php', data: formData);
      if (res.data['success'] == true) {
        goalController.clear();
        fetchDailyData();
      }
    } catch (e) {}
  }

  Future<void> toggleGoal(int id) async {
    try {
      final formData = dio.FormData.fromMap({'action': 'toggle_goal', 'id': id, 'goal_id': id});
      await _apiClient.dio.post('app_api.php', data: formData);
      fetchDailyData();
    } catch (e) {}
  }

  Future<void> deleteGoal(int id) async {
    try {
      final formData = dio.FormData.fromMap({'action': 'delete_goal', 'id': id, 'goal_id': id});
      await _apiClient.dio.post('app_api.php', data: formData);
      fetchDailyData();
    } catch (e) {}
  }

  // --- مدیریت شکرگزاری ---
  Future<void> addNote() async {
    if (noteController.text.isEmpty) return;
    try {
      final formData = dio.FormData.fromMap({'action': 'add_appreciation_note', 'note_text': noteController.text.trim()});
      final res = await _apiClient.dio.post('app_api.php', data: formData);
      if (res.data['success'] == true) {
        noteController.clear();
        fetchDailyData();
      }
    } catch (e) {}
  }
}

class DailyScreen extends StatelessWidget {
  final DailyController controller = Get.put(DailyController());

  DailyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryPink = Color(0xFFF72585);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        title: const Text('اهداف و شکرگزاری', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryPink,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.goals.isEmpty && controller.notes.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: primaryPink));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ====== بخش اهداف روزانه ======
              const Row(
                children: [
                  Icon(Icons.check_circle, color: primaryPink),
                  SizedBox(width: 8),
                  Text('اهداف امروز من', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5C3A3A))),
                ],
              ),
              const SizedBox(height: 12),
              
              // لیست اهداف
              ...controller.goals.map((goal) {
                bool isCompleted = goal['is_completed'] == 1 || goal['is_completed'] == '1';
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Checkbox(
                      value: isCompleted,
                      activeColor: primaryPink,
                      onChanged: (val) => controller.toggleGoal(int.parse(goal['id'].toString())),
                    ),
                    title: Text(
                      goal['goal_text'],
                      style: TextStyle(
                        decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                        color: isCompleted ? Colors.grey : Colors.black87,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => controller.deleteGoal(int.parse(goal['id'].toString())),
                    ),
                  ),
                );
              }),

              // فیلد افزودن هدف
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.goalController,
                      decoration: InputDecoration(
                        hintText: 'یک هدف جدید بنویس...',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: primaryPink,
                    radius: 24,
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: controller.addGoal,
                    ),
                  )
                ],
              ),

              const Divider(height: 48, thickness: 2, color: Colors.white),

              // ====== بخش شکرگزاری ======
              const Row(
                children: [
                  Icon(Icons.favorite, color: primaryPink),
                  SizedBox(width: 8),
                  Text('امروز برای چی شکرگزاری؟', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5C3A3A))),
                ],
              ),
              const SizedBox(height: 12),

               // لیست شکرگزاری‌ها
              ...controller.notes.map((note) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: primaryPink.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('✨', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(note['note_text'], style: const TextStyle(color: Color(0xFF5C3A3A)))),
                      ],
                    ),
                  ),
                );
              }),

              // فیلد افزودن شکرگزاری
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.noteController,
                      decoration: InputDecoration(
                        hintText: 'خدایا شکرت برای...',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: primaryPink,
                    radius: 24,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: controller.addNote,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }
}