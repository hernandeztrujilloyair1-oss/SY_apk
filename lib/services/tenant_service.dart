import 'package:flutter/material.dart';

class EmpresaTenant {
  final String idEmpresa;
  final String nombre;
  final String lema;
  final Color colorPrimario;
  final Color colorAcento;
  final String correoContacto;
  final String correoCobranza;
  final String logoUrl;
  final String tipoAlmacenamiento;
  final double cuotaTotalGb;
  double almacenamientoUsadoGb;

  EmpresaTenant({
    required this.idEmpresa,
    required this.nombre,
    required this.lema,
    required this.colorPrimario,
    required this.colorAcento,
    required this.correoContacto,
    required this.correoCobranza,
    required this.logoUrl,
    required this.tipoAlmacenamiento,
    required this.cuotaTotalGb,
    this.almacenamientoUsadoGb = 0.0,
  });

  bool get esWorkspacePropio => tipoAlmacenamiento == 'WORKSPACE_PROPIO';
  double get porcentajeUso =>
      cuotaTotalGb > 0 ? (almacenamientoUsadoGb / cuotaTotalGb).clamp(0.0, 1.0) : 0.0;
  double get espacioDisponibleGb =>
      (cuotaTotalGb - almacenamientoUsadoGb).clamp(0.0, cuotaTotalGb);

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
      tipoAlmacenamiento: 'WORKSPACE_PROPIO',
      cuotaTotalGb: 5000.0,
      almacenamientoUsadoGb: 34.2,
    );
  }
}

class TenantService extends ChangeNotifier {
  static final TenantService _instance = TenantService._internal();
  factory TenantService() => _instance;
  TenantService._internal();

  EmpresaTenant _empresaActiva = EmpresaTenant.enfoqueSeguro();
  EmpresaTenant get empresaActiva => _empresaActiva;

  final List<Map<String, String>> empresasDisponibles = const [
    {'id': 'EMP_ENFOQUE', 'nombre': 'Enfoque Seguro (Workspace 5 TB)'},
  ];

  void cambiarEmpresa(String idEmpresa) {
    _empresaActiva = EmpresaTenant.enfoqueSeguro();
    notifyListeners();
  }

  void actualizarConsumo(double nuevosGbUsados) {
    _empresaActiva.almacenamientoUsadoGb = nuevosGbUsados;
    notifyListeners();
  }
}
