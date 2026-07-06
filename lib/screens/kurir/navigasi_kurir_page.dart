import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/jadwal_service.dart';
import '../../config.dart';
import '../kurir/SetorSampahPage.dart';

// 🎨 PALET WARNA KONSISTEN PREMIUM ASRI
const primaryColor = Color(0xFF1B4D1B);
const secondaryColor = Color(0xFF2E7D32);
const softGreenColor = Color(0xFFF0F7F1);
const backgroundColor = Color(0xFFF4F7F4);
const darkTextColor = Color(0xFF0A1F0A);
const greyTextColor = Color(0xFF4A554A);

class NavigasiKurirPage extends StatefulWidget {
  const NavigasiKurirPage({super.key});

  @override
  State<NavigasiKurirPage> createState() => _NavigasiKurirPageState();
}

class _NavigasiKurirPageState extends State<NavigasiKurirPage> {
  bool _isLoading = true;
  List<dynamic> _daftarRute = [];

  @override
  void initState() {
    super.initState();
    _loadSemuaRuteHariIni();
  }

  Future<void> _loadSemuaRuteHariIni() async {
    try {
      setState(() { _isLoading = true; });
      SharedPreferences prefs = await SharedPreferences.getInstance();

      int userId = 0;
      var rawId = prefs.get('user_id');
      if (rawId is int) {
        userId = rawId;
      } else if (rawId is String) {
        userId = int.tryParse(rawId) ?? 0;
      }

      if (userId == 0) {
        setState(() { _isLoading = false; });
        return;
      }

      final result = await JadwalService.getJadwalKurir(userId);

      if (!mounted) return;
      setState(() {
        _daftarRute = result ?? [];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Gagal sinkronisasi data rute berantai: $e");
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _bukaGoogleMaps(String alamat) async {
    final String query = Uri.encodeComponent(alamat);
    final Uri url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tidak dapat membuka Google Maps")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalTugas = _daftarRute.length;
    int tugasSelesai = _daftarRute.where((item) {
      String status = (item['status'] ?? '').toString().toLowerCase();
      return status == 'selesai' || status == 'completed';
    }).length;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor, strokeWidth: 3))
          : RefreshIndicator(
        color: primaryColor,
        onRefresh: _loadSemuaRuteHariIni,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              elevation: 0,
              backgroundColor: primaryColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              centerTitle: true,
              title: const Text(
                "Rute Penjemputan",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryColor, Color(0xFF143A14)],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                                "Daftar Urutan Jalan",
                                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)
                            ),
                            Text(
                                "$tugasSelesai / $totalTugas Lokasi Selesai",
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Container(
                height: 20,
                decoration: const BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
              ),
            ),

            _daftarRute.isEmpty
                ? SliverFillRemaining(child: _buildStateKosong())
                : SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final item = _daftarRute[index];
                    final nasabahObj = item['nasabah'] ?? item['user'];

                    String idJadwal = item['id']?.toString() ?? "0";
                    int nasabahId = int.tryParse(item['nasabah_id']?.toString() ?? nasabahObj?['id']?.toString() ?? '0') ?? 0;
                    String nama = nasabahObj?['name'] ?? "Nasabah ASRI";
                    String alamat = item['alamat'] ?? "Alamat tidak diisi";
                    String catatan = item['catatan'] ?? "Ambil sampah berkala";
                    String status = (item['status'] ?? 'terjadwal').toString().toLowerCase();

                    bool isSelesai = status == 'selesai' || status == 'completed';

                    bool isUrutanPertamaAktif = false;
                    if (!isSelesai) {
                      int indexAktifPertama = _daftarRute.indexWhere((element) {
                        String s = (element['status'] ?? '').toString().toLowerCase();
                        return s != 'selesai' && s != 'completed';
                      });
                      isUrutanPertamaAktif = (index == indexAktifPertama);
                    }

                    return _buildRuteItemCard(
                      index: index + 1,
                      idJadwal: idJadwal,
                      nasabahId: nasabahId,
                      nama: nama,
                      alamat: alamat,
                      catatan: catatan,
                      isSelesai: isSelesai,
                      isAktif: isUrutanPertamaAktif,
                    );
                  },
                  childCount: _daftarRute.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildStateKosong() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_bike_rounded, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            "Tidak Ada Jadwal Rute Jalan\nUntuk Hari Ini",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: greyTextColor, fontWeight: FontWeight.bold, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildRuteItemCard({
    required int index,
    required String idJadwal,
    required int nasabahId,
    required String nama,
    required String alamat,
    required String catatan,
    required bool isSelesai,
    required bool isAktif,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(isAktif),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelesai ? Colors.grey.shade400 : (isAktif ? primaryColor : Colors.grey.shade300),
                  shape: BoxShape.circle,
                ),
                child: Text("$index", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  nama,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelesai ? greyTextColor : darkTextColor,
                    decoration: isSelesai ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              _buildBadgeStatus(isSelesai, isAktif),
            ],
          ),
          const Divider(height: 24, thickness: 1),

          _rowDetail(Icons.location_on_rounded, "Alamat Penjemputan:", alamat, isSelesai),
          const SizedBox(height: 12),
          _rowDetail(Icons.chat_bubble_rounded, "Catatan Lapangan:", catatan, isSelesai),

          if (isAktif) ...[
            const SizedBox(height: 20),
            // Tombol diubah menjadi full width (double.infinity) karena hanya tersisa Peta Maps
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _bukaGoogleMaps(alamat),
                icon: const Icon(Icons.map_rounded, size: 18),
                label: const Text("PETA MAPS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildBadgeStatus(bool isSelesai, bool isAktif) {
    String txt = isSelesai ? "SELESAI" : (isAktif ? "SEKARANG" : "ANTREAN");
    Color bg = isSelesai ? Colors.grey.shade200 : (isAktif ? softGreenColor : Colors.orange.shade50);
    Color fg = isSelesai ? Colors.grey.shade600 : (isAktif ? primaryColor : Colors.orange.shade900);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(txt, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg)),
    );
  }

  Widget _rowDetail(IconData icon, String label, String value, bool isSelesai) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: isSelesai ? Colors.grey : secondaryColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: isSelesai ? Colors.grey : greyTextColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelesai ? Colors.grey : darkTextColor,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

BoxDecoration cardDecoration(bool isAktif) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: isAktif ? primaryColor : primaryColor.withOpacity(0.12),
      width: isAktif ? 2.0 : 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(isAktif ? 0.06 : 0.03),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}