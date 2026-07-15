import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:asriapp/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'client_helper.dart';

class NotifikasiService {
  static http.Client get _client => getSafeClient();

  static Future<List<dynamic>> getNotifikasi(int userId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse('${AppConfig.baseUrl}/notifikasi-kurir');
      final response = await _client.get(
        url,
        headers: {
          "Accept": "application/json",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
        },
      );

      print("DEBUG NOTIFIKASI - STATUS: ${response.statusCode}");
      print("DEBUG NOTIFIKASI - BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data;
        } else if (data is Map) {
          return data['data'] ?? data['notifikasi'] ?? [];
        }
      }
      return [];
    } catch (e) {
      print("ERROR FETCH NOTIFIKASI: $e");
      return [];
    }
  }

  static Future<List<dynamic>> getNotifikasiNasabah(int userId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse('${AppConfig.baseUrl}/notifikasi-nasabah');
      final response = await _client.get(
        url,
        headers: {
          "Accept": "application/json",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
        },
      );

      print("DEBUG NOTIFIKASI NASABAH - STATUS: ${response.statusCode}");
      print("DEBUG NOTIFIKASI NASABAH - BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data;
        } else if (data is Map) {
          return data['data'] ?? data['notifikasi'] ?? [];
        }
      }
      return [];
    } catch (e) {
      print("ERROR FETCH NOTIFIKASI NASABAH: $e");
      return [];
    }
  }

  static Future<bool> markAsRead(int notificationId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse('${AppConfig.baseUrl}/notifikasi/$notificationId/read');
      final response = await _client.post(
        url,
        headers: {
          "Accept": "application/json",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print("ERROR MARK AS READ: $e");
      return false;
    }
  }
}
