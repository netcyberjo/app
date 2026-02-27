import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'features/auth/login_screen.dart';
import 'features/main_layout/main_screen.dart'; // اضافه شدن فایل جدید

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  const storage = FlutterSecureStorage();
  String? token = await storage.read(key: 'api_token');
  
  // اگر توکن داشتیم، میره به صفحه اصلی (که منوی پایین داره)
  String initialRoute = (token != null && token.isNotEmpty) ? '/main' : '/login';

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
      locale: const Locale('fa', 'IR'),
      fallbackLocale: const Locale('fa', 'IR'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF72585)),
        useMaterial3: true,
        textTheme: GoogleFonts.vazirmatnTextTheme(Theme.of(context).textTheme),
      ),
      initialRoute: initialRoute,
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/main', page: () => MainScreen()), // روت جدید و اصلی برنامه
      ],
    );
  }
}