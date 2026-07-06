import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config.dart';

// 🎨 PALET WARNA KONSISTEN PREMIUM ASRI (Kontras Tinggi & Profesional)
const primaryColor = Color(0xFF1B4D1B);     // Hijau tua yang dalam dan profesional
const secondaryColor = Color(0xFF2E7D32);   // Hijau material aktif
const softGreenColor = Color(0xFFF0F7F1);   // Latar belakang elemen hijau lembut
const backgroundColor = Color(0xFFF4F7F4);  // Abu-hijau muda
const darkTextColor = Color(0xFF0A1F0A);    // Teks utama super pekat
const greyTextColor = Color(0xFF4A554A);    // Teks sekunder kontras tinggi

class PencapaianKurirPage extends StatefulWidget {
  const PencapaianKurirPage({super.key});

  @override
  State<PencapaianKurirPage> createState() => _PencapaianKurirPageState();
}

class _PencapaianKurirPageState extends State<PencapaianKurirPage> {
  bool isLoading = true;
  List<dynamic> riwayatList = [];
  DateTime selectedMonth = DateTime.now();
  Map<int, double> dailyStats = {};
  Map<int, int> dailyRevenue = {};
  double maxWeight = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('user_id') ?? 0;

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/riwayat-kurir/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          riwayatList = data;
        } else if (data is Map) {
          riwayatList = data['riwayat'] ?? data['aktivitas_terbaru'] ?? [];
        }
        _processData();
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _processData() {
    dailyStats.clear();
    dailyRevenue.clear();
    maxWeight = 0;

    int daysInMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
    for (int i = 1; i <= daysInMonth; i++) {
      dailyStats[i] = 0.0;
      dailyRevenue[i] = 0;
    }

    for (var item in riwayatList) {
      String rawDate = item['created_at'] ?? '';
      if (rawDate.isNotEmpty) {
        DateTime date = DateTime.parse(rawDate);
        if (date.year == selectedMonth.year && date.month == selectedMonth.month) {
          double berat = double.tryParse(item['berat'].toString()) ?? 0.0;
          int total = int.tryParse(item['total'].toString()) ?? 0;
          dailyStats[date.day] = (dailyStats[date.day] ?? 0) + berat;
          dailyRevenue[date.day] = (dailyRevenue[date.day] ?? 0) + total;
        }
      }
    }

    dailyStats.forEach((day, weight) {
      if (weight > maxWeight) maxWeight = weight;
    });

    if (maxWeight == 0) maxWeight = 10;
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: "PILIH BULAN & TAHUN",
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: darkTextColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedMonth = DateTime(picked.year, picked.month);
        _processData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String monthName = DateFormat('MMMM yyyy', 'id_ID').format(selectedMonth);
    double totalWeight = dailyStats.values.fold(0, (sum, item) => sum + item);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor, strokeWidth: 4))
          : RefreshIndicator(
        onRefresh: _fetchData,
        color: primaryColor,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            // ================= HEADER MODERN =================
            SliverAppBar(
              expandedHeight: 150,
              pinned: true,
              elevation: 0,
              backgroundColor: primaryColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              centerTitle: true,
              title: const Text(
                "Pencapaian Kerja Kurir",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.3),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryColor, Color(0xFF143A14)],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Periode Laporan", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text(monthName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _selectMonth(context),
                          icon: const Icon(Icons.calendar_month_rounded, size: 16),
                          label: const Text("Pilih Bulan", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.18),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Lengkungan Pemisah Konten Premium
            SliverToBoxAdapter(
              child: Container(
                height: 20,
                decoration: const BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
              ),
            ),

            // ================= ISI PANEL KONTEN =================
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildChartSection(),
                  const SizedBox(height: 20),
                  _sectionHeading("Ringkasan Statistik Kerja"),
                  const SizedBox(height: 12),
                  _buildSummaryCards(),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeading(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkTextColor, letterSpacing: -0.2),
    );
  }

  // 🔥 PERUBAHAN UTAMA: Grafik Batang Kaku diubah menjadi Grafik Kurva Garis Area yang Halus & Sangat Bersih
  Widget _buildChartSection() {
    List<FlSpot> spots = dailyStats.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();

    return Container(
      height: 310,
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Tren Setoran Sampah", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkTextColor)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: softGreenColor, borderRadius: BorderRadius.circular(8)),
                child: const Text("Satuan: Kg", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor)),
              )
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => primaryColor,
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          "Tgl ${spot.x.toInt()}\n${spot.y.toStringAsFixed(1)} Kg",
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, height: 1.3),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        int day = value.toInt();
                        if (day == 1 || day == 7 || day == 14 || day == 21 || day == 28 || day == dailyStats.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(day.toString(), style: const TextStyle(color: greyTextColor, fontWeight: FontWeight.bold, fontSize: 11)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        if (value == meta.max || value == meta.min) return const SizedBox.shrink();
                        return Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(color: greyTextColor, fontSize: 11, fontWeight: FontWeight.w600),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 1,
                maxX: dailyStats.length.toDouble(),
                minY: 0,
                maxY: maxWeight * 1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true, // 🔥 Tetap aktifkan ini untuk membuat kurva melengkung halus
                    color: primaryColor,
                    barWidth: 3.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [primaryColor.withOpacity(0.24), primaryColor.withOpacity(0.00)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Center(child: Text("Tanggal Kerja Operasional", style: TextStyle(color: greyTextColor, fontSize: 11, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
  Widget _buildSummaryCards() {
    double totalWeight = dailyStats.values.fold(0, (sum, item) => sum + item);
    int activeDays = dailyStats.values.where((v) => v > 0).length;
    int totalRev = dailyRevenue.values.fold(0, (sum, item) => sum + item);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Column(
      children: [
        _WideSummaryCard(
          title: "Total Sampah Berhasil Diangkut",
          value: "${totalWeight.toStringAsFixed(1)} Kg",
          icon: Icons.scale_rounded,
          color: Colors.orange.shade900,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MiniSummaryCard(
                title: "Hari Aktif Jalan",
                value: "$activeDays Hari",
                icon: Icons.directions_bike_rounded,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniSummaryCard(
                title: "Total Pendapatan",
                value: currencyFormatter.format(totalRev),
                icon: Icons.payments_rounded,
                color: Colors.teal.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Komponen kartu ringkasan melebar (Utama)
class _WideSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _WideSummaryCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: greyTextColor, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkTextColor, letterSpacing: -0.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Komponen kartu ringkasan mini
class _MiniSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniSummaryCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(fontSize: 11, color: greyTextColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkTextColor, height: 1.2)),
        ],
      ),
    );
  }
}

// Dekorasi komponen kartu profesional
BoxDecoration cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: primaryColor.withOpacity(0.12),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.03),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}