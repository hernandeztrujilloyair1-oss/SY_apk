import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmpresaConfigService extends ChangeNotifier {
  static final EmpresaConfigService _instancia = EmpresaConfigService._interno();
  factory EmpresaConfigService() => _instancia;
  EmpresaConfigService._interno();

  // 1. TU LOGO POR DEFECTO (puedes poner una URL directa a tu imagen o dejarla como fallback)
  static const String _logoDefaultUrl = 'https://enfoqueseguro.mx/logo.png'; // O la URL pública de tu logo

  String _nombreDespacho = 'Enfoque Seguro';
  String _lemaDespacho = 'Gestión Integral y Asesoría Patrimonial';
  String _brokerTitular = 'Raúl Martínez';
  String _correoContacto = 'direccion@enfoqueseguro.mx';
  String _correoCobranza = 'cobranza@enfoqueseguro.mx';
  String? _logoClienteBase64; // Logo subido por el cliente en memoria/local

  Color _colorNavbar = const Color(0xFF091428); // Azul Noche Corporativo
  Color _colorSidebar = const Color(0xFF0F172A); // Grafito Oscuro
  Color _colorAcento = const Color(0xFFD4AF37); // Oro de Enfoque Seguro

  // Getters
  String get nombreDespacho => _nombreDespacho;
  String get lemaDespacho => _lemaDespacho;
  String get brokerTitular => _brokerTitular;
  String get correoContacto => _correoContacto;
  String get correoCobranza => _correoCobranza;
  String? get logoBase64 => _logoClienteBase64;
  String get logoDefaultUrl => _logoDefaultUrl;

  Color get colorNavbar => _colorNavbar;
  Color get colorSidebar => _colorSidebar;
  Color get colorAcento => _colorAcento;

  // Cargar configuración guardada del cliente desde el almacenamiento local
  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    _nombreDespacho = prefs.getString('empresa_nombre') ?? _nombreDespacho;
    _lemaDespacho = prefs.getString('empresa_lema') ?? _lemaDespacho;
    _brokerTitular = prefs.getString('empresa_broker') ?? _brokerTitular;
    _correoContacto = prefs.getString('empresa_correo') ?? _correoContacto;
    _correoCobranza = prefs.getString('empresa_cobranza') ?? _correoCobranza;
    _logoClienteBase64 = prefs.getString('empresa_logo_base64');

    final navVal = prefs.getInt('empresa_nav_color');
    if (navVal != null) _colorNavbar = Color(navVal);

    final acentoVal = prefs.getInt('empresa_acento_color');
    if (acentoVal != null) _colorAcento = Color(acentoVal);

    notifyListeners();
  }

  // Guardar cuando el cliente sube su propio logo o cambia datos
  Future<void> guardar({
    required String nuevoNombre,
    required String nuevoLema,
    required String nuevoBroker,
    required String nuevoCorreoContacto,
    required String nuevoCorreoCobranza,
    String? nuevoLogo,
    required Color nuevoNavbar,
    required Color nuevoAcento,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _nombreDespacho = nuevoNombre;
    _lemaDespacho = nuevoLema;
    _brokerTitular = nuevoBroker;
    _correoContacto = nuevoCorreoContacto;
    _correoCobranza = nuevoCorreoCobranza;
    _logoClienteBase64 = nuevoLogo;
    _colorNavbar = nuevoNavbar;
    _colorAcento = nuevoAcento;

    await prefs.setString('empresa_nombre', nuevoNombre);
    await prefs.setString('empresa_lema', nuevoLema);
    await prefs.setString('empresa_broker', nuevoBroker);
    await prefs.setString('empresa_correo', nuevoCorreoContacto);
    await prefs.setString('empresa_cobranza', nuevoCorreoCobranza);
    if (nuevoLogo != null) {
      await prefs.setString('empresa_logo_base64', nuevoLogo);
    }
    await prefs.setInt('empresa_nav_color', nuevoNavbar.toARGB32());
    await prefs.setInt('empresa_acento_color', nuevoAcento.toARGB32());

    notifyListeners();
  }

  // Restablecer al logotipo y datos originales tuyos
  Future<void> restablecerPorDefecto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _nombreDespacho = 'Enfoque Seguro';
    _lemaDespacho = 'Gestión Integral y Asesoría Patrimonial';
    _brokerTitular = 'Raúl Martínez';
    _correoContacto = 'direccion@enfoqueseguro.mx';
    _correoCobranza = 'cobranza@enfoqueseguro.mx';
    _logoClienteBase64 = null;
    _colorNavbar = const Color(0xFF091428);
    _colorSidebar = const Color(0xFF0F172A);
    _colorAcento = const Color(0xFFD4AF37);
    notifyListeners();
  }
}