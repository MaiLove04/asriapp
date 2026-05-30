import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config.dart'; // Menghubungkan aman dengan AppConfig Mai

class profile_page extends StatefulWidget {
  const profile_page({super.key});

  @override
  State<profile_page> createState() => _profile_pageState();
}

class _profile_pageState extends State<profile_page> {
  // --- STATE DATA PROFILE NASABAH ---
  String namaNasabah = "...";
  String idNasabah = "-";
  int saldoNasabah = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getProfileNasabah();
  }

  // ========================================================
  // ⚡ LOAD DATA PROFIL & SALDO LANGSUNG DARI LARAVEL
  // ========================================================
  Future<void> getProfileNasabah() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('user_id') ?? 0;

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/dashboard-nasabah/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            namaNasabah = data['nasabah']['name'] ?? 'Nasabah Basayan';
            idNasabah = "ID ${data['nasabah']['id'] ?? '-'}";
            saldoNasabah = int.tryParse(data['nasabah']['saldo'].toString()) ?? 0;
            isLoading = false;
          });
        }
      } else {
        print("Gagal mengambil data profil. Status: ${response.statusCode}");
        setState(() { isLoading = false; });
      }
    } catch (e) {
      print("ERROR REAL-TIME PROFILE: $e");
      setState(() { isLoading = false; });
    }
  }

  // Formatter Rupiah Lokalan Basayan Bestari
  String formatRupiah(int angka) {
    return "Rp " + angka.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.'
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      // ================= APPBAR =================
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        elevation: 0,
        title: const Text("Profil Akun", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E521E), strokeWidth: 4))
          : RefreshIndicator(
        color: Colors.green[900],
        onRefresh: getProfileNasabah, // Tarik ke bawah untuk refresh data profil & saldo
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ================= CONTAINER UTAMA =================
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    // ================= PROFILE CARD DYNAMIC =================
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 28,
                            backgroundColor: Color(0xFF2E7D32),
                            child: Icon(Icons.person, color: Colors.white, size: 32),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  namaNasabah, // 🔥 Nama Asli dari DB
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D240D)),
                                ),
                                const SizedBox(height: 3),
                                Text(idNasabah, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ================= KOTAK SALDO DYNAMIC =================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total Saldo Berjalan",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            formatRupiah(saldoNasabah), // 🔥 Saldo Asli dari DB
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ================= MENU OPSI =================
                    _menuItem(Icons.lock, "Ubah Kata Sandi"),
                    _menuItem(Icons.settings, "Pengaturan Akun"),
                    _menuItem(Icons.notifications, "Notifikasi"),
                    _menuItem(Icons.security, "Keamanan dan Privasi"),
                    _menuItem(Icons.help, "Pusat Bantuan"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // ================= BOTTOM NAV CONTROL =================
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green[900],
        unselectedItemColor: Colors.grey,
        currentIndex: 4, // Mengunci indikator aktif di menu Profil
        onTap: (index) {
          if (index == 0) {
            // Kembali ke halaman beranda utama
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 1) {
            // Arahkan ke halaman Riwayat Aktivitas
            Navigator.pushReplacementNamed(context, '/riwayat');
          } else if (index == 2) {
            // Arahkan ke halaman Setor
            Navigator.pushReplacementNamed(context, '/setor');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Riwayat"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: "Mulai Setor"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifikasi"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }

  // ================= WIDGET COMPONENT MENU ITEM =================
  Widget _menuItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[800], size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0D240D), fontSize: 13),
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey)
        ],
      ),
    );
  }
}