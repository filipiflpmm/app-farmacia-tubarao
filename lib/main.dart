import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_farmacia/services/firebase_options.dart';
import 'package:app_farmacia/services/database_service.dart';
import 'package:app_farmacia/views/tela_inicial_view.dart';
import 'package:app_farmacia/views/tela_consulta_view.dart';
import 'package:app_farmacia/views/tela_login_view.dart';
import 'package:app_farmacia/views/tela_admin_view.dart';
import 'package:app_farmacia/views/tela_atualizacao_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await DatabaseService.instance.inicializarDadosSeVazio();

  runApp(const FarmaciaApp());
}

class FarmaciaApp extends StatelessWidget {
  const FarmaciaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmácia Municipal Central de Tubarão',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF003366),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF003366),
          primary: const Color(0xFF003366),
          secondary: const Color(0xFF0056B3),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFEBF2FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF003366),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const TelaInicialView(),
        '/consulta': (context) => const TelaConsultaView(),
        '/login': (context) => const TelaLoginView(),
        '/admin': (context) => const TelaAdminView(),
        '/atualizacao': (context) => const TelaAtualizacaoView(),
      },
    );
  }
}