import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:asriapp/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'client_helper.dart';

class JadwalService {
  static http.Client get _client => getSafeClient();

  // ================= GET JADWAL KURIR =================
  static Future<List<dynamic>> getJadwalKurir(int id) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/kurir/jadwal/$id');
      final response = await _client.get(url, headers: {"Accept": "application/json"});
      
      final body = jsonDecode(response.body);
      return body['data'] ?? [];
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
