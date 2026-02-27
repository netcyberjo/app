import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart'; 
import 'features/memories/memories_screen.dart'; // NEW: اضافه شدن مسیر خاطرات

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // بررسی اینکه آیا کاربر قبلا لاگین کرده است یا خیر
  const storage = FlutterSecureStorage();
  String? token = await storage.read(key: 'api_token');
  String initialRoute = (token != null && token.isNotEmpty) ? '/dashboard' : '/login';

  runApp(DelbarApp(initialRoute: initialRoute));
}

class DelbarApp extends StatelessWidget {
  final String initialRoute;
  
  const DelbarApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'دلبر',
      debugShowCheckedModeBanner: false,
      // تنظیمات راست‌چین کردن کل اپلیکیشن (فارسی)
      locale: const Locale('fa', 'IR'),
      fallbackLocale: const Locale('fa', 'IR'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF72585)),
        useMaterial3: true,
        // اعمال فونت وزیرمتن به کل اپلیکیشن
        textTheme: GoogleFonts.vazirmatnTextTheme(Theme.of(context).textTheme),
      ),
      initialRoute: initialRoute,
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/dashboard', page: () => DashboardScreen()),
        GetPage(name: '/memories', page: () => MemoriesScreen()), // NEW: ثبت روت خاطرات
      ],
    );
  }
}