
import 'package:asriapp/screens/user/activity_riwayat.dart';
import 'package:asriapp/screens/user/profile.dart';
import 'package:asriapp/screens/user/tarik_tunai.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/user/dashboard_screen.dart';
import 'screens/user/setor_sampah.dart';
import 'screens/kurir/dashboard_kurir.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', // halaman pertama
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(name: "User"),
        '/setorsampah': (context) => const SetorSampahScreen(),
        '/riwayat': (context) => const RiwayatPage(),
        '/tariktunai': (context) => const TarikTunaiPage(),
        '/profil': (context) => const profile_page(),
        '/dashboard_kurir': (context) => const DashboardKurir()

      },
    );
  }
}