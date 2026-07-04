import 'package:flutter/material.dart';
import '../services/jenis_sampah_service.dart';
import '../models/jenis_sampah.dart';
import 'package:intl/intl.dart';

// Palet warna premium dengan kontras tinggi (Senior-Friendly & Professional)
const primaryColor = Color(0xFF1B4D1B);     // Hijau dalam yang solid
const secondaryColor = Color(0xFF2E7D32);   // Hijau aktif untuk aksen
const softGreenColor = Color(0xFFF0F7F1);   // Background elemen penyejuk mata
const backgroundColor = Color(0xFFF4F7F4);  // Abu-hijau muda kontras maksimal
const darkTextColor = Color(0xFF0A1F0A);    // Teks utama super pekat
const greyTextColor = Color(0xFF4A554A);    // Teks deskripsi kontras tinggi

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
        title: const Text("Pusat Panduan & Edukasi", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 4,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: "KATALOG SAMPAH"),
            Tab(text: "PANDUAN JALAN"),
            Tab(text: "TANYA JAWAB"),
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

  // === 1. TAB KATALOG SAMPAH (Desain Elegan & Kontras Tinggi) ===
  Widget _buildKatalogSampah() {
    if (isLoading) return const Center(child: CircularProgressIndicator(color: primaryColor, strokeWidth: 3));
    if (listJenis.isEmpty) {
      return const Center(
        child: Text("Data jenis sampah belum tersedia.", style: TextStyle(color: greyTextColor, fontSize: 16, fontWeight: FontWeight.w500)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: listJenis.length,
      itemBuilder: (context, index) {
        final item = listJenis[index];
        final hargaFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(item.harga);

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: cardDecoration(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: softGreenColor, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.recycling_rounded, color: primaryColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.nama, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkTextColor)),
                    const SizedBox(height: 4),
                    Text("$hargaFormat / Kg", style: const TextStyle(color: secondaryColor, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 10),
                    Text(
                      _getDeskripsiSampah(item.nama),
                      style: const TextStyle(color: greyTextColor, fontSize: 13, height: 1.5, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getDeskripsiSampah(String nama) {
    nama = nama.toLowerCase();
    if (nama.contains("plastik")) return "Wajib bersih & kering. Botol dipres tipis, lepaskan label plastik luarnya jika memungkinkan.";
    if (nama.contains("kertas") || nama.contains("karton")) return "Kardus dibongkar mendatar, pastikan kering total. Jangan dicampur kertas karbon.";
    if (nama.contains("logam") || nama.contains("besi")) return "Bilas kaleng bekas minuman/makanan. Singkirkan benda tajam berbahaya.";
    if (nama.contains("kaca")) return "Botol/jar utuh bersih. Letakkan di wadah terpisah agar aman saat dibawa berkendara.";
    return "Dapat ditimbang dan ditukar saldo transaksi langsung melalui aplikasi sesuai timbangan fisik.";
  }

  // === 2. TAB PANDUAN APLIKASI (Desain Berundak / Step-by-Step UI) ===
  Widget _buildPanduanAplikasi() {
    final panduan = [
      {
        "judul": "Langkah 1: Cara Jemput Sampah",
        "steps": [
          "Buka menu 'Buka Tugas' di halaman utama.",
          "Pilih baris lokasi nasabah yang ingin dituju hari ini.",
          "Tekan tombol 'MULAI JEMPUT' untuk melihat navigasi jalan."
        ]
      },
      {
        "judul": "Langkah 2: Proses Timbang & Input",
        "steps": [
          "Nyalakan Bluetooth untuk timbangan pintar (atau pakai manual).",
          "Pindai/Scan QR Code kartu nasabah di lokasi penjemputan.",
          "Ketikkan berat sampah yang tertera sesuai kategori bendanya.",
          "Cek kembali nominal uang lalu konfirmasi bersama nasabah."
        ]
      },
      {
        "judul": "Langkah 3: Sistem Saldo Nasabah",
        "steps": [
          "Pastikan nasabah menyetujui total timbangan di layar hp.",
          "Tekan tombol 'Selesai Transaksi'.",
          "Saldo nasabah otomatis bertambah detik itu juga tanpa kendala."
        ]
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: panduan.length,
      itemBuilder: (context, index) {
        final item = panduan[index];
        final List<String> steps = item["steps"] as List<String>;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: cardDecoration(),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              iconColor: primaryColor,
              collapsedIconColor: greyTextColor,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: primaryColor.withOpacity(0.08), shape: BoxShape.circle),
                child: const Icon(Icons.menu_book_rounded, color: primaryColor, size: 20),
              ),
              title: Text(item["judul"] as String, style: const TextStyle(fontWeight: FontWeight.bold, color: darkTextColor, fontSize: 15)),
              children: steps.map((stepText) {
                int stepIndex = steps.indexOf(stepText) + 1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: secondaryColor,
                        child: Text("$stepIndex", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          stepText,
                          style: const TextStyle(color: darkTextColor, fontSize: 14, height: 1.4, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // === 3. TAB TANYA JAWAB / FAQ (Desain Kontras & Bold Alert) ===
  Widget _buildFAQ() {
    final faqs = [
      {"q": "Nasabah sedang tidak berada di tempat?", "a": "Bapak/Ibu kurir dapat menandai tugas sebagai 'Gagal' dengan menyertakan alasan, atau coba hubungi nomor telepon nasabah melalui tombol panggil jika tersedia."},
      {"q": "Timbangan digital macet / tidak konek?", "a": "Periksa apakah Bluetooth HP sudah aktif. Jika masih sulit tersambung, gunakan fitur 'Input Manual' di bagian pojok kanan atas layar penimbangan."},
      {"q": "Jenis sampah tercampur aduk di karung?", "a": "Mintalah nasabah dengan sopan untuk memilahnya terlebih dahulu, atau masukkan ke dalam kategori 'Sampah Campuran / Residu' jika terpaksa."},
      {"q": "Salah mengetik angka berat sampah?", "a": "Segera hubungi petugas Admin Kantor lewat grup WA agar dibantu edit data transaksi sebelum hari kerja berakhir."},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: cardDecoration(),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 18),
              iconColor: primaryColor,
              collapsedIconColor: greyTextColor,
              title: Text(faqs[index]["q"]!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor, height: 1.3)),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: softGreenColor, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    faqs[index]["a"]!,
                    style: const TextStyle(fontSize: 14, color: darkTextColor, height: 1.5, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Sistem dekorasi terpusat agar konsisten di seluruh aplikasi kurir ASRI
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