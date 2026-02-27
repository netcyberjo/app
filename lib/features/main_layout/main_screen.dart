import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../dashboard/dashboard_screen.dart';
import '../memories/memories_screen.dart';
import '../razgo/razgo_screen.dart';
import '../vault/vault_screen.dart'; // از صندوقچه به جای پروفایل فعلاً استفاده می‌کنیم

class MainController extends GetxController {
  // این متغیر تب فعلی را نگه می‌دارد (پیش‌فرض 0 یعنی داشبورد)
  var currentIndex = 0.obs;

  // لیست صفحاتی که در منوی پایین نمایش داده می‌شوند
  final List<Widget> pages = [
    DashboardScreen(),
    MemoriesScreen(),
    RazgoScreen(), // جایگزین شد
    VaultScreen(), // جایگزین شد (آیکون پروفایل فعلاً صندوقچه را باز می‌کند)
  ];

  void changePage(int index) {
    currentIndex.value = index;
  }
}

class MainScreen extends StatelessWidget {
  final MainController controller = Get.put(MainController());

  MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryPink = Color(0xFFF72585);

    return Scaffold(
      // بدنه اصلی که بر اساس تب انتخاب شده تغییر می‌کند
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: controller.pages,
      )),
      
      // منوی ناوبری پایین
      bottomNavigationBar: Obx(() => Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
          selectedItemColor: primaryPink,
          unselectedItemColor: Colors.grey.shade400,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'خانه'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'خاطرات'),
            BottomNavigationBarItem(icon: Icon(Icons.mail_rounded), label: 'رازگو'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'پروفایل'),
          ],
        ),
      )),
    );
  }
}