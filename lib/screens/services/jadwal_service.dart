import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:asriapp/config.dart';

class JadwalService {
  // 🔥 CLIENT AMAN UNTUK MENEMBUS SSL HOSTING
  static http.Client get _client {
    final ioClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
    return IOClient(ioClient);
  }

  // ================= GET JADWAL KURIR =================
  static Future<List<dynamic>> getJadwalKurir(int id) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/kurir/jadwal/$id');

      // 🔥 1. Tambahkan log untuk memastikan URL & ID benar
      print("DEBUG JADWAL KURIR - URL: $url");

      final response = await _client.get(url, headers: {"Accept": "application/json"});

      // 🔥 2. Tambahkan log untuk intip status dan body asli dari Laravel
      print("DEBUG JADWAL KURIR - STATUS: ${response.statusCode}");
      print("DEBUG JADWAL KURIR - BODY ASLI: ${response.body}");

      final body = jsonDecode(response.body);

      // 🔥 3. Amankan antisipasi jika datanya ternyata list langsung tanpa bungkus 'data'
      if (body is List) {
        return body;
      } else if (body is Map && body.containsKey('data')) {
        return body['data'] ?? [];
      }

      return [];
    } catch (e) {
      print('GET JADWAL KURIR ERROR: $e');
      return [];
    }
  }

  // ================= GET JADWAL AKTIF NASABAH =================
  static Future<Map<String, dynamic>?> getJadwalNasabah(int id) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/nasabah/jadwal/$id');
      print("DEBUG JADWAL - FETCHING FOR USER: $id");
      print("DEBUG JADWAL - URL: $url");
      
      final response = await _client.get(url, headers: {
        "Accept": "application/json",
      });
      
      print("DEBUG JADWAL - STATUS: ${response.statusCode}");
      print("DEBUG JADWAL - BODY: ${response.body}");
      
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'];
      }
      return null;
    } catch (e) {
      print('GET JADWAL NASABAH ERROR: $e');
      return null;
    }
  }
}
