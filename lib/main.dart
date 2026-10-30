import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'services/empresa_config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EmpresaConfigService().cargar();
  runApp(const SistemaMarcaBlancaSegurosApp());
}

class SistemaMarcaBlancaSegurosApp extends StatelessWidget {
  const SistemaMarcaBlancaSegurosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Gestión de Seguros',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1B365D),
        scaffoldBackgroundColor: const Color(0xFF0A1120),
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0284C7),
          secondary: Color(0xFF38BDF8),
          surface: Color(0xFF131F37),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}