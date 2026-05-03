import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TarikTunaiPage extends StatefulWidget {
  const TarikTunaiPage({super.key});

  @override
  State<TarikTunaiPage> createState() => _TarikTunaiPageState();
}

class _TarikTunaiPageState extends State<TarikTunaiPage> {
  int saldo = 15000;
  int nominal = 10000;

  void setNominal(int value) {
    setState(() {
      saldo -= nominal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        title: const Text(
          "Tarik Tunai",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ================= SALDO =================
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[200],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.shade800),
              ),
              child: Column(
                children: [
                  const Text("Saldo Poin Anda"),
                  const SizedBox(height: 5),
                  CircleAvatar(
                    backgroundColor: Colors.green[800],
                    child: const Text("Rp",
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Rp ${saldo.toString()}",
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= FORM =================
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Formulir Tarik Tunai",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Center(
                    child: Text(
                      "Silakan isi formulir penarikan di bawah ini",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ================= NOMINAL =================
                  const Text("Nominal Penarikan"),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.attach_money),
                        Expanded(
                          child: Text(
                            "Rp $nominal",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // QUICK BUTTON
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _quickButton(5000),
                      _quickButton(10000),
                      _quickButton(15000),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // ================= JUMLAH =================
                  const Text("Jumlah Penarikan"),
                  const SizedBox(height: 5),

                  Container(
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text("Rp $nominal"),
                  ),

                  const SizedBox(height: 10),

                  // ================= BIAYA =================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Biaya Admin"),
                      Text("Rp 0"),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Penarikan"),
                      Text("Rp $nominal"),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // ================= BUTTON =================
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        // ✅ validasi saldo
                        if (nominal > saldo) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Saldo tidak cukup")),
                          );
                          return;
                        }

                        setState(() {
                          saldo -= nominal;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Penarikan berhasil diajukan")),
                        );
                      },
                      child: const Text(
                        "Ajukan Penarikan",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= QUICK BUTTON =================
  Widget _quickButton(int value) {
    return GestureDetector(
      onTap: () => setNominal(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: nominal == value ? Colors.green : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          value.toString(),
          style: TextStyle(
            color: nominal == value ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

String formatRupiah(int value) {
  return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
      .format(value);
}