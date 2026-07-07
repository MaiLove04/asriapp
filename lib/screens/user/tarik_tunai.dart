import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/tarik_tunai_service.dart';
import 'success_withdrawal_page.dart';

const primaryColor = Color(0xFF1E521E);
const backgroundColor = Color(0xFFF9FBF9);
const darkTextColor = Color(0xFF0D240D);
const greyTextColor = Color(0xFF555555);

class TarikTunaiPage extends StatefulWidget {
  const TarikTunaiPage({super.key});

  @override
  State<TarikTunaiPage> createState() => _TarikTunaiPageState();
}

class _TarikTunaiPageState extends State<TarikTunaiPage> {
  final TarikTunaiService _tarikTunaiService = TarikTunaiService();
  final TextEditingController _nominalController = TextEditingController();

  int saldoAktif = 0;
  int saldoPending = 0;
  bool _isLoading = true;

  // VALIDASI LAPANGAN (Disamakan dengan backend)
  final int _minimalPenarikan = 5000;

  @override
  void initState() {
    super.initState();
    _fetchSaldo();
    // 🔥 UBAH: Nominal default ketikan awal disesuaikan ke minimal baru (5.000)
    _nominalController.text = formatAngka(5000);
    _nominalController.addListener(_onNominalChanged);
  }

