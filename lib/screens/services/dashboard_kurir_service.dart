import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:asriapp/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'client_helper.dart';

class DashboardKurirService {
  // 🔥 Gunakan Client Aman agar tidak error SSL di HP
  static http.Client get _client => getSafeClient(trustedHost: 'simpasda.one-babel.my.id');

  static Future<Map<String, dynamic>> getDashboard(int id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse(
        '${AppConfig.baseUrl}/dashboard-kurir/$id',
      );

      print('GET DASHBOARD : $url');

      final response = await _client.get(
        url,
        headers: {
          "Accept": "application/json",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
        },
      );

      print('STATUS : ${response.statusCode}');
      print('BODY : ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Gagal mengambil dashboard');
      }
    } catch (e) {
      print('ERROR DASHBOARD : $e');
      rethrow;
    }
  }
}