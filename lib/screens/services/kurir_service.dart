import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:asriapp/config.dart';

import '../models/dashboard_kurir_model.dart';

class KurirService {

  static Future<DashboardKurirModel>
  getDashboard() async {

    final url = Uri.parse(
      '${AppConfig.baseUrl}/dashboard-kurir',
    );

    debugPrint(
      'REQUEST: $url',
    );

    final response =
    await http.get(url);

    debugPrint(
      'STATUS: ${response.statusCode}',
    );

    debugPrint(
      'BODY: ${response.body}',
    );

    if (
    response.statusCode != 200
    ) {
      throw Exception(
        response.body,
      );
    }

    final json =
    jsonDecode(
      response.body,
    );

    return DashboardKurirModel
        .fromJson(json);
  }
}