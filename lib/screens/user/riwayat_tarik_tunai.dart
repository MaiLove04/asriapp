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
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(angka);

  String _formatTanggal(DateTime? date) {
    if (date == null) return "-";
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange; // Pending
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        title: const Text("Riwayat Penarikan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E521E),
        elevation: 0,
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
            onRefresh: () async {
              setState(() {
                _futureRiwayat = _service.getRequests();
              });
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatRupiah(item.jumlahNominal),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E521E)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(item.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.status.toUpperCase(),
                    style: TextStyle(color: _getStatusColor(item.status), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _infoRow(Icons.calendar_today, "Request:", _formatTanggal(item.tanggalRequest)),
            if (item.status == 'approved')
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _infoRow(Icons.check_circle_outline, "Selesai:", _formatTanggal(item.tanggalSelesai)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(width: 5),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_edu, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("Belum ada riwayat penarikan.", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}