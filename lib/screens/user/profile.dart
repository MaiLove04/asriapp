import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config.dart';
import '../services/setor_sampah_service.dart';

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
  bool _hasPin = false;
  bool isLoading = true;
  bool _isSubmitting = false;

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
      int userId = 0;
      if (prefs.containsKey('user_id')) {
        final rawId = prefs.get('user_id');
        if (rawId is int) {
          userId = rawId;
        } else if (rawId is String) {
          userId = int.tryParse(rawId) ?? 0;
        }
      }

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
            _hasPin = data['nasabah']['has_pin'] ?? false;
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

  void _showSetupPinDialog() {
    final TextEditingController pinController = TextEditingController();
    final TextEditingController confirmController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(_hasPin ? "Ubah PIN Transaksi" : "Buat PIN Transaksi", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_hasPin 
              ? "Silakan masukkan PIN baru Anda." 
              : "Demi keamanan, silakan buat 6 digit PIN untuk setiap transaksi Anda.", 
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 20),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: "PIN Baru", counterText: ""),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: "Konfirmasi PIN", counterText: ""),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("BATAL", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E521E)),
            onPressed: () async {
              if (pinController.text.length == 6 && pinController.text == confirmController.text) {
                Navigator.pop(ctx);
                _eksekusiSetupPin(pinController.text, confirmController.text);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("PIN tidak cocok atau kurang dari 6 digit."), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("SIMPAN PIN", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _eksekusiSetupPin(String pin, String confirm) async {
    setState(() => _isSubmitting = true);
    final result = await SetorSampahService.setupPin(pin: pin, pinConfirmation: confirm);
    
    if (mounted) {
      setState(() => _isSubmitting = false);
      if (result['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("PIN berhasil diperbarui!"), backgroundColor: Color(0xFF1E521E)),
        );
        setState(() => _hasPin = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['data']['message'] ?? "Gagal memproses PIN."), backgroundColor: Colors.red),
        );
      }
    }
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
                    _menuItem(Icons.lock, "Ubah Kata Sandi", onTap: () {}),
                    _menuItem(Icons.settings, "Pengaturan Akun", onTap: () {}),
                    _menuItem(Icons.notifications, "Notifikasi", onTap: () {}),
                    _menuItem(
                      _hasPin ? Icons.security_rounded : Icons.lock_open_rounded, 
                      _hasPin ? "Ubah PIN Transaksi" : "Setel PIN Transaksi", 
                      onTap: _showSetupPinDialog
                    ),
                    _menuItem(Icons.help, "Pusat Bantuan", onTap: () {}),
                    _menuItem(Icons.power_settings_new_rounded, "Keluar Akun", onTap: () async {
                      bool? yakin = await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text("Konfirmasi"),
                          content: const Text("Apakah Anda yakin ingin keluar dari akun?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                              onPressed: () async {
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                await prefs.clear();
                                if (mounted) {
                                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                                }
                              },
                              child: const Text("Keluar", style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    }),
                    
                    if (_isSubmitting)
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: LinearProgressIndicator(color: Color(0xFF1E521E)),
                      ),
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
  Widget _menuItem(IconData icon, String title, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
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
      ),
    );
  }
}
