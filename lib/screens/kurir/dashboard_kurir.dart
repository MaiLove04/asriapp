import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/dashboard_kurir_service.dart';
import '../../config.dart';
import '../kurir/JadwalJemputScreen.dart';
import 'ProfilKurirScreen.dart';
import 'RiwayatKurirScreen.dart';
import 'ScanBarcode.dart';
import 'navigasi_kurir_page.dart';
import 'pencapaian_kurir_page.dart';
import 'edukasi_kurir_page.dart';
import 'NotifikasiKurirScreen.dart';

// Palet warna premium dengan kontras tinggi (Senior-Friendly & Professional)
const primaryColor = Color(0xFF1B4D1B);     // Lebih dalam, kontras tinggi, sangat profesional
const secondaryColor = Color(0xFF2E7D32);   // Hijau material untuk elemen aktif
const softGreenColor = Color(0xFFF0F7F1);   // Background komponen yang lebih segar
const backgroundColor = Color(0xFFF4F7F4);  // Abu-hijau sangat muda untuk menaikkan kontras kartu putih
const darkTextColor = Color(0xFF0A1F0A);    // Teks utama super pekat
const greyTextColor = Color(0xFF4A554A);    // Teks sekunder yang tetap kontras tinggi

class DashboardKurir extends StatefulWidget {
  const DashboardKurir({super.key});

  @override
  State<DashboardKurir> createState() => _DashboardKurirState();
}

class _DashboardKurirState extends State<DashboardKurir> {
  Map<String, dynamic>? dashboardData;
  bool isLoading = true;

  Future<void> getDashboard() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('user_id') ?? 0;

      if (userId == 0) {
        setState(() { isLoading = false; });
        return;
      }

      final result = await DashboardKurirService.getDashboard(userId);

      setState(() {
        dashboardData = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() { isLoading = false; });
    }
  }

  @override
  void initState() {
    super.initState();
    getDashboard();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor, strokeWidth: 4)),
      );
    }
    String? idJadwalAktif = dashboardData?['jadwal']?['id']?.toString();
    List<dynamic> aktivitasTerbaru = dashboardData?['aktivitas_terbaru'] ?? [];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final keluar = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text("Keluar Aplikasi", style: TextStyle(fontWeight: FontWeight.bold, color: darkTextColor)),
            content: const Text("Apakah Anda yakin ingin keluar dari aplikasi ASRI?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Batal", style: TextStyle(color: greyTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade800,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Ya, Keluar", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );

        if (keluar == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: RefreshIndicator(
          color: primaryColor,
          backgroundColor: Colors.white,
          onRefresh: getDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Column(
              children: [
                const _HeaderSection(),
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _ActiveMissionCard(dashboardData: dashboardData),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("Ringkasan Hari Ini"),
                      const SizedBox(height: 12),
                      _TodaySummarySection(dashboardData: dashboardData),
                      const SizedBox(height: 28),

                      _sectionTitle("Menu Akses Cepat"),
                      const SizedBox(height: 8),
                      const _QuickActionsGrid(),
                      const SizedBox(height: 28),

                      _sectionTitle("Catatan Performa"),
                      const SizedBox(height: 12),
                      _InsightCard(dashboardData: dashboardData),
                      const SizedBox(height: 28),

                      _sectionTitle("Riwayat Setor Terakhir"),
                      const SizedBox(height: 12),
                      aktivitasTerbaru.isEmpty
                          ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: cardDecoration(),
                        child: const Center(
                          child: Text(
                            "Belum ada catatan setoran hari ini.\nTarik ke bawah untuk menyegarkan data.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: greyTextColor, fontSize: 15, fontWeight: FontWeight.w500, height: 1.4),
                          ),
                        ),
                      )
                          : Column(
                        children: aktivitasTerbaru.map((item) => _ActivityCard(data: item)).toList(),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: _ScanFab(jadwalId: idJadwalAktif),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: darkTextColor,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _GridActionCard(
          icon: Icons.assignment_rounded,
          title: "Buka Tugas",
          color: Colors.blue.shade800,
          onTap: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const JadwalJemputScreen()));
            if (result == true) {
              context.findAncestorStateOfType<_DashboardKurirState>()?.getDashboard();
            }
          },
        ),
        _GridActionCard(
          icon: Icons.menu_book_rounded,
          title: "Panduan Kurir",
          color: Colors.teal.shade700,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EdukasiKurirPage())),
        ),
        _GridActionCard(
          icon: Icons.bar_chart_rounded,
          title: "Lihat Performa",
          color: Colors.purple.shade700,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PencapaianKurirPage())),
        ),
        _GridActionCard(
          icon: Icons.history_rounded,
          title: "Riwayat Kerja",
          color: Colors.blueGrey.shade700,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RiwayatKurirScreen())),
        ),
      ],
    );
  }
}

