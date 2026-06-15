import 'dart:convert';
import 'package:asriapp/screens/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// import halaman kamu
import 'package:asriapp/screens/register_screen.dart';
import 'package:asriapp/screens/kurir/dashboard_kurir.dart';
import 'package:asriapp/screens/user/dashboard_screen.dart';

// Konsistensi palet warna alam/eco sesuai branding ASRI kamu
const primaryColor = Color(0xFF2F6B2F);
const secondaryColor = Color(0xFF58C063);
const backgroundColor = Color(0xFFF4F7F5); // Lebih soft abu-kehijauan ringan
const darkTextColor = Color(0xFF1A301A);   // Hijau gelap pekat untuk teks formal

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool rememberMe = false;
  bool _obscurePassword = true;

  // 🔥 FUNCTION LOGIN (Fungsi asli milik Mai, 100% dipertahankan)
  Future<void> login() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await AuthService.login(
        email: emailController.text,
        password: passwordController.text,
      );

      final status = result['status'];
      final data = result['data'];

      if (status == 200) {
        String token = data['token'] ?? '';
        String role = data['user']['role']?.toString() ?? '';
        String name = data['user']['name']?.toString() ?? '';
        String? foto = data['user']['foto']?.toString();
        int idUser = int.tryParse(data['user']['id']?.toString() ?? '0') ?? 0;

        print('TOKEN: $token');
        print('USER ID LOGIN: $idUser');

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setInt('user_id', idUser);
        await prefs.setString('role', role);

        if (!context.mounted) return;

        if (role == 'kurir') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const DashboardKurir(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardScreen(
                name: name,
                foto: foto,
              ),
            ),
          );
        }
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Text(data['message'] ?? "Login gagal"),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text('Error: $e'),
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // 🎨 ELEMEN DEKORASI BACKGROUND BIAR GREGET (Top Right Blur Circle)
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: secondaryColor.withOpacity(0.15),
              ),
            ),
          ),
          // 🎨 ELEMEN DEKORASI BACKGROUND (Bottom Left Blur Circle)
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.08),
              ),
            ),
          ),

          // UTAMA
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🔥 LOGO ASRI MAI
                    Hero(
                      tag: 'logo_asri',
                      child: Image.asset(
                        "assets/images/logo_asri.png",
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 1),

                    // 🔥 TULISAN BRANDING BESAR "ASRI"
                    Text(
                      "ASRI",
                      style: TextStyle(
                        fontSize: 40,
                        // GANTI MENJADI INI:
                        fontWeight: FontWeight.w900, //  Ini alternatif paling tebal (setara Black) // Super tebal biar kokoh dan mantap
                        color: darkTextColor,
                        letterSpacing: 1.5,
                      ),
                    ),

                    // 🔥 SUB-HEADING ADMIN
                    Text(
                      "Kelola Sampahmu, Asri Lingkunganmu",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 🔥 ELEGAN GLASSMORPHISM CARD FORM
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28), // Lebih membulat estetik
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: primaryColor.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // TEKS INSTRUKSI DI DALAM CARD
                            Text(
                              "Silakan masuk untuk mengelola bank sampah",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // EMAIL FIELD
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Colors.black87, fontSize: 15),
                              decoration: InputDecoration(
                                hintText: "Email",
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                prefixIcon: const Icon(Icons.mail_outline_rounded, color: primaryColor, size: 22),
                                filled: true,
                                fillColor: backgroundColor.withOpacity(0.5), // Efek kontras halus
                                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.08)),
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
                                if (value == null || value.isEmpty) {
                                  return "Email tidak boleh kosong";
                                }
                                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                if (!emailRegex.hasMatch(value)) {
                                  return "Format email tidak valid";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // PASSWORD FIELD WITH SHOW/HIDE TOGGLE
                            TextFormField(
                              controller: passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.black87, fontSize: 15),
                              decoration: InputDecoration(
                                hintText: "Password",
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                prefixIcon: const Icon(Icons.lock_outline_rounded, color: primaryColor, size: 22),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: Colors.grey.shade500,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: backgroundColor.withOpacity(0.5),
                                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.08)),
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
                                if (value == null || value.isEmpty) {
                                  return "Password tidak boleh kosong";
                                }
                                if (value.length < 6) {
                                  return "Password minimal 6 karakter";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // REMEMBER ME & FORGOT PASSWORD ROW
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: Checkbox(
                                        value: rememberMe,
                                        activeColor: primaryColor,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                        side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                        onChanged: (value) {
                                          setState(() {
                                            rememberMe = value!;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          rememberMe = !rememberMe;
                                        });
                                      },
                                      child: Text(
                                        "Remember Me",
                                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                                  child: const Text(
                                    "Forgot Password?",
                                    style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 24),

                            // BUTTON LOGIN (MODERN GRADIENT DESIGN)
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
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: isLoading
                                    ? null
                                    : () {
                                  if (_formKey.currentState!.validate()) {
                                    login();
                                  }
                                },
                                child: isLoading
                                    ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                                    : const Text(
                                  "Masuk Sekarang",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: .5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // REGISTER NAVIGATION TEXT (DI LUAR BOX CARD AGAR SEPERTI GAMBAR)
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                      ),
                      child: RichText(
                        text: const TextSpan(
                          text: "Belum punya akun? ",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                          children: [
                            TextSpan(
                              text: "Daftar",
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
          ),
        ],
      ),
    );
  }
}