  Future<void> _fetchSaldo() async {
    try {
      final fetchedData = await _tarikTunaiService.getSaldoNasabah();
      if (mounted) {
        setState(() {
          saldoAktif = fetchedData['saldo_aktif'] ?? 0;
          saldoPending = fetchedData['saldo_pending'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nominalController.dispose();
    super.dispose();
  }

  int get currentNominal {
    String cleanString = _nominalController.text.replaceAll('.', '').trim();
    return int.tryParse(cleanString) ?? 0;
  }

  void _onNominalChanged() {
    setState(() {});
  }

  void setNominalPilihan(int value) {
    setState(() {
      _nominalController.text = formatAngka(value);
    });
  }

  Future<void> _prosesKirimKeBackend(int nominalTarik) async {
    setState(() {
      _isLoading = true;
    });

    final result = await _tarikTunaiService.createRequestTarik(jumlahNominal: nominalTarik);

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      // 🔥 BERSIH: Tidak ada pemotongan saldo buatan di memori HP.
      // Kita murni mengandalkan reload dashboard via data server agar sinkron.

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessWithdrawalPage(
            nominal: nominalTarik,
            transactionId: "TRX-${DateTime.now().millisecondsSinceEpoch}",
          ),
        ),
      );
    } else {
      _showSnackbar(result['message'] ?? "Gagal memproses penarikan", Colors.red[700]!);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSaldoKurang = currentNominal > saldoAktif;
    bool isKurangDariMinimal = currentNominal < _minimalPenarikan && currentNominal > 0;

    // 🔥 TAMBAHAN: Cek kelipatan pecahan 500 menggunakan modulus (%)
    bool isKelipatanSalah = currentNominal % 500 != 0 && currentNominal > 0;

    // 🔥 UBAH: Tombol aktif hanya jika memenuhi semua syarat (+ aturan kelipatan wajib benar)
    bool isInputValid = currentNominal >= _minimalPenarikan && !isSaldoKurang && !isKelipatanSalah;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        centerTitle: true,
        title: const Text(
          "Tarik Tunai",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        leading: const BackButton(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
        child: Column(
          children: [
            // ================= KARTU SALDO DENGAN PENDING INDIKATOR =================
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32, top: 8),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Saldo Aktif Anda",
                              style: TextStyle(color: Color(0xFFC8E6C9), fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              formatRupiah(saldoAktif),
                              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                        const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFC8E6C9), size: 36),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Colors.white24, height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.hourglass_empty_rounded, color: Colors.orangeAccent, size: 16),
                            SizedBox(width: 4),
                            Text(
                              "Dalam Pengajuan (Pending)",
                              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                        Text(
                          formatRupiah(saldoPending),
                          style: const TextStyle(color: Colors.orangeAccent, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= INPUT NOMINAL BESAR =================
                  const Text(
                    "Masukkan Nominal Penarikan",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: darkTextColor),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        // 🔥 UBAH: Box ikutan berubah warna merah kalau kelipatan tidak bulat 500
                        color: isSaldoKurang || isKurangDariMinimal || isKelipatanSalah ? Colors.red : Colors.transparent,
                        width: isSaldoKurang || isKurangDariMinimal || isKelipatanSalah ? 1.5 : 0,
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          "Rp",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isSaldoKurang || isKurangDariMinimal || isKelipatanSalah ? Colors.red : primaryColor
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _nominalController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: isSaldoKurang || isKurangDariMinimal || isKelipatanSalah ? Colors.red : darkTextColor
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              ThousandSeparatorFormatter(),
                            ],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "0",
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ================= TEKS VALIDASI DINAMIS =================
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: Builder(
                      builder: (context) {
                        if (isSaldoKurang) {
                          return const Row(
                            children: [
                              Icon(Icons.error_outline_rounded, color: Colors.red, size: 16),
                              SizedBox(width: 4),
                              Text(
                                "Saldo Anda tidak mencukupi untuk penarikan ini",
                                style: TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.w600),
                              ),
                            ],
                          );
                        } else if (isKurangDariMinimal) {
                          return Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                "Minimal penarikan adalah ${formatRupiah(_minimalPenarikan)}",
                                style: TextStyle(fontSize: 13, color: Colors.amber[900], fontWeight: FontWeight.w600),
                              ),
                            ],
                          );
                        } else if (isKelipatanSalah) {
                          // 🔥 TAMBAHAN: Peringatan visual jika mengetik pecahan acak
                          return const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16),
                              SizedBox(width: 4),
                              Text(
                                "Nominal harus kelipatan Rp 500 (Contoh: 5.500, 6.000)",
                                style: TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.w600),
                              ),
                            ],
                          );
                        } else {
                          return Text(
                            "*Minimal penarikan ${formatRupiah(_minimalPenarikan)} dan wajib kelipatan Rp 500",
                            style: const TextStyle(fontSize: 12, color: greyTextColor, fontStyle: FontStyle.italic),
                          );
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= TOMBOL INSTAN =================
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [5000, 10000, 20000, 50000, 100000].map((val) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _buildChipButton(val),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ================= RINGKASAN DATA =================
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _rowRincian("Biaya Admin", "Gratis", isFree: true),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(color: Color(0xFFF1F1F1), height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total Pengurangan", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: greyTextColor)),
                            Text(
                              formatRupiah(currentNominal),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: isSaldoKurang || isKurangDariMinimal || isKelipatanSalah ? Colors.red : primaryColor
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ================= TOMBOL UTAMA =================
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        disabledBackgroundColor: Colors.grey[300],
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: isInputValid ? () => _prosesKonfirmasi(context) : null,
                      child: Text(
                        "Lanjutkan Penarikan",
                        style: TextStyle(
                            color: isInputValid ? Colors.white : Colors.grey[500],
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipButton(int value) {
    final isSelected = currentNominal == value;
    return InkWell(
      onTap: () => setNominalPilihan(value),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          formatRupiah(value).replaceAll("Rp ", ""),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isSelected ? primaryColor : greyTextColor,
          ),
        ),
      ),
    );
  }

  Widget _rowRincian(String label, String value, {bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: greyTextColor, fontSize: 14, fontWeight: FontWeight.w500)),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isFree ? Colors.green[700] : darkTextColor),
        ),
      ],
    );
  }

  void _prosesKonfirmasi(BuildContext context) {
    int nominalTarik = currentNominal;

    if (nominalTarik < _minimalPenarikan) {
      _showSnackbar("Minimal penarikan adalah ${formatRupiah(_minimalPenarikan)}", Colors.amber[900]!);
      return;
    }
    if (nominalTarik % 500 != 0) {
      _showSnackbar("Nominal penarikan harus kelipatan Rp 500", Colors.red[700]!);
      return;
    }
    if (nominalTarik > saldoAktif) {
      _showSnackbar("Saldo aktif Anda tidak mencukupi untuk penarikan ini", Colors.red[700]!);
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: const BorderRadius.all(Radius.circular(2)))),
              ),
              const SizedBox(height: 18),
              const Text("Konfirmasi Penarikan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkTextColor)),
              const SizedBox(height: 8),
              const Text("Pastikan data penarikan Anda sudah benar sebelum dikirim ke admin.", style: TextStyle(color: greyTextColor)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Jumlah yang ditarik", style: TextStyle(fontWeight: FontWeight.w500, color: greyTextColor)),
                    Text(formatRupiah(nominalTarik), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _prosesKirimKeBackend(nominalTarik);
                      },
                      child: const Text("Ya, Kirim", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void _showSnackbar(String pesan, Color warna) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan, style: const TextStyle(fontWeight: FontWeight.w600)), backgroundColor: warna, behavior: SnackBarBehavior.floating),
    );
  }
}

class ThousandSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');
    int value = int.parse(newValue.text.replaceAll('.', ''));
    String newText = formatAngka(value);
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

String formatRupiah(int value) {
  return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(value);
}

String formatAngka(int value) {
  return NumberFormat.decimalPattern('id_ID').format(value);
}