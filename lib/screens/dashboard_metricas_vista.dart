import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../config/api_config.dart';
import '../models/poliza_model.dart';

class DashboardMetricasVista extends StatefulWidget {
  final List<PolizaModel> polizas;
  final VoidCallback onAbrirCargaIa;
  const DashboardMetricasVista({super.key, required this.polizas, required this.onAbrirCargaIa});
  @override
  State<DashboardMetricasVista> createState() => _DashboardMetricasVistaState();
}

class _DashboardMetricasVistaState extends State<DashboardMetricasVista> {
  final fMoneda = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
  bool _cargandoKpis = true;
  Map<String, dynamic> _kpis = {
    'totalPolizas': 7025,
    'polizasVigentes': 7025,
    'polizasCanceladas': 2015,
    'clientesUnicos': 1881,
    'primaTotalCartera': 296433000.0,
    'recibosPendientes': 1954,
    'importeCobranzaMora': 24680600.0,
  };
  Map<String, dynamic> _cobranzaAvisos = {'1°': 412, '2°': 320, '3°': 184, 'SR RAUL': 95};

  @override
  void initState() {
    super.initState();
    _cargarKpisEnVivo();
  }

  Future<void> _cargarKpisEnVivo() async {
    try {
      final res = await http.get(Uri.parse('${ApiConfig.appsScriptUrl}?accion=KPI_DASHBOARD'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map && data['kpis'] != null && mounted) {
          setState(() {
            _kpis = Map<String, dynamic>.from(data['kpis']);
            if (data['cobranzaAvisos'] != null) {
              _cobranzaAvisos = Map<String, dynamic>.from(data['cobranzaAvisos']);
            }
          });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _cargandoKpis = false);
  }

  @override
  Widget build(BuildContext context) {
    final vigentes = _kpis['polizasVigentes'] ?? 7025;
    final canceladas = _kpis['polizasCanceladas'] ?? 2015;
    final clientes = _kpis['clientesUnicos'] ?? 1881;
    final primaTotal = (_kpis['primaTotalCartera'] is num) ? (_kpis['primaTotalCartera'] as num).toDouble() : 296433000.0;
    final recibosPend = _kpis['recibosPendientes'] ?? 1954;
    final importeMora = (_kpis['importeCobranzaMora'] is num) ? (_kpis['importeCobranzaMora'] as num).toDouble() : 24680600.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF091428), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFFD4AF37), size: 30),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Centro Operativo & Inteligencia de Negocios (Power BI)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Monitoreo en tiempo real de cartera consolidada, primas, cobranza activa y renovaciones.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF091428), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
                  icon: const Icon(Icons.document_scanner_outlined, size: 18),
                  label: const Text('CARGAR PÓLIZA CON IA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: widget.onAbrirCargaIa,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _tarjeta('Cobranza en Mora', '$recibosPend Recibos', fMoneda.format(importeMora), Icons.warning_amber_rounded, const Color(0xFFDC2626), const Color(0xFFFEF2F2)),
              const SizedBox(width: 16),
              _tarjeta('Pólizas Activas Cartera', '$vigentes Activas', '$canceladas Canceladas', Icons.verified_user_outlined, const Color(0xFF091428), Colors.white),
              const SizedBox(width: 16),
              _tarjeta('Clientes Únicos (RFC)', '$clientes Clientes', 'Cartera Consolidada', Icons.people_outline, const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
              const SizedBox(width: 16),
              _tarjeta('Primas Totales Cartera', fMoneda.format(primaTotal), 'Monto con Impuestos', Icons.account_balance_wallet_outlined, const Color(0xFF059669), const Color(0xFFECFDF5)),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFCBD5E1))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.traffic_outlined, color: Color(0xFF091428), size: 20),
                    SizedBox(width: 8),
                    Text('SEMÁFORO DE GESTIÓN DE COBRANZA & AVISOS (1°, 2°, 3°, SR RAÚL)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF091428))),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _semaforo('1° Aviso (1 a 10 días)', _cobranzaAvisos['1°'] ?? 0, const Color(0xFF059669), const Color(0xFFECFDF5)),
                    const SizedBox(width: 12),
                    _semaforo('2° Aviso (11 a 20 días)', _cobranzaAvisos['2°'] ?? 0, const Color(0xFFD97706), const Color(0xFFFFFBEB)),
                    const SizedBox(width: 12),
                    _semaforo('3° Aviso (21 a 30 días)', _cobranzaAvisos['3°'] ?? 0, const Color(0xFFDC2626), const Color(0xFFFEF2F2)),
                    const SizedBox(width: 12),
                    _semaforo('SR RAÚL (> 30 días Mora)', _cobranzaAvisos['SR RAUL'] ?? 0, Colors.purple, const Color(0xFFFAF5FF)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjeta(String tit, String val, String sub, IconData ico, Color c, Color f) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: f, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFCBD5E1))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(tit, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)), overflow: TextOverflow.ellipsis)), Icon(ico, color: c, size: 22)]),
            const SizedBox(height: 10),
            Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF091428)), overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(sub, style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _semaforo(String tit, dynamic cant, Color c, Color f) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: f, borderRadius: BorderRadius.circular(8), border: Border.all(color: c.withOpacity(0.3))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tit, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: c)),
            const SizedBox(height: 6),
            Text('$cant Recibos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c)),
          ],
        ),
      ),
    );
  }
}
