import 'package:flutter/material.dart';
import '../models/aseguradora_model.dart';
import '../services/cotizador_autos_service.dart';
import '../services/cotizador_pdf_service.dart';

class CotizadorAutosVista extends StatefulWidget {
  const CotizadorAutosVista({super.key});

  @override
  State<CotizadorAutosVista> createState() => _CotizadorAutosVistaState();
}

class _CotizadorAutosVistaState extends State<CotizadorAutosVista> {
  final _clienteCtrl = TextEditingController(text: 'CLIENTE PROSPECTO');
  final _vehiculoCtrl = TextEditingController(text: 'SEDAN 2024');
  int _cantidadOpciones = 3; // 2, 3 o 4 opciones
  final List> _opciones = [
    {'aseguradora': 'Quálitas', 'neta': 12500.0, 'dedDM': '5%', 'dedRT': '10%'},
    {'aseguradora': 'Mapfre', 'neta': 11800.0, 'dedDM': '5%', 'dedRT': '10%'},
    {'aseguradora': 'AXA Seguros', 'neta': 13200.0, 'dedDM': '5%', 'dedRT': '10%'},
    {'aseguradora': 'GNP Seguros', 'neta': 14100.0, 'dedDM': '5%', 'dedRT': '10%'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Comparador Multi-Aseguradora (Autos)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: const Color(0xFFD4AF37),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: const Icon(Icons.picture_as_pdf, size: 18),
                label: const Text('DESCARGAR COMPARATIVA EN PDF (1-2 PÁG)', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  final selec = _opciones.take(_cantidadOpciones).map((op) {
                    final res = CotizadorAutosService.cotizar(primaNeta: op['neta'] as double);
                    return {
                      'aseguradora': op['aseguradora'],
                      'deducibleDM': op['dedDM'],
                      'deducibleRT': op['dedRT'],
                      'anual': res.primaTotalAnual.toStringAsFixed(2),
                      'semestral': res.pagoSemestral.toStringAsFixed(2),
                      'trimestral': res.pagoTrimestral.toStringAsFixed(2),
                      'mensual': res.pagoMensual.toStringAsFixed(2),
                    };
                  }).toList();

                  CotizadorPdfService.imprimirPropuesta(
                    cliente: _clienteCtrl.text,
                    tipoBien: _vehiculoCtrl.text,
                    opcionesSeleccionadas: selec,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _clienteCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre del Cliente', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: _vehiculoCtrl,
                      decoration: const InputDecoration(labelText: 'Vehículo / Modelo / Año', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 14),
                  DropdownButton<int>(
                    value: _cantidadOpciones,
                    items: const [
                      DropdownMenuItem(value: 2, child: Text('2 Opciones a Enviar')),
                      DropdownMenuItem(value: 3, child: Text('3 Opciones a Enviar')),
                      DropdownMenuItem(value: 4, child: Text('4 Opciones a Enviar')),
                    ],
                    onChanged: (v) => setState(() => _cantidadOpciones = v!),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Tablas comparativas dinámicas
          Row(
            children: List.generate(_cantidadOpciones, (i) {
              final op = _opciones[i];
              final res = CotizadorAutosService.cotizar(primaNeta: op['neta'] as double);
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: i == 0 ? const Color(0xFFD4AF37) : const Color(0xFFE2E8F0), width: i == 0 ? 2 : 1),
                  ),
                  child: Column(
                    children: [
                      Text(op['aseguradora'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Divider(),
                      Text('Prima Total Anual', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('\$ ${res.primaTotalAnual.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                      const SizedBox(height: 10),
                      Text('Semestral: \$ ${res.pagoSemestral.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                      Text('Trimestral: \$ ${res.pagoTrimestral.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                      Text('Mensual: \$ ${res.pagoMensual.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              );
            }),
          )
        ],
      ),
    );
  }
}