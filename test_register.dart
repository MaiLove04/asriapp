import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('http://simpasdaa.one-babel.my.id/api/register');
  final request = http.MultipartRequest('POST', url);
  request.headers['Accept'] = 'application/json';
  request.fields.addAll({
    "name": "Test User",
    "password": "password123",
    "password_confirmation": "password123",
    "no_hp": "081234567890",
    "alamat": "Jalan Test 123",
    "bank_sampah_id": "1",
  });
  
  try {
    final response = await request.send();
    final body = await response.stream.bytesToString();
    print('Status: ${response.statusCode}');
    print('Body: $body');
  } catch (e) {
    print('Exception: $e');
  }
}
