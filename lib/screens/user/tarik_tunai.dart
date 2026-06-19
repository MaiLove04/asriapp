import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config.dart';
import '../services/tarik_tunai_service.dart'; // Import service baru
import 'riwayat_tarik_tunai.dart'; // Nanti kita buat halaman riwayatnya

const primaryColor = Color(0xFF1E521E);
const softGreenColor = Color(0xFFE8F5E9);
const backgroundColor = Color(0xFFF9FBF9);
const darkTextColor = Color(0xFF0D240D);

class TarikTunaiPage extends StatefulWidget {
  const TarikTunaiPage({super.key});

  @override
  State<TarikTunaiPage> createState() => _TarikTunaiPageState();
}

class _TarikTunaiPageState extends State<TarikTunaiPage> {
  final TarikTunaiService _tarikService = TarikTunaiService();
  int _saldo = 0;
  int _nominal = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  int _userId = 0;

  final TextEditingController _nominalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _userId = prefs.getInt('user_id') ?? 0;

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/dashboard-nasabah/$_userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _saldo = int.tryParse(data['nasabah']['saldo'].toString()) ?? 0;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _setNominal(int value) {
    setState(() {
      _nominal = value;
      _nominalController.text = value.toString();
    });
  }

  Future<void> _kirimRequestTarik() async {
    if (_nominal < 1000) {
      _showPesan("Minimal penarikan adalah Rp 1.000", Colors.red);
      return;
    }

    if (_nominal > _saldo) {
      _showPesan("Saldo Anda tidak mencukupi.", Colors.red);
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await _tarikService.createRequestTarik(jumlahNominal: _nominal);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (result['success']) {
        _showSuksesDialog();
      } else {
        _showPesan(result['message'], Colors.red);
      }
    }
  }

  void _showSuksesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, color: primaryColor, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Request Berhasil!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              "Silakan datang ke Bank Sampah dan tunjukkan kartu nasabah Anda untuk mengambil uang tunai sebesar ${_formatRupiah(_nominal)}.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context); // Kembali ke dashboard
              },
              child: const Text("Selesai", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  void _showPesan(String pesan, Color warna) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan), backgroundColor: warna, behavior: SnackBarBehavior.floating),
    );
  }

  String _formatRupiah(int angka) => "Rp " + NumberFormat.decimalPattern('id').format(angka);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: const Text("Request Tarik Tunai", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RiwayatTarikTunaiPage())),
            icon: const Icon(Icons.history, color: Colors.white),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CARD SALDO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text("Saldo Anda", style: TextStyle(color: Colors.white70)),
                  Text(_formatRupiah(_saldo), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text("Masukkan Nominal Penarikan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: _nominalController,
              keyboardType: TextInputType.number,
              onChanged: (val) => setState(() => _nominal = int.tryParse(val) ?? 0),
              decoration: InputDecoration(
                hintText: "Contoh: 50000",
                prefixIcon: const Icon(Icons.payments, color: primaryColor),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [5000, 10000, 20000, 50000].map((val) => _quickOption(val)).toList(),
            ),
            const SizedBox(height: 40),
            const Text("Informasi:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const Text("Penarikan akan diproses secara tunai oleh Admin Bank Sampah saat Anda berkunjung.", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _kirimRequestTarik,
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Buat Request Penarikan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickOption(int value) {
    return InkWell(
      onTap: () => _setNominal(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: _nominal == value ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primaryColor),
        ),
        child: Text(
          NumberFormat.compact().format(value),
          style: TextStyle(color: _nominal == value ? Colors.white : primaryColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}