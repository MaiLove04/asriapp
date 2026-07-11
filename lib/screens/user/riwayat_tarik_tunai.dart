import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/tarik_tunai_service.dart';
import '../models/tarik_tunai_model.dart';

class RiwayatTarikTunaiPage extends StatefulWidget {
  const RiwayatTarikTunaiPage({super.key});

  @override
  State<RiwayatTarikTunaiPage> createState() => _RiwayatTarikTunaiPageState();
}

class _RiwayatTarikTunaiPageState extends State<RiwayatTarikTunaiPage> {
  final TarikTunaiService _service = TarikTunaiService();
  late Future<List<TarikTunaiModel>> _futureRiwayat;

  @override
  void initState() {
    super.initState();
    _futureRiwayat = _service.getRequests(); // Mengambil riwayat milik nasabah login
  }

  String _formatRupiah(int angka) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(angka);

  String _formatTanggal(DateTime? date) {
    if (date == null) return "-";
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  // 🔥 Menyesuaikan warna teks badge status
  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('approved') || s.contains('success') || s.contains('berhasil') || s.contains('setuju') || s == '1') {
      return const Color(0xFF2E7D32); // Hijau Sukses
    } else if (s.contains('rejected') || s.contains('failed') || s.contains('tolak') || s.contains('batal') || s == '2') {
      return const Color(0xFFC62828); // Merah Ditolak
    } else {
      return const Color(0xFFE65100); // Oranye Jingga Pending
    }
  }

  // 🔥 Menerjemahkan string database ke teks Indonesia yang rapi
  String _getStatusText(String status) {
    final s = status.toLowerCase();
    if (s.contains('approved') || s.contains('success') || s.contains('berhasil') || s.contains('setuju') || s == '1') {
      return "DISETUJUI";
    } else if (s.contains('rejected') || s.contains('failed') || s.contains('tolak') || s.contains('batal') || s == '2') {
      return "DITOLAK";
    } else if (s.contains('pending') || s.contains('tunggu') || s == '0') {
      return "PENDING";
    }
    return s.toUpperCase(); // Fallback ke teks asli jika tidak dikenali
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Diperhalus menjadi abu-abu netral profesional
      appBar: AppBar(
        title: const Text(
          "Riwayat Penarikan",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E521E),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: FutureBuilder<List<TarikTunaiModel>>(
        future: _futureRiwayat,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1E521E)));
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final list = snapshot.data!;
          return RefreshIndicator(
            color: const Color(0xFF1E521E),
            onRefresh: () async {
              setState(() {
                _futureRiwayat = _service.getRequests();
              });
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                return _buildCardRiwayat(item);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardRiwayat(TarikTunaiModel item) {
    final statusColor = _getStatusColor(item.status);
    final statusText = _getStatusText(item.status);

    // 🔥 Dinamisasi label subtitel keterangan status dan warna nominal teks kanan
    String subtitleText;
    Color nominalColor;

    final s = item.status.toLowerCase();
    if (s.contains('approved') || s.contains('success') || s.contains('berhasil') || s.contains('setuju') || s == '1') {
      subtitleText = "Penarikan Berhasil";
      nominalColor = const Color(0xFF1E521E);
    } else if (s.contains('rejected') || s.contains('failed') || s.contains('tolak') || s.contains('batal') || s == '2') {
      subtitleText = "Penarikan Ditolak";
      nominalColor = const Color(0xFFC62828);
    } else {
      subtitleText = "Menunggu Persetujuan";
      nominalColor = const Color(0xFFE65100);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02), // Efek bayangan halus modern (tidak kaku)
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Sisi Kiri: Ikon, Judul, Keterangan Status Dinamis, dan Tanggal
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9), // Kontainer ikon bulat hijau lembut
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF1E521E), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Tarik Tunai Dana",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF222222)),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitleText, // 🔥 Dinamis: Menampilkan status kontekstual Indonesia yang rapi
                          style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _formatTanggal(item.tanggalRequest),
                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                        const SizedBox(height: 8),
                        // Menambahkan info tambahan agar lebih informatif
                        _infoRow(Icons.confirmation_number_outlined, "ID", "#${item.id}"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Sisi Kanan: Nominal Dinamis dan Badge Status Ringkas
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatRupiah(item.jumlahNominal),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: nominalColor // 🔥 Dinamis: Warna nominal berganti serasi dengan kondisinya
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1), // Efek translucent/transparan modern
                    borderRadius: BorderRadius.circular(30), // Menggunakan pill-shaped melingkar sempurna
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 0.5
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

  Widget _infoRow(IconData icon, String label, String value, {Color? colorLabel}) {
    return Row(
      children: [
        Icon(icon, size: 15, color: colorLabel ?? const Color(0xFF888888)),
        const SizedBox(width: 8),
        Text(
          "$label:",
          style: TextStyle(color: colorLabel ?? const Color(0xFF888888), fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF333333)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_rounded, size: 64, color: Color(0xFF1E521E)),
          ),
          const SizedBox(height: 18),
          const Text(
            "Belum Ada Transaksi",
            style: TextStyle(color: Color(0xFF0D240D), fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          const Text(
            "Riwayat penarikan saldo Anda akan muncul di sini.",
            style: TextStyle(color: Color(0xFF888888), fontSize: 13),
          ),
        ],
      ),
    );
  }
}