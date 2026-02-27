import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api_client.dart';

class AddMemoryController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  final ImagePicker _picker = ImagePicker();

  var isLoading = false.obs;
  var selectedImagePath = ''.obs;
  var selectedMood = 'happy'.obs; // پیش‌فرض: خوشحال 🥰

  final titleController = TextEditingController();
  final contentController = TextEditingController();

  // لیست مودها
  final List<Map<String, String>> moods = [
    {'value': 'happy', 'emoji': '🥰'},
    {'value': 'sad', 'emoji': '😢'},
    {'value': 'angry', 'emoji': '😡'},
    {'value': 'surprised', 'emoji': '😱'},
    {'value': 'tired', 'emoji': '😴'},
  ];

  // باز کردن گالری و انتخاب عکس
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image != null) {
        selectedImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar('خطا', 'مشکل در باز کردن گالری 🥺');
    }
  }

  // حذف عکس انتخاب شده
  void removeImage() {
    selectedImagePath.value = '';
  }

  // ارسال اطلاعات به سرور
  Future<void> submitMemory() async {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      Get.snackbar('خطا', 'عنوان و متن خاطره رو بنویس دلبر جان 🌸',
          backgroundColor: Colors.redAccent.withOpacity(0.8), colorText: Colors.white);
      return;
    }

    isLoading(true);
    try {
      // ساختار ارسال فایل به سرور
      final formData = FormData.fromMap({
        'action': 'add_memory',
        'title': titleController.text.trim(),
        'content': contentController.text.trim(),
        'mood': selectedMood.value,
        // تاریخ را به صورت خودکار امروز در نظر می‌گیریم
        'memory_date': DateTime.now().toIso8601String().split('T')[0], 
      });

      // اگر عکسی انتخاب شده بود، آن را به فرم اضافه می‌کنیم
      if (selectedImagePath.value.isNotEmpty) {
        formData.files.add(MapEntry(
          'memory_image',
          await MultipartFile.fromFile(selectedImagePath.value, filename: 'memory_image.jpg'),
        ));
      }

      final response = await _apiClient.dio.post('handler.php', data: formData);

      if (response.data['success'] == true) {
        Get.snackbar('موفق', 'خاطره‌ت با موفقیت ثبت شد 💖',
            backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white);
        
        // بازگشت به صفحه قبل و رفرش کردن لیست خاطرات (اگر کنترلرش وجود داشت)
        Get.back(result: true); 
      } else {
        Get.snackbar('خطا', response.data['error'] ?? 'خطا در ثبت خاطره',
            backgroundColor: Colors.redAccent.withOpacity(0.8), colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('خطا', 'مشکل در ارتباط با سرور 🥺');
    } finally {
      isLoading(false);
    }
  }
}

class AddMemoryScreen extends StatelessWidget {
  final AddMemoryController controller = Get.put(AddMemoryController());

  AddMemoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryPink = Color(0xFFF72585);
    const Color lightPink = Color(0xFFFFF0F5);

    return Scaffold(
      backgroundColor: lightPink,
      appBar: AppBar(
        title: const Text('ثبت خاطره جدید', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryPink,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // فیلد عنوان
              TextField(
                controller: controller.titleController,
                decoration: InputDecoration(
                  labelText: 'عنوان خاطره...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              // فیلد متن خاطره
              TextField(
                controller: controller.contentController,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'امروز چی شد؟ برام بنویس...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              // انتخاب مود (احساس)
              const Text('مود امروزت چی بود؟ 🌸', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5C3A3A))),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: controller.moods.map((mood) {
                    bool isSelected = controller.selectedMood.value == mood['value'];
                    return GestureDetector(
                      onTap: () => controller.selectedMood.value = mood['value']!,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(left: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryPink.withOpacity(0.2) : Colors.white,
                          border: Border.all(color: isSelected ? primaryPink : Colors.transparent, width: 2),
                          shape: BoxShape.circle,
                        ),
                        child: Text(mood['emoji']!, style: const TextStyle(fontSize: 24)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // دکمه آپلود عکس
              const Text('یک عکس یادگاری انتخاب کن (اختیاری)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5C3A3A))),
              const SizedBox(height: 10),
              controller.selectedImagePath.value.isEmpty
                  ? GestureDetector(
                      onTap: controller.pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: primaryPink.withOpacity(0.5), style: BorderStyle.solid, width: 2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, color: primaryPink.withOpacity(0.6), size: 40),
                            const SizedBox(height: 8),
                            Text('لمس کن تا عکس انتخاب بشه', style: TextStyle(color: primaryPink.withOpacity(0.6))),
                          ],
                        ),
                      ),
                    )
                  : Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(controller.selectedImagePath.value),
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: controller.removeImage,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.close, color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
              
              const SizedBox(height: 32),

              // دکمه ثبت
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.submitMemory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPink,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('ثبت در دفتر خاطرات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
```

### ۳. اتصال دکمه "افزودن" در صفحه خاطرات
حالا فایل `lib/features/memories/memories_screen.dart` را باز کنید. در پایین فایل، بخش `floatingActionButton` را پیدا کرده و با کد زیر جایگزین کنید (تا با کلیک روی آن به صفحه جدید برویم و پس از برگشت رفرش کنیم):

```dart
// در فایل lib/features/memories/memories_screen.dart (حدود خط 100)
// جایگزین کردن floatingActionButton:

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // رفتن به صفحه افزودن و منتظر ماندن برای نتیجه
          final result = await Get.toNamed('/add_memory');
          // اگر نتیجه true بود (یعنی خاطره ثبت شد)، لیست را دوباره از سرور می‌گیریم
          if (result == true) {
            controller.fetchMemories();
          }
        },
        backgroundColor: primaryPink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
```

### ۴. افزودن مسیر در `main.dart`
در نهایت، باید فایل `lib/main.dart` را باز کرده و مسیر صفحه جدید را به آن معرفی کنید.

ابتدا فایل جدید را در بالای `main.dart` ایمپورت کنید:
```dart
import 'features/memories/add_memory_screen.dart'; // اضافه شود
```

سپس در لیست `getPages`، مسیر مربوطه را اضافه کنید:
```dart
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/main', page: () => MainScreen()),
        GetPage(name: '/memories', page: () => MemoriesScreen()),
        GetPage(name: '/add_memory', page: () => AddMemoryScreen()), // <--- این خط اضافه شود
      ],