import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';

class LoginScreen extends StatelessWidget {
  final AuthController _authController = Get.put(AuthController());

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryPink = Color(0xFFF72585);
    const Color lightPink = Color(0xFFFFF0F5);
    const Color darkText = Color(0xFF5C3A3A);

    return Scaffold(
      backgroundColor: lightPink,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Obx(() => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_rounded, size: 80, color: primaryPink),
                const SizedBox(height: 16),
                const Text('دلبر', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: darkText)),
                Text(
                  _authController.isLoginMode.value ? 'خوش برگشتی دلبر جان 🌸' : 'اینجا زمان می‌ایستد...',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // کادر اصلی فرم‌ها
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: primaryPink.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  // جابجایی انیمیشنی بین فرم ورود و ثبت‌نام
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _authController.isLoginMode.value
                        ? _buildLoginView(primaryPink)
                        : (!_authController.isOtpSent.value ? _buildRegisterStep1(primaryPink) : _buildRegisterStep2(primaryPink)),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // دکمه تغییر حالت (ورود / ثبت‌نام)
                TextButton(
                  onPressed: _authController.toggleMode,
                  child: Text(
                    _authController.isLoginMode.value 
                        ? 'حساب کاربری نداری؟ اینجا ثبت‌نام کن 💖' 
                        : 'قبلاً ثبت‌نام کردی؟ وارد شو 🌸',
                    style: const TextStyle(color: primaryPink, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                )
              ],
            )),
          ),
        ),
      ),
    );
  }

  // --- نمای ورود (Login) ---
  Widget _buildLoginView(Color primaryPink) {
    return Column(
      key: const ValueKey('loginView'),
      children: [
        _buildTextField(_authController.loginIdentifierController, 'نام کاربری یا موبایل', Icons.person, TextInputType.text),
        const SizedBox(height: 16),
        _buildTextField(_authController.loginPasswordController, 'رمز عبور', Icons.lock, TextInputType.visiblePassword, isObscure: true),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _authController.isLoading.value ? null : _authController.login,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPink,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _authController.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('ورود به دلبر', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // --- نمای ثبت نام (Register Step 1) ---
  Widget _buildRegisterStep1(Color primaryPink) {
    return Column(
      key: const ValueKey('registerStep1'),
      children: [
        _buildTextField(_authController.phoneController, 'شماره موبایل', Icons.phone_android, TextInputType.phone),
        const SizedBox(height: 16),
        _buildTextField(_authController.usernameController, 'نام کاربری (انگلیسی)', Icons.alternate_email, TextInputType.text),
        const SizedBox(height: 16),
        _buildTextField(_authController.passwordController, 'رمز عبور', Icons.lock, TextInputType.visiblePassword, isObscure: true),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _authController.isLoading.value ? null : _authController.sendOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPink,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _authController.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('شروع داستان', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // --- نمای تایید کد (Register Step 2) ---
  Widget _buildRegisterStep2(Color primaryPink) {
    return Column(
      key: const ValueKey('registerStep2'),
      children: [
        const Text('کد تایید برای شما پیامک شد 💌', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildTextField(_authController.otpController, 'کد ۶ رقمی', Icons.message, TextInputType.number),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _authController.isLoading.value ? null : _authController.verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPink,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _authController.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('تایید و ورود', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
        TextButton(
          onPressed: () => _authController.isOtpSent.value = false,
          child: const Text('ویرایش شماره موبایل', style: TextStyle(color: Colors.grey)),
        )
      ],
    );
  }

  // متد کمکی برای ساخت فیلدهای متنی
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, TextInputType type, {bool isObscure = false}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFF72585).withOpacity(0.5)),
        filled: true,
        fillColor: const Color(0xFFFFF0F5).withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}