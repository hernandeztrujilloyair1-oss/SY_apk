import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmpresaConfigService extends ChangeNotifier {
  static final EmpresaConfigService _instance = EmpresaConfigService._internal();
  factory EmpresaConfigService() => _instance;
  EmpresaConfigService._internal();

  String nombreDespacho = 'SY Soluciones';
  String lemaDespacho = 'Sistema de Gestión de Seguros';
  String brokerTitular = 'Yair Hernández';
  String correoContacto = 'contacto@sysoluciones.mx';
  String correoCobranza = 'cobranza@sysoluciones.mx';
  String? logoBase64;

  // Paleta de Colores No-Code
  Color colorNavbar = const Color(0xFF091428);
  Color colorSidebar = const Color(0xFF0B192C);
  Color colorAcento = const Color(0xFFD4AF37); // Dorado de realce

  Future<void> cargar() async {
    final sp = await SharedPreferences.getInstance();
    nombreDespacho = sp.getString('cfg_nombre') ?? nombreDespacho;
    lemaDespacho = sp.getString('cfg_lema') ?? lemaDespacho;
    brokerTitular = sp.getString('cfg_broker') ?? brokerTitular;
    correoContacto = sp.getString('cfg_correo') ?? correoContacto;
    correoCobranza = sp.getString('cfg_cobranza') ?? correoCobranza;
    logoBase64 = sp.getString('cfg_logo');

    final cNav = sp.getInt('cfg_col_nav');
    if (cNav != null) colorNavbar = Color(cNav);
    final cSide = sp.getInt('cfg_col_side');
    if (cSide != null) colorSidebar = Color(cSide);
    final cAc = sp.getInt('cfg_col_ac');
    if (cAc != null) colorAcento = Color(cAc);

    notifyListeners();
  }

  Future<void> guardar({
    required String nuevoNombre,
    required String nuevoLema,
    required String nuevoBroker,
    required String nuevoCorreoContacto,
    required String nuevoCorreoCobranza,
    String? nuevoLogo,
    Color? nuevoNavbar,
    Color? nuevoSidebar,
    Color? nuevoAcento,
  }) async {
    final sp = await SharedPreferences.getInstance();
    nombreDespacho = nuevoNombre;
    lemaDespacho = nuevoLema;
    brokerTitular = nuevoBroker;
    correoContacto = nuevoCorreoContacto;
    correoCobranza = nuevoCorreoCobranza;

    await sp.setString('cfg_nombre', nuevoNombre);
    await sp.setString('cfg_lema', nuevoLema);
    await sp.setString('cfg_broker', nuevoBroker);
    await sp.setString('cfg_correo', nuevoCorreoContacto);
    await sp.setString('cfg_cobranza', nuevoCorreoCobranza);

    if (nuevoLogo != null) {
      logoBase64 = nuevoLogo;
      await sp.setString('cfg_logo', nuevoLogo);
    }
    if (nuevoNavbar != null) {
      colorNavbar = nuevoNavbar;
      await sp.setInt('cfg_col_nav', nuevoNavbar.toARGB32());
    }
    if (nuevoSidebar != null) {
      colorSidebar = nuevoSidebar;
      await sp.setInt('cfg_col_side', nuevoSidebar.toARGB32());
    }
    if (nuevoAcento != null) {
      colorAcento = nuevoAcento;
      await sp.setInt('cfg_col_ac', nuevoAcento.toARGB32());
    }

    notifyListeners();
  }
}