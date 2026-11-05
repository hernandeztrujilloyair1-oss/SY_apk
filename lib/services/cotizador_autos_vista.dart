import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:html' as html;
import '../config/api_config.dart';

class CotizadorAutosVista extends StatefulWidget {
  const CotizadorAutosVista({super.key});

  @override
  State<CotizadorAutosVista> createState() => _CotizadorAutosVistaState();
}

class _CotizadorAutosVistaState extends State<CotizadorAutosVista> {
  final _clienteCtrl = TextEditingController(text: 'Cliente Particular');
  final _vehiculoCtrl = TextEditingController(text: 'Nissan Versa Advance');
  final _modeloCtrl = TextEditingController(text: '2023');
  final _cpCtrl = TextEditingController(text: '08200');
  String _frecuencia = 'ANUAL';
  bool _anexarRedEnlace = true;
  bool _generandoPdf = false;

  final _opcionesAutos = [
    {
      'aseguradora': 'QUALITAS',
      'plan': 'AMPLIA',
      'deducibleDM': '5%',
      'deducibleRobo': '10%',
      'rcLuc': '\$3,000,000',
      'gastosMedicos': '\$200,000',
      'primaNetaAnual': 12450.0,
      'seleccionado': true
    },
    {
      'aseguradora': 'GNP',
      'plan': 'PREMIUM',
      'deducibleDM': '5%',
      'deducibleRobo': '10%',
      'rcLuc': '\$4,000,000',
      'gastosMedicos': '\$250,000',
      'primaNetaAnual': 14890.0,
      'seleccionado': true
    },
    {
      'aseguradora': 'AXA',
      'plan': 'AMPLIA PLUS',
      'deducibleDM': '5%',
      'deducibleRobo': '10%',
      'rcLuc': '\$4,000,000',
      'gastosMedicos': '\$300,000',
      'primaNetaAnual': 13780.0,
      'seleccionado': true
    },
    {
      'aseguradora': 'MAPFRE',
      'plan': 'AMPLIA TOTAL',
      'deducibleDM': '5%',
      'deducibleRobo': '10%',
      'rcLuc': '\$3,000,000',
      'gastosMedicos': '\$200,000',
      'primaNetaAnual': 11950.0,
      'seleccionado': false
    },
    {
      'aseguradora': 'CHUBB',
      'plan': 'AMPLIA',
      'deducibleDM': '5%',
      'deducibleRobo': '10%',
      'rcLuc': '\$3,500,000',
      'gastosMedicos': '\$200,000',
      'primaNetaAnual': 13100.0,
      'seleccionado': false
    }
  ];

  Future<void> _exportarPdf() async {
    final seleccionadas = _opcionesAutos.where((o) => o['seleccionado'] == true).toList();
    if (seleccionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona al menos una aseguradora.')));
      return;
    }

    setState(() => _generandoPdf = true);
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.appsScriptUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accion': 'GENERAR_COMPARATIVA_AUTOS_PDF',
          'cliente': _clienteCtrl.text,
          'vehiculo': _vehiculoCtrl.text,
          'modelo': _modeloCtrl.text,
          'cp': _cpCtrl.text,
          'frecuencia': _frecuencia,
          'anexarRedEnlace': _anexarRedEnlace,
          'opciones': seleccionadas,
        }),
      );

      final data = jsonDecode(res.body);
      if (data['status'] == 'success' && data['pdfUrl'] != null) {
        html.window.open(data['pdfUrl'], '_blank');
      } else {
        throw Exception(data['mensaje'] ?? 'Error desconocido');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al generar PDF: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _generandoPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fMoneda = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cotizador de Autos & Pickups Multicompañía', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
                  SizedBox(height: 4),
                  Text('Genera comparativas con N aseguradoras, coberturas, asistencias y desglose de pagos.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF091428),
                  foregroundColor: const Color(0xFFD4AF37),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                icon: _generandoPdf ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 2)) : const Icon(Icons.picture_as_pdf_outlined),
                label: Text(_generandoPdf ? 'GENERANDO...' : 'EXPORTAR COMPARATIVA EN PDF'),
                onPressed: _generandoPdf ? null : _exportarPdf,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: TextField(controller: _clienteCtrl, decoration: const InputDecoration(labelText: 'Contratante / Asegurado', border: OutlineInputBorder()))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: _vehiculoCtrl, decoration: const InputDecoration(labelText: 'Descripción del Vehículo', border: OutlineInputBorder()))),
                    const SizedBox(width: 12),
                    SizedBox(width: 100, child: TextField(controller: _modeloCtrl, decoration: const InputDecoration(labelText: 'Modelo', border: OutlineInputBorder()))),
                    const SizedBox(width: 12),
                    SizedBox(width: 100, child: TextField(controller: _cpCtrl, decoration: const InputDecoration(labelText: 'C.P.', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _frecuencia,
                        decoration: const InputDecoration(labelText: 'Frecuencia de Pago', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'ANUAL', child: Text('ANUAL (Contado 1 Pago)')),
                          DropdownMenuItem(value: 'SEMESTRAL', child: Text('SEMESTRAL (2 Pagos)')),
                          DropdownMenuItem(value: 'TRIMESTRAL', child: Text('TRIMESTRAL (4 Pagos)')),
                          DropdownMenuItem(value: 'MENSUAL', child: Text('MENSUAL (12 Pagos)')),
                        ],
                        onChanged: (v) => setState(() => _frecuencia = v ?? 'ANUAL'),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Row(
                      children: [
                        Switch(value: _anexarRedEnlace, activeThumbColor: const Color(0xFFD4AF37), onChanged: (v) => setState(() => _anexarRedEnlace = v)),
                        const Text('Anexar Cobertura Red Enlace A.C.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF091428))),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Selecciona las Aseguradoras a cotejar en el cuadro:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _opcionesAutos.map((op) {
              final sel = op['seleccionado'] == true;
              final costoStr = fMoneda.format(op['primaNetaAnual']);
              final cia = op['aseguradora'];
              final pl = op['plan'];
              return FilterChip(
                label: Text('$cia - $pl ($costoStr)'),
                selected: sel,
                selectedColor: const Color(0xFF091428),
                labelStyle: TextStyle(color: sel ? const Color(0xFFD4AF37) : const Color(0xFF091428), fontWeight: FontWeight.bold),
                onSelected: (val) => setState(() => op['seleccionado'] = val),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
