class TarikTunaiModel {
  final int id;
  final int userId;
  final int jumlahNominal;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime? tanggalRequest;
  final DateTime? tanggalSelesai;
  final String? namaNasabah; // Diambil dari relasi 'user' di Laravel

  TarikTunaiModel({
    required this.id,
    required this.userId,
    required this.jumlahNominal,
    required this.status,
    this.tanggalRequest,
    this.tanggalSelesai,
    this.namaNasabah,
  });

  // Fungsi untuk mengubah JSON dari API Laravel menjadi Object Dart
  factory TarikTunaiModel.fromJson(Map<String, dynamic> json) {
    return TarikTunaiModel(
      id: json['id'],
      // Kadang API mengirim angka sebagai String, jadi kita amankan dengan parse
      userId: json['user_id'] is String
          ? int.parse(json['user_id'])
          : json['user_id'],
      jumlahNominal: json['jumlah_nominal'] is String
          ? int.parse(json['jumlah_nominal'])
          : json['jumlah_nominal'],
      status: json['status'] ?? 'pending',
      // Parsing string tanggal menjadi objek DateTime
      tanggalRequest: json['tanggal_request'] != null
          ? DateTime.parse(json['tanggal_request'])
          : null,
      tanggalSelesai: json['tanggal_selesai'] != null
          ? DateTime.parse(json['tanggal_selesai'])
          : null,
      // Mengambil nama nasabah dari relasi user di Laravel (with('user'))
      namaNasabah: json['user'] != null ? json['user']['name'] : null,
    );
  }

  // Fungsi untuk mengubah Object Dart kembali ke JSON (jika perlu dikirim ke API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'jumlah_nominal': jumlahNominal,
      'status': status,
      'tanggal_request': tanggalRequest?.toIso8601String(),
      'tanggal_selesai': tanggalSelesai?.toIso8601String(),
    };
  }
}