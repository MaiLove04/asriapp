import 'dart:convert';
// import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:asriapp/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'client_helper.dart';

class SetorSampahService {
  // 🔥 1. CLIENT AMAN UNTUK HOSTING (Bebas SSL Error)
  static http.Client get _client => getSafeClient(trustedHost: 'pht.my.id');

  // ================= 1. CREATE REQUEST PENJEMPUTAN (NASABAH) =================
  static Future<bool> store({
    required int userId,
    required List<int> jenisIds,
    required String catatan,

    /// Tanggal penjemputan hasil perhitungan validasi, format: "yyyy-MM-dd".
    /// null berarti tidak ada jadwal spesifik (backend menentukan sendiri).
    String? tanggalPenjemputan,
  }) async {
    try {
      final items = jenisIds
          .map((id) => {"jenis_sampah_id": id, "berat": 0})
          .toList();
      final url = Uri.parse('${AppConfig.baseUrl}/request-penjemputan');

      final Map<String, dynamic> body = {
        "user_id": userId,
        "catatan": catatan,
        "items": items,
      };

      // Hanya sertakan tanggal_penjemputan jika ada nilainya
      if (tanggalPenjemputan != null && tanggalPenjemputan.isNotEmpty) {
        body["tanggal_penjemputan"] = tanggalPenjemputan;
      }

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // ================= 2. READ RIWAYAT TRANSAKSI (NASABAH) - FIXED =================
  static Future<List<dynamic>> getRiwayat({required int userId}) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/dashboard-nasabah/$userId');
      print('GET REQUEST RIWAYAT VIA: $url');

      final response = await http.get(
        url,
        headers: {"Accept": "application/json"},
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
      final url = Uri.parse('${AppConfig.baseUrl}/request-detail/$nasabahId');
      final response = await http.get(
        url,
        headers: {"Accept": "application/json"},
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
      final response = await http.get(
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

  // ================= 5. SUBMIT SETOR SAMPAH =================
  // ================= 5. SUBMIT SETOR SAMPAH (FIXED ERROR 405) =================
  // ================= 5. SUBMIT SETOR SAMPAH (FIXED 405 VIA CLIENT.PATCH) =================
  static Future<http.Response> submitSetoran({
    required int userId,
    required int kurirId,
    required int grandTotal,
    required String judulDinamis,
    required String catatan,
    String? jadwalId,
    required List<Map<String, dynamic>> sampahList,
    required String setoranId,
  }) async {
    var urlString = '${AppConfig.baseUrl}/setor-sampah';

    if (setoranId.isNotEmpty) {
      urlString += '/request-nasabah/$setoranId';
    } else if (jadwalId != null && jadwalId.isNotEmpty) {
      urlString += '/jadwal-admin/$jadwalId';
    }

    var uri = Uri.parse(urlString);

    final Map<String, dynamic> body = {
      "user_id": userId,
      "kurir_id": kurirId,
      "grand_total": grandTotal,
      "judul_dinamis": judulDinamis,
      "catatan": catatan,
      "sampah_list": jsonEncode(sampahList),
    };

    if (jadwalId != null && jadwalId.isNotEmpty) {
      body['jadwal_id'] = jadwalId;
    }

    // 🔥 Ganti .post menjadi .patch agar metodenya murni PATCH di mata Laravel
    return await _client.patch(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(body),
    );
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
