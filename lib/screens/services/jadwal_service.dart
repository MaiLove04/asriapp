import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:asriapp/config.dart';

class JadwalService {

  // ================= GET JADWAL KURIR =================
  static Future<List<dynamic>>
  getJadwalKurir(int id) async {

    try {

      final url = Uri.parse(
        '${AppConfig.baseUrl}/kurir/jadwal/$id',
      );

      print(
        'GET REQUEST : $url',
      );

      final response =
      await http.get(

        url,

        headers: {

          "Accept":
          "application/json",

        },
      );

      print(
        'GET STATUS : ${response.statusCode}',
      );

      print(
        'GET BODY : ${response.body}',
      );

      final body =
      jsonDecode(
        response.body,
      );

      return body['data'];

    } catch (e) {

      print(
        'GET ERROR : $e',
      );

      return [];
    }
  }
}