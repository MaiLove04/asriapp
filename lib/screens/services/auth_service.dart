import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:asriapp/config.dart';

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

    return {

      "status":
      response.statusCode,

      "data":
      jsonDecode(
        response.body,
      ),
    };
  }
}