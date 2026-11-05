import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/poliza_model.dart';
import '../services/tenant_service.dart';
import 'dashboard_metricas_vista.dart';
import 'cobranza_seguimiento_vista.dart';
import 'calendario_operativo_vista.dart';
import 'importador_documental_vista.dart';
import 'campanas_correo_vista.dart';
import 'auditoria_portales_vista.dart';
import '../services/reporte_contratantes_vista.dart';
import '../services/cotizador_gmm_vista.dart';
import 'configuracion_vista.dart';
import 'lector_ia_poliza_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _indiceSeleccionado = 0;
  String _terminoBusqueda = '';
  final TextEditingController _searchCtrl = TextEditingController();
  List<PolizaModel> _polizasCartera = [];

  final List<String> _titulos = [
    'DASHBOARD GERENCIAL',
    'COBRANZA ACTIVA & SEGUIMIENTO',
    'CALENDARIO OPERATIVO',
    'CONTRATANTES / CARTERA',
    'IMPORTADOR SIGA (IA)',
    'AUDITORÍA DE PORTALES',
    'CAMPAÑAS POR CORREO',
    'COTIZADOR DE SEGUROS',
    'CONFIGURACIÓN CENTRAL',
  ];

  @override
  void initState() {
    super.initState();
    _cargarPolizasGlobales();
  }

  Future<void> _cargarPolizasGlobales() async {
    try {
      final res = await http.get(Uri.parse('${ApiConfig.appsScriptUrl}?tabla=POLIZAS'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List && mounted) {
          setState(() {
            _polizasCartera = data
                .whereType()
                .map((e) => PolizaModel.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          });
        }
      }
    } catch (_) {}
  }

  void _abrirLectorIaDialog() async {
    final creado = await showDialog<bool>(
      context: context,
      builder: (ctx) => const LectorIaPolizaDialog(),
    );
    if (creado == true) {
      _cargarPolizasGlobales();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenant = TenantService().empresaActiva;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Row(
        children: [
          Container(
            width: 250,
            color: const Color(0xFF091428),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: tenant.colorAcento,
                        radius: 18,
                        child: Text(
                          tenant.nombre.isNotEmpty ? tenant.nombre[0] : 'E',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tenant.nombre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                            Text(tenant.lema, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFF1E293B), height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _itemMenu(0, Icons.dashboard_outlined, 'DASHBOARD'),
                      _itemMenu(1, Icons.attach_money_rounded, 'COBRANZA ACTIVA'),
                      _itemMenu(2, Icons.calendar_month_outlined, 'CALENDARIO OPERATIVO'),
                      _itemMenu(3, Icons.people_alt_outlined, 'CONTRATANTES / CARTERA'),
                      _itemMenu(4, Icons.cloud_upload_outlined, 'IMPORTADOR SIGA (IA)'),
                      _itemMenu(5, Icons.fact_check_outlined, 'AUDITORÍA PORTALES'),
                      _itemMenu(6, Icons.forward_to_inbox_outlined, 'CAMPAÑAS POR CORREO'),
                      _itemMenu(7, Icons.calculate_outlined, 'COTIZADOR SEGUROS'),
                      _itemMenu(8, Icons.settings_outlined, 'CONFIGURACIÓN'),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF060D1A),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: tenant.colorAcento,
                        radius: 14,
                        child: const Text('R', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Raúl Martínez', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            Text('DIRECCIÓN GENERAL', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 9, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                            onChanged: (val) => setState(() => _terminoBusqueda = val.trim()),
                            decoration: InputDecoration(
                              hintText: 'Buscar en ' + _titulos[_indiceSeleccionado] + '...',
                              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                              prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF64748B)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF059669)),
                            const SizedBox(width: 6),
                            Text(tenant.nombre, style: const TextStyle(color: Color(0xFF059669), fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _construirVistaActiva()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemMenu(int index, IconData icon, String label) {
    final bool seleccionado = _indiceSeleccionado == index;
    final tenant = TenantService().empresaActiva;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: seleccionado ? const Color(0xFF1E293B) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: seleccionado ? Border.all(color: tenant.colorAcento, width: 0.8) : null,
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: seleccionado ? tenant.colorAcento : const Color(0xFF94A3B8), size: 18),
        title: Text(label, style: TextStyle(color: seleccionado ? Colors.white : const Color(0xFF94A3B8), fontWeight: seleccionado ? FontWeight.bold : FontWeight.w500, fontSize: 11)),
        onTap: () {
          setState(() {
            _indiceSeleccionado = index;
            _terminoBusqueda = '';
            _searchCtrl.clear();
          });
        },
      ),
    );
  }

  Widget _construirVistaActiva() {
    switch (_indiceSeleccionado) {
      case 0:
        return DashboardMetricasVista(
          polizas: _polizasCartera,
          onAbrirCargaIa: _abrirLectorIaDialog,
        );
      case 1:
        return const CobranzaSeguimientoVista();
      case 2:
        return const CalendarioOperativoVista();
      case 3:
        return const ReporteContratantesVista();
      case 4:
        return const ImportadorDocumentalVista();
      case 5:
        return const AuditoriaPortalesVista();
      case 6:
        return const CampanasCorreoVista();
      case 7:
        return const CotizadorGmmVista();
      case 8:
        return const ConfiguracionVista();
      default:
        return DashboardMetricasVista(
          polizas: _polizasCartera,
          onAbrirCargaIa: _abrirLectorIaDialog,
        );
    }
  }
}