class _GridActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _GridActionCard({required this.icon, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: cardDecoration(),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, size: 26, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkTextColor, height: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodaySummarySection extends StatelessWidget {
  final Map<String, dynamic>? dashboardData;
  const _TodaySummarySection({required this.dashboardData});

  @override
  Widget build(BuildContext context) {
    String totalBeratHariIni = dashboardData?['total_berat_hari_ini']?.toString() ?? '0';
    String totalPendapatanHariIni = dashboardData?['total_pendapatan_hari_ini']?.toString() ?? '0';

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.local_shipping_rounded,
            title: "TUGAS HARI INI",
            value: "${dashboardData?['total_pesanan'] ?? 0} Lokasi",
            subtitle: "Harus Dikunjungi",
            accentColor: primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            icon: Icons.scale_rounded,
            title: "TOTAL SAMPAH",
            value: "$totalBeratHariIni Kg",
            subtitle: "Rp $totalPendapatanHariIni",
            accentColor: Colors.orange.shade900,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color accentColor;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: accentColor),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 11, color: greyTextColor, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkTextColor, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 14, color: accentColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, Color(0xFF143A14)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Hero(
                tag: 'logo_asri',
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: ClipOval(child: Image.asset("assets/images/logo_asri.png", fit: BoxFit.contain)),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text("ASRI", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_rounded, color: Colors.white, size: 26),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotifikasiKurirScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveMissionCard extends StatelessWidget {
  final Map<String, dynamic>? dashboardData;
  const _ActiveMissionCard({required this.dashboardData});

  @override
  Widget build(BuildContext context) {
    final String? fotoPath = dashboardData?['foto'];
    final String cleanBaseUrl = AppConfig.baseUrl.replaceAll('/api', '');

    int totalTugas = dashboardData?['total_pesanan'] ?? 0;
    int tugasSelesai = dashboardData?['total_pesanan_selesai'] ?? 0;
    double progressValue = totalTugas > 0 ? (tugasSelesai / totalTugas) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilKurirScreen()),
                  );
                  if (context.mounted) {
                    context.findAncestorStateOfType<_DashboardKurirState>()?.getDashboard();
                  }
                },
                borderRadius: BorderRadius.circular(28),
                child: fotoPath != null && fotoPath.isNotEmpty
                    ? Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      "$cleanBaseUrl/$fotoPath",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 32, color: greyTextColor),
                    ),
                  ),
                )
                    : const CircleAvatar(
                  radius: 28,
                  backgroundColor: softGreenColor,
                  child: Icon(Icons.person_rounded, size: 32, color: primaryColor),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Selamat Bekerja,", style: TextStyle(color: greyTextColor, fontSize: 13, fontWeight: FontWeight.w500)),
                    Text("${dashboardData?['nama_kurir'] ?? 'Kurir'}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkTextColor)),
                  ],
                ),
              ),
              _activeBadge(context),
            ],
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const NavigasiKurirPage()));
              if (result == true) {
                context.findAncestorStateOfType<_DashboardKurirState>()?.getDashboard();
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Jadwal Jalan Hari Ini", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkTextColor)),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: primaryColor),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Align(
              alignment: Alignment.centerLeft,
              child: Text("Ada $totalTugas lokasi yang harus dikunjungi", style: const TextStyle(fontSize: 14, color: greyTextColor, fontWeight: FontWeight.w500))
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 10,
              backgroundColor: backgroundColor,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // Diubah menjadi end agar tombol merapat ke kanan dengan rapi
            children: [
              _startButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _activeBadge(BuildContext context) {
    String? idJadwal = context.findAncestorStateOfType<_DashboardKurirState>()?.dashboardData?['jadwal']?['id']?.toString();
    bool tidakAdaTugas = idJadwal == null || idJadwal.isEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: tidakAdaTugas ? Colors.grey.shade200 : softGreenColor,
          borderRadius: BorderRadius.circular(12)
      ),
      child: Text(
          tidakAdaTugas ? "LIBUR" : "SIAP",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: tidakAdaTugas ? Colors.grey.shade700 : primaryColor)
      ),
    );
  }

  Widget _startButton(BuildContext context) {
    final state = context.findAncestorStateOfType<_DashboardKurirState>();
    String? idJadwal = state?.dashboardData?['jadwal']?['id']?.toString();
    bool tidakAdaTugas = idJadwal == null || idJadwal.isEmpty;

    return ElevatedButton.icon(
      onPressed: tidakAdaTugas ? null : () async {
        final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const JadwalJemputScreen()));
        if (result == true) state?.getDashboard();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: tidakAdaTugas ? Colors.grey.shade300 : primaryColor,
        elevation: tidakAdaTugas ? 0 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      icon: Icon(tidakAdaTugas ? Icons.block_rounded : Icons.play_circle_filled_rounded, color: tidakAdaTugas ? Colors.grey.shade600 : Colors.white, size: 18),
      label: Text(
        tidakAdaTugas ? "TIADA TUGAS" : "MULAI JEMPUT",
        style: TextStyle(color: tidakAdaTugas ? Colors.grey.shade700 : Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final Map<String, dynamic>? dashboardData;
  const _InsightCard({this.dashboardData});

  @override
  Widget build(BuildContext context) {
    String beratBulanIni = dashboardData?['berat_bulan_ini']?.toString() ?? '0';
    String keteranganTren = dashboardData?['keterangan_tren'] ?? 'Tetap semangat menjaga kebersihan lingkungan bersama ASRI.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Bulan ini Bapak/Ibu sudah berhasil mengumpulkan total $beratBulanIni Kg sampah lingkungan.\n\n$keteranganTren",
              style: const TextStyle(height: 1.5, color: darkTextColor, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ActivityCard({required this.data});

  @override
  Widget build(BuildContext context) {
    String namaJenis = data['jenis_sampah']?['nama'] ?? 'Sampah';
    String tanggal = data['created_at_formatted'] ?? data['created_at'] ?? '-';
    String totalHarga = "Rp ${data['total']?.toString() ?? '0'}";
    String beratSampah = "${data['berat']?.toString() ?? '0'} Kg";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: softGreenColor, shape: BoxShape.circle),
            child: const Icon(Icons.check_circle_rounded, color: primaryColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(namaJenis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkTextColor)),
                const SizedBox(height: 4),
                Text(tanggal, style: const TextStyle(fontSize: 12, color: greyTextColor, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(totalHarga, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primaryColor)),
              const SizedBox(height: 4),
              Text(beratSampah, style: const TextStyle(fontSize: 13, color: darkTextColor, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScanFab extends StatelessWidget {
  final String? jadwalId;
  const _ScanFab({required this.jadwalId});

  @override
  Widget build(BuildContext context) {
    bool adaJadwal = jadwalId != null && jadwalId!.isNotEmpty;
    return Container(
      height: 68,
      width: 68,
      margin: const EdgeInsets.only(bottom: 8),
      child: FloatingActionButton(
        elevation: 6,
        backgroundColor: adaJadwal ? primaryColor : Colors.orange.shade800,
        shape: const CircleBorder(),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ScanBarcodePage(jadwalId: jadwalId.toString())),
          );
          if (result == true) {
            context.findAncestorStateOfType<_DashboardKurirState>()?.getDashboard();
          }
        },
        child: const Icon(Icons.qr_code_scanner_rounded, size: 30, color: Colors.white),
      ),
    );
  }
}

BoxDecoration cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: primaryColor.withOpacity(0.12),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.03),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}