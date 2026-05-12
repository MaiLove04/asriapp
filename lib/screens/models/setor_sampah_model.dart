class DetailSetor {
  final String nama;
  final String berat;

  DetailSetor({
    required this.nama,
    required this.berat,
  });
}

class SetorSampahModel {
  final int id;
  final String jenisSampah;
  final String status;
  final String beratKg;
  final String totalHarga;
  final String createdAt;
  final String catatan;
  final List<DetailSetor> details;

  SetorSampahModel({
    required this.id,
    required this.jenisSampah,
    required this.status,
    required this.beratKg,
    required this.totalHarga,
    required this.createdAt,
    required this.catatan,
    required this.details,
  });

  factory SetorSampahModel.fromJson(
      Map<String, dynamic> json,
      ) {
    String namaJenis = "-";

    List<DetailSetor> detailItems = [];

    // format data baru
    if (
    json['details'] != null &&
        json['details'].isNotEmpty) {

      final rawDetails =
      json['details'] as List;

      detailItems =
          rawDetails.map((e) {
            return DetailSetor(
              nama:
              e['jenis_sampah']['nama'] ?? "-",

              berat:
              e['berat'] != null
                  ? "${e['berat']} Kg"
                  : "0 Kg",
            );
          }).toList();

      final firstName =
          detailItems.first.nama;

      if (detailItems.length == 1) {
        namaJenis = firstName;
      } else {
        namaJenis =
        "$firstName +${detailItems.length - 1} lainnya";
      }
    }

    // format data lama
    else if (
    json['jenis_sampah'] != null) {

      namaJenis =
          json['jenis_sampah']['nama'] ?? "-";

      detailItems = [
        DetailSetor(
          nama: namaJenis,

          berat:
          json['berat'] != null
              ? "${json['berat']} Kg"
              : "0 Kg",
        ),
      ];
    }

    return SetorSampahModel(
      id: json['id'] ?? 0,

      jenisSampah: namaJenis,

      status:
      json['status'] ?? "-",

      beratKg:
      json['berat'] != null
          ? "${json['berat']} Kg"
          : "0 Kg",

      totalHarga:
      json['total'] != null
          ? "Rp ${json['total']}"
          : "Rp 0",

      createdAt:
      json['created_at'] ?? "-",

      catatan:
      json['catatan'] ??
          "Tidak ada catatan",

      details: detailItems,
    );
  }
}