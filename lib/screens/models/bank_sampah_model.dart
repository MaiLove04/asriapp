class BankSampahModel {
  final int id;
  final String nama;

  BankSampahModel({
    required this.id,
    required this.nama,
  });

  factory BankSampahModel.fromJson(Map<String, dynamic> json) {
    return BankSampahModel(
      id: json['id'] ?? 0,
      // Membaca 'nama_bank' sesuai kolom di database Anda
      nama: json['nama_bank'] ?? json['nama'] ?? json['name'] ?? '-',
    );
  }
}
