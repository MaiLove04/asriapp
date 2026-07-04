import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/dashboard_kurir_service.dart';
import '../../config.dart';
import '../kurir/SetorSampahPage.dart';

// 🎨 PALET WARNA KONSISTEN SENIOR-FRIENDLY ASRI / BASAYAN BESTARI
const primaryColor = Color(0xFF1E521E);
const secondaryColor = Color(0xFF4CAF50);
const softGreenColor = Color(0xFFE8F5E9);
const backgroundColor = Color(0xFFF9FBF9);
const darkTextColor = Color(0xFF0D240D);
const greyTextColor = Color(0xFF555555);

class NavigasiKurirPage extends StatefulWidget {
  const NavigasiKurirPage({super.key});

  @override
  State<NavigasiKurirPage> createState() => _NavigasiKurirPageState();
}

class _NavigasiKurirPageState extends State<NavigasiKurirPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _liveJadwalData;

  int nasabahId = 0;
  String namaNasabah = "Memuat...";
  String alamatNasabah = "Memuat...";
  String catatanNasabah = "Tidak ada catatan";
  String jadwalId = "";
  String statusJemput = "terjadwal";

  @override
  void initState() {
    super.initState();
    _loadDataJadwalDariDatabase();
  }

  Future<void> _loadDataJadwalDariDatabase() async {
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

      if (userId == 0) {
        setState(() { _isLoading = false; });
        return;
      }

      final result = await DashboardKurirService.getDashboard(userId);

      if (result != null && result['jadwal'] != null) {
        final jadwalObj = result['jadwal'];
        final nasabahObj = jadwalObj['user'] ?? jadwalObj['nasabah'];
        setState(() {
          _liveJadwalData = result;

          jadwalId = jadwalObj['id']?.toString() ?? "0";          nasabahId = int.tryParse(jadwalObj['nasabah_id'].toString()) ?? int.tryParse(jadwalObj['user_id'].toString()) ?? 0;
          namaNasabah = nasabahObj?['name'] ?? "Nasabah Basayan Bestari";
          alamatNasabah = jadwalObj['alamat'] ?? "Alamat tidak diisi";
          catatanNasabah = jadwalObj['catatan'] ?? "Ambil sampah penjemputan";
          statusJemput = (jadwalObj['status'] ?? 'terjadwal').toString().toLowerCase();

          _isLoading = false;
        });
      } else {
        setState(() { _isLoading = false; });
      }
    } catch (e) {
      print("DEBUG MAI - Gagal sinkronisasi data rute: $e");
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _openGoogleMaps() async {
    final Uri url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$alamatNasabah");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal membuka Google Maps")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor, strokeWidth: 4)),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Detail Penjemputan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CARD INFORMASI NASABAH
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: softGreenColor,
                        child: Icon(Icons.person_rounded, color: primaryColor, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(namaNasabah, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: darkTextColor)),
                            const SizedBox(height: 4),
                            Text("ID Jadwal: #$jadwalId", style: const TextStyle(fontSize: 12, color: greyTextColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _infoRow(Icons.location_on_rounded, "Alamat Penjemputan", alamatNasabah),
                  const SizedBox(height: 16),
                  _infoRow(Icons.edit_note_rounded, "Catatan Nasabah", catatanNasabah),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // TOMBOL GOOGLE MAPS
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _openGoogleMaps,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.map_rounded),
                label: const Text("BUKA DI GOOGLE MAPS", style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),

            const SizedBox(height: 32),

            // TIMELINE STATUS
            const Text("Status Penjemputan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: darkTextColor)),
            const SizedBox(height: 16),
            _statusStep("Menunggu", "Jadwal telah dibuat", statusJemput == 'terjadwal' || statusJemput == 'proses' || statusJemput == 'selesai', isFirst: true),
            _statusStep("Dalam Perjalanan", "Kurir sedang menuju lokasi", statusJemput == 'proses' || statusJemput == 'selesai'),
            _statusStep("Tiba & Timbang", "Proses penimbangan sampah", statusJemput == 'selesai', isLast: true),

            const SizedBox(height: 40),

            // TOMBOL AKSI
            if (statusJemput != 'selesai')
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () async {
                  final hasilSetor = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SetorSampahPage(
                        nasabahId: nasabahId,
                        namaNasabah: namaNasabah,
                        alamat: alamatNasabah,
                        barcode: "BRC-${nasabahId}99",
                        jadwalId: jadwalId,
                      ),
                    ),
                  );
                  if (hasilSetor == true) {
                    if (mounted) Navigator.pop(context, true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text("SAYA SUDAH SAMPAI & TIMBANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: greyTextColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: darkTextColor)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusStep(String title, String desc, bool isDone, {bool isFirst = false, bool isLast = false}) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 2,
              height: 20,
              color: isFirst ? Colors.transparent : (isDone ? primaryColor : Colors.grey.shade300),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? primaryColor : Colors.white,
                border: Border.all(color: isDone ? primaryColor : Colors.grey.shade300, width: 2),
              ),
              child: isDone ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
            ),
            Container(
              width: 2,
              height: 20,
              color: isLast ? Colors.transparent : (isDone ? primaryColor : Colors.grey.shade300),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: isDone ? darkTextColor : greyTextColor)),
            Text(desc, style: TextStyle(fontSize: 12, color: isDone ? greyTextColor : Colors.grey.shade400)),
          ],
        ),
      ],
    );
  }
}
