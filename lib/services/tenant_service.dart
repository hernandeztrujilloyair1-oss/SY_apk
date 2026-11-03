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

  factory EmpresaTenant.planBasico(String id, String nombreDespacho) {
    return EmpresaTenant(
      idEmpresa: id,
      nombre: nombreDespacho,
      lema: 'Despacho Afiliado a Plataforma SaaS',
      colorPrimario: const Color(0xFF1E3A8A),
      colorAcento: const Color(0xFF38BDF8),
      correoContacto: 'contacto@${id.toLowerCase()}.com',
      correoCobranza: 'cobranza@${id.toLowerCase()}.com',
      logoUrl: '',
      tipoAlmacenamiento: 'SAAS_CENTRALIZADO',
      cuotaTotalGb: 250.0,
      almacenamientoUsadoGb: 12.8,
    );
  }
}

class TenantService extends ChangeNotifier {
  static final TenantService _instance = TenantService._internal();
  factory TenantService() => _instance;
  TenantService._internal();

  EmpresaTenant _empresaActiva = EmpresaTenant.enfoqueSeguro();
  EmpresaTenant get empresaActiva => _empresaActiva;

  final List> empresasDisponibles = const [
    {'id': 'EMP_ENFOQUE', 'nombre': 'Enfoque Seguro (Workspace 5 TB)'},
    {'id': 'EMP_BRITO', 'nombre': 'Brito Patrimonial (Plan Básico 250 GB)'},
    {'id': 'EMP_CENTRO', 'nombre': 'Asesores del Centro (Plan Básico 250 GB)'},
  ];

  void cambiarEmpresa(String idEmpresa) {
    if (idEmpresa == 'EMP_ENFOQUE') {
      _empresaActiva = EmpresaTenant.enfoqueSeguro();
    } else if (idEmpresa == 'EMP_BRITO') {
      _empresaActiva = EmpresaTenant.planBasico('EMP_BRITO', 'Brito Patrimonial');
    } else {
      _empresaActiva = EmpresaTenant.planBasico(idEmpresa, 'Asesores del Centro');
    }
    notifyListeners();
  }

  void actualizarConsumo(double nuevosGbUsados) {
    _empresaActiva.almacenamientoUsadoGb = nuevosGbUsados;
    notifyListeners();
  }
}