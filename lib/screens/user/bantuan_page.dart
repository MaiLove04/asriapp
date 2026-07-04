import 'package:flutter/material.dart';

const primaryColor = Color(0xFF1E521E);
const softGreenColor = Color(0xFFE8F5E9);
const backgroundColor = Color(0xFFF9FBF9);
const darkTextColor = Color(0xFF0D240D);
const greyTextColor = Color(0xFF555555);

class BantuanPage extends StatelessWidget {
  const BantuanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        "q": "Bagaimana cara menyetor sampah?",
        "a": "Pilih menu 'Setor Sampah' di beranda, lalu buat permintaan penjemputan. Kurir akan datang ke lokasi Anda sesuai jadwal."
      },
      {
        "q": "Berapa minimal saldo untuk ditarik?",
        "a": "Minimal penarikan saldo adalah Rp 10.000. Anda dapat melakukan penarikan melalui menu 'Tarik Tunai'."
      },
      {
        "q": "Kenapa status penjemputan belum berubah?",
        "a": "Kurir mungkin sedang dalam perjalanan atau menangani nasabah lain. Anda dapat memantau status di menu 'Lacak Jemputan'."
      },
      {
        "q": "Bagaimana jika data timbangan salah?",
        "a": "Anda dapat mengajukan keberatan melalui menu 'Layanan Aduan' dengan melampirkan foto bukti jika diperlukan."
      },
      {
        "q": "Apa saja sampah yang tidak diterima?",
        "a": "Kami saat ini belum menerima sampah organik (sisa makanan) dan sampah B3 (limbah medis, baterai, bohlam)."
      },
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: const Text("Pusat Bantuan",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= HEADER BANTUAN =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.help_center_rounded, color: Colors.white, size: 60),
                  const SizedBox(height: 12),
                  const Text(
                    "Ada yang bisa dibantu?",
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Cari jawaban dari pertanyaan yang sering diajukan nasabah ASRI di bawah ini.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ================= FAQ LIST =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        title: Text(
                          faqs[index]['q']!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: darkTextColor,
                          ),
                        ),
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: softGreenColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              faqs[index]['a']!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: darkTextColor,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // ================= CONTACT SUPPORT =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E6B2E), primaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.support_agent_rounded, color: Colors.white, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Masih Butuh Bantuan?",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Hubungi layanan aduan kami untuk bantuan lebih lanjut.",
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
