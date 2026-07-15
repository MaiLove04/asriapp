import 'dart:convert';
import 'dart:io';

import 'package:asriapp/config.dart';
import 'package:http/http.dart' as http;
import '../models/bank_sampah_model.dart';
import 'client_helper.dart';

class RegisterService {
  static http.Client get _client => getSafeClient();

  // Mendapatkan daftar bank sampah
  static Future<List<BankSampahModel>> getBankSampah() async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/bank-sampah');
      final response = await _client.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = (decoded is Map && decoded['data'] != null) 
            ? decoded['data'] 
            : (decoded is List ? decoded : []);
            
        return data.map((e) => BankSampahModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error Get Bank Sampah: $e');
      return [];
    }
  }

  // Melakukan registrasi user baru
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String phone,
    required String address,
    required int bankSampahId,
    File? foto,
  }) async {
    try {
      final uri = Uri.parse("${AppConfig.baseUrl}/register");
      final request = http.MultipartRequest("POST", uri);
      
      request.headers['Accept'] = 'application/json';
      request.fields.addAll({
        "name": name,
        "email": email,
        "password": password,
        "password_confirmation": confirmPassword,
        "no_hp": phone,
        "alamat": address,
        "bank_sampah_id": bankSampahId.toString(),
      });

      if (foto != null) {
        request.files.add(await http.MultipartFile.fromPath("foto", foto.path));
      }

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      
      print('REGISTER RESPONSE BODY: ${response.body}');
      
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        return {
          "status": response.statusCode,
          "data": {"message": "Server error (Not JSON). Status: ${response.statusCode}"},
        };
      }

      return {
        "status": response.statusCode,
        "data": data,
      };
    } catch (e) {
      return {
        "status": 500,
        "data": {"message": e.toString()},
      };
    }
  }

  // Update status nasabah (PATCH)
  static Future<Map<String, dynamic>> updateNasabahStatus({
    required int id,
    required String status,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/admin/nasabah/$id/status');
      final response = await _client.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'status': status}),
      );

      return {
        "status": response.statusCode,
        "data": jsonDecode(response.body),
      };
    } catch (e) {
      return {
        "status": 500,
        "data": {"message": "Gagal terhubung ke server: $e"},
      };
    }
  }
}

// Tambahan helper jika belum ada di file ini
void debugPrint(String message) {
  print(message);
}