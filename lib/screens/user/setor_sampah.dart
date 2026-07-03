import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 🔥 Wajib ditambahkan!

import '../models/jenis_sampah.dart';
import '../services/jenis_sampah_service.dart';
import '../services/jadwal_service.dart';
import '../services/setor_sampah_service.dart';
import '../user/activity_riwayat.dart';
import '../user/status_penjemputan.dart';

// 🎨 PALET WARNA UTAMA (Tema Konsisten Senior-Friendly Basayan Bestari)
const primaryColor = Color(0xFF1E521E);
const secondaryColor = Color(0xFF4CAF50);
const softGreenColor = Color(0xFFE8F5E9);
const backgroundColor = Color(0xFFF9FBF9);
const darkTextColor = Color(0xFF0D240D);
const greyTextColor = Color(0xFF555555);

// 🕐 Jam operasional layanan setor sampah
const int _jamBukaOperasional = 8; // Buka pukul 08:00
const int _jamTutupOperasional = 16; // Tutup pukul 16:00

class SetorSampahScreen extends StatefulWidget {
  const SetorSampahScreen({super.key});

  @override
  State<SetorSampahScreen> createState() => _SetorSampahScreenState();
}

class _SetorSampahScreenState extends State<SetorSampahScreen> {
  List<JenisSampah> selectedJenis = [];
  List<JenisSampah> daftarJenis = [];
  bool isLoading = true;
  bool isSubmitting = false; // Pengaman double-click tombol kirim

  /// Tanggal penjemputan final hasil perhitungan validasi
  DateTime? _tanggalPenjemputan;

  final catatanController = TextEditingController();

  List<int> get selectedJenisIds {
    return selectedJenis.map((e) => e.id).toList();
  }

  @override
  void initState() {
    super.initState();
    loadJenis();
  }

  @override
  void dispose() {
    catatanController.dispose();
    super.dispose();
  }

