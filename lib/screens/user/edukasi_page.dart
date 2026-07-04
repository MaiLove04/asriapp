import 'package:flutter/material.dart';
import '../services/jenis_sampah_service.dart';
import '../models/jenis_sampah.dart';
import 'package:intl/intl.dart';

const primaryColor = Color(0xFF1E521E);
const secondaryColor = Color(0xFF4CAF50);
const softGreenColor = Color(0xFFE8F5E9);
const backgroundColor = Color(0xFFF9FBF9);
const darkTextColor = Color(0xFF0D240D);
const greyTextColor = Color(0xFF555555);

class EdukasiPage extends StatefulWidget {
  const EdukasiPage({super.key});

  @override
  State<EdukasiPage> createState() => _EdukasiPageState();
}

class _EdukasiPageState extends State<EdukasiPage> {
  List<JenisSampah> listJenis = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJenisSampah();
  }

  Future<void> _fetchJenisSampah() async {
    try {
      final data = await JenisSampahService.getData();
      setState(() {
        listJenis = data;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: const Text("Edukasi Sampah",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER EDUKASI =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.psychology_rounded, color: Colors.white, size: 60),
                  const SizedBox(height: 12),
                  const Text(
                    "Mari Memilah Sampah",
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Pilah sampahmu dari rumah untuk bumi yang lebih bersih dan tabungan yang lebih banyak!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ================= TIPS MEMILAH =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tips Memilah Sampah",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkTextColor)),
                  const SizedBox(height: 16),
                  _buildTipsCard(
                    Icons.cleaning_services_rounded,
                    "Bersihkan & Keringkan",
                    "Pastikan botol, plastik, atau kaleng dalam keadaan kosong dan kering sebelum disetor.",
                  ),
                  _buildTipsCard(
                    Icons.category_rounded,
                    "Pisahkan Berdasarkan Jenis",
                    "Jangan campur kertas dengan plastik atau logam agar mempermudah proses penimbangan.",
                  ),
                  _buildTipsCard(
                    Icons.compress_rounded,
                    "Padatkan Sampah",
                    "Remas botol plastik atau lipat kardus agar hemat tempat dan mudah dibawa kurir.",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ================= KATALOG JENIS SAMPAH =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const Text("Katalog Jenis Sampah",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkTextColor)),
            ),
            const SizedBox(height: 16),

            isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryColor))
                : listJenis.isEmpty
                    ? const Center(child: Text("Data jenis sampah tidak tersedia"))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: listJenis.length,
                        itemBuilder: (context, index) {
                          final item = listJenis[index];
                          final hargaFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(item.harga);
                          return _buildJenisCard(item.nama, hargaFormat, _getDeskripsiSampah(item.nama));
                        },
                      ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard(IconData icon, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: softGreenColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkTextColor)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 12, color: greyTextColor, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJenisCard(String nama, String harga, String deskripsi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: softGreenColor, shape: BoxShape.circle),
            child: const Icon(Icons.recycling_rounded, color: primaryColor, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkTextColor)),
                    Text(harga, style: const TextStyle(fontWeight: FontWeight.w900, color: secondaryColor, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(deskripsi, style: const TextStyle(fontSize: 13, color: greyTextColor, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDeskripsiSampah(String nama) {
    nama = nama.toLowerCase();
    if (nama.contains("plastik")) return "Botol minum, gelas plastik, kantong kresek, dll. Bersihkan dari sisa cairan.";
    if (nama.contains("kertas") || nama.contains("karton")) return "Kardus, kertas HVS, koran, majalah. Pastikan tidak terkena air atau minyak.";
    if (nama.contains("logam") || nama.contains("besi")) return "Kaleng minuman, besi tua, tembaga, kuningan. Bilas sisa makanan jika ada.";
    if (nama.contains("kaca")) return "Botol kaca, toples. Hati-hati jangan sampai pecah.";
    return "Sampah yang dapat didaur ulang sesuai kategori yang ditentukan.";
  }
}
