import 'dart:convert';
import 'dart:io';

import 'package:asriapp/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// 🎨 PALET WARNA UTAMA (Tema Konsisten Senior-Friendly Mai)
const primaryColor = Color(0xFF1E521E);
const secondaryColor = Color(0xFF4CAF50);
const softGreenColor = Color(0xFFE8F5E9);
const backgroundColor = Color(0xFFF9FBF9);
const darkTextColor = Color(0xFF0D240D);
const greyTextColor = Color(0xFF555555);

class SetorSampahPage extends StatefulWidget {
  final int nasabahId;
  final String namaNasabah;
  final String alamat;
  final String barcode;
  final int jadwalId;

  const SetorSampahPage({
    super.key,
    required this.nasabahId,
    required this.namaNasabah,
    required this.alamat,
    required this.barcode,
    required this.jadwalId,
  });

  @override
  State<SetorSampahPage> createState() => _SetorSampahPageState();
}

class _SetorSampahPageState extends State<SetorSampahPage> {
  final TextEditingController jenisController = TextEditingController();
  final TextEditingController beratController = TextEditingController();
  final TextEditingController totalController = TextEditingController();

  File? imageFile;
  final picker = ImagePicker();
  List jenisSampahList = [];
  Map<String, dynamic>? selectedJenisSampah;
  int hargaPerKg = 0;

  // State untuk animasi loading saat mengambil data dari alat IoT
  bool isCapturingIot = false;

  // ========================================================
  // AMBIL DATA BERAT DARI TIMBANGAN IOT LARAVEL
  // ========================================================
  Future<void> fetchBeratFromIot() async {
    setState(() {
      isCapturingIot = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/berat-timbangan-iot'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        double beratIot = double.parse(data['berat_iot'].toString());

        setState(() {
          beratController.text = beratIot.toString();
          hitungTotalPendapatan();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("✅ Berat berhasil dimuat dari IoT: $beratIot Kg"),
              backgroundColor: primaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } else {
        throw Exception("Gagal merespon alat timbangan");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Gagal terhubung ke Timbangan IoT: $e"),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isCapturingIot = false;
        });
      }
    }
  }

  // ========================================================
  // HITUNG TOTAL PENDAPATAN
  // ========================================================
  void hitungTotalPendapatan() {
    double berat = double.tryParse(beratController.text) ?? 0;
    int total = (berat * hargaPerKg).round();
    // Memasukkan teks yang sudah diformat titik ribuan ke TextField
    totalController.text = numberFormat(total);
  }

