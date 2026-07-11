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
    // Helper untuk mengambil nominal dari berbagai kemungkinan nama field
    int parseNominal(Map<String, dynamic> j) {
      var val = j['jumlah_nominal'] ?? j['nominal'] ?? j['jumlah'] ?? 0;
      if (val is int) return val;
      if (val is String) return int.tryParse(val.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return 0;
    }

    // Helper untuk mengambil ID secara aman
    int parseId(dynamic id) {
      if (id is int) return id;
      if (id is String) return int.tryParse(id) ?? 0;
      return 0;
    }

    return TarikTunaiModel(
      id: parseId(json['id']),
      userId: parseId(json['user_id']),
      jumlahNominal: parseNominal(json),
      // Memastikan status selalu string dan tidak null, handle 'state' atau 'status_pembayaran'
      status: (json['status'] ?? json['state'] ?? json['status_pembayaran'] ?? 'pending').toString(),
      // Parsing string tanggal menjadi objek DateTime secara aman
      tanggalRequest: json['tanggal_request'] != null
          ? DateTime.tryParse(json['tanggal_request'].toString())
          : (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null),
      tanggalSelesai: json['tanggal_selesai'] != null
          ? DateTime.tryParse(json['tanggal_selesai'].toString())
          : (json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null),
      // Mengambil nama nasabah dari relasi user di Laravel (with('user'))
      namaNasabah: json['user'] != null ? json['user']['name'] : (json['nama_nasabah'] ?? json['nasabah']),
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