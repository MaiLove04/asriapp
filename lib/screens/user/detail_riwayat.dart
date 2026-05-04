import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/setor_sampah_model.dart';

class DetailRiwayatPage
    extends StatelessWidget {

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


      body: SafeArea(

        top: false,

        child: Column(

          children: [


            Container(

              height: 140,

              decoration:
              const BoxDecoration(

                color: Color(
                    0xff2f5d2f),

                borderRadius:
                BorderRadius
                    .only(

                  bottomLeft:
                  Radius.circular(
                      40),

                  bottomRight:
                  Radius.circular(
                      40),
                ),
              ),

              child: Row(

                children: [

                  IconButton(

                    onPressed: () {

                      Navigator.pop(
                        context,
                      );
                    },

                    icon:
                    const Icon(

                      Icons
                          .arrow_back,

                      color:
                      Colors
                          .white,
                    ),
                  ),


                  const Expanded(

                    child:
                    Center(

                      child:
                      Text(

                        "Detail Riwayat",

                        style:
                        TextStyle(

                          color:
                          Colors
                              .white,

                          fontSize:
                          20,

                          fontWeight:
                          FontWeight
                              .bold,
                        ),
                      ),
                    ),
                  ),


                  const SizedBox(
                    width: 48,
                  ),
                ],
              ),
            ),



            Expanded(

              child: Center(

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
                              .grey[
                          100],

                          borderRadius:
                          BorderRadius
                              .circular(
                              20),

                          border:
                          Border.all(

                            color:
                            Colors
                                .green
                                .shade800,

                            width: 2,
                          ),
                        ),

                        child:
                        Column(

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

                                size:
                                30,
                              ),
                            ),

                            const SizedBox(
                              height:
                              10,
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
                              height:
                              5,
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

                              child:
                              Text(

                                data
                                    .jenisSampah,

                                style:
                                const TextStyle(

                                  color:
                                  Colors
                                      .white,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height:
                              10,
                            ),


                            Text(
                              "$tanggal | Setor",
                            ),

                            const Divider(),


                            ...data.details
                                .map(

                                  (item) {

                                return Padding(

                                  padding:
                                  const EdgeInsets
                                      .only(
                                    bottom:
                                    8,
                                  ),

                                  child:
                                  Row(

                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,

                                    children: [

                                      Text(
                                        item.nama,
                                      ),

                                      Text(
                                        item.berat,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),


                            const Divider(),


                            Row(

                              mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,

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

                                    color:
                                    Colors.green[
                                    800],

                                    fontWeight:
                                    FontWeight
                                        .bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}