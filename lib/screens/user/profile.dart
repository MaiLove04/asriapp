import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:gal/gal.dart';

import '../../config.dart';
import '../services/setor_sampah_service.dart';
import 'bantuan_page.dart'; // 🔥 Memastikan import halaman bantuan aktif
import 'NotifikasiNasabahScreen.dart';

// 🎨 PALET WARNA EXECUTIVE PREMIUM (ASRI MODERN)
const primaryColor = Color(0xFF164716);     // Hijau Botol Mewah
const secondaryColor = Color(0xFF2E7D32);   // Hijau Aksen Aktif
const softGreenColor = Color(0xFFE8F0E9);   // Hijau sangat muda bersih
const backgroundColor = Color(0xFFF7F9F7);  // Putih keabu-abuan mutiara tenang
const darkTextColor = Color(0xFF0C1F0C);    // Hitam pekat legam teks utama
const greyTextColor = Color(0xFF5A665A);    // Abu-abu elegan sub-informasi

class profile_page extends StatefulWidget {
  final String? foto; // 🔥 Operan URL foto dinamis dari Dashboard

  const profile_page({super.key, this.foto});

  @override
  State<profile_page> createState() => _profile_pageState();
}

class _profile_pageState extends State<profile_page> {
  String namaNasabah = "...";
  String idNasabah = "-";
  int saldoNasabah = 0;
  String? fotoNasabah; // 🔥 Tambahkan state foto
  bool _hasPin = false;
  bool isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fotoNasabah = widget.foto; // Inisialisasi awal
    getProfileNasabah();
  }

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
            var nasabahData = data['nasabah'];
            namaNasabah = nasabahData['name'] ?? 'Nasabah Basayan';
            idNasabah = nasabahData['kode_nasabah'] ?? '-';
            saldoNasabah = int.tryParse(nasabahData['saldo'].toString()) ?? 0;
            _hasPin = nasabahData['has_pin'] ?? false;
            
            // 🔥 Ambil foto terbaru dari API
            if (nasabahData['foto'] != null && nasabahData['foto'].toString().isNotEmpty) {
              String rawFoto = nasabahData['foto'].toString();
              if (rawFoto.startsWith('http')) {
                fotoNasabah = rawFoto;
              } else {
                // Bersihkan '/api' dari baseUrl untuk mendapatkan domain utama
                String domain = AppConfig.baseUrl.replaceAll('/api', '');
                fotoNasabah = "$domain/$rawFoto";
              }
            }
            
            isLoading = false;
          });
        }
      } else {
        setState(() { isLoading = false; });
      }
    } catch (e) {
      setState(() { isLoading = false; });
    }
  }

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(_hasPin ? "Ubah PIN Transaksi" : "Setel PIN Transaksi", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: darkTextColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_hasPin
                ? "Silakan masukkan 6 digit PIN baru Anda."
                : "Demi keamanan finansial Anda, silakan buat 6 digit PIN untuk otentikasi transaksi.",
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: greyTextColor)),
            const SizedBox(height: 20),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 8),
              decoration: InputDecoration(
                  hintText: "PIN BARU",
                  hintStyle: const TextStyle(fontSize: 13, letterSpacing: 0, color: Colors.grey),
                  counterText: "",
                  filled: true,
                  fillColor: backgroundColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 8),
              decoration: InputDecoration(
                  hintText: "KONFIRMASI PIN",
                  hintStyle: const TextStyle(fontSize: 13, letterSpacing: 0, color: Colors.grey),
                  counterText: "",
                  filled: true,
                  fillColor: backgroundColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("BATAL", style: TextStyle(color: greyTextColor, fontWeight: FontWeight.bold))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
            ),
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
            child: const Text("SIMPAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          const SnackBar(content: Text("PIN transaksi berhasil diperbarui!"), backgroundColor: secondaryColor),
        );
        setState(() => _hasPin = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['data']['message'] ?? "Gagal memproses PIN."), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showQrCodeDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return FutureBuilder<Map<String, dynamic>?>(
              future: _fetchQrCodeData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircularProgressIndicator(color: primaryColor),
                        SizedBox(height: 16),
                        Text("Memuat QR Code...", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError || snapshot.data == null || snapshot.data!['success'] == false) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    title: const Text("Gagal", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    content: const Text("Gagal mengambil data QR Code dari server."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Tutup"),
                      ),
                    ],
                  );
                }

                final base64Image = snapshot.data!['barcode'] as String;
                final imageBytes = base64Decode(base64Image);

                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  title: const Text(
                    "QR Code Nasabah",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, color: darkTextColor),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Tunjukkan QR Code ini kepada petugas/kurir saat penimbangan sampah.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200, width: 2),
                        ),
                        child: Image.memory(
                          imageBytes,
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        idNasabah,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor),
                      ),
                    ],
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Batal",
                        style: TextStyle(color: greyTextColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onPressed: () async {
                        try {
                          final hasAccess = await Gal.hasAccess();
                          if (!hasAccess) {
                            await Gal.requestAccess();
                          }
                          await Gal.putImageBytes(imageBytes);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text("✅ QR Code Berhasil Simpan ke Galeri!"),
                                backgroundColor: secondaryColor,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text("❌ Gagal menyimpan QR Code: $e"),
                                backgroundColor: Colors.red.shade800,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.download_rounded, color: Colors.white, size: 18),
                      label: const Text(
                        "Unduh QR",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _fetchQrCodeData() async {
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

      final token = prefs.getString('token') ?? '';
      
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/barcode/nasabah/$userId'),
        headers: {
          "Accept": "application/json",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'barcode': data['barcode'],
        };
      }
      return {'success': false};
    } catch (e) {
      return {'success': false};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // ================= APPBAR PREMIUM =================
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text("Profil Akun", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor, strokeWidth: 3))
          : RefreshIndicator(
        color: primaryColor,
        onRefresh: getProfileNasabah,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            children: [
              // ================= TAMPILAN HERO KARTU PROFIL =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 28),
                decoration: const BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 3),
                      ),
                      // 🔥 PERBAIKAN: Gunakan fotoNasabah dari state yang sudah diolah
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white12,
                        backgroundImage: fotoNasabah != null && fotoNasabah!.isNotEmpty
                            ? NetworkImage(fotoNasabah!)
                            : null,
                        child: fotoNasabah == null || fotoNasabah!.isEmpty
                            ? const Icon(Icons.person_rounded, color: Colors.white, size: 44)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      namaNasabah,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white, letterSpacing: -0.3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      idNasabah,
                      style: const TextStyle(fontSize: 13, color: Colors.white60, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= ISI KONTEN MENU OPSI (CLEAN INTERFACE) =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Informasi Keuangan", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: greyTextColor, letterSpacing: 0.5)),
                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("TOTAL SALDO BERJALAN", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: greyTextColor, letterSpacing: 0.8)),
                          const SizedBox(height: 6),
                          Text(
                            formatRupiah(saldoNasabah),
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor, letterSpacing: -0.5),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),
                    const Text("Pengaturan & Keamanan", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: greyTextColor, letterSpacing: 0.5)),
                    const SizedBox(height: 10),

                    Container(
                      decoration: cardDecoration(),
                      child: Column(
                        children: [
                          // _menuItem(Icons.lock_outline_rounded, "Ubah Kata Sandi", onTap: () {}),
                          // _dividerLine(),
                          // _menuItem(Icons.settings_outlined, "Pengaturan Akun", onTap: () {}),
                          // _dividerLine(),
                          // _menuItem(Icons.notifications_none_rounded, "Notifikasi Sistem", onTap: () {}),
                          // _dividerLine(),
                          // _menuItem(
                          //     _hasPin ? Icons.security_rounded : Icons.lock_open_rounded,
                          //     _hasPin ? "Ubah PIN Transaksi Dompet" : "Setel PIN Transaksi Dompet",
                          //     onTap: _showSetupPinDialog
                          // ),
                          // _dividerLine(),
                          _menuItem(
                            Icons.qr_code_2_rounded,
                            "QR Code Saya",
                            onTap: _showQrCodeDialog,
                          ),
                          _dividerLine(),
                          // 🔥 PERBAIKAN: Diarahkan ke halaman BantuanPage()
                          _menuItem(
                            Icons.help_outline_rounded,
                            "Pusat Bantuan",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const BantuanPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      decoration: cardDecoration(),
                      child: _menuItem(
                          Icons.power_settings_new_rounded,
                          "Keluar Dari Akun",
                          colorIconText: Colors.red.shade800,
                          onTap: () async {
                            showDialog(
                              context: context,
                              builder: (ctx) => AppExitDialog(onConfirm: () async {
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                await prefs.clear();
                                if (context.mounted) {
                                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                                }
                              }),
                            );
                          }
                      ),
                    ),

                    if (_isSubmitting)
                      const Padding(
                        padding: EdgeInsets.only(top: 14),
                        child: LinearProgressIndicator(color: primaryColor),
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey.shade400,
          currentIndex: 4,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          onTap: (index) {
            if (index == 0) {
              Navigator.popUntil(context, (route) => route.isFirst);
            } else if (index == 1) {
              Navigator.pushReplacementNamed(context, '/riwayat');
            } else if (index == 2) {
              Navigator.pushReplacementNamed(context, '/setorsampah');
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotifikasiNasabahScreen()),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded, size: 22), label: "Beranda"),
            BottomNavigationBarItem(icon: Icon(Icons.history_rounded, size: 22), label: "Riwayat"),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle_rounded, size: 24), label: "Mulai Setor"),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded, size: 22), label: "Notifikasi"),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded, size: 22), label: "Profil"),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, {required VoidCallback onTap, Color? colorIconText}) {
    Color activeColor = colorIconText ?? darkTextColor;
    Color iconColor = colorIconText ?? primaryColor;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, color: activeColor, fontSize: 14),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: colorIconText != null ? Colors.transparent : Colors.grey.shade400)
          ],
        ),
      ),
    );
  }

  Widget _dividerLine() {
    return Divider(color: Colors.grey.shade100, height: 1, thickness: 1, indent: 16, endIndent: 16);
  }
}

class AppExitDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  const AppExitDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text("Konfirmasi Keluar", style: TextStyle(fontWeight: FontWeight.bold, color: darkTextColor)),
      content: const Text("Apakah Anda yakin ingin keluar dari akun nasabah saat ini?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: greyTextColor, fontWeight: FontWeight.bold))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
          ),
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: const Text("Keluar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

BoxDecoration cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.02),
        blurRadius: 12,
        offset: const Offset(0, 4),
      )
    ],
  );
}