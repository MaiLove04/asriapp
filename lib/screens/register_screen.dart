import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'services/register_service.dart';
import 'login_screen.dart';
import 'models/bank_sampah_model.dart';

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
  bool isFetchingBank = true;

  List<BankSampahModel> listBank = [];

  @override
  void initState() {
    super.initState();
    fetchBankSampah();
  }

  Future<void> fetchBankSampah() async {
    setState(() => isFetchingBank = true);
    try {
      final data = await RegisterService.getBankSampah();
      setState(() {
        listBank = data;
        // 🚀 FALLBACK: Jika data dari API kosong, masukkan data manual agar user tetap bisa daftar
        if (listBank.isEmpty) {
          listBank.add(BankSampahModel(id: 1, nama: "Basayan Bestari"));
        }
        isFetchingBank = false;
      });
    } catch (e) {
      debugPrint("Error fetching bank sampah: $e");
      setState(() {
        // 🚀 FALLBACK: Jika terjadi error koneksi, tetap beri pilihan manual
        if (listBank.isEmpty) {
          listBank.add(BankSampahModel(id: 1, nama: "Basayan Bestari"));
        }
        isFetchingBank = false;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  // ================= FOTO =================
  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() {
      selectedImage = File(picked.path);
    });
  }

  // ================= POP UP NOTIFIKASI TUNGGU ADMIN =================
  void _showPendingApprovalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Pengguna wajib klik tombol di dalam pop-up
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              // Icon Animatif atau Estetik
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_clock_rounded,
                  size: 50,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Registrasi Berhasil!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkTextColor,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Akun Anda telah terdaftar. Silakan menunggu persetujuan (approval) dari Admin ASRI terlebih dahulu sebelum bisa masuk ke aplikasi.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              // Tombol Konfirmasi Selesai
              Container(
                width: double.infinity,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [primaryColor, secondaryColor],
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // Tutup dialog
                    Navigator.pop(context);
                    // Pindah ke Halaman Login
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Mengerti',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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

        // Panggil fungsi pop-up kustom di sini
        _showPendingApprovalDialog();

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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "Buat Akun ASRI",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: darkTextColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Bergabunglah untuk lingkungan yang lebih bersih",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // 🔥 CARD FORM
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
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
                          // ================= PICKER FOTO =================
                          GestureDetector(
                            onTap: pickImage,
                            child: Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: primaryColor.withOpacity(0.2), width: 2),
                                  ),
                                  child: CircleAvatar(
                                    radius: 38,
                                    backgroundColor: backgroundColor,
                                    backgroundImage: selectedImage != null ? FileImage(selectedImage!) : null,
                                    child: selectedImage == null
                                        ? const Icon(Icons.person_add_alt_1_rounded, size: 28, color: primaryColor)
                                        : null,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                                    child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          _buildInput(
                            controller: nameController,
                            hint: 'Nama Lengkap',
                            icon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 12),

                          _buildInput(
                            controller: emailController,
                            hint: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),

                          _buildInput(
                            controller: passwordController,
                            hint: 'Password',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            obscureVar: isObscure,
                            onToggle: () => setState(() => isObscure = !isObscure),
                          ),
                          const SizedBox(height: 12),

                          _buildInput(
                            controller: confirmPasswordController,
                            hint: 'Konfirmasi Password',
                            icon: Icons.lock_reset_rounded,
                            isPassword: true,
                            obscureVar: isObscureConfirm,
                            onToggle: () => setState(() => isObscureConfirm = !isObscureConfirm),
                          ),
                          const SizedBox(height: 12),

                          _buildInput(
                            controller: phoneController,
                            hint: 'No HP',
                            icon: Icons.phone_android_rounded,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),

                          _buildInput(
                            controller: addressController,
                            hint: 'Alamat Lengkap',
                            icon: Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 12),

                          // ================= BANK DROPDOWN (FIXED) =================
                          DropdownButtonFormField<int>(
                            value: selectedBankId,
                            icon: const Icon(Icons.expand_more_rounded, color: primaryColor, size: 24),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            style: const TextStyle(color: darkTextColor, fontSize: 14, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              hintText: isFetchingBank
                                  ? 'Memuat Bank Sampah...'
                                  : (listBank.isEmpty ? 'Gagal memuat / Data kosong' : 'Pilih Bank Sampah'),
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.normal),
                              prefixIcon: isFetchingBank
                                  ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor)
                                ),
                              )
                                  : const Icon(Icons.account_balance_rounded, color: primaryColor, size: 20),
                              suffixIcon: (!isFetchingBank && listBank.isEmpty)
                                  ? IconButton(
                                icon: const Icon(Icons.refresh, color: primaryColor, size: 20),
                                onPressed: fetchBankSampah,
                              )
                                  : null,
                              filled: true,
                              fillColor: backgroundColor.withOpacity(0.5),
                              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: Colors.grey.withOpacity(0.12)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: primaryColor, width: 1.5),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Colors.redAccent, width: 1),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                              ),
                            ),
                            // PENGAMAN: Jika data sedang dimuat, berikan list kosong [] untuk mencegah crash
                            items: isFetchingBank ? [] : listBank.map((bank) {
                              return DropdownMenuItem<int>(
                                value: bank.id,
                                child: Text(bank.nama, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            // PENGAMAN: Kunci klik dropdown jika data belum siap
                            onChanged: isFetchingBank || listBank.isEmpty
                                ? null
                                : (value) => setState(() => selectedBankId = value),
                            validator: (value) {
                              if (value == null) return 'Silakan pilih Bank Sampah';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // ================= BUTTON REGISTER =================
                          Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                colors: [primaryColor, secondaryColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: isLoading ? null : () {
                                if (_formKey.currentState!.validate()) register();
                              },
                              child: isLoading
                                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text(
                                'Daftar Sekarang',
                                style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // NAVIGASI BALIK KE LOGIN
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: RichText(
                      text: const TextSpan(
                        text: "Sudah punya akun? ",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
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
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(icon, color: primaryColor, size: 20),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(obscureVar! ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey, size: 18),
          onPressed: onToggle,
        )
            : null,
        filled: true,
        fillColor: backgroundColor.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
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