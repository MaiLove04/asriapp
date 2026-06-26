import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/dashboard_kurir_service.dart';
import '../../config.dart';
import '../login_screen.dart';
import '../kurir/JadwalJemputScreen.dart';
import 'ProfilKurirScreen.dart';
import 'RiwayatKurirScreen.dart';
import 'ScanBarcode.dart';
import 'navigasi_kurir_page.dart';
import '../user/aduan_page.dart';

// Palet Warna Kontras Tinggi & Profesional
const primaryColor = Color(0xFF154015);     // Hijau hutan tua (Sangat kontras & formal)
const secondaryColor = Color(0xFF2E7D32);   // Hijau medium untuk aksen status
const softGreenColor = Color(0xFFF0F7F0);   // Latar belakang komponen lembut
const backgroundColor = Color(0xFFF6F8F6);  // Abu-putih bersih untuk mengurangi glare layar
const darkTextColor = Color(0xFF0A1A0A);    // Hitam-hijau pekat untuk keterbacaan teks maksimal
const greyTextColor = Color(0xFF424242);    // Abu-abu gelap (bukan abu-abu pudar)

class DashboardKurir extends StatefulWidget {
  const DashboardKurir({super.key});

  @override
  State<DashboardKurir> createState() => _DashboardKurirState();
}

class _DashboardKurirState extends State<DashboardKurir> {
  Map<String, dynamic>? dashboardData;
  bool isLoading = true;

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  Future<void> getDashboard() async {
    try {
      setState(() => isLoading = true);
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
        setState(() => isLoading = false);
        return;
      }

      final result = await DashboardKurirService.getDashboard(userId);
      setState(() {
        dashboardData = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR DASHBOARD: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    getDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        _showExitDialog();
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryColor, strokeWidth: 4))
            : RefreshIndicator(
          color: primaryColor,
          onRefresh: getDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // ================= HEADER KOKOH =================
                _buildHeader(),

                // ================= LAYOUT UTAMA UTK USIA 30+ =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _sectionTitle("Tugas Terdekat Hari Ini"),
                      const SizedBox(height: 10),
                      dashboardData?['jadwal'] == null
                          ? _buildEmptyTask()
                          : _UrgentTaskItem(jadwal: dashboardData?['jadwal']),

                      const SizedBox(height: 28),
                      _sectionTitle("Ringkasan Performa Kerja"),
                      const SizedBox(height: 10),
                      _TodaySummarySection(dashboardData: dashboardData),

                      const SizedBox(height: 28),
                      _sectionTitle("Menu Akses Cepat"),
                      const SizedBox(height: 10),
                      const _QuickActionsLayout(),

                      const SizedBox(height: 28),
                      _sectionTitle("Catatan & Evaluasi"),
                      const SizedBox(height: 10),
                      _InsightCard(dashboardData: dashboardData),

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _PremiumBottomNav(onRefresh: getDashboard),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          height: 190,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          padding: const EdgeInsets.only(top: 50, left: 20, right: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ASRI SYSTEM", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                  SizedBox(height: 2),
                  Text("Manajemen Penjemputan Kurir", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 26),
                tooltip: "Keluar Akun",
                onPressed: _showLogoutConfirm,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 115, left: 16, right: 16),
          child: _ActiveMissionCard(dashboardData: dashboardData),
        ),
      ],
    );
  }

  Widget _buildEmptyTask() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      decoration: cardDecoration(),
      child: const Column(
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 52, color: secondaryColor),
          const SizedBox(height: 12),
          Text(
            "Tidak Ada Jadwal Penjemputan Aktif",
            style: TextStyle(color: darkTextColor, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            "Semua antrean tugas untuk hari ini telah selesai diproses.",
            style: TextStyle(color: greyTextColor, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: darkTextColor, letterSpacing: -0.3),
    );
  }

  void _showLogoutConfirm() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Konfirmasi Keluar", style: TextStyle(fontWeight: FontWeight.bold, color: darkTextColor)),
        content: const Text("Apakah Anda yakin ingin keluar dan mengakhiri sesi halaman kerja?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: greyTextColor, fontSize: 15, fontWeight: FontWeight.bold))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: logout,
            child: const Text("Keluar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() async {
    final keluar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Tutup Aplikasi", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Apakah Anda yakin ingin keluar dari Aplikasi ASRI?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Kembali")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Ya, Tutup", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (keluar == true) Navigator.of(context).pop();
  }
}

class _ActiveMissionCard extends StatelessWidget {
  final Map<String, dynamic>? dashboardData;
  const _ActiveMissionCard({required this.dashboardData});

