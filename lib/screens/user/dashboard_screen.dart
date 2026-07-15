import 'package:asriapp/screens/user/aduan_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Wajib untuk SystemNavigator.pop
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../config.dart';
import 'activity_riwayat.dart';
import 'profile.dart';
import 'setor_sampah.dart';
import 'tarik_tunai.dart';
import 'riwayat_tarik_tunai.dart';
import 'status_penjemputan.dart';
import 'package:asriapp/screens/login_screen.dart';
import 'edukasi_page.dart';
import 'bantuan_page.dart';
import 'NotifikasiNasabahScreen.dart';
import '../services/jadwal_service.dart';
import '../services/notifikasi_service.dart';

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
  Map<String, dynamic>? activeJadwal;
  int unreadNotificationCount = 0;

  // 🔥 1. Buat state lokal untuk menampung data profil
  String _userName = '';
  String? _userPhotoUrl;

  @override
  void initState() {
    super.initState();
    // 🔥 2. Inisialisasi state dengan data awal dari halaman login
    _userName = widget.name;
    _userPhotoUrl = widget.foto;
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

      String token = prefs.getString('token') ?? '';
      
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/dashboard-nasabah'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final scheduleRes = await JadwalService.getJadwalNasabah(userId);

      int unreadCount = 0;
      try {
        final notifRes = await NotifikasiService.getNotifikasiNasabah(userId);
        for (var item in notifRes) {
          bool isRead = (item['is_read'] == 1 || item['is_read'] == true || item['status'] == 'read');
          if (!isRead) {
            unreadCount++;
          }
        }
      } catch (e) {
        print("ERROR FETCH UNREAD COUNT: $e");
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          setState(() {
            var nasabahObj = data['nasabah'] ?? data['user'] ?? data;

            // 🔥 3. Update state dengan data terbaru dari API dashboard
            _userName = nasabahObj['name']?.toString() ?? _userName;
            _userPhotoUrl = nasabahObj['foto']?.toString();

            saldoNasabah = int.tryParse(nasabahObj['saldo'].toString()) ?? 0;
            mutasiList = data['riwayat_mutasi'] ?? [];
            totalBeratBulanIni = double.tryParse(nasabahObj['total_berat_kg'].toString()) ?? 0.0;

            if (scheduleRes != null) {
              final List mendatangs = scheduleRes['jadwal_mendatang'] ?? [];
              final List pendings = scheduleRes['request_pending'] ?? [];
              if (mendatangs.isNotEmpty) {
                activeJadwal = Map<String, dynamic>.from(mendatangs.first);
              } else if (pendings.isNotEmpty) {
                activeJadwal = Map<String, dynamic>.from(pendings.first);
              } else {
                activeJadwal = null;
              }
            } else {
              activeJadwal = null;
            }

            unreadNotificationCount = unreadCount;
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

                // ================= 🔥 JADWAL PENJEMPUTAN TERDEKAT =================
                _buildJadwalAktifCard(context),

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
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RiwayatTarikTunaiPage())),
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

  Widget _buildJadwalAktifCard(BuildContext context) {
    if (activeJadwal == null) return const SizedBox.shrink();

    String tanggal = activeJadwal!['tanggal_formatted'] ?? activeJadwal!['tanggal'] ?? '-';
    String status = (activeJadwal!['status'] ?? 'terjadwal').toString().toUpperCase();
    String tipe = activeJadwal!['tipe'] ?? 'jadwal'; // 'jadwal' or 'request'
    
    // Status colors
    Color statusColor;
    if (status == 'PROSES') {
      statusColor = Colors.blue.shade800;
    } else if (status == 'PENDING') {
      statusColor = Colors.orange.shade800;
    } else {
      statusColor = secondaryColor;
    }

    String courierName = activeJadwal!['kurir']?['nama'] ?? 'Menunggu Petugas';

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryColor.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: softGreenColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_shipping_rounded, color: primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Jadwal Penjemputan Sampah",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkTextColor),
                    ),
                    Text(
                      tipe == 'request' ? 'Request Mandiri' : 'Jadwal Rutin Petugas',
                      style: const TextStyle(fontSize: 11, color: greyTextColor, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Waktu Penjemputan:", style: TextStyle(fontSize: 10, color: greyTextColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    Text(tanggal, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkTextColor)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Petugas Kurir:", style: TextStyle(fontSize: 10, color: greyTextColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    Text(courierName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkTextColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatusPenjemputanPage()),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: primaryColor, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                "Lacak Status Penjemputan",
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          )
        ],
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
                          builder: (context) => profile_page(foto: _userPhotoUrl),
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
                        backgroundImage: _userPhotoUrl != null ? NetworkImage(_userPhotoUrl!) : null,
                        child: _userPhotoUrl == null ? const Icon(Icons.person_rounded, size: 24, color: Colors.white) : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Halo, $_userName", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.2)),
                      const Text("Nasabah Basayan Bestari", style: TextStyle(fontSize: 12, color: Colors.white60, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ],
              ),
              // IconButton(
              //   icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white70, size: 24),
              //   onPressed: () async {
              //     bool keluar = await _showExitDialog(context);
              //     if (keluar && context.mounted) {
              //       Navigator.pushReplacementNamed(context, '/login');
              //     }
              //   },
              // )
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
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotifikasiNasabahScreen()),
            ).then((_) => fetchDashboardData());
          } else if (index == 4) { // 🔥 4. Gunakan state yang sudah diupdate
            Navigator.push(context, MaterialPageRoute(builder: (context) => profile_page(foto: _userPhotoUrl)));
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_rounded, size: 22), label: "Beranda"),
          const BottomNavigationBarItem(icon: Icon(Icons.history_rounded, size: 22), label: "Riwayat"),
          const BottomNavigationBarItem(icon: Icon(Icons.add_circle_rounded, size: 24), label: "Mulai Setor"),
          BottomNavigationBarItem(
            icon: unreadNotificationCount > 0
                ? Badge(
                    label: Text('$unreadNotificationCount'),
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.notifications_rounded, size: 22),
                  )
                : const Icon(Icons.notifications_rounded, size: 22),
            label: "Notifikasi",
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person_rounded, size: 22), label: "Profil"),
        ],
      ),
    );
  }
}