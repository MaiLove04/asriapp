import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:asriapp/config.dart';
import '../kurir/SetorSampahPage.dart';

const primaryColor = Color(0xFF1E521E);
const backgroundColor = Color(0xFFF9FBF9);

class ScanBarcodePage extends StatefulWidget {
  final int jadwalId;
  final int nasabahId; // ID Nasabah dari jadwal (jika ada)

  const ScanBarcodePage({
    super.key,
    this.jadwalId = 0,
    this.nasabahId = 0,
  });

  @override
  State<ScanBarcodePage> createState() => _ScanBarcodePageState();
}

class _ScanBarcodePageState extends State<ScanBarcodePage> {
  final MobileScannerController controller = MobileScannerController();
  bool isScanCompleted = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleScan(String kode) async {
    if (isScanCompleted) return;
    setState(() => isScanCompleted = true);

    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/nasabah/qrcode/$kode'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final int scannedId = data['id'];

        // Jika ini dari Dashboard (jadwalId 0) atau Scanned ID cocok dengan jadwal
        int finalJadwalId = (widget.jadwalId != 0 && scannedId == widget.nasabahId) 
            ? widget.jadwalId 
            : 0;

        if (mounted) {
          // Langsung pindah ke Form Timbang tanpa dialog bertele-tele
          final result = await Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SetorSampahPage(
                nasabahId: scannedId,
                namaNasabah: data['name'],
                alamat: data['alamat'],
                barcode: kode,
                jadwalId: finalJadwalId,
              ),
            ),
          );
          if (result == true) Navigator.pop(context, true);
        }
      } else {
        _showError("Nasabah tidak ditemukan!");
      }
    } catch (e) {
      _showError("Gagal memproses data.");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    setState(() => isScanCompleted = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: primaryColor, title: const Text("Scan QR Nasabah", style: TextStyle(color: Colors.white))),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
            _handleScan(barcodes.first.rawValue!);
          }
        },
      ),
    );
  }
}
