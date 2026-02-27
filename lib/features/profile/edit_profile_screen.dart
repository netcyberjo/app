import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api_client.dart';

class EditProfileController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  final ImagePicker _picker = ImagePicker();

  var isLoading = false.obs;
  var selectedImagePath = ''.obs;
  final nameController = TextEditingController();

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (image != null) {
        selectedImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar('خطا', 'مشکل در باز کردن گالری');
    }
  }

  Future<void> saveProfile() async {
    isLoading(true);
    try {
      final formData = FormData.fromMap({
        'action': 'update_profile',
        'full_name': nameController.text.trim(),
      });

      if (selectedImagePath.value.isNotEmpty) {
        formData.files.add(MapEntry(
          'profile_image',
          await MultipartFile.fromFile(selectedImagePath.value, filename: 'profile.jpg'),
        ));
      }

      // استفاده از API اختصاصی جدید اپلیکیشن
      final response = await _apiClient.dio.post('app_api.php', data: formData);

      if (response.data['success'] == true) {
        Get.snackbar('موفق', 'پروفایلت خوشگل‌تر شد 🌸', 
            backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white);
        Get.back(result: true); // بازگشت و ارسال سیگنال رفرش
      } else {
        Get.snackbar('خطا', 'مشکلی پیش اومد.');
      }
    } catch (e) {
      Get.snackbar('خطای شبکه', 'ارتباط با سرور برقرار نشد.');
    } finally {
      isLoading(false);
    }
  }
}

class EditProfileScreen extends StatelessWidget {
  final EditProfileController controller = Get.put(EditProfileController());

  EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryPink = Color(0xFFF72585);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        title: const Text('ویرایش پروفایل', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryPink,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // بخش انتخاب عکس
            Obx(() => GestureDetector(
              onTap: controller.pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: controller.selectedImagePath.value.isNotEmpty
                        ? FileImage(File(controller.selectedImagePath.value))
                        : null,
                    child: controller.selectedImagePath.value.isEmpty
                        ? const Icon(Icons.person, size: 60, color: primaryPink)
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: primaryPink, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 32),
            
            // فیلد نام
            TextField(
              controller: controller.nameController,
              decoration: InputDecoration(
                labelText: 'نام نمایشی شما',
                prefixIcon: const Icon(Icons.badge, color: primaryPink),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 40),

            // دکمه ذخیره
            Obx(() => SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('ذخیره تغییرات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )),
          ],
        ),
      ),
    );
  }
}