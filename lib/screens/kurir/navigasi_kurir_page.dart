import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/dashboard_kurir_service.dart';
import '../../config.dart';
import 'ScanBarcode.dart'; // 🔥 Import Scan Barcode

const primaryColor = Color(0xFF1E521E);
const secondaryColor = Color(0xFF4CAF50);
const softGreenColor = Color(0xFFE8F5E9);
const backgroundColor = Color(0xFFF9FBF9);
const darkTextColor = Color(0xFF0D240D);
const greyTextColor = Color(0xFF555555);

class NavigasiKurirPage extends StatefulWidget {
  final Map<String, dynamic>? initialJadwalData;
  const NavigasiKurirPage({super.key, this.initialJadwalData});

  @override
  State<NavigasiKurirPage> createState() => _NavigasiKurirPageState();
}

class _NavigasiKurirPageState extends State<NavigasiKurirPage> {
  bool _isLoading = true;
  int nasabahId = 0;
  String alamatNasabah = "Memuat...";
  int jadwalId = 0;
  String statusJemput = "terjadwal";

  @override
  void initState() {
    super.initState();
    if (widget.initialJadwalData != null) {
      _applyData(widget.initialJadwalData!);
    } else {
      _loadDataJadwalDariDatabase();
    }
  }

  void _applyData(Map<String, dynamic> j) {
    setState(() {
      jadwalId = int.tryParse(j['id'].toString()) ?? 0;
      nasabahId = int.tryParse(j['nasabah_id']?.toString() ?? '') ?? 
                  int.tryParse(j['user_id']?.toString() ?? '') ?? 0;
      alamatNasabah = j['alamat'] ?? "Alamat tidak diisi";
      statusJemput = (j['status'] ?? 'terjadwal').toString().toLowerCase();
      _isLoading = false;
    });
  }

  Future<void> _loadDataJadwalDariDatabase() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('user_id') ?? 0;
      if (userId == 0) { setState(() { _isLoading = false; }); return; }

      final result = await DashboardKurirService.getDashboard(userId);
      if (result != null && result['jadwal'] != null) {
        _applyData(result['jadwal']);
      } else {
        setState(() { _isLoading = false; });
      }
    } catch (e) {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _openGoogleMaps() async {
    final Uri url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$alamatNasabah");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal membuka Google Maps")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: backgroundColor, body: Center(child: CircularProgressIndicator(color: primaryColor)));
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0, backgroundColor: primaryColor,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text("Navigasi & Status", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🗺️ TOMBOL GOOGLE MAPS (Utama)
            SizedBox(
              width: double.infinity, height: 64,
              child: ElevatedButton.icon(
                onPressed: _openGoogleMaps,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                icon: const Icon(Icons.map_rounded, color: Colors.white, size: 28),
                label: const Text("BUKA GOOGLE MAPS", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16)),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 📍 STATUS PENJEMPUTAN
            const Text("Progres Penjemputan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: darkTextColor)),
            const SizedBox(height: 20),
            _statusStep("Menunggu", "Jadwal telah dibuat", true, isFirst: true),
            _statusStep("Dalam Perjalanan", "Kurir sedang menuju lokasi", statusJemput == 'proses' || statusJemput == 'selesai'),
            _statusStep("Tiba & Timbang", "Proses penimbangan sampah", statusJemput == 'selesai', isLast: true),
            
            const SizedBox(height: 60),
            
            // 📸 TOMBOL SCAN BARCODE (Paling Bawah)
            if (statusJemput != 'selesai')
              SizedBox(
                width: double.infinity, height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ScanBarcodePage(
                          jadwalId: jadwalId,
                          nasabahId: nasabahId,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 6,
                  ),
                  icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
                  label: const Text("SCAN QR NASABAH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusStep(String title, String desc, bool isDone, {bool isFirst = false, bool isLast = false}) {
    return Row(
      children: [
        Column(
          children: [
            Container(width: 3, height: 25, color: isFirst ? Colors.transparent : (isDone ? primaryColor : Colors.grey.shade300)),
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(shape: BoxShape.circle, color: isDone ? primaryColor : Colors.white, border: Border.all(color: isDone ? primaryColor : Colors.grey.shade300, width: 3)),
              child: isDone ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
            ),
            Container(width: 3, height: 25, color: isLast ? Colors.transparent : (isDone ? primaryColor : Colors.grey.shade300)),
          ],
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: isDone ? darkTextColor : greyTextColor)),
            Text(desc, style: TextStyle(fontSize: 13, color: isDone ? greyTextColor : Colors.grey.shade400)),
          ],
        ),
      ],
    );
  }
}
