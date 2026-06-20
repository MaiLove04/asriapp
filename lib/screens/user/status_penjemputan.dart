import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/jadwal_service.dart';

const primaryColor = Color(0xFF1E521E);
const backgroundColor = Color(0xFFF9FBF9);
const darkTextColor = Color(0xFF0D240D);
const greyTextColor = Color(0xFF555555);

class StatusPenjemputanPage extends StatefulWidget {
  const StatusPenjemputanPage({super.key});

  @override
  State<StatusPenjemputanPage> createState() => _StatusPenjemputanPageState();
}

class _StatusPenjemputanPageState extends State<StatusPenjemputanPage> {
  Map<String, dynamic>? activeJadwal;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Ambil user_id dengan cara yang lebih aman (mendukung String & Int)
      int userId = 0;
      final rawId = prefs.get('user_id');
      if (rawId is int) {
        userId = rawId;
      } else if (rawId is String) {
        userId = int.tryParse(rawId) ?? 0;
      }
      
      print("DEBUG MAI - Lacak Status untuk User ID: $userId");

      if (userId != 0) {
        final data = await JadwalService.getJadwalNasabah(userId);
        setState(() {
          activeJadwal = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("DEBUG MAI - Error Load Status: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text("Status Penjemputan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : RefreshIndicator(
              onRefresh: _loadStatus,
              color: primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: activeJadwal == null
                    ? _buildEmptyState()
                    : _buildStatusContent(),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 100),
          Icon(Icons.assignment_turned_in_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("Tidak ada penjemputan aktif.", style: TextStyle(fontSize: 16, color: greyTextColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Yuk, request jemput sampah sekarang!", style: TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStatusContent() {
    String status = (activeJadwal!['status'] ?? 'terjadwal').toString().toLowerCase();
    String namaKurir = activeJadwal!['kurir']?['name'] ?? 'Kurir ASRI';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // INFO CARD
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.local_shipping_rounded, color: primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Kurir Penjemput", style: TextStyle(fontSize: 12, color: greyTextColor, fontWeight: FontWeight.bold)),
                        Text(namaKurir, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkTextColor)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              _rowInfo(Icons.calendar_today_rounded, "Tanggal", activeJadwal!['tanggal_penjemputan'] ?? '-'),
              const SizedBox(height: 12),
              _rowInfo(Icons.location_on_rounded, "Lokasi", activeJadwal!['alamat'] ?? '-'),
            ],
          ),
        ),

        const SizedBox(height: 32),

        const Text("Lacak Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkTextColor)),
        const SizedBox(height: 20),

        _step("Jadwal Dibuat", "Permintaan Anda telah diterima", true, isFirst: true),
        _step("Dalam Perjalanan", "Kurir sedang menuju ke lokasi Anda", status == 'proses'),
        _step("Sampai & Timbang", "Kurir sedang menimbang sampah Anda", false, isLast: true),
        
        const SizedBox(height: 30),
        const Center(
          child: Text(
            "Kurir akan segera sampai. Mohon siapkan sampah Anda di depan rumah.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: greyTextColor, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  Widget _rowInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: darkTextColor),
              children: [
                TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _step(String title, String desc, bool isActive, {bool isFirst = false, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 2,
              height: 20,
              color: isFirst ? Colors.transparent : (isActive ? primaryColor : Colors.grey.shade200),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? primaryColor : Colors.white,
                border: Border.all(color: isActive ? primaryColor : Colors.grey.shade300, width: 2),
              ),
              child: isActive ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
            ),
            Container(
              width: 2,
              height: 40,
              color: isLast ? Colors.transparent : (isActive ? primaryColor : Colors.grey.shade200),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isActive ? darkTextColor : Colors.grey)),
              Text(desc, style: TextStyle(fontSize: 12, color: isActive ? greyTextColor : Colors.grey.shade400)),
            ],
          ),
        ),
      ],
    );
  }
}
