import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:asriapp/config.dart';
import '../models/setor_sampah_model.dart';

class SetorSampahService {
  // ================= 1. CREATE REQUEST PENJEMPUTAN (NASABAH) =================
  static Future<bool> store({
    required int userId,
    required List<int> jenisIds,
    required String catatan,
  }) async {
    try {
      final items = jenisIds.map((id) => {
        "jenis_sampah_id": id,
        "berat": 0,
      }).toList();

      final url = Uri.parse('${AppConfig.baseUrl}/request-penjemputan');

      print('POST REQUEST : $url');

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "user_id": userId,
          "catatan": catatan,
          "items": items,
        }),
      );

      print('POST STATUS : ${response.statusCode}');
      print('POST BODY : ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('POST ERROR : $e');
      return false;
    }
  }

  // ================= 2. READ RIWAYAT TRANSAKSI (NASABAH) =================
  static Future<List<SetorSampahModel>> getRiwayat() async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/setor-sampah');
      print('GET REQUEST : $url');

      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
        },
      );

      print('GET STATUS : ${response.statusCode}');
      print('GET BODY : ${response.body}');

      final body = jsonDecode(response.body);
      List data = body['data'];

      return data.map((item) => SetorSampahModel.fromJson(item)).toList();
    } catch (e) {
      print('GET ERROR : $e');
      return [];
    }
  }

  // ================= 3. 🔥 BARU: AUTOLOAD MANIFES REQUEST (UNTUK KURIR) =================
  /// Fungsi ini dipanggil di HP Kurir saat membuka form timbang berdasarkan request nasabah.
  /// Berfungsi mengembalikan list item sampah kosong beserta harga terbarunya dari DB.
  static Future<Map<String, dynamic>?> getRequestDetail(int nasabahId) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/request-detail/$nasabahId');
      print('GET REQUEST DETAIL : $url');

      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
        },
      );

      print('GET DETAIL STATUS : ${response.statusCode}');
      print('GET DETAIL BODY : ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          return body; // Mengembalikan data 'setor_sampah_id' dan 'items' array
        }
      }
      return null;
    } catch (e) {
      print('GET DETAIL ERROR : $e');
      return null;
    }
  }
}