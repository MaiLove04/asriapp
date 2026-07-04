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

class EdukasiKurirPage extends StatefulWidget {
  const EdukasiKurirPage({super.key});

  @override
  State<EdukasiKurirPage> createState() => _EdukasiKurirPageState();
}

class _EdukasiKurirPageState extends State<EdukasiKurirPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<JenisSampah> listJenis = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Pusat Edukasi & Panduan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 4,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "JENIS SAMPAH"),
            Tab(text: "PANDUAN"),
            Tab(text: "FAQ"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildKatalogSampah(),
          _buildPanduanAplikasi(),
          _buildFAQ(),
        ],
      ),
    );
  }

  Widget _buildKatalogSampah() {
    if (isLoading) return const Center(child: CircularProgressIndicator(color: primaryColor));
    if (listJenis.isEmpty) {
      return const Center(child: Text("Data jenis sampah tidak ditemukan", style: TextStyle(color: greyTextColor)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: listJenis.length,
      itemBuilder: (context, index) {
        final item = listJenis[index];
        final hargaFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(item.harga);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: softGreenColor, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.recycling_rounded, color: primaryColor, size: 32),
            ),
            title: Text(item.nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkTextColor)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text("Estimasi: $hargaFormat / Kg", style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Text(_getDeskripsiSampah(item.nama), style: const TextStyle(color: greyTextColor, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getDeskripsiSampah(String nama) {
    nama = nama.toLowerCase();
    if (nama.contains("plastik")) return "Pastikan plastik dalam keadaan bersih dan kering. Lepas label jika memungkinkan.";
    if (nama.contains("kertas") || nama.contains("karton")) return "Kertas HVS, koran, atau kardus kering. Jangan dicampur dengan kertas karbon.";
    if (nama.contains("logam") || nama.contains("besi")) return "Kaleng minuman, besi tua, atau tembaga. Pastikan tidak berkarat parah.";
    if (nama.contains("kaca")) return "Botol kaca atau pecahan kaca. Harap berhati-hati saat menangani kategori ini.";
    return "Kategori sampah ini dapat ditimbang dan ditukar dengan saldo sesuai berat yang terukur.";
  }

  Widget _buildPanduanAplikasi() {
    final panduan = [
      {"judul": "Cara Jemput Sampah", "isi": "1. Buka menu 'Tugas Hari Ini'.\n2. Pilih lokasi nasabah.\n3. Tekan 'Mulai Jemput' untuk navigasi."},
      {"judul": "Cara Timbang & Input", "isi": "1. Gunakan timbangan IOT atau manual.\n2. Scan QR Code nasabah saat di lokasi.\n3. Masukkan berat sampah per kategori.\n4. Konfirmasi transaksi bersama nasabah."},
      {"judul": "Sistem Saldo", "isi": "Saldo nasabah akan otomatis bertambah setelah kurir menekan tombol 'Selesai' di aplikasi."},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: panduan.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade200)),
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            leading: CircleAvatar(backgroundColor: primaryColor, radius: 15, child: Text("${index + 1}", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
            title: Text(panduan[index]["judul"]!, style: const TextStyle(fontWeight: FontWeight.bold, color: darkTextColor, fontSize: 16)),
            children: [
              Text(panduan[index]["isi"]!, style: const TextStyle(color: greyTextColor, fontSize: 14, height: 1.6)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFAQ() {
    final faqs = [
      {"q": "Apa yang dilakukan jika nasabah tidak ada?", "a": "Kurir dapat menandai tugas sebagai 'Gagal' dengan alasan yang jelas, atau menghubungi nasabah via telepon jika tersedia."},
      {"q": "Timbangan IOT tidak konek?", "a": "Pastikan Bluetooth aktif. Jika tetap gagal, gunakan mode 'Input Manual' di halaman penimbangan."},
      {"q": "Bagaimana jika jenis sampah tercampur?", "a": "Sarankan nasabah untuk memilah terlebih dahulu atau kategorikan sebagai 'Sampah Residu/Campuran' jika tersedia."},
      {"q": "Salah input berat, bagaimana?", "a": "Hubungi admin melalui grup atau menu pengaduan untuk revisi data transaksi sebelum akhir hari."},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: softGreenColor)),
          child: ExpansionTile(
            title: Text(faqs[index]["q"]!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primaryColor)),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Text(faqs[index]["a"]!, style: const TextStyle(fontSize: 14, color: darkTextColor, height: 1.5)),
              ),
            ],
          ),
        );
      },
    );
  }
}
