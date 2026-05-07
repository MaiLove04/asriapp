class DashboardKurirModel {

  final int lokasi;
  final double totalKg;
  final List riwayat;

  DashboardKurirModel({
    required this.lokasi,
    required this.totalKg,
    required this.riwayat,
  });

  factory DashboardKurirModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return DashboardKurirModel(

      lokasi:
      (json["lokasi"] ?? 0) as int,

      totalKg:
      (json["total_kg"] ?? 0)
          .toDouble(),

      riwayat:
      json["riwayat"] ?? [],
    );
  }
}