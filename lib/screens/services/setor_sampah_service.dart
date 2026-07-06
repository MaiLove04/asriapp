import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:asriapp/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'client_helper.dart';

class SetorSampahService {
  // 🔥 1. CLIENT AMAN UNTUK HOSTING (Bebas SSL Error)
  static http.Client get _client => getSafeClient(trustedHost: 'pht.my.id');

  // ================= 1. CREATE REQUEST PENJEMPUTAN (NASABAH) =================
  static Future<Map<String, dynamic>> store({
    required int userId,
    required List<int> jenisIds,
    required String catatan,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final items = jenisIds
          .map((id) => {"jenis_sampah_id": id, "berat": 0})
          .toList();
      final url = Uri.parse('${AppConfig.baseUrl}/request-penjemputan');

      // Data dikirim tanpa parameter tanggal_penjemputan (otomatis disetel hari ini di Laravel)
      final Map<String, dynamic> body = {
        "user_id": userId,
        "catatan": catatan,
        "items": items,
      };

      print('--- DEBUG REQUEST PENJEMPUTAN ---');
      print('URL: $url');
      print('BODY: ${jsonEncode(body)}');

      final response = await _client.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      print('RESPONSE STATUS: ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');

      final decodedResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "message": "Berhasil terkirim"};
      } else {
        return {
          "success": false,
          "message": decodedResponse['message'] ?? "Error server (${response.statusCode})"
        };
      }
    } catch (e) {
      print('STORE REQUEST ERROR: $e');
      return {"success": false, "message": "Koneksi bermasalah: $e"};
    }
  }

  // ================= 2. READ RIWAYAT TRANSAKSI (NASABAH) =================
  static Future<List<dynamic>> getRiwayat({required int userId}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse('${AppConfig.baseUrl}/dashboard-nasabah/$userId');
      print('GET REQUEST RIWAYAT VIA: $url');

      final response = await _client.get(
        url,
        headers: {
          "Accept": "application/json",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
        },
      );

      print('GET STATUS RIWAYAT : ${response.statusCode}');
      print('GET BODY RIWAYAT : ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['riwayat_mutasi'] != null) {
          return body['riwayat_mutasi'] as List<dynamic>;
        }
      }
      return [];
    } catch (e) {
      print('GET ERROR RIWAYAT : $e');
      return [];
    }
  }

  // ================= 3. AUTOLOAD MANIFES REQUEST (UNTUK KURIR) =================
  static Future<Map<String, dynamic>?> getRequestDetail(int nasabahId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse('${AppConfig.baseUrl}/request-detail/$nasabahId');
      final response = await _client.get(
        url,
        headers: {
          "Accept": "application/json",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          return body;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ================= 4. FETCH BERAT DARI IOT =================
  static Future<double?> fetchBeratIot() async {
    try {
      final response = await _client.get(
        Uri.parse('${AppConfig.baseUrl}/berat-timbangan-iot'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return double.tryParse(data['berat_iot'].toString()) ?? 0.0;
      }
    } catch (e) {
      print("Error fetch berat Iot: $e");
    }
    return null;
  }

  // ================= 5. SUBMIT SETOR SAMPAH (FIXED UUID VALIDATION) =================
// ================= 5. SUBMIT SETOR SAMPAH (FIXED POST/PATCH & 301) =================
  static Future<http.Response> submitSetoran({
    required int userId,
    required int kurirId,
    required int grandTotal,
    required String judulDinamis,
    required String catatan,
    String? jadwalId,
    required List<Map<String, dynamic>> sampahList,
    required String setor_sampah_id,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    // 1. Tentukan base path awal
    String urlString = '${AppConfig.baseUrl}/setor-sampah';
    bool isByJadwal = false;

    bool isJadwalValid = jadwalId != null &&
        jadwalId.isNotEmpty &&
        jadwalId != "0" &&
        jadwalId != "null";

    // 2. Tentukan kelanjutan URL secara bersih (mencegah penumpukan penyebab 301)
    if (setor_sampah_id.isNotEmpty && setor_sampah_id != "0" && setor_sampah_id != "null") {
      urlString = '$urlString/request-nasabah/$setor_sampah_id';
      isByJadwal = false;
    } else if (isJadwalValid) {
      urlString = '$urlString/jadwal-admin/$jadwalId';
      isByJadwal = true; // Tandai bahwa ini transaksi jadwal admin
    }

    // 3. Parse URI dipindahkan ke sini setelah string URL benar-benar final terbentuk
    var uri = Uri.parse(urlString);

    final Map<String, dynamic> body = {
      "user_id": userId,
      "kurir_id": kurirId,
      "grand_total": grandTotal,
      "judul_dinamis": judulDinamis,
      "catatan": catatan,
      "sampah_list": jsonEncode(sampahList),
    };

    if (isJadwalValid) {
      body['jadwal_id'] = jadwalId;
    }

    print("--- DEBUG SUBMIT SETORAN (FIX 301 & METHOD) ---");
    print("FINAL URL: $urlString");
    print("USING METHOD: ${isByJadwal ? 'POST' : 'PATCH'}");
    print("BODY DATA: $body");

    // 4. Kirim method secara dinamis sesuai dengan route di Laravel api.php
    if (isByJadwal) {
      // Jika fitur jadwal, gunakan POST sesuai perubahan api.php terbaru kamu
      return await _client.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
    } else {
      // Jika fitur request nasabah, tetap gunakan PATCH sesuai api.php
      return await _client.patch(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
    }
  }

  // ================= 6. SETUP PIN NASABAH =================
  static Future<Map<String, dynamic>> setupPin({
    required String pin,
    required String pinConfirmation,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/setup-pin');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await _client.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
        },
        body: jsonEncode({"pin": pin, "pin_confirmation": pinConfirmation}),
      );

      return {"status": response.statusCode, "data": jsonDecode(response.body)};
    } catch (e) {
      return {
        "status": 500,
        "data": {"message": "Gagal setup PIN: $e"},
      };
    }
  }
}