class JadwalModel {
  final String id;
  final String nasabah;
  final String alamat;
  final String tanggal;
  final String status;

  JadwalModel({
    required this.id,
    required this.nasabah,
    required this.alamat,
    required this.tanggal,
    required this.status,
  });

  factory JadwalModel.fromJson(Map<String, dynamic> json) {
    return JadwalModel(
      id: json['id'].toString(),
      nasabah: json['nasabah']['name'],
      alamat: json['alamat'] ?? '',
      tanggal: json['tanggal_penjemputan'],
      status: json['status'],
    );
  }
}
