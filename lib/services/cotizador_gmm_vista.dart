import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:html' as html;
import '../config/api_config.dart';

class CotizadorGmmVista extends StatefulWidget {
  const CotizadorGmmVista({super.key});

  @override
  State<CotizadorGmmVista> createState() => _CotizadorGmmVistaState();
}

class _CotizadorGmmVistaState extends State<CotizadorGmmVista> {
  final _clienteCtrl = TextEditingController(text: 'Prospecto Patrimonial');
  final _edadCtrl = TextEditingController(text: '38');
  String _frecuencia = 'ANUAL';
  bool _anexarRedEnlace = true;
  bool _generandoPdf = false;

  final _opciones = [
    {
      'aseguradora': 'ALLIANZ',
      'plan': 'AMPLIA',
      'gama': 'GAMA ALTA',
      'deducible': 32000,
      'coaseguro': 0.10,
      'topeCoaseguro': 100000,
      'primaNetaAnual': 30226.0,
      'seleccionado': true
    },
    {
      'aseguradora': 'GNP',
      'plan': 'AMPLIO',
      'gama': 'GAMA ALTA',
      'deducible': 32000,
      'coaseguro': 0.10,
      'topeCoaseguro': 75000,
      'primaNetaAnual': 32831.0,
      'seleccionado': true
    },
    {
      'aseguradora': 'BX+',
      'plan': 'PLUS',
      'gama': 'GAMA MEDIA',
      'deducible': 35000,
      'coaseguro': 0.10,
      'topeCoaseguro': 48000,
      'primaNetaAnual': 24548.0,
      'seleccionado': true
    },
    {
      'aseguradora': 'AXA',
      'plan': 'PLUS',
      'gama': 'GAMA ALTA',
      'deducible': 72500,
      'coaseguro': 0.10,
      'topeCoaseguro': 64000,
      'primaNetaAnual': 96639.0,
      'seleccionado': false
    }
  ];

  Future<void> _exportarPdf() async {
    final seleccionadas = _opciones.where((o) => o['seleccionado'] == true).toList();
    if (seleccionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona al menos una opción para comparar.')));
      return;
    }

    setState(() => _generandoPdf = true);
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.appsScriptUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accion': 'GENERAR_COMPARATIVA_PDF',
          'cliente': _clienteCtrl.text,
          'edad': int.tryParse(_edadCtrl.text) ?? 35,
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
                  Text('Cotizador Multiaseguradora GMM & Cuadro Comparativo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
                  SizedBox(height: 4),
                  Text('Compara opciones en tiempo real, aplica Red Enlace y genera el PDF formal.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF091428),
                  foregroundColor: const Color(0xFFD4AF37),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                icon: _generandoPdf ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 2)) : const Icon(Icons.picture_as_pdf_outlined),
                label: Text(_generandoPdf ? 'GENERANDO PDF...' : 'DESCARGAR COMPARATIVO EN PDF'),
                onPressed: _generandoPdf ? null : _exportarPdf,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _clienteCtrl, decoration: const InputDecoration(labelText: 'Nombre del Prospecto', border: OutlineInputBorder()))),
                const SizedBox(width: 12),
                SizedBox(width: 90, child: TextField(controller: _edadCtrl, decoration: const InputDecoration(labelText: 'Edad', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _frecuencia,
                    decoration: const InputDecoration(labelText: 'Forma de Pago', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'ANUAL', child: Text('ANUAL (Contado)')),
                      DropdownMenuItem(value: 'SEMESTRAL', child: Text('SEMESTRAL (2 Pagos)')),
                      DropdownMenuItem(value: 'TRIMESTRAL', child: Text('TRIMESTRAL (4 Pagos)')),
                      DropdownMenuItem(value: 'MENSUAL', child: Text('MENSUAL (12 Pagos)')),
                    ],
                    onChanged: (v) => setState(() => _frecuencia = v ?? 'ANUAL'),
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    Switch(value: _anexarRedEnlace, activeColor: const Color(0xFFD4AF37), onChanged: (v) => setState(() => _anexarRedEnlace = v)),
                    const Text('Anexar Red Enlace A.C.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Selecciona las opciones a comparar en la tabla:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _opciones.map((op) {
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
