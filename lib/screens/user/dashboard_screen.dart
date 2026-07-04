import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../config.dart';
import 'activity_riwayat.dart';
import 'profile.dart';
import 'setor_sampah.dart';
import 'tarik_tunai.dart';
import 'aduan_page.dart';
import 'status_penjemputan.dart';
import 'edukasi_page.dart';
import 'bantuan_page.dart';

// 🎨 PALET WARNA EXECUTIVE PREMIUM (ASRI MODERN)
const primaryColor = Color(0xFF164716);
const secondaryColor = Color(0xFF2E7D32);
const softGreenColor = Color(0xFFE8F0E9);
const backgroundColor = Color(0xFFF7F9F7);
const darkTextColor = Color(0xFF0C1F0C);
const greyTextColor = Color(0xFF5A665A);

class DashboardScreen extends StatefulWidget {
  final String name;
  final String? foto;

  const DashboardScreen({
    super.key,
    required this.name,
    this.foto,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int saldoNasabah = 0;
  List<dynamic> mutasiList = [];
  bool isLoading = true;
  double totalBeratBulanIni = 0.0;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      setState(() { isLoading = true; });
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

      if (userId == 0) {
        setState(() { isLoading = false; });
        return;
      }

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/dashboard-nasabah/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          setState(() {
            var nasabahObj = data['nasabah'] ?? data['user'] ?? data;
            saldoNasabah = int.tryParse(nasabahObj['saldo'].toString()) ?? 0;
            mutasiList = data['riwayat_mutasi'] ?? [];
            totalBeratBulanIni = double.tryParse(nasabahObj['total_berat_kg'].toString()) ?? 0.0;
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

  Future<bool> _showExitDialog(BuildContext context) async {
    bool? keluar = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("Keluar Aplikasi", style: TextStyle(fontWeight: FontWeight.bold, color: darkTextColor)),
          content: const Text("Apakah Anda yakin ingin keluar ke halaman login?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal", style: TextStyle(color: greyTextColor, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade800,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Keluar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
    return keluar ?? false;
  }

  String formatRupiah(int angka) {
    return "Rp " + angka.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.'
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        bool keluar = await _showExitDialog(context);
        if (keluar && context.mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        bottomNavigationBar: _buildBottomNav(context),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryColor, strokeWidth: 3))
            : RefreshIndicator(
          color: primaryColor,
          onRefresh: fetchDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= 1. THE MAIN EXECUTIVE HEADER =================
                _buildExecutiveHeader(context),

                const SizedBox(height: 24),

                // ================= 2. MENU LAYANAN SECTION =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                          "Layanan Basayan Bestari",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkTextColor, letterSpacing: -0.3)
                      ),
                      const SizedBox(height: 16),
                      _buildMenuGrid(context),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ================= 3. CLEAN MUTASI FINANSIAL =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                              "Aktivitas Dompet Terbaru",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkTextColor, letterSpacing: -0.3)
                          ),
                          if (mutasiList.isNotEmpty)
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RiwayatPage())),
                              child: const Text(
                                  "Lihat Semua",
                                  style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold, fontSize: 13)
                              ),
                            )
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildCleanMutasiList(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExecutiveHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 54, left: 24, right: 24, bottom: 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, Color(0xFF0F360F)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 BARU: Row Paling Atas untuk Logo ASRI & Nama Aplikasi
          Row(
            children: [
              Hero(
                tag: 'logo_asri_nasabah',
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: ClipOval(child: Image.asset("assets/images/logo_asri.png", fit: BoxFit.contain)),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "ASRI",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Baris Akun (Klik Foto Profil -> Pindah Halaman)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // 🔥 BARU: GestureDetector untuk mendeteksi ketukan pada foto profil nasabah
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => profile_page(foto: widget.foto), // 🔥 Kirim data URL foto ke sini
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white12,
                        backgroundImage: widget.foto != null ? NetworkImage(widget.foto!) : null,
                        child: widget.foto == null ? const Icon(Icons.person_rounded, size: 24, color: Colors.white) : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Halo, ${widget.name}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.2)),
                      const Text("Nasabah Basayan Bestari", style: TextStyle(fontSize: 12, color: Colors.white60, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white70, size: 24),
                onPressed: () async {
                  bool keluar = await _showExitDialog(context);
                  if (keluar && context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              )
            ],
          ),

          const SizedBox(height: 32),

          const Text("TOTAL SALDO ANDA", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Text(
              formatRupiah(saldoNasabah),
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5)
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.scale_rounded, color: Colors.amber, size: 20),
                const SizedBox(width: 10),
                const Text("Sampah terkonversi bulan ini:", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                const Spacer(),
                Text("$totalBeratBulanIni Kg", style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {"icon": Icons.receipt_long_rounded, "label": "Riwayat", "page": const RiwayatPage()},
      {"icon": Icons.delete_sweep_rounded, "label": "Setor", "page": const SetorSampahScreen()},
      {"icon": Icons.monetization_on_rounded, "label": "Tarik Tunai", "page": const TarikTunaiPage()},
      {"icon": Icons.local_shipping_rounded, "label": "Lacak Rute", "page": const StatusPenjemputanPage()},
      {"icon": Icons.school_rounded, "label": "Edukasi", "page": const EdukasiPage()},
      {"icon": Icons.help_center_rounded, "label": "Bantuan", "page": const BantuanPage()},
      {"icon": Icons.support_agent_rounded, "label": "Aduan", "page": const AduanPage()},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menuItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 14,
        childAspectRatio: 0.88,
      ),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => item["page"] as Widget)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Icon(item["icon"] as IconData, color: primaryColor, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                item["label"] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: darkTextColor, height: 1.1),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildCleanMutasiList() {
    if (mutasiList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        alignment: Alignment.center,
        child: const Text("Belum ada mutasi aktivitas dompet.", style: TextStyle(color: greyTextColor, fontSize: 13, fontWeight: FontWeight.w500)),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: mutasiList.length > 4 ? 4 : mutasiList.length,
        separatorBuilder: (context, index) => Divider(color: Colors.grey.shade100, height: 24),
        itemBuilder: (context, index) {
          final item = mutasiList[index];
          String jenisTx = (item['jenis_transaksi'] ?? 'masuk').toString().toLowerCase();
          bool isUangMasuk = jenisTx == 'masuk';

          int nominal = int.tryParse(item['nominal'].toString()) ?? 0;
          String judulKartu = item['judul_dinamis'] ?? (isUangMasuk ? "Hasil Setor Sampah" : "Penarikan Saldo Tunai");

          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isUangMasuk ? Colors.green.shade50 : Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                    isUangMasuk ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    color: isUangMasuk ? Colors.green.shade700 : Colors.red.shade700,
                    size: 18
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(judulKartu, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkTextColor), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(item['tanggal_formatted'] ?? '-', style: const TextStyle(fontSize: 11, color: greyTextColor, fontWeight: FontWeight.w400))
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "${isUangMasuk ? '+' : '-'} ${formatRupiah(nominal)}",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isUangMasuk ? Colors.green.shade700 : Colors.red.shade700
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey.shade400,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const RiwayatPage()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SetorSampahScreen()));
          } else if (index == 4) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => profile_page(foto: widget.foto)));
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
    );
  }
}