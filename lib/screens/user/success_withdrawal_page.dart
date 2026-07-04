import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SuccessWithdrawalPage extends StatelessWidget {
  final int nominal;
  final String transactionId;
  final DateTime? tanggal;

  const SuccessWithdrawalPage({
    super.key,
    required this.nominal,
    required this.transactionId,
    this.tanggal,
  });

  String _formatRupiah(int angka) =>
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(angka);

  String _formatTanggal(DateTime date) {
    return DateFormat('dd MMMM yyyy, HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E521E);
    const secondaryColor = Color(0xFF58C063);
    const backgroundColor = Color(0xFFF9FBF9);
    final displayDate = tanggal ?? DateTime.now();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Icon Success
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: primaryColor,
                  size: 80,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Pengajuan Berhasil!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A301A),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Permintaan penarikan tunai Anda telah berhasil dikirim dan sedang menunggu persetujuan admin.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              
              // Detail Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailRow("ID Transaksi", transactionId),
                    const SizedBox(height: 8),
                    _buildDetailRow("Nominal Penarikan", _formatRupiah(nominal), isBold: true),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(),
                    ),
                    _buildDetailRow("Tanggal Pengajuan", _formatTanggal(displayDate)),
                    const SizedBox(height: 8),
                    _buildDetailRow("Status", "PENDING", valueColor: Colors.orange),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Bottom Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to home or dashboard
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Kembali ke Beranda",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Text Button for History
              TextButton(
                onPressed: () {
                  // This is a placeholder, usually we would replace current page with history
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Lihat Riwayat Penarikan",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? const Color(0xFF1A301A),
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
