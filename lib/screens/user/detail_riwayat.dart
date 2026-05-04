import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/setor_sampah_model.dart';

class DetailRiwayatPage extends StatelessWidget {

  final SetorSampahModel data;

  const DetailRiwayatPage({

    super.key,

    required this.data,
  });


  @override
  Widget build(
      BuildContext context) {

    final parsedDate =
    DateTime.tryParse(
        data.createdAt);

    final tanggal =
    parsedDate != null

        ? DateFormat(
      "dd MMM yyyy",
    ).format(
      parsedDate,
    )

        : "-";


    return Scaffold(

      backgroundColor:
      Colors.grey[200],

      appBar: AppBar(

        backgroundColor:
        Colors.green[800],

        title:
        const Text(
          "Detail Riwayat",
        ),

        leading:
        const BackButton(),
      ),

      body: Center(

        child:
        SingleChildScrollView(

          child: Column(

            children: [

              const SizedBox(
                height: 20,
              ),


              Container(

                width: 320,

                padding:
                const EdgeInsets
                    .all(
                    16),

                decoration:
                BoxDecoration(

                  color:
                  Colors
                      .grey[100],

                  borderRadius:
                  BorderRadius
                      .circular(
                      20),

                  border:
                  Border.all(

                    color:
                    Colors.green
                        .shade800,

                    width: 2,
                  ),
                ),

                child: Column(

                  children: [

                    CircleAvatar(

                      radius:
                      30,

                      backgroundColor:
                      Colors
                          .white,

                      child:
                      Icon(

                        Icons.eco,

                        color:
                        Colors.green[
                        800],

                        size: 30,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),


                    Text(

                      "ASRI",

                      style:
                      TextStyle(

                        fontWeight:
                        FontWeight
                            .bold,

                        fontSize:
                        18,

                        color:
                        Colors.green[
                        800],
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    const Text(
                      "Struk Setor Sampah",
                    ),

                    const Divider(),



                    Container(

                      padding:
                      const EdgeInsets
                          .symmetric(

                        horizontal:
                        12,

                        vertical:
                        6,
                      ),

                      decoration:
                      BoxDecoration(

                        color:
                        Colors.green[
                        800],

                        borderRadius:
                        BorderRadius
                            .circular(
                            20),
                      ),

                      child: Text(

                        data
                            .jenisSampah,

                        style:
                        const TextStyle(
                          color:
                          Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),


                    Text(
                      "$tanggal | Setor",
                    ),

                    const Divider(),



                    Row(

                      mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                      children: [

                        Column(

                          children: [

                            const Text(
                              "Berat",
                            ),

                            Text(
                              data
                                  .beratKg,
                            ),
                          ],
                        ),


                        Column(

                          children: [

                            const Text(
                              "Harga",
                            ),

                            Text(
                              data
                                  .totalHarga,
                            ),
                          ],
                        ),


                        Column(

                          children: [

                            const Text(
                              "Status",
                            ),

                            Text(
                              data
                                  .status,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Divider(),



                    Row(

                      mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                      children: [

                        const Text(

                          "Total",

                          style:
                          TextStyle(
                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),

                        Text(

                          data
                              .totalHarga,

                          style:
                          TextStyle(

                            fontWeight:
                            FontWeight
                                .bold,

                            color:
                            Colors.green[
                            800],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      data.status,
                    ),

                    const Divider(),

                    const Text(

                      "Terima kasih sudah berkontribusi untuk menjaga bumi.",

                      textAlign:
                      TextAlign
                          .center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}