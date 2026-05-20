import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:asriapp/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  static Future<Map<String, dynamic>>
  login({

    required String email,

    required String password,

  }) async {

    final url = Uri.parse(
      '${AppConfig.baseUrl}/login',
    );

    final stopwatch =
    Stopwatch()..start();

    final response =
    await http

        .post(

      url,

      headers: {

        'Content-Type':
        'application/json',

        'Accept':
        'application/json',

      },

      body: jsonEncode({

        'email':
        email,

        'password':
        password,

      }),
    )

        .timeout(
      const Duration(
        seconds: 10,
      ),
    );

    stopwatch.stop();

    print(
      'LOGIN TIME: '
          '${stopwatch.elapsedMilliseconds} ms',
    );

    final body =
    jsonDecode(response.body);

    // ================= SIMPAN LOGIN =================
    if (response.statusCode == 200) {

      SharedPreferences prefs =
      await SharedPreferences
          .getInstance();

      prefs.setInt(
        'user_id',
        body['user']['id'],
      );

      prefs.setString(
        'user_name',
        body['user']['name'],
      );

      prefs.setString(
        'role',
        body['user']['role'],
      );
    }

    return {

      "status":
      response.statusCode,

      "data":
      body,
    };
  }
}