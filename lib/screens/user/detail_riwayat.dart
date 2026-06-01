import 'package:flutter/material.dart';

// Palet warna resmi Basayan Bestari agar sinkron dengan beranda
const primaryColor = Color(0xFF1E521E);
const secondaryColor = Color(0xFF4CAF50);
const softGreenColor = Color(0xFFE8F5E9);
const backgroundColor = Color(0xFFF9FBF9);
const darkTextColor = Color(0xFF0D240D);
const greyTextColor = Color(0xFF555555);

class DetailRiwayatPage extends StatelessWidget {
  // 🔥 KUNCI UTAMA: Ubah parameter menjadi dynamic agar bisa menerima data JSON mentah langsung dari RiwayatPage
  final dynamic data;

  const DetailRiwayatPage({
    super.key,
    required this.data,
  });

  // Formatter Rupiah Mandiri
  String formatDuitRupiah(dynamic nominalRaw) {
    try {
      int angka = int.parse(nominalRaw.toString().replaceAll(RegExp(r'[^0-9]'), ''));
      return "Rp " + angka.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.'
      );
    } catch (e) {
      return "Rp $nominalRaw";
    }
  }

  @override
  Widget build(BuildContext context) {
    // 📡 Deteksi otomatis apakah ini transaksi Setor Sampah atau Tarik Tunai Dana
    String jenisTx = (data['jenis_transaksi'] ?? 'masuk').toString().toLowerCase();
    bool isPenarikan = jenisTx.contains('keluar') || jenisTx.contains('tarik');

    // Ekstraksi Variabel dengan Null-Safety Ketat
    String judulStruk = isPenarikan ? "Struk Tarik Tunai" : "Struk Setor Sampah";
    String tanggal = (data['tanggal_formatted'] ?? '-').toString();
    String status = (data['status'] ?? 'SUKSES').toString().toUpperCase();
    String nominalUang = formatDuitRupiah(data['nominal'] ?? '0');
    String catatan = (data['catatan'] ?? '-').toString();
    String kategoriJudul = (data['judul_dinamis'] ?? (isPenarikan ? 'Tarik Tunai' : 'Setor Sampah')).toString();
    String beratTotal = "${data['total_berat'] ?? '0'} Kg";

    Color temaWarnaStruk = isPenarikan ? Colors.red.shade800 : primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ================= PREMIUM HEADER CUSTOM =================
            Container(
              height: 120,
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Detail Transaksi",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Penyeimbang tombol back kiri
                  ],
                ),
              ),
            ),

            // ================= NOTA / STRUK DETAIL (ANTI CRASH) =================
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.88,
                    margin: const EdgeInsets.symmetric(vertical: 24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        )
                      ],
                      border: Border.all(
                        color: temaWarnaStruk.withOpacity(0.15),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: isPenarikan ? Colors.red.shade50 : softGreenColor,
                          child: Icon(
                            isPenarikan ? Icons.payments_rounded : Icons.receipt_long_rounded,
                            color: temaWarnaStruk,
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "BASAYAN BESTARI",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: temaWarnaStruk,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          judulStruk,
                          style: const TextStyle(fontSize: 13, color: greyTextColor, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        const Divider(thickness: 1, height: 1),
                        const SizedBox(height: 16),

                        // Badge Kategori Dinamis (Plastik, Kertas, atau Tarik Tunai)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: temaWarnaStruk.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            kategoriJudul,
                            style: TextStyle(
                              color: temaWarnaStruk,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Detail baris demi baris informasi mutasi
                        _buildRowDetail("Waktu Transaksi", tanggal),
                        const SizedBox(height: 10),
                        _buildRowDetail("Status", status == 'MASUK' || status == 'KELUAR' ? 'SUKSES' : status, isStatus: true, statusColor: temaWarnaStruk),

                        // Tampilkan info berat timbangan HANYA jika transaksi berupa setor sampah
                        if (!isPenarikan) ...[
                          const SizedBox(height: 10),
                          _buildRowDetail("Total Timbangan", beratTotal),
                        ],

                        const SizedBox(height: 10),
                        _buildRowDetail("Catatan", catatan),

                        const SizedBox(height: 16),
                        const Divider(thickness: 1, height: 1),
                        const SizedBox(height: 16),

                        // Total Uang Tabungan Masuk / Keluar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Jumlah Nominal",
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: darkTextColor),
                            ),
                            Text(
                              nominalUang,
                              style: TextStyle(
                                color: temaWarnaStruk,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildRowDetail(String label, String value, {bool isStatus = false, Color? statusColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: greyTextColor, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              color: isStatus ? (statusColor ?? primaryColor) : darkTextColor,
              fontWeight: isStatus ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}