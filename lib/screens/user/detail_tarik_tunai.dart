import 'package:flutter/material.dart';

class DetailRiwayatPage extends StatelessWidget {
  const DetailRiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: const Text("Detail Riwayat"),
        leading: const BackButton(),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // CARD STRUK
              Container(
                width: 320,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade800, width: 2),
                ),
                child: Column(
                  children: [
                    // LOGO
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.eco, color: Colors.green[800], size: 30),
                    ),

                    const SizedBox(height: 10),

                    // TITLE
                    Text(
                      "Basayan Bestari",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green[800],
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text("Struk Setor Sampah"),
                    const Divider(),

                    // JENIS
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green[800],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Plastik",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text("12 November 2025 | Setor"),
                    const Divider(),

                    // DETAIL
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Column(
                          children: [
                            Text("Berat"),
                            Text("3.0 Kg"),
                          ],
                        ),
                        Column(
                          children: [
                            Text("Harga/Kg"),
                            Text("Rp 2.000"),
                          ],
                        ),
                        Column(
                          children: [
                            Text("Total"),
                            Text("Rp 6.000"),
                          ],
                        ),
                      ],
                    ),

                    const Divider(),

                    // TOTAL
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Rp 6.000",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    const Text("Status"),
                    const Text(
                      "Menunggu Penjemputan",
                      style: TextStyle(color: Colors.green),
                    ),

                    const Divider(),

                    const Text(
                      "Terima kasih sudah berkontribusi untuk menjaga bumi.",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text("Bagikan"),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text("Unduh"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}