  Future<void> loadJenis() async {
    try {
      final data = await JenisSampahService.getData();
      setState(() {
        daftarJenis = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error load jenis sampah: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // ============================================================
  //  HELPER: Konversi nama hari Indonesia → weekday (1=Mon..7=Sun)
  // ============================================================
  int? _parseHariToWeekday(String hari) {
    final h = hari.toLowerCase().trim();
    if (h == 'senin') return DateTime.monday;
    if (h == 'selasa') return DateTime.tuesday;
    if (h == 'rabu') return DateTime.wednesday;
    if (h == 'kamis') return DateTime.thursday;
    if (h == 'jumat' || h == "jum'at") return DateTime.friday;
    if (h == 'sabtu') return DateTime.saturday;
    if (h == 'minggu') return DateTime.sunday;
    return null;
  }

  // ============================================================
  //  HELPER: Nama hari Indonesia dari DateTime
  // ============================================================
  String _namaHari(DateTime dt) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return days[dt.weekday - 1]; // weekday: 1=Mon … 7=Sun
  }

  // ============================================================
  //  HELPER: Ekstrak weekday dari data jadwal rutin API
  // ============================================================
  int? _getJadwalWeekday(Map<String, dynamic>? jadwalData) {
    if (jadwalData == null) return null;
    if (jadwalData['hari'] != null) {
      return _parseHariToWeekday(jadwalData['hari'].toString());
    }
    if (jadwalData['tanggal_penjemputan'] != null) {
      try {
        return DateTime.parse(
          jadwalData['tanggal_penjemputan'].toString(),
        ).weekday;
      } catch (_) {}
    }
    return null;
  }

  // ============================================================
  //  VALIDASI + PROSES SUBMIT
  // ============================================================
  Future<void> _prosesSubmit() async {
    if (selectedJenis.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan pilih minimal 1 jenis sampah dahulu!"),
        ),
      );
      return;
    }

    setState(() { isSubmitting = true; });

    // --- Ambil user ID ---
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int idNasabahLogin = 0;
    final rawId = prefs.get('user_id');
    if (rawId is int) {
      idNasabahLogin = rawId;
    } else if (rawId is String) {
      idNasabahLogin = int.tryParse(rawId) ?? 0;
    }

    print("DEBUG UI - Mengirim request atas nama User ID: $idNasabahLogin");

    if (idNasabahLogin == 0) {
      setState(() { isSubmitting = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal: Sesi login tidak ditemukan. Silakan login ulang."),
        ),
      );
      return;
    }

    // --- Ambil jadwal rutin nasabah ---
    final jadwalData = await JadwalService.getJadwalNasabah(idNasabahLogin);
    setState(() { isSubmitting = false; });
    if (!mounted) return;

    final now     = DateTime.now();
    final hariIni = DateTime(now.year, now.month, now.day); // date-only
    final jadwalWD = _getJadwalWeekday(jadwalData);

    // ============================================================
    //  CEK 1: Apakah hari ini adalah hari jadwal rutin?
    // ============================================================
    if (jadwalWD != null && jadwalWD == now.weekday) {
      // ❌ BLOKIR: Hari ini adalah hari setoran rutin
      _showErrorHariRutin(_namaHari(now));
      return;
    }

    // ============================================================
    //  CEK 2: Apakah saat ini di luar jam kerja?
    // ============================================================
    final isLuarJamKerja =
        now.hour < _jamBukaOperasional || now.hour >= _jamTutupOperasional;

    if (isLuarJamKerja) {
      final besok        = hariIni.add(const Duration(days: 1));
      final besokAdaRutin = jadwalWD != null && jadwalWD == besok.weekday;

      // Tentukan tanggal penjemputan aktual:
      //   besok aman         → besok
      //   besok = hari rutin → besok + 1 hari
      final DateTime tanggalFinal =
          besokAdaRutin ? besok.add(const Duration(days: 1)) : besok;

      // ⚠️ Tampilkan dialog peringatan jam kerja
      _showWarningLuarJamKerja(besok, besokAdaRutin, tanggalFinal, idNasabahLogin);
      return;
    }

    // ============================================================
    //  SEMUA VALIDASI LOLOS → penjemputan hari ini
    // ============================================================
    setState(() { _tanggalPenjemputan = hariIni; });
    await _kirimRequest(idNasabahLogin);
  }

  // ============================================================
  //  AKSI KIRIM SETELAH SEMUA VALIDASI LOLOS
  // ============================================================
  Future<void> _kirimRequest(int userId) async {
    setState(() { isSubmitting = true; });

    // Format tanggal ke yyyy-MM-dd untuk dikirim ke API
    final String? tanggalStr = _tanggalPenjemputan != null
        ? "${_tanggalPenjemputan!.year.toString().padLeft(4, '0')}-"
          "${_tanggalPenjemputan!.month.toString().padLeft(2, '0')}-"
          "${_tanggalPenjemputan!.day.toString().padLeft(2, '0')}"
        : null;

    print("DEBUG SETOR - Tanggal penjemputan dikirim: $tanggalStr");

    final berhasil = await SetorSampahService.store(
      userId: userId,
      jenisIds: selectedJenisIds,
      catatan: catatanController.text,
      tanggalPenjemputan: tanggalStr,
    );

    setState(() { isSubmitting = false; });
    if (!mounted) return;

    if (berhasil) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengirim request penjemputan.")),
      );
    }
  }

  // ============================================================
  //  DIALOG ERROR: Hari ini adalah hari rutin
  // ============================================================
  void _showErrorHariRutin(String namaHari) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3E0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_busy_rounded,
                color: Color(0xFFE65100),
                size: 56,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Tidak Dapat Dilakukan",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: darkTextColor,
              ),
            ),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  color: greyTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
                children: [
                  const TextSpan(text: "Setor sampah "),
                  const TextSpan(
                    text: "by request",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: " tidak dapat dilakukan pada hari "),
                  TextSpan(
                    text: namaHari,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFE65100),
                    ),
                  ),
                  const TextSpan(
                    text:
                        ", karena hari tersebut merupakan jadwal setoran sampah ",
                  ),
                  const TextSpan(
                    text: "rutin",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const TextSpan(
                    text:
                        " Anda.\n\nKurir kami akan datang menjemput sampah Anda sesuai jadwal yang telah ditetapkan.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "SAYA MENGERTI",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  //  DIALOG PERINGATAN: Di luar jam kerja
  // ============================================================
  void _showWarningLuarJamKerja(
    DateTime besok,
    bool besokAdaRutin,
    DateTime tanggalFinal,
    int userId,
  ) {
    final namaBesok           = _namaHari(besok);
    final namaHariFinal       = _namaHari(tanggalFinal);
    final keteranganTambahan  = besokAdaRutin
        ? "Dikarenakan hari $namaBesok merupakan hari pengambilan rutin, "
          "pengambilan sampah by request akan dijadwalkan pada hari "
          "$namaHariFinal."
        : '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF8E1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.access_time_rounded,
                color: Color(0xFFF57F17),
                size: 56,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Di Luar Jam Operasional",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: darkTextColor,
              ),
            ),
            const SizedBox(height: 12),

            // Pesan utama
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  color: greyTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
                children: [
                  const TextSpan(
                    text:
                        "Permintaan diterima! Namun karena saat ini di luar jam operasional "
                        "(08.00 – 16.00), kurir akan dijadwalkan pada ",
                  ),
                  TextSpan(
                    // Jika besok aman tampilkan besok, jika besok rutin tampilkan hari final
                    text: besokAdaRutin ? "hari $namaHariFinal" : "hari $namaBesok",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: primaryColor,
                    ),
                  ),
                  const TextSpan(text: "."),
                ],
              ),
            ),

            // Keterangan tambahan jika besok ada jadwal rutin
            if (keteranganTambahan.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFFFCC02),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFFE65100),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        keteranganTambahan,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6D3000),
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: primaryColor, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "BATAL",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      // Simpan tanggal penjemputan final ke state lalu kirim
                      if (mounted) {
                        setState(() { _tanggalPenjemputan = tanggalFinal; });
                        await _kirimRequest(userId);
                      }
                    },
                    child: const Text(
                      "LANJUTKAN",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: softGreenColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: secondaryColor,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Permintaan Berhasil!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: darkTextColor,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Permintaan penjemputan sampah Anda telah terkirim. Kurir akan segera menuju lokasi Anda.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: greyTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: primaryColor, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Tutup dialog
                      Navigator.pop(context); // Kembali ke dashboard
                    },
                    child: const Text(
                      "OKE",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const RiwayatPage()),
                      );
                    },
                    child: const Text(
                      "LIHAT STATUS",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String getIcon(String kode) {
    switch (kode.toLowerCase()) {
      case "plastik":
        return "assets/images/plastik.png";
      case "kertas":
        return "assets/images/kertas.png";
      case "logam":
        return "assets/images/metal.png";
      case "organik":
        return "assets/images/organik.png";
      default:
        return "assets/images/plastik.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 30),
          children: [
            /// HEADER PREMIUM GRADIENT
            Container(
              height: 140,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, Color(0xFF2E6B2E)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(36),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Formulir Jemput Sampah",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// BOX JENIS SAMPAH (MULTI SELECT CARD)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pilih Kategori Sampah yang Mau Disetor:",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: darkTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                            strokeWidth: 3,
                          ),
                        )
                      : Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: daftarJenis
                              .map((item) => _itemSampah(item))
                              .toList(),
                        ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// BOX INPUTAN CATATAN TAMBAHAN
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade100,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: const Text(
                      "Catatan untuk Kurir Lapangan",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.edit_note_rounded,
                          color: primaryColor,
                          size: 36,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: catatanController,
                            minLines: 2,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: darkTextColor,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  "Contoh: Sampah kardus sudah diikat rapi di depan pagar teras rumah...",
                              hintStyle: const TextStyle(
                                color: greyTextColor,
                                fontWeight: FontWeight.normal,
                                fontSize: 13,
                              ),
                              contentPadding: const EdgeInsets.all(14),
                              filled: true,
                              fillColor: backgroundColor,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: primaryColor,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            /// BUTTON SUBMIT FINAL ACTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: primaryColor.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: isSubmitting ? null : _prosesSubmit,
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.local_shipping_rounded, size: 22),
                  label: Text(
                    isSubmitting ? "MEMPROSES..." : "KONFIRMASI PENJEMPUTAN",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemSampah(JenisSampah item) {
    final isSelected = selectedJenis.any((e) => e.id == item.id);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedJenis.removeWhere((e) => e.id == item.id);
          } else {
            selectedJenis.add(item);
          }
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? softGreenColor : Colors.grey.shade50,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? primaryColor : Colors.grey.shade200,
                width: 3,
              ),
            ),
            child: Image.asset(
              getIcon(item.kodeIcon ?? item.nama),
              width: 44,
              height: 44,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.eco_rounded, color: primaryColor, size: 44),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.nama,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              color: isSelected ? primaryColor : darkTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
