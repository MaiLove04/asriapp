import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'services/register_service.dart';
import 'login_screen.dart';

// Konsistensi palet warna ASRI
const primaryColor = Color(0xFF2F6B2F);
const secondaryColor = Color(0xFF58C063);
const backgroundColor = Color(0xFFF4F7F5);
const darkTextColor = Color(0xFF1A301A);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  int? selectedBankId;
  File? selectedImage;
  bool isLoading = false;
  bool isObscure = true;
  bool isObscureConfirm = true;

  // ================= FOTO =================
  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() {
      selectedImage = File(picked.path);
    });
  }

  // ================= REGISTER =================
  Future<void> register() async {
    if (selectedBankId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih bank sampah')),
      );
      return;
    }

    setState(() { isLoading = true; });

    try {
      final result = await RegisterService.register(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
        phone: phoneController.text,
        address: addressController.text,
        bankSampahId: selectedBankId!,
        foto: selectedImage,
      );

      final status = result['status'];
      final data = result['data'];

      if (status == 200 || status == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Registrasi gagal')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }

    if (!mounted) return;
    setState(() { isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // 🎨 DEKORASI BACKGROUND
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: secondaryColor.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.06),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // 🔥 HEADER LOGO & BRANDING
                  Hero(
                    tag: 'logo_asri',
                    child: Image.asset(
                      "assets/images/logo_asri.png",
                      width: 90,
                      height: 90,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Buat Akun ASRI",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900, // Greget tebal
                      color: darkTextColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Bergabunglah untuk lingkungan yang lebih bersih",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 30),

                  // 🔥 GLASSMORPHISM CARD
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // ================= PICKER FOTO MODEREN =================
                          GestureDetector(
                            onTap: pickImage,
                            child: Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: primaryColor.withOpacity(0.2), width: 2),
                                  ),
                                  child: CircleAvatar(
                                    radius: 45,
                                    backgroundColor: backgroundColor,
                                    backgroundImage: selectedImage != null ? FileImage(selectedImage!) : null,
                                    child: selectedImage == null
                                        ? const Icon(Icons.person_add_alt_1_rounded, size: 35, color: primaryColor)
                                        : null,
                                  ),
                                ),
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                                    child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),

                          _buildInput(
                            controller: nameController,
                            hint: 'Nama Lengkap',
                            icon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 16),

                          _buildInput(
                            controller: emailController,
                            hint: 'Email',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          _buildInput(
                            controller: passwordController,
                            hint: 'Password',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            obscureVar: isObscure,
                            onToggle: () => setState(() => isObscure = !isObscure),
                          ),
                          const SizedBox(height: 16),

                          _buildInput(
                            controller: confirmPasswordController,
                            hint: 'Konfirmasi Password',
                            icon: Icons.lock_reset_rounded,
                            isPassword: true,
                            obscureVar: isObscureConfirm,
                            onToggle: () => setState(() => isObscureConfirm = !isObscureConfirm),
                          ),
                          const SizedBox(height: 16),

                          _buildInput(
                            controller: phoneController,
                            hint: 'No HP',
                            icon: Icons.phone_android_rounded,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),

                          _buildInput(
                            controller: addressController,
                            hint: 'Alamat Lengkap',
                            icon: Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 16),

                          // ================= BANK DROPDOWN ESTETIK =================
                          DropdownButtonFormField<int>(
                            value: selectedBankId,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor),
                            dropdownColor: Colors.white,
                            style: const TextStyle(color: darkTextColor, fontSize: 15),
                            decoration: InputDecoration(
                              hintText: 'Pilih Bank Sampah',
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                              prefixIcon: const Icon(Icons.account_balance_rounded, color: primaryColor, size: 22),
                              filled: true,
                              fillColor: backgroundColor.withOpacity(0.5),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: primaryColor, width: 1.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                            ),
                            items: const [
                              DropdownMenuItem(value: 1, child: Text('Basayan Bestari')),
                              DropdownMenuItem(value: 2, child: Text('Asri Mandiri')),
                            ],
                            onChanged: (value) => setState(() => selectedBankId = value),
                          ),
                          const SizedBox(height: 32),

                          // ================= BUTTON REGISTER GRADIENT =================
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [primaryColor, secondaryColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: isLoading ? null : () {
                                if (_formKey.currentState!.validate()) register();
                              },
                              child: isLoading
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text(
                                'Daftar Sekarang',
                                style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // NAVIGASI BALIK KE LOGIN
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: RichText(
                      text: const TextSpan(
                        text: "Sudah punya akun? ",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                        children: [
                          TextSpan(
                            text: "Login",
                            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= INPUT FIELD REUSABLE =================
  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool? obscureVar,
    VoidCallback? onToggle,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? (obscureVar ?? true) : false,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, color: primaryColor, size: 22),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(obscureVar! ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey, size: 20),
          onPressed: onToggle,
        )
            : null,
        filled: true,
        fillColor: backgroundColor.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return '$hint tidak boleh kosong';
        if (hint == 'Email' && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Format email tidak valid';
        if (hint == 'Password' && value.length < 6) return 'Password minimal 6 karakter';
        if (hint == 'Konfirmasi Password' && value != passwordController.text) return 'Password tidak sama';
        if (hint == 'No HP' && value.length < 10) return 'No HP tidak valid';
        return null;
      },
    );
  }
}