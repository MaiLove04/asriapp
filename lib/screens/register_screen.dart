import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'services/register_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {

  const RegisterScreen({
    super.key,
  });

  @override
  State<RegisterScreen>
  createState() =>
      _RegisterScreenState();
}


class _RegisterScreenState
    extends State<RegisterScreen> {

  final _formKey =
  GlobalKey<FormState>();


  final nameController =
  TextEditingController();

  final emailController =
  TextEditingController();

  final passwordController =
  TextEditingController();

  final confirmPasswordController =
  TextEditingController();

  final phoneController =
  TextEditingController();

  final addressController =
  TextEditingController();


  int? selectedBankId;

  File? selectedImage;


  bool isLoading = false;

  bool isObscure = true;



  // ================= FOTO =================
  Future<void>
  pickImage() async {

    final picked =

    await ImagePicker()

        .pickImage(

      source:
      ImageSource.gallery,

    );

    if (
    picked == null
    ) return;


    setState(() {

      selectedImage =

          File(
            picked.path,
          );

    });
  }



  // ================= REGISTER =================
  Future<void>
  register() async {

    if (
    selectedBankId == null
    ) {

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(

          content:
          Text(
            'Pilih bank sampah',
          ),
        ),
      );

      return;
    }


    setState(() {

      isLoading = true;

    });


    try {

      final result =

      await RegisterService

          .register(

        name:
        nameController.text,

        email:
        emailController.text,

        password:
        passwordController.text,

        confirmPassword:
        confirmPasswordController.text,

        phone:
        phoneController.text,

        address:
        addressController.text,

        bankSampahId:
        selectedBankId!,

        foto:
        selectedImage,

      );


      final status =
      result['status'];

      final data =
      result['data'];


      if (

      status == 200 ||

          status == 201

      ) {

        if (
        !mounted
        ) return;


        ScaffoldMessenger.of(
          context,
        ).showSnackBar(

          const SnackBar(

            content:
            Text(
              'Registrasi berhasil',
            ),
          ),
        );


        Navigator
            .pushReplacement(

          context,

          MaterialPageRoute(

            builder: (_) =>

            const LoginScreen(),

          ),
        );

      } else {

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(

          SnackBar(

            content:
            Text(

              data['message'] ??

                  'Registrasi gagal',

            ),
          ),
        );
      }

    } catch (e) {

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        SnackBar(

          content:
          Text(
            '$e',
          ),
        ),
      );

    }


    if (
    !mounted
    ) return;


    setState(() {

      isLoading = false;

    });
  }



  @override
  Widget build(
      BuildContext context,
      ) {

    return Scaffold(

      backgroundColor:
      const Color(
        0xFFF4F7F4,
      ),

      body: SafeArea(

        child:
        SingleChildScrollView(

          padding:
          const EdgeInsets
              .all(24),

          child: Form(

            key:
            _formKey,

            child:
            Column(

              children: [

                const SizedBox(
                  height: 30,
                ),


                const Icon(

                  Icons.person_add,

                  size: 60,

                  color:
                  Color(
                    0xFF4CAF50,
                  ),
                ),


                const SizedBox(
                  height: 15,
                ),


                const Text(

                  'Buat Akun',

                  style:
                  TextStyle(

                    fontSize: 26,

                    fontWeight:
                    FontWeight
                        .bold,

                    color:
                    Color(
                      0xFF2E7D32,
                    ),
                  ),
                ),


                const SizedBox(
                  height: 30,
                ),



                // ================= FOTO =================
                GestureDetector(

                  onTap:
                  pickImage,

                  child:
                  CircleAvatar(

                    radius:
                    45,

                    backgroundColor:

                    Colors
                        .grey[300],

                    backgroundImage:

                    selectedImage
                        != null

                        ?

                    FileImage(
                      selectedImage!,
                    )

                        :

                    null,

                    child:

                    selectedImage
                        == null

                        ?

                    const Icon(

                      Icons
                          .camera_alt,

                      size:
                      30,

                    )

                        :

                    null,
                  ),
                ),


                const SizedBox(
                  height: 25,
                ),



                _buildInput(

                  controller:
                  nameController,

                  hint:
                  'Nama',

                  icon:
                  Icons.person,

                ),


                const SizedBox(
                  height: 15,
                ),



                _buildInput(

                  controller:
                  emailController,

                  hint:
                  'Email',

                  icon:
                  Icons.email,

                ),


                const SizedBox(
                  height: 15,
                ),



                _buildInput(

                  controller:
                  passwordController,

                  hint:
                  'Password',

                  icon:
                  Icons.lock,

                  isPassword:
                  true,

                ),


                const SizedBox(
                  height: 15,
                ),



                _buildInput(

                  controller:

                  confirmPasswordController,

                  hint:

                  'Konfirmasi Password',

                  icon:
                  Icons.lock,

                  isPassword:
                  true,

                ),


                const SizedBox(
                  height: 15,
                ),



                _buildInput(

                  controller:
                  phoneController,

                  hint:
                  'No HP',

                  icon:
                  Icons.phone,

                  keyboardType:

                  TextInputType
                      .phone,

                ),


                const SizedBox(
                  height: 15,
                ),



                _buildInput(

                  controller:

                  addressController,

                  hint:
                  'Alamat',

                  icon:

                  Icons
                      .location_on,

                ),


                const SizedBox(
                  height: 15,
                ),



                // ================= BANK =================
                DropdownButtonFormField<int>(

                  value:
                  selectedBankId,

                  decoration:
                  InputDecoration(

                    hintText:

                    'Pilih Bank Sampah',

                    prefixIcon:

                    const Icon(
                      Icons.store,
                    ),

                    filled:
                    true,

                    fillColor:

                    const Color(
                      0xFFE6ECE6,
                    ),

                    border:

                    OutlineInputBorder(

                      borderRadius:

                      BorderRadius
                          .circular(
                        20,
                      ),

                      borderSide:

                      BorderSide.none,
                    ),
                  ),

                  items:
                  const [

                    DropdownMenuItem(

                      value:
                      1,

                      child:
                      Text(

                        'Basayan Bestari',

                      ),
                    ),

                    DropdownMenuItem(

                      value:
                      2,

                      child:
                      Text(

                        'Asri Mandiri',

                      ),
                    ),

                  ],

                  onChanged:

                      (value) {

                    setState(() {

                      selectedBankId =
                          value;

                    });
                  },
                ),


                const SizedBox(
                  height: 25,
                ),



                // ================= BUTTON =================
                SizedBox(

                  width:
                  double.infinity,

                  height:
                  55,

                  child:
                  ElevatedButton(

                    style:

                    ElevatedButton
                        .styleFrom(

                      backgroundColor:

                      const Color(
                        0xFF5E8C61,
                      ),

                      shape:

                      RoundedRectangleBorder(

                        borderRadius:

                        BorderRadius
                            .circular(
                          30,
                        ),
                      ),
                    ),

                    onPressed:

                    isLoading

                        ?

                    null

                        :

                        () {

                      if (

                      _formKey
                          .currentState!

                          .validate()

                      ) {

                        register();

                      }
                    },

                    child:

                    isLoading

                        ?

                    const CircularProgressIndicator(

                      color:
                      Colors.white,

                    )

                        :

                    const Text(

                      'Daftar',

                      style:
                      TextStyle(

                        fontSize:
                        18,

                        color:
                        Colors.white,

                      ),
                    ),
                  ),
                ),


                const SizedBox(
                  height: 20,
                ),



                TextButton(

                  onPressed:
                      () {

                    Navigator.pop(
                      context,
                    );

                  },

                  child:
                  const Text(

                    'Sudah punya akun? Login',

                    style:
                    TextStyle(

                      color:
                      Color(
                        0xFF2E7D32,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  // ================= INPUT =================
  Widget _buildInput({

    required TextEditingController
    controller,

    required String hint,

    required IconData icon,

    bool isPassword =
    false,

    TextInputType keyboardType =

        TextInputType.text,

  }) {

    return TextFormField(

      controller:
      controller,

      obscureText:

      isPassword

          ?

      isObscure

          :

      false,

      keyboardType:
      keyboardType,

      decoration:
      InputDecoration(

        hintText:
        hint,

        prefixIcon:
        Icon(
          icon,
        ),

        filled:
        true,

        fillColor:

        const Color(
          0xFFE6ECE6,
        ),

        border:
        OutlineInputBorder(

          borderRadius:

          BorderRadius
              .circular(
            20,
          ),

          borderSide:

          BorderSide.none,
        ),

        suffixIcon:

        isPassword

            ?

        IconButton(

          icon:
          Icon(

            isObscure

                ?

            Icons
                .visibility_off

                :

            Icons
                .visibility,

          ),

          onPressed:
              () {

            setState(() {

              isObscure =
              !isObscure;

            });
          },
        )

            :

        null,
      ),

      validator:
          (value) {

        if (

        value == null ||

            value.isEmpty

        ) {

          return

            '$hint tidak boleh kosong';
        }


        if (

        hint == 'Email'

        ) {

          final emailRegex =

          RegExp(

            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
          );

          if (

          !emailRegex
              .hasMatch(
            value,
          )

          ) {

            return

              'Format email tidak valid';
          }
        }


        if (

        hint == 'Password' &&

            value.length < 6

        ) {

          return

            'Password minimal 6 karakter';
        }


        if (

        hint ==

            'Konfirmasi Password'

        ) {

          if (

          value !=

              passwordController
                  .text

          ) {

            return

              'Password tidak sama';
          }
        }


        if (

        hint == 'No HP' &&

            value.length < 10

        ) {

          return
            'No HP tidak valid';
        }

        return null;
      },
    );
  }
}