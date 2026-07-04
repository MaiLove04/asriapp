class DetailSetor {
  final String nama;
  final String berat;

  DetailSetor({
    required this.nama,
    required this.berat,
  });
}

class SetorSampahModel {
  final String id;
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

  factory SetorSampahModel.fromJson(Map<String, dynamic> json) {
    String namaJenis = "-";
    List<DetailSetor> detailItems = [];
    double totalBeratMultiItem = 0.0; // 🔥 Penampung total berat untuk format baru

    // 1. Format Data Baru (Multi-Item)
    if (json['details'] != null && (json['details'] as List).isNotEmpty) {
      final rawDetails = json['details'] as List;

      detailItems = rawDetails.map((e) {
        // Ambil berat mentah untuk diakumulasikan
        final double beratMentah = double.tryParse(e['berat']?.toString() ?? '0') ?? 0.0;
        totalBeratMultiItem += beratMentah;

        return DetailSetor(
          nama: e['jenis_sampah'] != null ? (e['jenis_sampah']['nama'] ?? "-") : "-",
          berat: "$beratMentah Kg",
        );
      }).toList();

      final firstName = detailItems.first.nama;
      if (detailItems.length == 1) {
        namaJenis = firstName;
      } else {
        namaJenis = "$firstName +${detailItems.length - 1} lainnya";
      }
    }
    // 2. Format Data Lama (Single-Item)
    else if (json['jenis_sampah'] != null) {
      namaJenis = json['jenis_sampah']['nama'] ?? "-";
      final double beratLama = double.tryParse(json['berat']?.toString() ?? '0') ?? 0.0;

      detailItems = [
        DetailSetor(
          nama: namaJenis,
          berat: "$beratLama Kg",
        ),
      ];
    }

    // 🔥 Tentukan string berat secara cerdas berdasarkan format datanya
    String tampilkanBerat = "0 Kg";
    if (json['details'] != null && (json['details'] as List).isNotEmpty) {
      tampilkanBerat = "${totalBeratMultiItem.toStringAsFixed(totalBeratMultiItem % 1 == 0 ? 0 : 2)} Kg";
    } else if (json['berat'] != null) {
      tampilkanBerat = "${json['berat']} Kg";
    }

    return SetorSampahModel(
      id: json['id']?.toString() ?? "",
      jenisSampah: namaJenis,
      status: json['status'] ?? "-",
      beratKg: tampilkanBerat, // 🔥 Sudah sinkron dengan akumulasi detail item
      totalHarga: json['total'] != null ? "Rp ${json['total']}" : "Rp 0",
      createdAt: json['created_at'] ?? "-",
      catatan: json['catatan'] ?? "Tidak ada catatan",
      details: detailItems,
    );
  }
}