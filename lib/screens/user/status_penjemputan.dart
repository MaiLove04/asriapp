import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/jadwal_service.dart';

const primaryColor = Color(0xFF1E521E);
const backgroundColor = Color(0xFFF9FBF9);
const darkTextColor = Color(0xFF0D240D);
const greyTextColor = Color(0xFF555555);

class StatusPenjemputanPage extends StatefulWidget {
  const StatusPenjemputanPage({super.key});

  @override
  State<StatusPenjemputanPage> createState() => _StatusPenjemputanPageState();
}

class _StatusPenjemputanPageState extends State<StatusPenjemputanPage> {
  Map<String, dynamic>? activeJadwal;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      int userId = 0;
      final rawId = prefs.get('user_id');
      if (rawId is int) {
        userId = rawId;
      } else if (rawId is String) {
        userId = int.tryParse(rawId) ?? 0;
      }

      print("DEBUG MAI - Lacak Status untuk User ID: $userId");

      if (userId != 0) {
        // Memanggil API backend kamu
        final response = await JadwalService.getJadwalNasabah(userId);

        setState(() {
          // Kita cek apakah ada jadwal_mendatang atau request_pending
          final List mendatang = response?['jadwal_mendatang'] ?? [];
          final List pending = response?['request_pending'] ?? [];

          if (mendatang.isNotEmpty) {
            // prioritaskan jadwal aktif yang sudah ada kurirnya
            activeJadwal = Map<String, dynamic>.from(mendatang.first);
          } else if (pending.isNotEmpty) {
            // jika tidak ada, pantau request mandiri nasabah yang masih pending
            activeJadwal = Map<String, dynamic>.from(pending.first);
          } else {
            activeJadwal = null;
          }

          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("DEBUG MAI - Error Load Status: $e");
      setState(() => isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          "Status Penjemputan",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : RefreshIndicator(
        onRefresh: _loadStatus,
        color: primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: activeJadwal == null
              ? _buildEmptyState()
              : _buildStatusContent(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 120),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.assignment_turned_in_rounded, size: 70, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          const Text(
            "Tidak ada penjemputan aktif",
            style: TextStyle(fontSize: 16, color: darkTextColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Yuk, request jemput sampah sekarang!",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusContent() {
    // Membaca tipe data ('jadwal' atau 'request') dan status asli backend
    String tipe = (activeJadwal!['tipe'] ?? 'request').toString();
    String status = (activeJadwal!['status'] ?? 'pending').toString().toLowerCase();

    // Mengambil info kurir sesuai struktur array kurir di backend kamu
    String namaKurir = "Belum Ada Kurir";
    if (activeJadwal!['kurir'] != null) {
      namaKurir = activeJadwal!['kurir']['nama'] ?? 'Kurir ASRI';
    }

    String tanggalTeks = activeJadwal!['tanggal_formatted'] ?? '-';
    if (activeJadwal!['jam'] != null) {
      tanggalTeks += " (${activeJadwal!['jam']})";
    }

    String alamatTeks = activeJadwal!['alamat'] ?? 'Penjemputan Mandiri';

    // Logika menyalakan step pelacakan kemajuan mobilitas sampah
    bool isStep1 = true; // Permintaan Masuk / Dibuat
    bool isStep2 = tipe == 'jadwal' || status == 'proses'; // Diterima / Dijadwalkan
    bool isStep3 = status == 'proses'; // Dalam Perjalanan
    bool isStep4 = status == 'selesai'; // Selesai ditimbang

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // INFO CARD (Tampilan Ringkas Informasi Kurir & Waktu)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFE8F5E9),
                    child: Icon(
                        tipe == 'request' ? Icons.mail_outline_rounded : Icons.local_shipping_rounded,
                        color: primaryColor,
                        size: 24
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tipe == 'request' ? "Jenis Aktivitas" : "Kurir Penjemput",
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tipe == 'request' ? "Request Mandiri Nasabah" : namaKurir,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkTextColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: Colors.grey.shade100, height: 1),
              ),
              _rowInfo(Icons.calendar_today_rounded, "Waktu", tanggalTeks),
              const SizedBox(height: 14),
              _rowInfo(Icons.location_on_rounded, "Lokasi", alamatTeks),
            ],
          ),
        ),

        const SizedBox(height: 32),

        const Text(
          "Kemajuan Aktivitas Sampah",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkTextColor, letterSpacing: 0.3),
        ),
        const SizedBox(height: 20),

        // STEP TIMELINE MOBILITAS
        _step(
            "Permintaan Dikirim",
            "Aktivitas penyetoran sampah berhasil masuk ke sistem ASRI",
            isStep1,
            isFirst: true
        ),
        _step(
            tipe == 'jadwal' ? "Permintaan Disetujui" : "Menunggu Konfirmasi",
            tipe == 'jadwal'
                ? "Jadwal penjemputan telah diatur oleh pihak ASRI"
                : "Menunggu admin menyetujui request mandiri Anda",
            isStep2
        ),
        _step(
            "Dalam Perjalanan",
            "Kurir sedang membawa armada menuju lokasi Anda",
            isStep3
        ),
        _step(
            "Sampai & Timbang",
            "Proses penimbangan sampah oleh kurir di lokasi",
            isStep4,
            isLast: true
        ),

        const SizedBox(height: 24),

        // BANNER INFORMASI BAWAH
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9).withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFC8E6C9).withOpacity(0.5), width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: primaryColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tipe == 'request' && !isStep2
                      ? "Request Anda akan segera diperiksa oleh admin. Mohon tunggu ya!"
                      : "Mohon siapkan sampah Anda di depan rumah untuk mempermudah tugas kurir.",
                  style: const TextStyle(fontSize: 13, color: primaryColor, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _rowInfo(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: darkTextColor, height: 1.3),
              children: [
                TextSpan(text: "$label: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                TextSpan(text: value, style: const TextStyle(color: greyTextColor)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _step(String title, String desc, bool isActive, {bool isFirst = false, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 2.5,
              height: 16,
              color: isFirst ? Colors.transparent : (isActive ? primaryColor : Colors.grey.shade300),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? primaryColor : Colors.white,
                border: Border.all(
                  color: isActive ? primaryColor : Colors.grey.shade300,
                  width: isActive ? 0 : 2,
                ),
                boxShadow: isActive ? [
                  BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))
                ] : null,
              ),
              child: isActive ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
            ),
            Container(
              width: 2.5,
              height: 40,
              color: isLast ? Colors.transparent : (isActive ? primaryColor : Colors.grey.shade300),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isActive ? darkTextColor : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 13,
                  color: isActive ? greyTextColor : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}