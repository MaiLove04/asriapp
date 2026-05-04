// import 'dart:convert';
//
// import 'package:http/http.dart' as http;
//
// class SetorSampahService {
//
//   static const baseUrl =
//       "http://10.230.122.144:8000/api";
//
//   static Future<bool> store({
//
//     required int userId,
//     required int jenisId,
//     required String catatan,
//
//   }) async {
//
//     try {
//
//       final response = await http.post(
//
//         Uri.parse(
//           "$baseUrl/setor-sampah",
//         ),
//
//         headers: {
//           "Content-Type": "application/json",
//         },
//
//         body: jsonEncode({
//
//           "user_id": userId,
//           "jenis_sampah_id": jenisId,
//           "catatan": catatan,
//
//         }),
//       );
//
//
//       print("STATUS : ${response.statusCode}");
//       print("BODY : ${response.body}");
//
//       return response.statusCode == 200 ||
//           response.statusCode == 201;
//
//     } catch(e){
//
//       print("ERROR : $e");
//
//       return false;
//     }
//   }
// }


// ====
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/setor_sampah_model.dart';

class SetorSampahService {

static const baseUrl =
"http://10.230.122.144:8000/api";



// ================= CREATE =================
static Future<bool> store({

required int userId,
required int jenisId,
required String catatan,

}) async {

try {

final response =
await http.post(

Uri.parse(
"$baseUrl/setor-sampah",
),

headers: {

"Content-Type":
"application/json",

"Accept":
"application/json",
},

body: jsonEncode({

"user_id":
userId,

"jenis_sampah_id":
jenisId,

"catatan":
catatan,
}),
);


print(
"POST STATUS : ${response.statusCode}",
);

print(
"POST BODY : ${response.body}",
);

return response.statusCode == 200 ||
response.statusCode == 201;

} catch(e){

print(
"POST ERROR : $e",
);

return false;
}
}




// ================= READ =================
static Future<
List<SetorSampahModel>
> getRiwayat() async {

try {

final response =
await http.get(

Uri.parse(
"$baseUrl/setor-sampah",
),

headers: {

"Accept":
"application/json",
},
);


print(
"GET STATUS : ${response.statusCode}",
);

print(
"GET BODY : ${response.body}",
);


final body =
jsonDecode(
response.body);

List data =
body['data'];


return data
    .map(

(item) =>

SetorSampahModel
    .fromJson(
item),
)
    .toList();

} catch(e){

print(
"GET ERROR : $e",
);

return [];
}
}
}