import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:asriapp/config.dart'; // Jalur config milik Mai
import '../login_screen.dart';
import 'ScanBarcode.dart';
import 'RiwayatKurirScreen.dart';
import 'NotifikasiKurirScreen.dart';
import 'JadwalJemputScreen.dart';

// Palet warna kontras tinggi (Senior-Friendly Theme) - Setema dengan Dashboard
const primaryColor = Color(0xFF1E521E);
const secondaryColor = Color(0xFF4CAF50);
const softGreenColor = Color(0xFFE8F5E9);
const backgroundColor = Color(0xFFF9FBF9);
const darkTextColor = Color(0xFF0D240D);
const greyTextColor = Color(0xFF555555);

class ProfilKurirScreen extends StatefulWidget {
  const ProfilKurirScreen({super.key});

  @override
  State<ProfilKurirScreen> createState() => _ProfilKurirScreenState();
}

class _ProfilKurirScreenState extends State<ProfilKurirScreen> {
  String namaKurir = 'Memuat...';
  String emailKurir = '-';
  String noHpKurir = '-';
  String alamatKurir = '-';
  String? fotoPath;
  String idJadwalAktif = "0";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getProfilData();
  }

  Future<void> getProfilData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('user_id') ?? 0;

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/dashboard-kurir/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Pengaman: Ambil objek kurir dari jadwal jika ada
        final kurirDariJadwal = data['jadwal']?['kurir'];

        setState(() {
          namaKurir = data['nama_kurir'] ?? 'Kurir ASRI';

          // 🔥 PENGAMAN BERLAPIS:
          // Cek di root JSON dulu (data['email']), kalau kosong baru cek di dalam jadwal (kurirDariJadwal['email'])
          emailKurir = data['email'] ?? kurirDariJadwal?['email'] ?? '-';
          noHpKurir = data['no_hp'] ?? kurirDariJadwal?['no_hp'] ?? '-';
          alamatKurir = data['alamat'] ?? kurirDariJadwal?['alamat'] ?? '-';

          fotoPath = data['foto'] ?? kurirDariJadwal?['foto'];
          idJadwalAktif = data['jadwal']?['id']?.toString() ?? "0";
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("DEBUG MAI PROFIL ERROR: $e");
      setState(() {
        isLoading = false;
      });
    }
  }  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor, strokeWidth: 4)),
      );
    }

    // Bersihkan endpoint '/api' agar domain mengarah ke server utama untuk load gambar secara aman
    final String cleanBaseUrl = AppConfig.baseUrl.replaceAll('/api', '');

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ================= HEADER PROFILE (GRADIENT SENIOR) =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 70, bottom: 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, Color(0xFF2E6B2E)],
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
              ),
              child: Column(
                children: [
                  // LINGKARAN FOTO PROFIL BESAR
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: ClipOval(
                      child: fotoPath != null && fotoPath!.isNotEmpty
                          ? Image.network(
                        "$cleanBaseUrl/$fotoPath",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person_rounded, size: 60, color: Colors.white),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2));
                        },
                      )
                          : const Icon(Icons.person_rounded, size: 60, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    namaKurir,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24, // Diperbesar agar jelas terbaca lansia
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Petugas Kurir Lapangan",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ================= INFO CARDS =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Informasi Pribadi Akun",
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: darkTextColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.04),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoTile(Icons.email_rounded, "EMAIL AKTIF", emailKurir),
                        const Divider(height: 28, thickness: 1, color: Color(0xFFEEEEEE)),
                        _buildInfoTile(Icons.phone_android_rounded, "NOMOR HANDPHONE", noHpKurir),
                        const Divider(height: 28, thickness: 1, color: Color(0xFFEEEEEE)),
                        _buildInfoTile(Icons.location_on_rounded, "ALAMAT TUGAS", alamatKurir),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ================= TOMBOL LOGOUT RAKSASA MERAH CONTRAS =================
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: Colors.red.shade200, width: 1.5),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: const Text("Keluar Akun", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: darkTextColor)),
                            content: const Text("Apakah Anda yakin ingin keluar dari akun aplikasi ASRI?", style: TextStyle(fontSize: 16)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Batal", style: TextStyle(color: greyTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade700,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  logout();
                                },
                                child: const Text("Ya, Keluar", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: Icon(Icons.power_settings_new_rounded, color: Colors.red.shade700, size: 24), // Tombol power merah tegas
                      label: Text(
                        "KELUAR DARI APLIKASI",
                        style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 140),
                ],
              ),
            ),
          ],
        ),
      ),

      // ================= NAVIGATION DOCKED ELEMENTS (SETEMA) =================
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 72,
        width: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor: primaryColor,
          shape: const CircleBorder(),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ScanBarcodePage(jadwalId: idJadwalAktif),
              ),
            );
          },
          child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 32),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        elevation: 24,
        color: Colors.white,
        shadowColor: primaryColor.withOpacity(0.4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(
              icon: Icons.home_rounded,
              label: "Beranda",
              active: false,
              onTap: () => Navigator.pop(context),
            ),
            _navItem(
              icon: Icons.assignment_turned_in_rounded,
              label: "Riwayat",
              active: false,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const RiwayatKurirScreen()),
                );
              },
            ),
            const SizedBox(width: 48),
            _navItem(
              icon: Icons.notifications_rounded,
              label: "Notifikasi",
              active: false,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const NotifikasiKurirScreen()),
                );
              },
            ),
            _navItem(
              icon: Icons.account_circle_rounded,
              label: "Akun Saya",
              active: true,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              shape: BoxShape.circle
          ),
          child: Icon(icon, color: primaryColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  label,
                  style: const TextStyle(color: greyTextColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)
              ),
              const SizedBox(height: 4),
              Text(
                  value,
                  style: const TextStyle(color: darkTextColor, fontWeight: FontWeight.w900, fontSize: 16) // Diperbesar
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26, color: active ? primaryColor : Colors.grey.shade600),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: active ? primaryColor : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}