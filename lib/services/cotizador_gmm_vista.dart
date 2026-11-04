import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class CotizadorGmmVista extends StatefulWidget {
  const CotizadorGmmVista({super.key});

  @override
  State<CotizadorGmmVista> createState() => _CotizadorGmmVistaState();
}

class _CotizadorGmmVistaState extends State<CotizadorGmmVista> {
  final _clienteCtrl = TextEditingController();
  final _edadCtrl = TextEditingController(text: '35');
  String _aseguradora = 'QUALITAS';
  double _costoCalculado = 0.0;

  void _calcular() {
    final edad = int.tryParse(_edadCtrl.text) ?? 30;
    setState(() {
      _costoCalculado = edad < 30 ? 18500.0 : (edad < 50 ? 28400.0 : 49500.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cotizador de Seguros (GMM & Autos)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
          const SizedBox(height: 8),
          const Text('Genera proyecciones y cotizaciones inmediatas para tus prospectos.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(controller: _clienteCtrl, decoration: const InputDecoration(labelText: 'Nombre del Prospecto / Cliente')),
                const SizedBox(height: 12),
                TextField(controller: _edadCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Edad del Asegurado')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _aseguradora,
                  items: const [
                    DropdownMenuItem(value: 'QUALITAS', child: Text('QUALITAS')),
                    DropdownMenuItem(value: 'GNP', child: Text('GNP SEGUROS')),
                    DropdownMenuItem(value: 'AXA', child: Text('AXA SEGUROS')),
                    DropdownMenuItem(value: 'MAPFRE', child: Text('MAPFRE')),
                  ],
                  onChanged: (v) => setState(() => _aseguradora = v ?? 'QUALITAS'),
                  decoration: const InputDecoration(labelText: 'Compañía Aseguradora'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF091428), foregroundColor: const Color(0xFFD4AF37)),
                  onPressed: _calcular,
                  child: const Text('CALCULAR PRIMA ESTIMADA'),
                ),
                if (_costoCalculado > 0) ...[
                  const SizedBox(height: 16),
                  Text('Prima Estimada Anual: \$$_costoCalculado MXN', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }
}
