import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/dashboard_kurir_model.dart';

class KurirService {

  static Future<DashboardKurirModel>
  getDashboard() async {

    try {

      final url = Uri.parse(
        "http://192.168.65.157:8000/api/kurir/dashboard",
      );

      debugPrint("REQUEST: $url");

      final response =
      await http.get(url);

      debugPrint(
        "STATUS: ${response.statusCode}",
      );

      debugPrint(
        "BODY: ${response.body}",
      );

      final json =
      jsonDecode(
        response.body,
      );

      return DashboardKurirModel
          .fromJson(json);

    } catch (e) {

      debugPrint(
        "ERROR SERVICE: $e",
      );

      rethrow;
    }
  }
}