import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmpresaConfigService extends ChangeNotifier {
  static final EmpresaConfigService _instancia = EmpresaConfigService._internal();
  factory EmpresaConfigService() => _instancia;
  EmpresaConfigService._internal();

  String nombreDespacho = 'Despacho de Seguros';
  String lemaDespacho = 'Gestión Integral y Asesoría Patrimonial';
  String brokerTitular = 'Dirección General';
  String correoContacto = 'contacto@despachoseguros.com';
  String correoCobranza = 'cobranza@despachoseguros.com';
  String telefonoWhatsApp = '';
  String? logoBase64;

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    nombreDespacho = prefs.getString('mb_nombre') ?? 'Despacho de Seguros';
    lemaDespacho = prefs.getString('mb_lema') ?? 'Gestión Integral y Asesoría Patrimonial';
    brokerTitular = prefs.getString('mb_broker') ?? 'Dirección General';
    correoContacto = prefs.getString('mb_correo_contacto') ?? 'contacto@despachoseguros.com';
    correoCobranza = prefs.getString('mb_correo_cobranza') ?? 'cobranza@despachoseguros.com';
    telefonoWhatsApp = prefs.getString('mb_telefono_wa') ?? '';
    logoBase64 = prefs.getString('mb_logo');
    notifyListeners();
  }

  Future<void> guardar({
    required String nuevoNombre,
    required String nuevoLema,
    required String nuevoBroker,
    required String nuevoCorreoContacto,
    required String nuevoCorreoCobranza,
    String? nuevoTelefonoWhatsApp,
    String? nuevoLogo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    nombreDespacho = nuevoNombre.trim().isEmpty ? 'Despacho de Seguros' : nuevoNombre.trim();
    lemaDespacho = nuevoLema.trim().isEmpty ? 'Gestión Integral' : nuevoLema.trim();
    brokerTitular = nuevoBroker.trim().isEmpty ? 'Dirección General' : nuevoBroker.trim();
    correoContacto = nuevoCorreoContacto.trim();
    correoCobranza = nuevoCorreoCobranza.trim();
    telefonoWhatsApp = nuevoTelefonoWhatsApp?.trim() ?? '';
    if (nuevoLogo != null) logoBase64 = nuevoLogo;

    await prefs.setString('mb_nombre', nombreDespacho);
    await prefs.setString('mb_lema', lemaDespacho);
    await prefs.setString('mb_broker', brokerTitular);
    await prefs.setString('mb_correo_contacto', correoContacto);
    await prefs.setString('mb_correo_cobranza', correoCobranza);
    await prefs.setString('mb_telefono_wa', telefonoWhatsApp);
    if (logoBase64 != null) await prefs.setString('mb_logo', logoBase64!);

    notifyListeners();
  }
}