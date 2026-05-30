import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:asriapp/screens/user/detail_riwayat.dart';

import '../services/setor_sampah_service.dart';
import '../models/setor_sampah_model.dart';

// Palet warna resmi Basayan Bestari
const primaryColor = Color(0xFF1E521E);
const secondaryColor = Color(0xFF4CAF50);
const softGreenColor = Color(0xFFE8F5E9);
const backgroundColor = Color(0xFFF9FBF9);
const darkTextColor = Color(0xFF0D240D);
const greyTextColor = Color(0xFF555555);

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  bool isSetor = true;
  DateTime selectedDate = DateTime.now();
  String selectedJenis = "Semua";
  List<SetorSampahModel> riwayat = [];
  bool isLoading = true;

  final List<String> jenisSampah = ["Semua", "Plastik", "Metal", "Kertas"];

  @override
  void initState() {
    super.initState();
    loadRiwayat();
  }

  Future<void> loadRiwayat() async {
    try {
      final result = await SetorSampahService.getRiwayat();
      setState(() {
        riwayat = result;
        isLoading = false;
      });
    } catch (e) {
      print("Error load riwayat data: $e");
      setState(() { isLoading = false; });
    }
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: primaryColor, onPrimary: Colors.white, onSurface: darkTextColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() { selectedDate = picked; });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat("MMM yyyy").format(selectedDate);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
        ),
        title: const Text("Riwayat Transaksi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _tabButton(
                        text: "Setor Sampah",
                        icon: Icons.recycling_rounded,
                        isActive: isSetor,
                        onTap: () => setState(() => isSetor = true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _tabButton(
                        text: "Tarik Tunai",
                        icon: Icons.monetization_on_rounded, // Menggunakan koin pilihan Mai!
                        isActive: !isSetor,
                        onTap: () => setState(() => isSetor = false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _filterTanggal(formattedDate)),
                    const SizedBox(width: 12),
                    Expanded(child: _filterJenis()),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryColor, strokeWidth: 4))
                : riwayat.isEmpty
                ? const Center(child: Text("Belum ada riwayat transaksi", style: TextStyle(fontWeight: FontWeight.bold, color: greyTextColor)))
                : RefreshIndicator(
              color: primaryColor,
              onRefresh: loadRiwayat,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: riwayat.length,
                itemBuilder: (context, index) {
                  final item = riwayat[index];
                  return TransactionCard(
                    title: item.jenisSampah ?? 'Setor Sampah',
                    weight: item.beratKg ?? '0 Kg',
                    status: item.status ?? 'Pending',
                    price: "Rp " + (item.totalHarga ?? '0'),
                    date: item.createdAt ?? '',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DetailRiwayatPage(data: item)),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton({required String text, required IconData icon, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? primaryColor : Colors.white, size: 20),
            const SizedBox(width: 6),
            Text(text, style: TextStyle(color: isActive ? primaryColor : Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _filterTanggal(String text) {
    return GestureDetector(
      onTap: pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _filterJenis() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedJenis,
          dropdownColor: primaryColor,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          items: jenisSampah.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: (value) => setState(() => selectedJenis = value!),
        ),
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final String title;
  final String weight;
  final String status;
  final String price;
  final String date;
  final VoidCallback onTap;

  const TransactionCard({super.key, required this.title, required this.weight, required this.status, required this.price, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateTime.tryParse(date);
    String displayDate = formattedDate != null ? DateFormat("dd MMM yyyy").format(formattedDate) : "-";

    Color statusColor = Colors.orange.shade800;
    if (status.toLowerCase() == 'selesai' || status.toLowerCase() == 'success') statusColor = primaryColor;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Colors.grey.shade100)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const CircleAvatar(radius: 26, backgroundColor: softGreenColor, child: Icon(Icons.recycling_rounded, color: primaryColor, size: 26)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: darkTextColor))),
                        Text(displayDate, style: const TextStyle(fontSize: 11, color: greyTextColor, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 11)),
                        ),
                        Text(price, style: const TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 15)),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}