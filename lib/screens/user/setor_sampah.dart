import 'package:flutter/material.dart';

class SetorSampahScreen extends StatefulWidget {
  const SetorSampahScreen({super.key});

  @override
  State<SetorSampahScreen> createState() =>
      _SetorSampahScreenState();
}

class _SetorSampahScreenState
    extends State<SetorSampahScreen> {

  String? selectedJenis;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe5e5e5),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: [

            /// HEADER
            Container(
              height: 140,
              decoration: const BoxDecoration(
                color: Color(0xff2f5d2f),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Setor Sampah",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40)
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// CARD JENIS SAMPAH
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 5)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Jenis Sampah",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(child: _itemSampah("assets/images/plastik.png", "Plastik")),
                      Expanded(child: _itemSampah("assets/images/metal.png", "Metal")),
                      Expanded(child: _itemSampah("assets/images/organik.png", "Organik")),
                      Expanded(child: _itemSampah("assets/images/kertas.png", "Kertas")),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// CATATAN TAMBAHAN
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFECECEC),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// JUDUL
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey),
                      ),
                    ),
                    child: const Text(
                      "Catatan Tambahan",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),

                  /// INPUT AUTO EXPAND
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Icon(
                          Icons.note_alt,
                          color: Color(0xFF2E7D32),
                          size: 35,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: TextField(
                            minLines: 1,
                            maxLines: null, // 🔥 auto membesar
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                              hintText: "Tambahkan catatan...",
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D5A27),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          selectedJenis ?? "Belum pilih sampah",
                        ),
                      ),
                    );

                  },
                  icon: const Icon(Icons.local_shipping),
                  label: const Text("Konfirmasi Penjemputan"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// ITEM SAMPAH
  Widget _itemSampah(String img, String text) {

    final isSelected = selectedJenis == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedJenis = text;
        });
      },

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: Colors.green[100],
              shape: BoxShape.circle,

              border: Border.all(
                color:
                isSelected
                    ? Colors.green
                    : Colors.transparent,
                width: 3,
              ),
            ),

            child: Image.asset(
              img,
              width: 40,
              height: 40,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            text,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }}