import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:asriapp/screens/user/detail_riwayat.dart';


class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  bool isSetor = true;

  DateTime selectedDate = DateTime.now();
  String selectedJenis = "Semua";

  final List<String> jenisSampah = [
    "Semua",
    "Plastik",
    "Metal",
    "Kertas",
  ];

  // ================= DATE PICKER =================
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat("MMM yyyy").format(selectedDate);

    return Scaffold(
      backgroundColor: Colors.grey[200],

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        elevation: 0,
        leading: const Icon(Icons.arrow_back),
        title: const Text(
          "Riwayat Transaksi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      // ================= BODY =================
      body: Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[900],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                // ================= TAB =================
                Row(
                  children: [
                    Expanded(
                      child: _tabButton(
                        text: "Setor Sampah",
                        icon: Icons.delete_outline,
                        isActive: isSetor,
                        onTap: () {
                          setState(() {
                            isSetor = true;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _tabButton(
                        text: "Tarik Tunai",
                        icon: Icons.account_balance_wallet_outlined,
                        isActive: !isSetor,
                        onTap: () {
                          setState(() {
                            isSetor = false;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // ================= FILTER =================
                Row(
                  children: [
                    Expanded(
                      child: _filterTanggal(formattedDate),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _filterJenis(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ================= LIST =================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                TransactionCard(
                  title: "Plastik",
                  weight: "2 Kg",
                  status: "Menunggu Penjemputan",
                  price: "Rp 2000",
                  date: "10 Des 2025",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DetailRiwayatPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),

      // ================= NAVBAR =================
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green[900],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Riwayat"),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: "Mulai Setor"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifikasi"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }

  // ================= TAB BUTTON =================
  Widget _tabButton({
    required String text,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.green[700],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? Colors.green : Colors.white),
            const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(
                color: isActive ? Colors.green : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= FILTER TANGGAL =================
  Widget _filterTanggal(String text) {
    return GestureDetector(
      onTap: pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.green[700],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: Colors.white, size: 18),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // ================= FILTER JENIS =================
  Widget _filterJenis() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.green[700],
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedJenis,
          dropdownColor: Colors.green[700],
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          style: const TextStyle(color: Colors.white),
          items: jenisSampah.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedJenis = value!;
            });
          },
        ),
      ),
    );
  }
}

// ================= CARD =================
class TransactionCard extends StatelessWidget {
  final String title;
  final String weight;
  final String status;
  final String price;
  final String date;
  final VoidCallback onTap; // 🔥 TAMBAHAN

  const TransactionCard({
    super.key,
    required this.title,
    required this.weight,
    required this.status,
    required this.price,
    required this.date,
    required this.onTap, // 🔥 TAMBAHAN
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap, // 🔥 INI KUNCI NYA
        leading: CircleAvatar(
          backgroundColor: Colors.green[200],
          child: const Icon(Icons.recycling, color: Colors.green),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("$title  $weight",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(date, style: const TextStyle(fontSize: 12)),
          ],
        ),
        subtitle: Text("Status: $status"),
        trailing: Text(
          price,
          style: const TextStyle(
              color: Colors.green, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}