  // ========================================================
  // AMBIL DAFTAR JENIS SAMPAH DARI BACKEND
  // ========================================================
  Future<void> getJenisSampah() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/jenis-sampah'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Jenis Sampah Response: $data');

        setState(() {
          jenisSampahList = data.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      }
    } catch (e) {
      print(e);
    }
  }

  // ========================================================
  // AMBIL FOTO SAMPAH MENGGUNAKAN KAMERA HP
  // ========================================================
  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  // ========================================================
  // SIMPAN DATA SETOR (UPLOAD TEKS + FOTO KE DATABASE)
  // ========================================================
  Future<void> simpanSetorSampah() async {
    String jenis = jenisController.text;
    String berat = beratController.text;

    // Kembalikan ke bentuk angka murni tanpa titik sebelum dikirim ke database Laravel
    String totalRaw = totalController.text.replaceAll('.', '');

    if (jenis.isEmpty || berat.isEmpty || totalRaw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("❌ Semua field wajib diisi!"),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: primaryColor, strokeWidth: 4),
      ),
    );

    try {
      var uri = Uri.parse('${AppConfig.baseUrl}/setor-sampah');
      var request = http.MultipartRequest('POST', uri);

      request.fields['user_id'] = widget.nasabahId.toString();
      request.fields['jadwal_id'] = widget.jadwalId.toString();
      request.fields['kurir_id'] = "14";
      request.fields['jenis_sampah_id'] = selectedJenisSampah?['id'].toString() ?? '';
      request.fields['berat'] = berat;
      request.fields['harga_per_kg'] = hargaPerKg.toString();
      request.fields['total'] = totalRaw;
      request.fields['catatan'] = "Disetor lewat aplikasi kurir";

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'foto_sampah',
            imageFile!.path,
          ),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (mounted) Navigator.pop(context);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("✅ Data setor sampah berhasil masuk database!"),
              backgroundColor: primaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        final errorData = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal: ${errorData['message'] ?? response.reasonPhrase}"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Kesalahan koneksi: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getJenisSampah();
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
          "Setor Sampah",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BARCODE KODE NASABAH (Premium Gradient Box)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryColor, Color(0xFF2E6B2E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: primaryColor.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("KODE BARCODE NASABAH", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.0)),
                  const SizedBox(height: 6),
                  Text(
                    widget.barcode,
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // KARTU DETAIL DATA NASABAH (Clean Minimalist Card dengan Shadow Tipis)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Informasi Pemilik", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: darkTextColor)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: softGreenColor, shape: BoxShape.circle),
                        child: const Icon(Icons.person_rounded, color: primaryColor, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          widget.namaNasabah,
                          style: const TextStyle(fontWeight: FontWeight.w800, color: darkTextColor, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: softGreenColor, shape: BoxShape.circle),
                        child: const Icon(Icons.location_on_rounded, color: primaryColor, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          widget.alamat,
                          style: const TextStyle(fontWeight: FontWeight.w600, color: greyTextColor, fontSize: 14, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // SELEKSI DROPDOWN JENIS SAMPAH
// ========================================================
// 🛠️ TAMPILAN DROPDOWN KATEGORI SAMPAH PREMIUM & KONTRASTING
// ========================================================
            DropdownButtonFormField<Map<String, dynamic>>(
              value: selectedJenisSampah,
              isExpanded: true, // Membuat teks tidak terpotong jika nama sampah panjang
              icon: const Icon(Icons.arrow_drop_down_circle_rounded, color: primaryColor, size: 26), // Ikon dropdown modern
              dropdownColor: Colors.white, // Warna background menu pop-up pilihan
              borderRadius: BorderRadius.circular(20), // Sudut melengkung pada pop-up menu
              style: const TextStyle(color: darkTextColor, fontWeight: FontWeight.w800, fontSize: 16),

              // Dekorasi Bingkai Input
              decoration: InputDecoration(
                labelText: "Kategori Jenis Sampah",
                labelStyle: const TextStyle(color: greyTextColor, fontWeight: FontWeight.bold, fontSize: 14),
                hintText: "Pilih jenis sampah yang ditimbang",
                hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 14),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.recycling_rounded, color: primaryColor, size: 24), // Ikon depan daur ulang

                // Bingkai saat aktif / ditekan
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: primaryColor, width: 2),
                ),
                // Bingkai default saat standby
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),

              // Kustomisasi Tinggi dan Jarak Setiap Item Pilihan (Agar Senior-Friendly & Anti-Typo)
              items: jenisSampahList.map<DropdownMenuItem<Map<String, dynamic>>>((item) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: item,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.eco_rounded, color: secondaryColor, size: 20), // Ikon daun mini di tiap pilihan
                        const SizedBox(width: 12),
                        Text(
                          item['nama'] ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: darkTextColor, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),

              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  selectedJenisSampah = value;
                  jenisController.text = value['nama'] ?? '';

                  final hargaRaw = value['harga_per_kg'];
                  if (hargaRaw is int) {
                    hargaPerKg = hargaRaw;
                  } else if (hargaRaw is double) {
                    hargaPerKg = hargaRaw.toInt();
                  } else if (hargaRaw is String) {
                    hargaPerKg = double.tryParse(hargaRaw)?.toInt() ?? 0;
                  } else {
                    hargaPerKg = 0;
                  }
                  hitungTotalPendapatan();
                });
              },
            ),            const SizedBox(height: 16),

            // HARGA PER KG INFO (Warna Orange Lembut Kontras)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.shade100, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Nilai Tukar / Kg", style: TextStyle(fontWeight: FontWeight.w800, color: darkTextColor)),
                  Text(
                    "Rp ${numberFormat(hargaPerKg)}",
                    style: TextStyle(fontWeight: FontWeight.w900, color: Colors.orange.shade900, fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 💡 TEKS PETUNJUK RAMAH UNTUK KURIR
            const Padding(
              padding: EdgeInsets.only(bottom: 10.0, left: 2),
              child: Row(
                children: [
                  Icon(Icons.wifi_tethering_rounded, color: Colors.orange, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Pastikan Hotspot HP aktif agar timbangan IoT terhubung otomatis.",
                      style: TextStyle(fontSize: 12, color: greyTextColor, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),

            // FORM INPUT BERAT BERBENTUK ROW BERDAMPINGAN DENGAN TOMBOL LOAD IOT
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: beratController,
                    style: const TextStyle(color: darkTextColor, fontWeight: FontWeight.w900, fontSize: 16),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) => hitungTotalPendapatan(),
                    decoration: InputDecoration(
                      labelText: "Berat Sampah (Kg)",
                      labelStyle: const TextStyle(color: greyTextColor, fontWeight: FontWeight.w700),
                      hintText: "0.0",
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.scale_rounded, color: primaryColor),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryColor, width: 2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // 🔥 TOMBOL SYNC TIMBANGAN IOT (Dicocokkan Warnanya dengan Tombol Filter Riwayat)
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: isCapturingIot ? null : fetchBeratFromIot,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    icon: isCapturingIot
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.cloud_download_rounded, color: Colors.white),
                    label: const Text(
                      "LOAD IOT",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.3),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // FORM READ-ONLY TOTAL PENDAPATAN
            TextField(
              controller: totalController,
              readOnly: true,
              style: const TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 18),
              decoration: InputDecoration(
                labelText: "Total Saldo Masuk",
                labelStyle: const TextStyle(color: greyTextColor, fontWeight: FontWeight.w700),
                prefixText: "Rp ",
                prefixStyle: const TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 18),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
              ),
            ),
            const SizedBox(height: 28),

            // CAPTURE MEDIA FOTO SAMPAH
            const Text("Foto Bukti Penimbangan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: darkTextColor, letterSpacing: -0.3)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: pickImage,
              child: Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200, width: 1.5),
                ),
                child: imageFile == null
                    ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_rounded, size: 54, color: primaryColor),
                    SizedBox(height: 12),
                    Text(
                      "Ketuk untuk Ambil Foto Sampah",
                      style: TextStyle(color: greyTextColor, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.file(imageFile!, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 36),

            // SUBMIT BUTTON (Gaya Elegan Kontras Tinggi Final)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  backgroundColor: primaryColor,
                  shadowColor: primaryColor.withOpacity(0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: simpanSetorSampah,
                child: const Text(
                  "SIMPAN SETOR SAMPAH",
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi pembantu memformat angka rupiah agar konsisten dengan view backend
  String numberFormat(int number) {
    return number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}