import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:asriapp/config.dart';

class DashboardKurirService {

  static Future<Map<String, dynamic>>
  getDashboard(int id) async {

    try {

      final url = Uri.parse(
        '${AppConfig.baseUrl}/dashboard-kurir/$id',
      );

      print(
        'GET DASHBOARD : $url',
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
        'STATUS : ${response.statusCode}',
      );

      print(
        'BODY : ${response.body}',
      );

      if (response.statusCode == 200) {

        return jsonDecode(
          response.body,
        );

      } else {

        throw Exception(
          'Gagal mengambil dashboard',
        );
      }

    } catch (e) {

      print(
        'ERROR DASHBOARD : $e',
      );

      rethrow;
    }
  }
}