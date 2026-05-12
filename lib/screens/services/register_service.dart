import 'dart:convert';
import 'dart:io';

import 'package:asriapp/config.dart';
import 'package:http/http.dart'
as http;


class RegisterService {

  static Future<
      Map<String, dynamic>>

  register({

    required String name,

    required String email,

    required String password,

    required String
    confirmPassword,

    required String phone,

    required String
    address,

    required int
    bankSampahId,

    File? foto,

  }) async {

    try {

      final uri = Uri.parse(

        "${AppConfig.baseUrl}/register",
      );


      final request =

      http.MultipartRequest(
        "POST",
        uri,
      );


      request.fields.addAll({

        "name":
        name,

        "email":
        email,

        "password":
        password,

        "password_confirmation":
        confirmPassword,

        "no_hp":
        phone,

        "alamat":
        address,

        "bank_sampah_id":

        bankSampahId
            .toString(),
      });


      if (

      foto != null

      ) {

        request.files.add(

          await http
              .MultipartFile
              .fromPath(

            "foto",

            foto.path,
          ),
        );
      }


      final response =

      await request
          .send();


      final body =

      await response
          .stream
          .bytesToString();


      final data =

      jsonDecode(
        body,
      );


      return {

        "status":

        response
            .statusCode,

        "data":
        data,
      };

    } catch (e) {

      return {

        "status": 500,

        "data": {

          "message":
          e.toString(),
        },
      };
    }
  }
}