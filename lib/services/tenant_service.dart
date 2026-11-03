import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmpresaTenant {
  final String idEmpresa;
  final String nombre;
  final String lema;
  final Color colorPrimario;
  final Color colorAcento;
  final String correoContacto;
  final String correoCobranza;
  final String logoUrl;

  EmpresaTenant({
    required this.idEmpresa,
    required this.nombre,
    required this.lema,
    required this.colorPrimario,
    required this.colorAcento,
    required this.correoContacto,
    required this.correoCobranza,
    required this.logoUrl,
  });

  factory EmpresaTenant.enfoqueSeguro() {
    return EmpresaTenant(
      idEmpresa: 'EMP_ENFOQUE',
      nombre: 'Enfoque Seguro',
      lema: 'Gestión Integral y Asesoría Patrimonial',
      colorPrimario: const Color(0xFF091428),
      colorAcento: const Color(0xFFD4AF37),
      correoContacto: 'direccion@enfoqueseguro.mx',
      correoCobranza: 'cobranza@enfoqueseguro.mx',
      logoUrl: 'https://enfoqueseguro.mx/logo.png',
    );
  }

  factory EmpresaTenant.fromJson(String id, Map<String, dynamic> json) {
    return EmpresaTenant(
      idEmpresa: id,
      nombre: json['nombre'] ?? 'Despacho de Seguros',
      lema: json['lema'] ?? '',
      colorPrimario: Color(int.parse((json['colorPrimario'] ?? '#091428').replaceAll('#', '0xFF'))),
      colorAcento: Color(int.parse((json['colorAcento'] ?? '#D4AF37').replaceAll('#', '0xFF'))),
      correoContacto: json['correoContacto'] ?? '',
      correoCobranza: json['correoCobranza'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
    );
  }
}

class TenantService extends ChangeNotifier {
  static final TenantService _instance = TenantService._internal();
  factory TenantService() => _instance;
  TenantService._internal();

  EmpresaTenant _empresaActiva = EmpresaTenant.enfoqueSeguro();
  EmpresaTenant get empresaActiva => _empresaActiva;

  // Catálogo de empresas contratantes disponibles en el login
  final List> empresasDisponibles = [
    {'id': 'EMP_ENFOQUE', 'nombre': 'Enfoque Seguro'},
    {'id': 'EMP_BRITO', 'nombre': 'Brito Patrimonial'},
  ];

  void cambiarEmpresa(String idEmpresa) {
    if (idEmpresa == 'EMP_ENFOQUE') {
      _empresaActiva = EmpresaTenant.enfoqueSeguro();
    } else {
      _empresaActiva = EmpresaTenant(
        idEmpresa: idEmpresa,
        nombre: 'Brito Patrimonial',
        lema: 'Seguridad y Confianza Familiar',
        colorPrimario: const Color(0xFF1E3A8A),
        colorAcento: const Color(0xFF38BDF8),
        correoContacto: 'contacto@britopatrimonial.mx',
        correoCobranza: 'cobranza@britopatrimonial.mx',
        logoUrl: 'https://britopatrimonial.mx/logo.png',
      );
    }
    notifyListeners();
  }
}