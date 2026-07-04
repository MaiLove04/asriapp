import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notifikasi_service.dart';
import 'package:intl/intl.dart';

// Palet warna kontras tinggi (Senior-Friendly Theme)
const _primaryColor = Color(0xFF1E521E);
const _darkTextColor = Color(0xFF0D240D);
const _greyTextColor = Color(0xFF555555);
const _backgroundColor = Color(0xFFF9FBF9);

class NotifikasiKurirScreen extends StatefulWidget {
  const NotifikasiKurirScreen({super.key});

  @override
  State<NotifikasiKurirScreen> createState() => _NotifikasiKurirScreenState();
}

class _NotifikasiKurirScreenState extends State<NotifikasiKurirScreen> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      setState(() => isLoading = true);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userId = prefs.getInt('user_id') ?? 0;

      if (userId == 0) {
        setState(() => isLoading = false);
        return;
      }

      final result = await NotifikasiService.getNotifikasi(userId);
      setState(() {
        notifications = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  String _formatTime(String? rawTime) {
    if (rawTime == null || rawTime.isEmpty) return "-";
    try {
      DateTime dt = DateTime.parse(rawTime);
      return DateFormat('dd MMM, HH:mm').format(dt);
    } catch (e) {
      return rawTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Column(
        children: [
          // ================= HEADER =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_primaryColor, Color(0xFF2E6B2E)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      "Notifikasi",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 28),
                    onPressed: fetchNotifications,
                  ),
                ],
              ),
            ),
          ),

          // ================= NOTIFICATION LIST =================
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: _primaryColor))
                : notifications.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: fetchNotifications,
                        color: _primaryColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final item = notifications[index];
                            return _buildNotificationCard(item);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_off_rounded,
                size: 80,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                "Belum ada notifikasi",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item) {
    // Mapping field dari API (menyesuaikan kemungkinan nama field Laravel)
    String title = item['judul'] ?? item['title'] ?? "Pemberitahuan";
    String body = item['pesan'] ?? item['body'] ?? item['message'] ?? "";
    String time = _formatTime(item['created_at'] ?? item['waktu']);
    bool isRead = (item['is_read'] == 1 || item['is_read'] == true || item['status'] == 'read');
    String type = item['type'] ?? item['kategori'] ?? 'info';

    IconData iconData;
    Color iconColor;

    switch (type.toLowerCase()) {
      case 'tugas':
      case 'penjemputan':
        iconData = Icons.assignment_rounded;
        iconColor = Colors.orange.shade700;
        break;
      case 'setoran':
      case 'transaksi':
        iconData = Icons.check_circle_rounded;
        iconColor = Colors.green.shade700;
        break;
      case 'peringatan':
      case 'warning':
        iconData = Icons.warning_rounded;
        iconColor = Colors.red.shade700;
        break;
      default:
        iconData = Icons.info_rounded;
        iconColor = Colors.blue.shade700;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFE8F5E9).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isRead 
          ? Border.all(color: Colors.grey.shade200)
          : Border.all(color: _primaryColor.withOpacity(0.3), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (!isRead) {
              int? id = int.tryParse(item['id'].toString());
              if (id != null) {
                NotifikasiService.markAsRead(id);
                setState(() {
                  // Update UI local biar cepet
                  if (item.containsKey('is_read')) item['is_read'] = 1;
                  if (item.containsKey('status')) item['status'] = 'read';
                });
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isRead ? FontWeight.bold : FontWeight.w900,
                                color: _darkTextColor,
                              ),
                            ),
                          ),
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 12,
                              color: _greyTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        body,
                        style: TextStyle(
                          fontSize: 14,
                          color: _greyTextColor,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
