import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:asriapp/config.dart';
import '../kurir/SetorSampahPage.dart';

// 🎨 PALET WARNA UTAMA (Tema Konsisten Senior-Friendly Mai)
const primaryColor = Color(0xFF1E521E);
const backgroundColor = Color(0xFFF9FBF9);

class ScanBarcodePage extends StatefulWidget {
  final int jadwalId;
  final int scheduledNasabahId;

  const ScanBarcodePage({
    super.key,
    required this.jadwalId,
    this.scheduledNasabahId = 0,
  });

  @override
  State<ScanBarcodePage> createState() => _ScanBarcodePageState();
}

class _ScanBarcodePageState extends State<ScanBarcodePage> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  // Status kunci agar tidak terjadi double-trigger navigasi saat scan
  bool isScanCompleted = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pindai Barcode Nasabah',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 20, letterSpacing: -0.5),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryColor, Color(0xFF2E6B2E)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              // ========================================================
              // HEADER CARD BANNER (Informasi Petunjuk Kurir)
              // ========================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, Color(0xFF2E6B2E)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scanner Aktif',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.3),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Arahkan kamera ke barcode nasabah. Sistem akan otomatis mengalihkan Anda ke formulir input berat sampah.',
                            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 42,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // ========================================================
              // LIVE CAMERA SCANNER BLOCK (Murni Kotak Kamera)
              // ========================================================
              Container(
                height: 380, // Ukuran kotak kamera dibuat sedikit lebih besar dan lega
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.grey.shade200, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: MobileScanner(
                    controller: controller,
                    onDetect: (capture) async {
                      // Kunci agar tidak memproses scan berkali-kali dalam satu detik
                      if (isScanCompleted) return;

                      final List<Barcode> barcodes = capture.barcodes;
                      if (barcodes.isEmpty) return;

                      final String? kode = barcodes.first.rawValue;

                      if (kode != null) {
                        setState(() {
                          isScanCompleted = true; // Kunci scanner aktif
                        });

                        // Toast notifikasi loading kilat sebelum lompat halaman
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🔍 Memproses Barcode Nasabah...'),
                              duration: Duration(milliseconds: 700),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }

                        try {
                          final response = await http.get(
                            Uri.parse('${AppConfig.baseUrl}/nasabah/qrcode/$kode'),
                          );

                          if (response.statusCode == 200) {
                            final data = jsonDecode(response.body);
                            final int scannedNasabahId = data['id'];

                            // LOGIKA PINTAR:
                            // Jika yang discan ADALAH nasabah di jadwal -> Gunakan jadwalId asli.
                            // Jika yang discan BUKAN nasabah di jadwal -> Gunakan jadwalId = 0 (Request Baru).
                            int finalJadwalId = (scannedNasabahId == widget.scheduledNasabahId) 
                                ? widget.jadwalId 
                                : 0;

                            if (mounted) {
                              // Tampilkan Dialog Konfirmasi sebelum masuk ke halaman setor
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: Row(
                                    children: [
                                      const Icon(Icons.person_pin_rounded, color: primaryColor),
                                      const SizedBox(width: 10),
                                      const Text("Nasabah Ditemukan", style: TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Nama: ${data['name']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 5),
                                      Text("Alamat: ${data['alamat']}", style: const TextStyle(color: Colors.grey)),
                                      const SizedBox(height: 15),
                                      const Divider(),
                                      Text(
                                        finalJadwalId == 0 
                                          ? "Mendeteksi Request Baru/Lainnya..." 
                                          : "Mode Penjemputan Terjadwal.",
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic, 
                                          fontSize: 12, 
                                          color: finalJadwalId == 0 ? Colors.orange.shade800 : primaryColor
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        setState(() => isScanCompleted = false);
                                      },
                                      child: const Text("BATAL", style: TextStyle(color: Colors.red)),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                      onPressed: () async {
                                        Navigator.pop(ctx);
                                        // Baru pindah ke halaman timbangan
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => SetorSampahPage(
                                              nasabahId: data['id'],
                                              namaNasabah: data['name'],
                                              alamat: data['alamat'],
                                              barcode: kode,
                                              jadwalId: finalJadwalId,
                                            ),
                                          ),
                                        );

                                        if (result == true && mounted) {
                                          Navigator.pop(context, true);
                                        } else {
                                          setState(() => isScanCompleted = false);
                                        }
                                      },
                                      child: const Text("PROSES", style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            }
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('❌ Kode barcode nasabah tidak terdaftar!'),
                                  backgroundColor: Colors.red.shade800,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                            setState(() { isScanCompleted = false; }); // Buka kembali scanner
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('⚠️ Gangguan Koneksi Backend: $e'),
                                backgroundColor: Colors.red.shade800,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          }
                          setState(() { isScanCompleted = false; }); // Buka kembali scanner
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}