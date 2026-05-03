import 'package:asriapp/screens/user/activity_riwayat.dart';
import 'package:asriapp/screens/user/profile.dart';
import 'package:asriapp/screens/user/setor_sampah.dart';
import 'package:asriapp/screens/user/tarik_tunai.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({super.key});
class DashboardScreen extends StatelessWidget {
  final String name;

  const DashboardScreen({
    super.key,
    required this.name,
  });

  Future<bool> _showExitDialog(BuildContext context) async {
    bool? keluar = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: const Text("Apakah yakin ingin keluar?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Tidak"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Ya"),
            ),
          ],
        );
      },
    );

    return keluar ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        bool keluar = await _showExitDialog(context);
        if (keluar) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        bottomNavigationBar: _buildBottomNav(context),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [

                // HEADER
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2D5A27),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Basayan Bestari",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.power_settings_new, color: Colors.white),
                            onPressed: () async {
                              bool keluar = await _showExitDialog(context);
                              if (keluar) {
                                Navigator.pushReplacementNamed(context, '/login');
                              }
                            },
                          )
                        ],
                      ),
                      const SizedBox(height: 20),

                      // CARD WELCOME
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person, size: 35),
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Halo, $name!",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  "Terima kasih sudah menabung!\nLihat setoranmu bulan ini.",
                                  style: TextStyle(fontSize: 12),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "Ringkasan Hari Ini",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(45),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Row(
                            children: [

                              // KIRI
                              Expanded(
                                child: Container(
                                  color: Colors.white,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.monetization_on,
                                          color: Color(0xFF2E7D32)),
                                      SizedBox(height: 5),
                                      Text(
                                        "Rp 15.000",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "Saldo Poin Anda",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // KANAN
                              Expanded(
                                child: Container(
                                  color: const Color(0xFFA5D6A7),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.scale,
                                          color: Color(0xFF1B5E20)),
                                      SizedBox(height: 5),
                                      Text(
                                        "1,6 Kg",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1B5E20),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "Total Setoran Bulan Ini",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // MENU
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Menu Utama",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _menuItem(Icons.receipt_long, "Riwayat\nTransaksi", () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RiwayatPage(),
                              ),
                            );
                          }),
                          _menuItem(
                            Icons.delete,
                            "Setor\nSampah",
                                () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SetorSampahScreen(),
                                ),
                              );
                            },
                          ),
                          _menuItem(Icons.attach_money, "Tarik\nTunai", () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TarikTunaiPage(),
                              ),
                            );
                          }),
                          _menuItem(Icons.help_outline, "Bantuan", () {}),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Catatan Sampah Anda",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Anda mengumpulkan 10 Kg sampah\nbulan ini, 3 kg lebih banyak dari\nbulan lalu.",
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.show_chart,
                          size: 50,
                          color: Color(0xFF2E7D32),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    height: 1,
                    color: Colors.grey.shade400,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Riwayat Setoran",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      _historyItem("Organik", "10 Des 2025", "Rp 2000", "2 Kg"),
                      _historyItem("Anorganik", "10 Des 2025", "Rp 2000", "2 Kg"),
                      _historyItem("Organik", "10 Des 2025", "Rp 2000", "2 Kg"),
                    ],
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                )
              ],
            ),
            child: Icon(icon, color: const Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          )
        ],
      ),
    );
  }

  Widget _historyItem(String type, String date, String price, String weight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(type,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(date, style: const TextStyle(fontSize: 12))
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(weight, style: const TextStyle(fontSize: 12))
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: const Color(0xFF2E7D32),
      unselectedItemColor: Colors.grey,
      currentIndex: 0, // halaman dashboard
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RiwayatPage(),
            ),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SetorSampahScreen(),
            ),
          );
        } else if (index == 3) {
          // Notifikasi (kosong dulu)
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const profile_page(), // 🔥 INI
            ),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: "Riwayat"),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: "Mulai Setor"),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifikasi"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
      ],
    );
  }}

