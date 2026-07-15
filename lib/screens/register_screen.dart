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
        if (listBank.isEmpty) {
          listBank.add(BankSampahModel(id: 1, nama: "Basayan Bestari"));
        }
        isFetchingBank = false;
      });
    } catch (e) {
      print("Error fetching bank sampah: $e");
      setState(() {
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

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() {
      selectedImage = File(picked.path);
    });
  }

  void _showPendingApprovalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_clock_rounded, size: 50, color: primaryColor),
              const SizedBox(height: 20),
              const Text("Registrasi Berhasil!", style: TextStyle(fontWeight: FontWeight.bold)),
              const Text("Silakan menunggu persetujuan Admin.", textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
                child: const Text('Mengerti'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> register() async {
    if (selectedBankId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih bank sampah')));
      return;
    }
    setState(() => isLoading = true);
    try {
      // PERBAIKAN: Menambahkan parameter 'email' di sini
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
      if (result['status'] == 200 || result['status'] == 201) {
        if (!mounted) return;
        _showPendingApprovalDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['data']['message'] ?? 'Registrasi gagal')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text("Buat Akun ASRI", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: darkTextColor)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: pickImage,
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: backgroundColor,
                          backgroundImage: selectedImage != null ? FileImage(selectedImage!) : null,
                          child: selectedImage == null ? const Icon(Icons.person_add_alt_1_rounded, size: 28, color: primaryColor) : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInput(controller: nameController, hint: 'Nama Lengkap', icon: Icons.person_outline_rounded),
                      const SizedBox(height: 12),
                      _buildInput(controller: emailController, hint: 'Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 12),
                      _buildInput(controller: passwordController, hint: 'Password', icon: Icons.lock_outline_rounded, isPassword: true, obscureVar: isObscure, onToggle: () => setState(() => isObscure = !isObscure)),
                      const SizedBox(height: 12),
                      _buildInput(controller: confirmPasswordController, hint: 'Konfirmasi Password', icon: Icons.lock_reset_rounded, isPassword: true, obscureVar: isObscureConfirm, onToggle: () => setState(() => isObscureConfirm = !isObscureConfirm)),
                      const SizedBox(height: 12),
                      _buildInput(controller: phoneController, hint: 'No HP', icon: Icons.phone_android_rounded, keyboardType: TextInputType.phone),
                      const SizedBox(height: 12),
                      _buildInput(controller: addressController, hint: 'Alamat Lengkap', icon: Icons.location_on_outlined),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: selectedBankId,
                        items: isFetchingBank ? [] : listBank.map((bank) => DropdownMenuItem<int>(value: bank.id, child: Text(bank.nama))).toList(),
                        onChanged: isFetchingBank || listBank.isEmpty ? null : (value) => setState(() => selectedBankId = value),
                        decoration: _inputDecoration('Pilih Bank Sampah', Icons.account_balance_rounded),
                        validator: (value) => value == null ? 'Silakan pilih Bank Sampah' : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () { if (_formKey.currentState!.validate()) register(); },
                          child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Daftar Sekarang'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: backgroundColor.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      );

  Widget _buildInput({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false, bool? obscureVar, VoidCallback? onToggle, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? (obscureVar ?? true) : false,
      keyboardType: keyboardType,
      decoration: _inputDecoration(hint, icon).copyWith(
        suffixIcon: isPassword ? IconButton(icon: Icon(obscureVar! ? Icons.visibility_off_outlined : Icons.visibility_outlined), onPressed: onToggle) : null,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return '$hint tidak boleh kosong';
        if (hint == 'Email' && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Format email tidak valid';
        if (hint == 'Password' && value.length < 6) return 'Password minimal 6 karakter';
        if (hint == 'Konfirmasi Password' && value != passwordController.text) return 'Password tidak sama';
        return null;
      },
    );
  }
}