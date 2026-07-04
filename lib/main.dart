
import 'package:asriapp/screens/user/activity_riwayat.dart';
import 'package:asriapp/screens/user/profile.dart';
import 'package:asriapp/screens/user/tarik_tunai.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/user/dashboard_screen.dart';
import 'screens/user/setor_sampah.dart';
import 'screens/kurir/dashboard_kurir.dart';


import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  String? role = prefs.getString('role');
  String? name = prefs.getString('user_name');

  runApp(MyApp(token: token, role: role, name: name));
}

class MyApp extends StatelessWidget {
  final String? token;
  final String? role;
  final String? name;

  const MyApp({super.key, this.token, this.role, this.name});

  @override
  Widget build(BuildContext context) {
    String initialRoute = '/login';
    if (token != null) {
      initialRoute = (role == 'kurir') ? '/dashboard_kurir' : '/dashboard';
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => DashboardScreen(name: name ?? "User"),
        '/setorsampah': (context) => const SetorSampahScreen(),
        '/riwayat': (context) => const RiwayatPage(),
        '/tariktunai': (context) => const TarikTunaiPage(),
        '/profil': (context) => const profile_page(),
        '/dashboard_kurir': (context) => const DashboardKurir()
      },
    );
  }
}
