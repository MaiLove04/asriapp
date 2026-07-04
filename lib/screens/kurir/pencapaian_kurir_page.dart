import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config.dart';

// Palet warna premium dengan kontras tinggi (Senior-Friendly & Professional)
const primaryColor = Color(0xFF1B4D1B);     // Hijau tua yang dalam dan profesional
const secondaryColor = Color(0xFF2E7D32);   // Hijau material aktif
const softGreenColor = Color(0xFFF0F7F1);   // Latar belakang elemen hijau lembut
const backgroundColor = Color(0xFFF4F7F4);  // Abu-hijau muda untuk menonjolkan kartu putih
const darkTextColor = Color(0xFF0A1F0A);    // Teks utama super pekat
const greyTextColor = Color(0xFF4A554A);    // Teks sekunder yang tetap aman terbaca

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
      appBar: AppBar(
        title: const Text("Pencapaian Kerja", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor, strokeWidth: 3))
          : RefreshIndicator(
        onRefresh: _fetchData,
        color: primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(monthName, totalWeight),
              Transform.translate(
                offset: const Offset(0, -20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildChartSection(),
                      const SizedBox(height: 16),
                      _buildSummaryCards(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String monthName, double totalWeight) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 44),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, Color(0xFF143A14)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Periode Laporan", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(monthName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _selectMonth(context),
                icon: const Icon(Icons.calendar_month_rounded, size: 16),
                label: const Text("Pilih Bulan", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      height: 330,
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Grafik Sampah Harian", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkTextColor)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: softGreenColor, borderRadius: BorderRadius.circular(8)),
                child: const Text("Satuan: Kg", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor)),
              )
            ],
          ),
          const SizedBox(height: 28),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxWeight * 1.25,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => primaryColor,
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    tooltipMargin: 4,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        "${rod.toY.toStringAsFixed(1)} Kg",
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int day = value.toInt();
                        // Hanya tampilkan label kelipatan agar tidak padat bagi mata tua
                        if (day == 1 || day == 7 || day == 14 || day == 21 || day == 28 || day == dailyStats.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(day.toString(), style: const TextStyle(color: greyTextColor, fontWeight: FontWeight.bold, fontSize: 11)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: dailyStats.entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: entry.value > 0 ? primaryColor : Colors.grey.shade300,
                        width: 7,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Center(child: Text("Tanggal Kerja", style: TextStyle(color: greyTextColor, fontSize: 11, fontWeight: FontWeight.w600))),
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
          title: "Total Sampah Diangkut",
          value: "${totalWeight.toStringAsFixed(1)} Kg",
          icon: Icons.scale_rounded,
          color: Colors.orange.shade900,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: "Hari Aktif Kerja",
                value: "$activeDays Hari",
                icon: Icons.calendar_today_rounded,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
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
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: greyTextColor, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkTextColor, letterSpacing: -0.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Komponen kartu ringkasan mini
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({required this.title, required this.value, required this.icon, required this.color});

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
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
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

// Dekorasi komponen kartu profesional (Sama dengan spesifikasi Dashboard sebelumnya)
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