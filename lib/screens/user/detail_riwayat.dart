import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const primaryColor = Color(0xFF1E521E);
const secondaryColor = Color(0xFF4CAF50);
const softGreenColor = Color(0xFFE8F5E9);
const backgroundColor = Color(0xFFF9FBF9);
const darkTextColor = Color(0xFF0D240D);
const greyTextColor = Color(0xFF555555);

class DetailRiwayatPage extends StatelessWidget {
  final dynamic data;

  const DetailRiwayatPage({
    super.key,
    required this.data,
  });

  String formatDuitRupiah(dynamic nominalRaw) {
    try {
      int angka = int.parse(nominalRaw.toString().replaceAll(RegExp(r'[^0-9]'), ''));
      return "Rp " + NumberFormat.decimalPattern('id').format(angka);
    } catch (e) {
      return "Rp $nominalRaw";
    }
  }

  @override
  Widget build(BuildContext context) {
    String jenisTx = (data['jenis_transaksi'] ?? 'masuk').toString().toLowerCase();
    bool isPenarikan = jenisTx.contains('keluar') || jenisTx.contains('tarik');

    String judulHalaman = isPenarikan ? "Bukti Tarik Tunai" : "Bukti Setoran Sampah";
    
    // Formatting Tanggal
    String tanggal = '-';
    String rawDate = data['created_at'] ?? '';
    if (rawDate.isNotEmpty) {
      try {
        DateTime parsedDate = DateTime.parse(rawDate);
        tanggal = DateFormat('dd MMMM yyyy, HH:mm').format(parsedDate) + " WIB";
      } catch (e) {
        tanggal = data['tanggal_formatted'] ?? rawDate;
      }
    }

    String nominalUang = formatDuitRupiah(data['nominal'] ?? '0');
    String catatan = (data['catatan'] ?? 'Tidak ada catatan').toString();
    String trxId = "TRX-${data['id'] ?? '0'}";
    String namaNasabah = (data['user_name'] ?? 'Nasabah').toString();
    
    // Ambil Nama Kurir
    String namaKurir = "Kurir ASRI";
    if (data['kurir'] != null && data['kurir']['name'] != null) {
      namaKurir = data['kurir']['name'].toString();
    } else if (data['nama_kurir'] != null) {
      namaKurir = data['nama_kurir'].toString();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
        ),
        title: Text(
          judulHalaman,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            // ================= RECEIPT CARD =================
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  // Green Header Section inside card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 54),
                        const SizedBox(height: 12),
                        const Text(
                          "TRANSAKSI BERHASIL",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Bank Sampah Basayan Bestari",
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            nominalUang,
                            style: const TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 34, letterSpacing: -0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            trxId,
                            style: const TextStyle(color: greyTextColor, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(thickness: 1.5, color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 16),

                        _buildInfoRow("Nama Nasabah", namaNasabah),
                        _buildInfoRow("Waktu Setor", tanggal),
                        _buildInfoRow("Nama Kurir", namaKurir),

                        if (!isPenarikan) ...[
                          const SizedBox(height: 8),
                          const Divider(thickness: 1.5, color: Color(0xFFEEEEEE)),
                          const SizedBox(height: 14),
                          const Text(
                            "RINCIAN ITEM SAMPAH",
                            style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.3),
                          ),
                          const SizedBox(height: 12),
                          _buildItemsList(),
                        ],

                        const SizedBox(height: 12),
                        const Divider(thickness: 1.5, color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 16),

                        const Text(
                          "Catatan Timbangan:",
                          style: TextStyle(color: greyTextColor, fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FBF9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            catatan,
                            style: const TextStyle(color: darkTextColor, fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Gerigi Bawah Struk (Square Pattern)
                  Container(
                    height: 10,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                      child: Row(
                        children: List.generate(
                          20,
                          (index) => Expanded(
                            child: Container(
                              height: 10,
                              color: index % 2 == 0 ? Colors.white : const Color(0xFFEEEEEE),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Tombol Kembali
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  "KEMBALI KE RIWAYAT",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: greyTextColor, fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: darkTextColor, fontSize: 14, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    List<dynamic> details = data['details'] ?? [];

    if (details.isEmpty) {
      // Fallback jika tidak ada data detail spesifik
      String nama = data['judul_dinamis'] ?? 'Setor Sampah';
      String berat = "${data['total_berat'] ?? '0'} Kg";
      String total = formatDuitRupiah(data['nominal'] ?? '0');
      return _buildItemRow(nama, berat, "", total);
    }

    return Column(
      children: details.map((item) {
        String nama = (item['jenis_sampah']?['nama'] ?? item['nama'] ?? 'Sampah').toString();
        String berat = "${item['berat'] ?? '0'} Kg";
        
        // Ambil harga per kg
        var rawHarga = item['jenis_sampah']?['harga_per_kg'] ?? item['harga_per_kg'];
        String hargaPerKg = rawHarga != null ? formatDuitRupiah(rawHarga) : "";
        
        String subtotal = formatDuitRupiah(item['total'] ?? item['subtotal'] ?? '0');

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildItemRow(nama, berat, hargaPerKg, subtotal),
        );
      }).toList(),
    );
  }

  Widget _buildItemRow(String title, String weight, String pricePerKg, String subtotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "• $title",
              style: const TextStyle(color: darkTextColor, fontWeight: FontWeight.w800, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              pricePerKg.isNotEmpty ? "$weight x $pricePerKg" : weight,
              style: const TextStyle(color: greyTextColor, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Text(
          subtotal,
          style: const TextStyle(color: darkTextColor, fontWeight: FontWeight.w900, fontSize: 14),
        ),
      ],
    );
  }
}
