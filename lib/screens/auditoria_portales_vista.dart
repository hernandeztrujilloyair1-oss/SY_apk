import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import '../config/api_config.dart';

class AuditoriaPortalesVista extends StatefulWidget {
  const AuditoriaPortalesVista({super.key});

  @override
  State<AuditoriaPortalesVista> createState() => _AuditoriaPortalesVistaState();
}

class _AuditoriaPortalesVistaState extends State<AuditoriaPortalesVista> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _endpointCtrl = TextEditingController(text: ApiConfig.appsScriptUrl);

  bool _cargando = false;
  List<Map<String, dynamic>> _portales = [
    {'portal': 'QUALITAS', 'totalPolizas': 42, 'primaTotal': 485230.50, 'vigentes': 38, 'canceladas': 4, 'discrepancias': 1},
    {'portal': 'GNP SEGUROS', 'totalPolizas': 29, 'primaTotal': 612400.00, 'vigentes': 27, 'canceladas': 2, 'discrepancias': 0},
    {'portal': 'AXA SEGUROS', 'totalPolizas': 18, 'primaTotal': 234100.80, 'vigentes': 15, 'canceladas': 3, 'discrepancias': 2},
    {'portal': 'MAPFRE', 'totalPolizas': 35, 'primaTotal': 410900.00, 'vigentes': 34, 'canceladas': 1, 'discrepancias': 0},
  ];

  final TextEditingController _polizaTargetCtrl = TextEditingController(text: '5157914');
  final TextEditingController _titularTargetCtrl = TextEditingController(text: 'CRISOFORO ROBERTO PEREZ ONOFRE');
  final TextEditingController _ciaTargetCtrl = TextEditingController(text: 'QUALITAS');
  final TextEditingController _ramoTargetCtrl = TextEditingController(text: 'Autos / Amplia Plus');

  final List<Map<String, dynamic>> _checklistDocs = [
    {'doc': 'Carátula de Póliza Oficial Emitida', 'incluido': true},
    {'doc': 'Aviso de Cobro o Comprobante de Pago', 'incluido': true},
    {'doc': 'Identificación Oficial Vigente (INE / Pasaporte)', 'incluido': true},
    {'doc': 'Constancia de Situación Fiscal (SAT)', 'incluido': true},
    {'doc': 'Formato Identificación Art. 492 Firmado', 'incluido': true},
    {'doc': 'Factura o Carta Factura Vehicular', 'incluido': false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _endpointCtrl.dispose();
    _polizaTargetCtrl.dispose();
    _titularTargetCtrl.dispose();
    _ciaTargetCtrl.dispose();
    _ramoTargetCtrl.dispose();
    super.dispose();
  }

  Future<void> _consultarAuditoriaSheets() async {
    final url = _endpointCtrl.text.trim();
    if (url.isEmpty) return;
    setState(() => _cargando = true);
    try {
      final res = await http.get(Uri.parse(url + '?accion=OBTENER_AUDITORIA_PORTALES'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map && data.containsKey('portales')) {
          final listRaw = data['portales'] as List;
          setState(() {
            _portales = listRaw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _cargando = false);
  }

  void _imprimirExpedienteFisico() {
    Printing.layoutPdf(
      onLayout: (format) async {
        final itemsHtml = _checklistDocs.map((d) {
          final String docNom = d['doc']?.toString() ?? '';
          final bool inc = d['incluido'] == true;
          return '<li>' + docNom + ': <strong>' + (inc ? 'INTEGRADO' : 'PENDIENTE') + '</strong></li>';
        }).join('');

        return await Printing.convertHtml(
          format: format,
          html: '<div><h2>ENFOQUE SEGURO</h2><p>CONTRATANTE: ' + _titularTargetCtrl.text + '</p><p>POLIZA: ' + _polizaTargetCtrl.text + '</p><ul>' + itemsHtml + '</ul></div>',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Auditoría de Portales & Expedientes Físicos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF091428),
        foregroundColor: const Color(0xFFD4AF37),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFD4AF37),
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'PORTAL POR PORTAL'),
            Tab(text: 'EXPEDIENTES FÍSICOS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _portales.length,
            itemBuilder: (ctx, i) {
              final p = _portales[i];
              return Card(
                child: ListTile(
                  title: Text(p['portal'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Vigentes: ' + p['vigentes'].toString() + ' | Canceladas: ' + p['canceladas'].toString()),
                  trailing: Text(r'$ ' + (p['primaTotal'] as num).toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF091428), foregroundColor: const Color(0xFFD4AF37)),
                icon: const Icon(Icons.print_outlined),
                label: const Text('IMPRIMIR CARÁTULA Y PESTAÑAS FÍSICAS'),
                onPressed: _imprimirExpedienteFisico,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
