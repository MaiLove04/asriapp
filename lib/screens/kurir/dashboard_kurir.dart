import 'package:flutter/material.dart';

class DashboardKurir extends StatelessWidget {
  const DashboardKurir({super.key});

  static const primary = Color(0xFF2F6B2F);
  static const secondary = Color(0xFF58C063);
  static const softGreen = Color(0xFFEAF8EC);
  static const background = Color(0xFFF7F8FA);
  static const darkText = Color(0xFF1B1B1B);
  static const greyText = Color(0xFF7A7A7A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: SingleChildScrollView(
        child: Column(
          children: [

            const _HeaderSection(),

            //card awal
            Transform.translate(
              offset: const Offset(
                0,
                -30,
              ),

              child: const Padding(
                padding:
                EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child:
                _ActiveMissionCard(),
              ),
            ),

            //ringkasan
            Transform.translate(
              offset: const Offset(
                0,
                -18,
              ),

              child: Padding(
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 20,
                ),

                child: Column(
                  children: [

                    _sectionTitle(
                      "Ringkasan Hari Ini",
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    const _TodaySummarySection(),

                    const SizedBox(
                      height: 28,
                    ),

                    _sectionTitle(
                      "Akses Cepat",
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    const _QuickActionsRow(),

                    const SizedBox(
                      height: 28,
                    ),

                    _sectionTitle(
                      "Performa Bulan Ini",
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    const _InsightCard(),

                    const SizedBox(
                      height: 28,
                    ),

                    _sectionTitle(
                      "Aktivitas Terbaru",
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    ...dummyHistory.map(
                          (e) =>
                          _ActivityCard(
                            data: e,
                          ),
                    ),

                    const SizedBox(
                      height: 120,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButtonLocation:
      FloatingActionButtonLocation
          .centerDocked,

      floatingActionButton:
      const _ScanFab(),

      bottomNavigationBar:
      const _PremiumBottomNav(),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
      ),
    );
  }
}

class _TodaySummarySection
    extends StatelessWidget {

  const _TodaySummarySection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        Expanded(
          child: _SummaryCard(
            icon:
            Icons.local_shipping,
            title:
            "Tugas Hari Ini",
            value:
            "3 Lokasi",
            subtitle:
            "2 selesai",
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: _SummaryCard(
            icon:
            Icons.recycling,
            title:
            "Hasil Hari Ini",
            value:
            "12 Kg",
            subtitle:
            "Rp45K",
          ),
        ),
      ],
    );
  }
}

class _SummaryCard
    extends StatelessWidget {

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(

      height: 130,

      padding:
      const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(
          24,
        ),

        border: Border.all(
          color:
          Colors.grey
              .withOpacity(
            .08,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black
                .withOpacity(
              .03,
            ),
            blurRadius: 18,
            offset:
            const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Icon(
            icon,
            size: 18,
            color:
            DashboardKurir
                .primary,
          ),

          const Spacer(),

          Text(
            title,
            style:
            const TextStyle(
              fontSize: 11,
              color:
              DashboardKurir
                  .greyText,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style:
            const TextStyle(
              fontSize: 20,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,
            style:
            const TextStyle(
              fontSize: 12,
              color: Colors.green,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow
    extends StatelessWidget {

  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: const [

        _MiniActionCard(
          icon:
          Icons.list_alt_outlined,
          title: "Jemput",
        ),

        _MiniActionCard(
          icon:
          Icons.map_outlined,
          title: "Map",
        ),

        _MiniActionCard(
          icon:
          Icons.delete_outline,
          title: "Data",
        ),

        _MiniActionCard(
          icon: Icons.history,
          title: "Riwayat",
        ),
      ],
    );
  }
}

class _MiniActionCard
    extends StatelessWidget {

  final IconData icon;
  final String title;

  const _MiniActionCard({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 90,

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(
              .04,
            ),
            blurRadius: 18,
            offset:
            const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [

          Container(
            padding:
            const EdgeInsets.all(9),

            decoration: BoxDecoration(
              color:
              DashboardKurir
                  .softGreen,

              borderRadius:
              BorderRadius.circular(
                14,
              ),
            ),

            child: Icon(
              icon,
              size: 20,
              color:
              DashboardKurir
                  .primary,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumBottomNav
    extends StatelessWidget {
  const _PremiumBottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 72,

      shape:
      const CircularNotchedRectangle(),

      notchMargin: 8,

      elevation: 12,

      color: Colors.white,

      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceAround,
        children: [

          _navItem(
            icon: Icons.home,
            label: "Beranda",
            active: true,
          ),

          _navItem(
            icon: Icons.history,
            label: "Riwayat",
          ),

          const SizedBox(width: 40),

          _navItem(
            icon:
            Icons.notifications_none,
            label: "Notif",
          ),

          _navItem(
            icon: Icons.person_outline,
            label: "Profil",
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    bool active = false,
  }) {
    return Column(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: [

        Icon(
          icon,
          size: 22,
          color: active
              ? DashboardKurir.primary
              : Colors.grey,
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight:
            FontWeight.w600,
            color: active
                ? DashboardKurir.primary
                : Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _ScanFab extends StatelessWidget {
  const _ScanFab();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      width: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        elevation: 0,
        backgroundColor:
        DashboardKurir.primary,
        onPressed: () {},

        child: const Icon(
          Icons.qr_code_scanner,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 165, // sebelumnya 200

      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DashboardKurir.primary,
            DashboardKurir.secondary,
          ],
        ),

        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(36),
        ),
      ),

      child: SafeArea(
        bottom: false,

        //logo
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 30,
          ),

          child: Align(
            alignment: Alignment.topCenter,

            child: Row(
              children: [

                _logo(),

                const SizedBox(
                  width: 12,
                ),

                const Expanded(
                  child: Text(
                    "ASRI",

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                ),

                const SizedBox(
                  width: 14,
                ),

                const Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    return Container(
      width: 48,
      height: 48,

      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 12,
          ),
        ],
      ),

      child: ClipOval(
        child: Image.asset(
          "assets/images/logo_asri.png",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _ActiveMissionCard
    extends StatelessWidget {

  const _ActiveMissionCard();

  @override
  Widget build(BuildContext context) {
    return Container(

      padding:
      const EdgeInsets.all(22),

      decoration:
      cardDecoration(),

      child: Column(
        children: [

          Row(
            children: [

              const CircleAvatar(
                radius: 26,

                backgroundImage:
                AssetImage(
                  "assets/images/kurir.jpg",
                ),
              ),

              const SizedBox(
                  width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [

                    Text(
                      "Halo, Budi Saputra 👋",
                      style:
                      TextStyle(
                        fontSize:
                        16,
                        fontWeight:
                        FontWeight
                            .bold,
                      ),
                    ),

                    SizedBox(
                        height: 4),

                    Text(
                      "Kurir Aktif • Online",
                      style:
                      TextStyle(
                        color:
                        DashboardKurir
                            .greyText,
                        fontSize:
                        12,
                      ),
                    ),
                  ],
                ),
              ),

              _activeBadge(),
            ],
          ),

          const SizedBox(
              height: 20),

          const Align(
            alignment:
            Alignment.centerLeft,
            child: Text(
              "Jemputan Hari Ini",
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(
              height: 4),

          const Align(
            alignment:
            Alignment.centerLeft,
            child: Text(
              "3 tugas aktif",
            ),
          ),

          const SizedBox(
              height: 18),

          ClipRRect(
            borderRadius:
            BorderRadius.circular(
              12,
            ),

            child:
            const LinearProgressIndicator(
              value: .65,
              minHeight: 8,
            ),
          ),

          const SizedBox(
              height: 12),

          Row(
            children: [

              const Text(
                "65% selesai",
                style: TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const Spacer(),

              _startButton(),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _activeBadge() {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color:
        DashboardKurir
            .softGreen,

        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),

      child: const Text(
        "AKTIF",
        style: TextStyle(
          fontSize: 11,
          fontWeight:
          FontWeight.bold,
          color:
          DashboardKurir
              .primary,
        ),
      ),
    );
  }

  static Widget _startButton() {
    return ElevatedButton.icon(
      onPressed: () {},

      style:
      ElevatedButton.styleFrom(
        backgroundColor:
        DashboardKurir.primary,

        foregroundColor:
        Colors.white,

        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(
            18,
          ),
        ),
      ),

      icon: const Icon(
        Icons.local_shipping,
        color: Colors.white,
      ),

      label: const Text(
        "MULAI",
        style: TextStyle(
          color: Colors.white,
          fontWeight:
          FontWeight.bold,
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: cardDecoration(),
      child: Row(
        children: [

          const Expanded(
            child: Text(
              "Anda mengumpulkan 10 Kg "
                  "sampah bulan ini.\n"
                  "Naik 3 Kg dari bulan lalu.",
              style: TextStyle(
                height: 1.6,
              ),
            ),
          ),

          Icon(
            Icons.trending_up,
            size: 44,
            color:
            DashboardKurir.primary,
          ),
        ],
      ),
    );
  }
}

class _ActivityCard
    extends StatelessWidget {

  final HistoryModel data;

  const _ActivityCard({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(

      margin:
      const EdgeInsets.only(
        bottom: 14,
      ),

      padding:
      const EdgeInsets.all(
        16,
      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(
          22,
        ),

        border: Border.all(
          color:
          Colors.grey
              .withOpacity(.08),
        ),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black
                .withOpacity(
              .025,
            ),
            blurRadius: 18,
            offset:
            const Offset(0, 6),
          ),
        ],
      ),

      child: Row(
        children: [

          Container(
            width: 48,
            height: 48,

            decoration:
            BoxDecoration(
              color:
              DashboardKurir
                  .softGreen,

              borderRadius:
              BorderRadius
                  .circular(
                16,
              ),
            ),

            child: const Icon(
              Icons.recycling,
              color:
              DashboardKurir
                  .primary,
            ),
          ),

          const SizedBox(
              width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [

                Row(
                  children: [

                    Expanded(
                      child: Text(
                        data.name,
                        style:
                        const TextStyle(
                          fontSize:
                          14,
                          fontWeight:
                          FontWeight
                              .bold,
                        ),
                      ),
                    ),

                    _statusChip(),
                  ],
                ),

                const SizedBox(
                    height: 4),

                Text(
                  data.date,
                  style:
                  const TextStyle(
                    fontSize:
                    12,
                    color:
                    DashboardKurir
                        .greyText,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
              width: 10),

          Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .end,

            children: [

              Text(
                data.price,
                style:
                const TextStyle(
                  fontSize: 14,
                  fontWeight:
                  FontWeight
                      .bold,
                  color:
                  Colors.green,
                ),
              ),

              const SizedBox(
                  height: 4),

              Text(
                data.weight,
                style:
                const TextStyle(
                  fontSize: 12,
                  color:
                  DashboardKurir
                      .greyText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip() {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),

      decoration: BoxDecoration(
        color:
        DashboardKurir
            .softGreen,

        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),

      child: const Text(
        "Selesai",
        style: TextStyle(
          fontSize: 10,
          fontWeight:
          FontWeight.bold,
          color:
          DashboardKurir
              .primary,
        ),
      ),
    );
  }
}

BoxDecoration cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius:
    BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color:
        Colors.black.withOpacity(
          .04,
        ),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ],
  );
}

class HistoryModel {
  final String name;
  final String date;
  final String price;
  final String weight;

  HistoryModel({
    required this.name,
    required this.date,
    required this.price,
    required this.weight,
  });
}

final dummyHistory = [

  HistoryModel(
    name: "Organik",
    date: "10 Des 2025",
    price: "+Rp2.000",
    weight: "2 Kg",
  ),

  HistoryModel(
    name: "Botol Plastik",
    date: "08 Des 2025",
    price: "+Rp4.000",
    weight: "3 Kg",
  ),

  HistoryModel(
    name: "Kertas",
    date: "05 Des 2025",
    price: "+Rp3.000",
    weight: "5 Kg",
  ),
];