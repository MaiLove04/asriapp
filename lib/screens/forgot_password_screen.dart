import 'package:flutter/material.dart';
import 'services/auth_service.dart';

const primaryColor = Color(0xFF1E521E);
const backgroundColor = Color(0xFFF9FBF9);
const darkTextColor = Color(0xFF0D240D);
const greyTextColor = Color(0xFF555555);

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int currentStep = 1; // 1: Input HP, 2: OTP, 3: Reset Pass
  bool isLoading = false;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  // --- LOGIKA TAHAPAN ---

  void sendOtp() async {
    if (phoneController.text.isEmpty) {
      _showError("Nomor HP tidak boleh kosong");
      return;
    }

    setState(() => isLoading = true);
    try {
      final res = await AuthService.requestOtp(phoneController.text);
      if (res['status'] == 200 || res['status'] == 201) {
        setState(() => currentStep = 2);
      } else {
        _showError(res['data']['message'] ?? "Gagal mengirim OTP");
      }
    } catch (e) {
      _showError("Terjadi kesalahan: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void verifyOtp() async {
    if (otpController.text.length < 4) {
      _showError("Masukkan 4 digit kode OTP");
      return;
    }

    setState(() => isLoading = true);
    try {
      final res = await AuthService.verifyOtp(phoneController.text, otpController.text);
      if (res['status'] == 200 || res['status'] == 201) {
        setState(() => currentStep = 3);
      } else {
        _showError(res['data']['message'] ?? "Kode OTP salah atau kedaluwarsa");
      }
    } catch (e) {
      _showError("Terjadi kesalahan: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void resetPassword() async {
    if (passController.text.length < 6) {
      _showError("Password minimal 6 karakter");
      return;
    }
    if (passController.text != confirmPassController.text) {
      _showError("Konfirmasi password tidak cocok");
      return;
    }

    setState(() => isLoading = true);
    try {
      final res = await AuthService.resetPassword(
        phoneController.text, 
        otpController.text, 
        passController.text
      );
      if (res['status'] == 200 || res['status'] == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Password berhasil diubah! Silakan login."),
              backgroundColor: primaryColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        _showError(res['data']['message'] ?? "Gagal merubah password");
      }
    } catch (e) {
      _showError("Terjadi kesalahan: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg), 
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: darkTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Lupa Password", style: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            if (currentStep == 1) _stepInputPhone(),
            if (currentStep == 2) _stepInputOtp(),
            if (currentStep == 3) _stepResetPassword(),
          ],
        ),
      ),
    );
  }

  // --- WIDGET PER TAHAP ---

  Widget _stepInputPhone() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.message_rounded, size: 64, color: Colors.green),
        ),
        const SizedBox(height: 24),
        const Text("Masukkan Nomor HP", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: darkTextColor)),
        const SizedBox(height: 12),
        const Text(
          "Kami akan mengirimkan kode verifikasi lewat WhatsApp ke nomor Anda.", 
          textAlign: TextAlign.center, 
          style: TextStyle(color: greyTextColor, fontSize: 14, height: 1.5)
        ),
        const SizedBox(height: 32),
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: _inputDeco("Contoh: 081234567890", Icons.phone_android_rounded),
        ),
        const SizedBox(height: 32),
        _btnMain("KIRIM KODE OTP", sendOtp),
      ],
    );
  }

  Widget _stepInputOtp() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.security_rounded, size: 64, color: primaryColor),
        ),
        const SizedBox(height: 24),
        const Text("Verifikasi OTP", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: darkTextColor)),
        const SizedBox(height: 12),
        Text(
          "Masukkan 4 digit kode yang kami kirim ke nomor WhatsApp ${phoneController.text}", 
          textAlign: TextAlign.center, 
          style: const TextStyle(color: greyTextColor, fontSize: 14, height: 1.5)
        ),
        const SizedBox(height: 32),
        TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 15),
          decoration: _inputDeco("----", null),
        ),
        const SizedBox(height: 24),
        _btnMain("VERIFIKASI KODE", verifyOtp),
        TextButton(
          onPressed: isLoading ? null : () => setState(() => currentStep = 1),
          child: const Text("Ganti Nomor HP?", style: TextStyle(color: greyTextColor, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  Widget _stepResetPassword() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.lock_reset_rounded, size: 64, color: primaryColor),
        ),
        const SizedBox(height: 24),
        const Text("Password Baru", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: darkTextColor)),
        const SizedBox(height: 12),
        const Text(
          "Silakan buat password baru yang aman dan mudah diingat.", 
          textAlign: TextAlign.center, 
          style: TextStyle(color: greyTextColor, fontSize: 14, height: 1.5)
        ),
        const SizedBox(height: 32),
        TextField(
          controller: passController, 
          obscureText: true, 
          decoration: _inputDeco("Password Baru", Icons.lock_outline_rounded)
        ),
        const SizedBox(height: 16),
        TextField(
          controller: confirmPassController, 
          obscureText: true, 
          decoration: _inputDeco("Konfirmasi Password", Icons.lock_clock_outlined)
        ),
        const SizedBox(height: 32),
        _btnMain("SIMPAN PASSWORD", resetPassword),
      ],
    );
  }

  // --- STYLING HELPER ---

  InputDecoration _inputDeco(String hint, IconData? icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: icon != null ? Icon(icon, color: primaryColor, size: 22) : null,
      filled: true,
      fillColor: Colors.white,
      counterText: "",
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), 
        borderSide: BorderSide(color: Colors.grey.shade200)
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), 
        borderSide: const BorderSide(color: primaryColor, width: 1.5)
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  Widget _btnMain(String text, VoidCallback onPress) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor, 
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
        ),
        onPressed: isLoading ? null : onPress,
        child: isLoading 
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) 
          : Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15, letterSpacing: 0.5)),
      ),
    );
  }
}