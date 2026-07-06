import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/client_helper.dart';

import '../../config.dart';
import '../services/jadwal_service.dart';
import '../services/dashboard_kurir_service.dart';
import 'NotifikasiKurirScreen.dart';
import 'RiwayatKurirScreen.dart';
import 'ProfilKurirScreen.dart';
import 'ScanBarcode.dart';
import 'SetorSampahPage.dart';
import 'navigasi_kurir_page.dart';

const primaryColor = Color(0xFF1E521E);
const secondaryColor = Color(0xFF4CAF50);
const softGreenColor = Color(0xFFE8F5E9);
const backgroundColor = Color(0xFFF9FBF9);
const darkTextColor = Color(0xFF0D240D);
const greyTextColor = Color(0xFF555555);

class JadwalJemputScreen extends StatefulWidget {
  const JadwalJemputScreen({super.key});

  @override
  State<JadwalJemputScreen> createState() => _JadwalJemputScreenState();
}

class _JadwalJemputScreenState extends State<JadwalJemputScreen> {
  List<dynamic> jadwalList = [];
  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    getJadwal();
  }

  Future<void> getJadwal() async {
    try {
      setState(() => isLoading = true);
      SharedPreferences prefs = await SharedPreferences.getInstance();

      int userId = 0;
      var rawId = prefs.get('user_id');
      if (rawId is int) {
        userId = rawId;
      } else if (rawId is String) {
        userId = int.tryParse(rawId) ?? 0;
      }

      if (userId == 0) {
        setState(() => isLoading = false);
        _bukaDialogInterogasi(
          "⚠️ MASALAH LOGIN:\nID Kurir di HP terbaca 0. Silakan LOGOUT lalu LOGIN ulang agar ID tersimpan di memori HP!",
        );
        return;
      }

      final resultJadwal = await JadwalService.getJadwalKurir(userId);

      if (!mounted) return;
      setState(() {
        jadwalList = resultJadwal;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _bukaDialogInterogasi(String pesan) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text(
          "🔍 Hasil Interogasi Sistem",
          style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
        ),
        content: Text(
          pesan,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text("SAYA PAHAM", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> mulaiJemputKurir(String jadwalId) async {
    try {
      setState(() => isLoading = true);
      final secureClient = getSafeClient();
      final targetUrl = "${AppConfig.baseUrl}/jadwal-penjemputan/$jadwalId/mulai";

      final response = await secureClient.patch(
        Uri.parse(targetUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("STATUS TUGAS: DALAM PROSES PENJEMPUTAN!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            backgroundColor: Colors.blueAccent,
            duration: Duration(seconds: 3),
          ),
        );
        getJadwal();
      }
    } catch (e) {
      print("Error koneksi penjemputan: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor, strokeWidth: 4)),
      );
    }

    List<dynamic> filteredList = jadwalList.where((jadwal) {
      String namaNasabah = (jadwal['nasabah']?['name'] ?? '').toString().toLowerCase();
      String alamatTugas = (jadwal['alamat'] ?? '').toString().toLowerCase();

      return namaNasabah.contains(searchQuery.toLowerCase()) ||
          alamatTugas.contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // ================= HEADER FIXED =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryColor, Color(0xFF2E6B2E)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 26),
                        onPressed: () => Navigator.pop(context, true),
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          "Jadwal Penjemputan",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 28),
                        onPressed: () => getJadwal(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      "Ada ${filteredList.length} total tugas penjemputan",
                      style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= SEARCH BAR =================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              controller: searchController,
              onChanged: (value) => setState(() => searchQuery = value),
              style: const TextStyle(color: darkTextColor, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: "Cari nama nasabah atau alamat...",
                hintStyle: const TextStyle(color: greyTextColor),
                prefixIcon: const Icon(Icons.search_rounded, color: primaryColor),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: greyTextColor),
                  onPressed: () {
                    searchController.clear();
                    setState(() => searchQuery = "");
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryColor, width: 2)),
              ),
            ),
          ),

          // ================= CARDS LIST =================
          Expanded(
            child: filteredList.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_late_rounded, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    "Tidak ada jadwal penjemputan",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              color: primaryColor,
              onRefresh: getJadwal,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final item = filteredList[index];

                  String jamFormatted = "--:--";
                  if (item['created_at'] != null && item['created_at'].toString().length >= 16) {
                    try {
                      jamFormatted = item['created_at'].toString().substring(11, 16);
                    } catch (e) {
                      jamFormatted = "--:--";
                    }
                  }

                  String displayStatus = (item['status'] ?? 'terjadwal').toString().toLowerCase();
                  bool isTerjadwal = (displayStatus == 'terjadwal' || displayStatus == 'pending');
                  bool isProses = (displayStatus == 'proses' || displayStatus == 'on_progress');

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: JadwalCard(
                      id: item['id'].toString(),
                      nama: item['nasabah']?['name'] ?? 'Tanpa Nama',
                      alamat: item['alamat'] ?? 'Alamat tidak tersedia',
                      catatan: item['catatan'] ?? 'Tidak ada catatan tambahan',
                      jam: jamFormatted,
                      status: displayStatus,
                      onLihatLokasi: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const NavigasiKurirPage()));
                      },
                      onMulaiJemput: () async {
                        if (isTerjadwal) {
                          mulaiJemputKurir(item['jadwal_id'].toString());
                        } else if (isProses) {
                          final String idJadwal = item['id'].toString();
                          final refresh = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ScanBarcodePage(jadwalId: idJadwal)),
                          );
                          if (refresh == true) getJadwal();
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      // 🔥 MENGUBAH LOKASI FAB AGAR BERADA PAS DI TENGAH LAYAR BAWAH
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // ================= FLOATING ACTION SCANNER (CENTER FLOAT) =================
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30.0), // Jarak ngambang ke atas dari bawah layar
        child: Container(
          height: 72,
          width: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton(
            elevation: 0,
            backgroundColor: primaryColor,
            shape: const CircleBorder(),
            onPressed: () async {
              String idJadwalTerpilih = jadwalList.isNotEmpty ? jadwalList[0]['jadwalId']?.toString() ?? '' : '';
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ScanBarcodePage(jadwalId: idJadwalTerpilih),
                ),
              );
              if (result == true) getJadwal();
            },
            child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }
}

class JadwalCard extends StatelessWidget {
  final String id;
  final String nama;
  final String alamat;
  final String catatan;
  final String jam;
  final String status;
  final VoidCallback onLihatLokasi;
  final VoidCallback onMulaiJemput;

  const JadwalCard({
    super.key,
    required this.id,
    required this.nama,
    required this.alamat,
    required this.catatan,
    required this.jam,
    required this.status,
    required this.onLihatLokasi,
    required this.onMulaiJemput,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String displayStatus = status.toLowerCase();

    if (displayStatus == 'selesai' || displayStatus == 'completed') {
      statusColor = Colors.green.shade800;
    } else if (displayStatus == 'proses' || displayStatus == 'on_progress') {
      statusColor = Colors.blue.shade800;
    } else {
      statusColor = Colors.orange.shade800;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: primaryColor.withOpacity(0.08),
                child: const Icon(Icons.person_rounded, color: primaryColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: darkTextColor, letterSpacing: -0.3)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(padding: EdgeInsets.only(top: 2.0), child: Icon(Icons.location_on_rounded, size: 16, color: primaryColor)),
                        const SizedBox(width: 6),
                        Expanded(child: Text(alamat, style: const TextStyle(color: greyTextColor, fontSize: 13, fontWeight: FontWeight.w700))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(padding: EdgeInsets.only(top: 2.0), child: Icon(Icons.sticky_note_2_rounded, size: 16, color: secondaryColor)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                              "Catatan: $catatan",
                              style: const TextStyle(color: Colors.deepOrange, fontSize: 13, fontWeight: FontWeight.w600)
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: statusColor.withOpacity(.1), borderRadius: BorderRadius.circular(14)),
                child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.3)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onLihatLokasi,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 50),
                side: const BorderSide(color: primaryColor, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.map_rounded, color: primaryColor, size: 18),
              label: const Text("LIHAT LOKASI / NAVIGASI MAPS", style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.3)),
            ),
          ),
        ],
      ),
    );
  }
}