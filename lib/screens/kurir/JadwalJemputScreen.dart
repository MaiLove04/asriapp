import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/jadwal_service.dart';

const primary = Color(0xFF2F6B2F);
const secondary = Color(0xFF58C063);
const softGreen = Color(0xFFEAF8EC);
const background = Color(0xFFF7F8FA);
const darkText = Color(0xFF1B1B1B);
const greyText = Color(0xFF7A7A7A);

class JadwalJemputScreen
    extends StatefulWidget {

  const JadwalJemputScreen({
    super.key,
  });

  @override
  State<JadwalJemputScreen>
  createState() =>
      _JadwalJemputScreenState();
}

class _JadwalJemputScreenState
    extends State<JadwalJemputScreen> {

  List<dynamic> jadwalList = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    getJadwal();
  }

  Future<void> getJadwal() async {

    try {

      SharedPreferences prefs =
      await SharedPreferences
          .getInstance();

      int userId =
          prefs.getInt(
              'user_id') ?? 0;

      final result =
      await JadwalService
          .getJadwalKurir(
          userId);

      setState(() {

        jadwalList = result;
        print(jadwalList);
        isLoading = false;
      });

    } catch (e) {

      print(e);

      setState(() {

        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {

      return const Scaffold(

        body: Center(

          child:
          CircularProgressIndicator(),

        ),
      );
    }
    return Scaffold(

      backgroundColor: background,

      body: Column(
        children: [

          // ================= HEADER =================
          Container(

            height: 220,

            decoration: const BoxDecoration(

              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primary,
                  secondary,
                ],
              ),

              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(36),
              ),
            ),

            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 18,
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Row(
                      children: [

                        Container(
                          width: 52,
                          height: 52,

                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),

                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Image.asset(
                              "assets/images/logo_asri.png",
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        const Expanded(
                          child: Text(
                            "ASRI",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const Icon(
                          Icons.notifications_none,
                          color: Colors.white,
                          size: 26,
                        ),

                        const SizedBox(width: 14),

                        const Icon(
                          Icons.logout,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),

                    const Spacer(),

                    const Text(
                      "Jadwal Penjemputan",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "3 jadwal hari ini",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ================= BODY =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [

                  // ================= SEARCH =================
                  Container(

                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),

                    height: 60,

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                      BorderRadius.circular(22),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.04),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),

                    child: Row(
                      children: [

                        Icon(
                          Icons.search,
                          color: primary,
                          size: 28,
                        ),

                        const SizedBox(width: 14),

                        const Expanded(
                          child: TextField(

                            decoration: InputDecoration(
                              hintText:
                              "Cari alamat / nasabah",
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        Container(

                          padding: const EdgeInsets.all(10),

                          decoration: BoxDecoration(
                            color: softGreen,
                            borderRadius:
                            BorderRadius.circular(14),
                          ),

                          child: Icon(
                            Icons.tune,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ================= FILTER =================
                  SizedBox(
                    height: 42,

                    child: ListView(
                      scrollDirection: Axis.horizontal,

                      children: const [

                        FilterChipWidget(
                          title: "Semua",
                          active: true,
                        ),

                        FilterChipWidget(
                          title: "Hari Ini",
                        ),

                        FilterChipWidget(
                          title: "Proses",
                        ),

                        FilterChipWidget(
                          title: "Selesai",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ================= LIST =================
                  ...jadwalList.map(

                        (jadwal) => Padding(

                      padding:
                      const EdgeInsets.only(
                        bottom: 18,
                      ),

                      child: JadwalCard(


                        nama:
                        jadwal['nasabah']
                        ['name'],

                        alamat:
                        jadwal['alamat'],

                        jam:
                        jadwal[
                        'tanggal_penjemputan'
                        ],

                        status:
                        jadwal['status'],

                        statusColor:

                        jadwal['status']
                            == 'selesai'

                            ? Colors.green

                            : jadwal['status']
                            == 'proses'

                            ? Colors.blue

                            : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,

      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,

        onPressed: () {},

        child: const Icon(
          Icons.qr_code_scanner,
          color: Colors.white,
          size: 32,
        ),
      ),

      bottomNavigationBar: BottomAppBar(

        shape: const CircularNotchedRectangle(),

        notchMargin: 8,

        height: 74,

        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceAround,

          children: [

            navItem(
              Icons.home,
              "Beranda",
              true,
            ),

            navItem(
              Icons.history,
              "Riwayat",
              false,
            ),

            const SizedBox(width: 40),

            navItem(
              Icons.notifications_none,
              "Notif",
              false,
            ),

            navItem(
              Icons.person_outline,
              "Profil",
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget navItem(
      IconData icon,
      String label,
      bool active,
      ) {
    return Column(
      mainAxisAlignment:
      MainAxisAlignment.center,

      children: [

        Icon(
          icon,
          color:
          active
              ? primary
              : Colors.grey,
        ),

        const SizedBox(height: 4),

        Text(
          label,

          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color:
            active
                ? primary
                : Colors.grey,
          ),
        ),
      ],
    );
  }
}

// ================= FILTER CHIP =================

class FilterChipWidget extends StatelessWidget {

  final String title;
  final bool active;

  const FilterChipWidget({
    super.key,
    required this.title,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(

      margin: const EdgeInsets.only(
        right: 12,
      ),

      padding:
      const EdgeInsets.symmetric(
        horizontal: 22,
      ),

      decoration: BoxDecoration(
        color:
        active
            ? primary
            : Colors.white,

        borderRadius:
        BorderRadius.circular(18),
      ),

      alignment: Alignment.center,

      child: Text(
        title,

        style: TextStyle(
          color:
          active
              ? Colors.white
              : darkText,

          fontWeight:
          FontWeight.w600,
        ),
      ),
    );
  }
}

// ================= CARD =================

class JadwalCard extends StatelessWidget {

  final String nama;
  final String alamat;
  final String jam;
  final String status;
  final Color statusColor;

  const JadwalCard({
    super.key,
    required this.nama,
    required this.alamat,
    required this.jam,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(.04),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        children: [

          Row(
            children: [

              CircleAvatar(
                radius: 28,
                backgroundColor:
                softGreen,

                child: Icon(
                  Icons.person,
                  color: primary,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(
                      nama,

                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [

                        Icon(
                          Icons.location_on,
                          size: 18,
                          color: primary,
                        ),

                        const SizedBox(width: 6),

                        Expanded(
                          child: Text(
                            alamat,

                            style: TextStyle(
                              color: greyText,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [

                        Icon(
                          Icons.access_time,
                          size: 18,
                          color: primary,
                        ),

                        const SizedBox(width: 6),

                        Text(
                          jam,

                          style: TextStyle(
                            color: greyText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(

                padding:
                const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),

                decoration: BoxDecoration(
                  color:
                  statusColor.withOpacity(.12),

                  borderRadius:
                  BorderRadius.circular(20),
                ),

                child: Text(
                  status,

                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [

              Expanded(
                child: OutlinedButton.icon(

                  onPressed: () {},

                  style:
                  OutlinedButton.styleFrom(
                    minimumSize:
                    const Size(0, 54),

                    side: BorderSide(
                      color: primary,
                    ),

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(18),
                    ),
                  ),

                  icon: Icon(
                    Icons.map,
                    color: primary,
                  ),

                  label: Text(
                    "Lihat Lokasi",

                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: ElevatedButton.icon(

                  onPressed: () {},

                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    primary,

                    minimumSize:
                    const Size(0, 54),

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(18),
                    ),
                  ),

                  icon: const Icon(
                    Icons.local_shipping,
                    color: Colors.white,
                  ),

                  label: const Text(
                    "Mulai Jemput",

                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}