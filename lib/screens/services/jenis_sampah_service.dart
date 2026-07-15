import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:asriapp/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/jenis_sampah.dart';

class JenisSampahService {

  static Future<List<JenisSampah>>
  getData() async {

    try {

      final url = Uri.parse(
        '${AppConfig.baseUrl}/jenis-sampah',
      );

      print('REQUEST : $url');

      // Ambil token dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('STATUS : ${response.statusCode}');

      print(
        'BODY : ${response.body}',
      );

      if (
      response.statusCode != 200
      ) {
        return [];
      }

      final List data =
      jsonDecode(
        response.body,
      );

      return data
          .map(
            (e) =>
            JenisSampah
                .fromJson(e),
      )
          .toList();

    } catch (e) {

      print(
        'ERROR API : $e',
      );

      return [];
    }
  }
}