  @override
  Widget build(BuildContext context) {
    final String cleanBaseUrl = AppConfig.baseUrl.replaceAll('/api', '');
    int total = int.tryParse(dashboardData?['total_pesanan']?.toString() ?? '0') ?? 0;
    int selesai = int.tryParse(dashboardData?['total_pesanan_selesai']?.toString() ?? '0') ?? 0;
    double progress = total > 0 ? (selesai / total) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 6))],
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: softGreenColor,
                backgroundImage: dashboardData?['foto'] != null ? NetworkImage("$cleanBaseUrl/${dashboardData?['foto']}") : null,
                child: dashboardData?['foto'] == null ? const Icon(Icons.account_box_rounded, size: 36, color: primaryColor) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Akun Petugas Kurir", style: TextStyle(color: greyTextColor, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      "${dashboardData?['nama_kurir'] ?? 'Petugas Lapangan'}",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkTextColor, letterSpacing: -0.5),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(6), border: Border.all(color: secondaryColor, width: 1)),
                child: const Text("AKTIF", style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.w900)),
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Progres Kerja Hari Ini", style: TextStyle(fontWeight: FontWeight.w700, color: darkTextColor, fontSize: 14)),
              Text("$selesai Selesai dari $total Lokasi", style: const TextStyle(fontWeight: FontWeight.w900, color: primaryColor, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 14, // Lebih tebal agar mudah dilihat
              backgroundColor: Colors.grey.shade100,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodaySummarySection extends StatelessWidget {
  final Map<String, dynamic>? dashboardData;
  const _TodaySummarySection({required this.dashboardData});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryBox(
            title: "TOTAL ALAMAT",
            value: "${dashboardData?['total_pesanan'] ?? 0}",
            unit: "Titik Jemput",
            icon: Icons.local_shipping_rounded,
            color: primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryBox(
            title: "BERAT TERTINJAU",
            value: "${dashboardData?['total_berat_hari_ini'] ?? 0}",
            unit: "Kilogram (Kg)",
            icon: Icons.scale_rounded,
            color: Colors.orange.shade900,
          ),
        ),
      ],
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String title, value, unit;
  final IconData icon;
  final Color color;

  const _SummaryBox({required this.title, required this.value, required this.unit, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: greyTextColor, fontWeight: FontWeight.w900, letterSpacing: 0.3)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            verticalDirection: VerticalDirection.down,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: darkTextColor, height: 1.0)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(unit, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// PERBAIKAN: Mengganti GridView kecil dengan Layout Tombol Baris Berukuran Besar (Senior-Friendly)
class _QuickActionsLayout extends StatelessWidget {
  const _QuickActionsLayout();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _largeMenuButton(context, Icons.assignment_rounded, "Daftar Tugas Kerja", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JadwalJemputScreen())))),
            const SizedBox(width: 12),
            Expanded(child: _largeMenuButton(context, Icons.map_rounded, "Navigasi Peta Rute", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NavigasiKurirPage())))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _largeMenuButton(context, Icons.history_rounded, "Riwayat Kerja", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RiwayatKurirScreen())))),
            const SizedBox(width: 12),
            Expanded(child: _largeMenuButton(context, Icons.support_agent_rounded, "Pusat Aduan", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AduanPage())))),
          ],
        ),
      ],
    );
  }

  Widget _largeMenuButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: cardDecoration().copyWith(
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primaryColor, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkTextColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UrgentTaskItem extends StatelessWidget {
  final dynamic jadwal;
  const _UrgentTaskItem({required this.jadwal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration().copyWith(
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5), // Highlight batas agar fokus mata jelas
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: Colors.orange, size: 22),
              const SizedBox(width: 6),
              Text(
                  "JADWAL PENJEMPUTAN TERDEKAT",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.orange.shade900, letterSpacing: 0.5)
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(backgroundColor: softGreenColor, radius: 24, child: Icon(Icons.person_pin_circle_rounded, color: primaryColor, size: 28)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jadwal['nasabah']?['name'] ?? 'Nama Nasabah Tidak Tersedia',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: darkTextColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      jadwal['alamat'] ?? 'Alamat penjemputan belum diatur',
                      style: const TextStyle(fontSize: 14, color: greyTextColor, fontWeight: FontWeight.w600, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52, // Tinggi tombol dimaksimalkan agar nyaman ditekan oleh jari
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ScanBarcodePage(
                    jadwalId: int.parse(jadwal['id'].toString()),
                    nasabahId: int.parse(jadwal['nasabah_id'].toString()),
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 22),
              label: const Text("MULAI PROSES & TIMBANG", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5)),
            ),
          )
        ],
      ),
    );
  }
}

class _PremiumBottomNav extends StatelessWidget {
  final VoidCallback onRefresh;
  const _PremiumBottomNav({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 76,
      elevation: 10,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_rounded, "Beranda", true, () {}),
          _navItem(Icons.history_rounded, "Riwayat", false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RiwayatKurirScreen()))),
          _navItem(Icons.notifications_none_rounded, "Notifikasi", false, () {}),
          _navItem(Icons.person_rounded, "Profil Saya", false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilKurirScreen())).then((_) => onRefresh())),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? primaryColor : greyTextColor, size: 26),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: active ? primaryColor : greyTextColor, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final Map<String, dynamic>? dashboardData;
  const _InsightCard({this.dashboardData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.analytics_rounded, color: primaryColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              dashboardData?['keterangan_tren'] ?? "Total setoran Anda bulan ini tercatat ${dashboardData?['berat_bulan_ini'] ?? 0} Kg. Teris jaga performa berkendara aman.",
              style: const TextStyle(color: darkTextColor, fontSize: 14, fontWeight: FontWeight.w600, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14), // Radius sudut dikurangi agar tampak kokoh/formal
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
  );
}