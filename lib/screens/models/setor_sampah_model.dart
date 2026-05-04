// class SetorSampahModel {
//   final int id;
//   final String jenisSampah;
//   final String status;
//   final String? catatan;
//   final String createdAt;
//
//   SetorSampahModel({
//     required this.id,
//     required this.jenisSampah,
//     required this.status,
//     this.catatan,
//     required this.createdAt,
//   });
//
//   factory SetorSampahModel.fromJson(Map<String, dynamic> json) {
//     return SetorSampahModel(
//       id: json['id'],
//       jenisSampah: json['jenis_sampah'],
//       status: json['status'],
//       catatan: json['catatan'],
//       createdAt: json['created_at'],
//     );
//   }
// }

class SetorSampahModel {

  final int id;

  final String jenisSampah;

  final String status;

  final String beratKg;

  final String totalHarga;

  final String createdAt;


  SetorSampahModel({

    required this.id,

    required this.jenisSampah,

    required this.status,

    required this.beratKg,

    required this.totalHarga,

    required this.createdAt,
  });


  factory SetorSampahModel.fromJson(
      Map<String, dynamic> json) {

    return SetorSampahModel(

      id:
      json['id'],


      jenisSampah:

      json['jenis_sampah'] != null

          ? json['jenis_sampah']['nama']
          .toString()

          : "-",


      status:
      json['status']
          .toString(),


      beratKg:

      json['berat'] != null

          ? "${json['berat']} Kg"

          : "0 Kg",


      totalHarga:

      json['total_harga'] != null

          ? "Rp ${json['total_harga']}"

          : "Rp 0",


      createdAt:

      json['created_at']
          .toString(),
    );
  }
}