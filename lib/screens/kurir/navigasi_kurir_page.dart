import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // 🔥 Import modul peta
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/jadwal_service.dart';
import '../../config.dart';

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
  final MapController _mapController = MapController();

  // Titik default pusat peta (Bangka Belitung / Menyesuaikan lokasi pangkalan bank sampah)
  LatLng _pusatPeta = const LatLng(-2.1299, 106.1128);
  List<Marker> _markersPeta = [];

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

      List<dynamic> dataRute = result ?? [];
      List<Marker> temporaryMarkers = [];

      // Loop data dari backend untuk membuat titik penanda lokasi di peta
      for (int i = 0; i < dataRute.length; i++) {
        final item = dataRute[i];

        // Membaca koordinat latitude & longitude dari API backend jika tersedia
        double lat = double.tryParse(item['latitude']?.toString() ?? '') ?? (-2.1299 + (i * 0.005));
        double lng = double.tryParse(item['longitude']?.toString() ?? '') ?? (106.1128 + (i * 0.005));

        String status = (item['status'] ?? 'terjadwal').toString().toLowerCase();
        bool isSelesai = status == 'selesai' || status == 'completed';

        temporaryMarkers.add(
          Marker(
            point: LatLng(lat, lng),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () {
                _mapController.move(LatLng(lat, lng), 16.0);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Titik ${i + 1}: ${item['nasabah']?['name'] ?? 'Nasabah'}"),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                      Icons.location_on_rounded,
                      size: 40,
                      color: isSelesai ? Colors.grey : (i == 0 ? Colors.blue.shade800 : primaryColor)
                  ),
                  Positioned(
                    top: 5,
                    child: Text(
                      "${i + 1}",
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }

      setState(() {
        _daftarRute = dataRute;
        _markersPeta = temporaryMarkers;
        if (_markersPeta.isNotEmpty) {
          _pusatPeta = _markersPeta.first.point; // Fokuskan peta ke tujuan pertama
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Gagal memuat rute dan koordinat peta: $e");
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
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Rute: $tugasSelesai / $totalTugas Lokasi Selesai",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _loadSemuaRuteHariIni,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor, strokeWidth: 3))
          : Stack(
        children: [
          // ================= LAYER 1: TAMPILAN PETA DIGITAL =================
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _pusatPeta,
              initialZoom: 14.0,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.asri.app',
              ),
              MarkerLayer(markers: _markersPeta),
            ],
          ),

          // ================= LAYER 2: PANEL LIST JALAN (BOTTOM SHEET DRAGGABLE) =================
          _daftarRute.isEmpty
              ? _buildStateKosong()
              : DraggableScrollableSheet(
            initialChildSize: 0.35, // Tinggi awal daftar tugas saat pertama dibuka
            minChildSize: 0.15,     // Tinggi minimum saat panel diciutkan
            maxChildSize: 0.85,     // Tinggi maksimum saat ditarik ke atas
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2))],
                ),
                child: Column(
                  children: [
                    // Handle penarik panel
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10)),
                    ),
                    const Text(
                      "Geser Ke Atas Untuk Detail Urutan Jalan",
                      style: TextStyle(fontSize: 12, color: greyTextColor, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        itemCount: _daftarRute.length,
                        itemBuilder: (context, index) {
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
                            lat: double.tryParse(item['latitude']?.toString() ?? '') ?? _pusatPeta.latitude,
                            lng: double.tryParse(item['longitude']?.toString() ?? '') ?? _pusatPeta.longitude,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStateKosong() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_bike_rounded, size: 44, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            const Text(
              "Tidak Ada Jadwal Rute Jalan Hari Ini",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: greyTextColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
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
    required double lat,
    required double lng,
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
                child: InkWell(
                  onTap: () {
                    // Ketika baris nama ditekan, peta akan bergeser fokus ke titik koordinat nasabah tersebut
                    _mapController.move(LatLng(lat, lng), 16.0);
                  },
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
                style: TextStyle(fontSize: 14, color: isSelesai ? Colors.grey : darkTextColor, fontWeight: FontWeight.w500, height: 1.4),
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