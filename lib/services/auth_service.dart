import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum RolUsuario { maestro, cobranza, ejecutivo, anonimo }

class UsuarioSesion {
  final String id;
  final String nombre;
  final String correo;
  final RolUsuario rol;
  final double comisionPct;

  UsuarioSesion({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
    required this.comisionPct,
  });

  bool get esMaestro => rol == RolUsuario.maestro;
  bool get esCobranza => rol == RolUsuario.cobranza || rol == RolUsuario.maestro;
  bool get esEjecutivo => rol == RolUsuario.ejecutivo;

  bool puedeEditarParametrosYComisiones() => esMaestro;
  bool puedeModificarCarteraYPolizas() => esCobranza;
  bool soloLecturaReportes() => esEjecutivo;
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UsuarioSesion? _usuarioActual;
  UsuarioSesion? get usuarioActual => _usuarioActual;
  bool get estaAutenticado => _usuarioActual != null;

  final String endpointAppsScript =
      'https://script.google.com/macros/s/AKfycbx0_EtCpa4kd4xWQ3exYT_18PH6YXhEcAUgWxl0h242elBfzs5WUiaEmuueJRLfDHSg/exec';

  Future<bool> iniciarSesion(String correo, String password) async {
    final mail = correo.trim().toLowerCase();

    // Respaldo de acceso institucional
    if (mail == 'direccion@enfoqueseguro.mx' && password == 'Master2026*') {
      _usuarioActual = UsuarioSesion(
        id: 'USR-001',
        nombre: 'Raúl Martínez',
        correo: correo,
        rol: RolUsuario.maestro,
        comisionPct: 100.0,
      );
      notifyListeners();
      return true;
    } else if (mail == 'cobranza@enfoqueseguro.mx' && password == 'Cobranza2026*') {
      _usuarioActual = UsuarioSesion(
        id: 'USR-002',
        nombre: 'Yair Hernández',
        correo: correo,
        rol: RolUsuario.cobranza,
        comisionPct: 0.0,
      );
      notifyListeners();
      return true;
    } else if (mail.contains('ejecutivo') || mail.contains('ventas')) {
      _usuarioActual = UsuarioSesion(
        id: 'USR-003',
        nombre: 'Ejecutivo de Cuenta',
        correo: correo,
        rol: RolUsuario.ejecutivo,
        comisionPct: 15.0,
      );
      notifyListeners();
      return true;
    }

    // Consulta remota a tu Google Apps Script implementado
    try {
      final res = await http.post(
        Uri.parse(endpointAppsScript),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accion': 'LOGIN',
          'correo': correo,
          'password': password,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          final u = data['usuario'];
          RolUsuario rol = RolUsuario.ejecutivo;
          if (u['rol'] == 'MAESTRO') rol = RolUsuario.maestro;
          if (u['rol'] == 'COBRANZA') rol = RolUsuario.cobranza;

          _usuarioActual = UsuarioSesion(
            id: u['id']?.toString() ?? 'USR-999',
            nombre: u['nombre']?.toString() ?? 'Usuario',
            correo: u['correo']?.toString() ?? correo,
            rol: rol,
            comisionPct: (u['comision_pct'] as num?)?.toDouble() ?? 0.0,
          );
          notifyListeners();
          return true;
        }
      }
    } catch (_) {}

    return false;
  }

  void cerrarSesion() {
    _usuarioActual = null;
    notifyListeners();
  }
}
