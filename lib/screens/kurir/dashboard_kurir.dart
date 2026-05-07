import 'package:flutter/material.dart';
import '../models/dashboard_kurir_model.dart';
import '../services/kurir_service.dart';

class DashboardKurir extends StatefulWidget {
  const DashboardKurir({super.key});

  @override
  State<DashboardKurir> createState() => _DashboardKurir();
}

class _DashboardKurir extends State<DashboardKurir> {
  static const Color primary = Color(0xff2C5A27);
  static const Color secondary = Color(0xff3F6F35);
  static const Color softGreen = Color(0xffD7E9C4);
  static const Color bgColor = Color(0xffF4F4EF);
  static const Color textDark = Color(0xff2F3A2D);
  static const Color subtitleGrey = Color(0xff6B7280);

  int selectedNav = 0;

  DashboardKurirModel? dashboard;

  bool isLoading = true;
  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  _header(),
                  Transform.translate(
                    offset: const Offset(0, -24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        children: [
                          _greetingCard(),
                          const SizedBox(height: 22),
                          _sectionTitle("Ringkasan Hari Ini"),
                          const SizedBox(height: 12),
                          _summaryCard(),
                          const SizedBox(height: 22),
                          _sectionTitle("Menu Utama"),
                          const SizedBox(height: 14),
                          _menuSection(),
                          const SizedBox(height: 24),
                          _sectionTitle("Catatan Sampah Anda"),
                          const SizedBox(height: 12),
                          _noteCard(),
                          const SizedBox(height: 24),
                          _sectionTitle("Riwayat Setoran"),
                          const SizedBox(height: 12),
                          _historyItem(
                            title: "Organik",
                            date: "10 Des 2025",
                          ),
                          const SizedBox(height: 10),
                          _historyItem(
                            title: "Anorganik",
                            date: "10 Des 2025",
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: softGreen,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        onPressed: () {},
        child: const Icon(
          Icons.qr_code_scanner,
          color: primary,
          size: 28,
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance,
              color: primary,
            ),
          ),
          const Spacer(),
          const Text(
            "Besayan Besari",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.power_settings_new,
            color: Colors.white,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _greetingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: primary.withOpacity(.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: softGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: primary, width: 2),
                ),
                child: const Icon(
                  Icons.person,
                  color: primary,
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Halo, Pak Dito !",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Semoga hari anda menyenangkan!",
                      style: TextStyle(
                        color: textDark,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "Ada 3 jemputan hari ini.",
                      style: TextStyle(
                        color: textDark,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.local_shipping,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Text(
                  "MULAI JEMPUT",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primary),
        gradient: const LinearGradient(
          colors: [
            Colors.white,
            softGreen,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Row(
            children: const [
              Icon(
                Icons.local_shipping,
                color: primary,
                size: 32,
              ),
              SizedBox(width: 10),
              Text(
                "3 Lokasi",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 1,
            height: 40,
            color: primary,
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Total Sampah:",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.scale,
                    color: primary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    "3 Kg",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _menuSection() {
    final menus = [
      ["Daftar\nPenjemputan", Icons.list],
      ["Navigasi\nLokasi", Icons.location_on],
      ["Data\nSampah", Icons.delete_outline],
      ["Riwayat\nPenjemputan", Icons.description_outlined],
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: menus.map((menu) {
        return Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                menu[1] as IconData,
                color: primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 72,
              child: Text(
                menu[0] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.2,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _noteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(
                child: Text(
                  "Anda mengumpulkan 10 Kg sampah bulan ini, 3 kg lebih banyak dari bulan lalu.",
                  style: TextStyle(
                    fontSize: 15,
                    color: textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.trending_up,
                size: 46,
                color: primary,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),
        ],
      ),
    );
  }

  Widget _historyItem({
    required String title,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: primary.withOpacity(.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: softGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    color: subtitleGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Rp 2000",
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "2Kg",
                style: TextStyle(
                  color: subtitleGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bottomNav() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      elevation: 12,
      child: SizedBox(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home, "Beranda", 0),
            _navItem(Icons.history, "Riwayat", 1),
            const SizedBox(width: 30),
            _navItem(Icons.notifications, "Notifikasi", 2),
            _navItem(Icons.person, "Profil", 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
      IconData icon,
      String label,
      int index,
      ) {
    final selected = selectedNav == index;

    return InkWell(
      onTap: () {
        setState(() {
          selectedNav = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: selected ? primary : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: selected ? primary : Colors.grey,
              fontWeight:
              selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}