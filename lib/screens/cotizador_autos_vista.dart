import 'package:flutter/material.dart';
import '../services/cotizador_pdf_service.dart';

class CotizadorAutosVista extends StatefulWidget {
  const CotizadorAutosVista({super.key});

  @override
  State<CotizadorAutosVista> createState() => _CotizadorAutosVistaState();
}

class _CotizadorAutosVistaState extends State<CotizadorAutosVista> {
  final _clienteCtrl = TextEditingController(text: 'CLIENTE EJECUTIVO');
  final _vehiculoCtrl = TextEditingController(text: 'NISSAN VERSA ADVANCE CVT 2024');
  int _cantidadOpciones = 3;

  final List> _opciones = [
    {
      'aseguradora': 'Qualitas',
      'paquete': 'Amplia Plus',
      'deducibleDM': '3% Deducible',
      'deducibleRT': '5% Robo Total',
      'rc': '\$4,000,000 MXN',
      'gm': '\$300,000 MXN',
      'primaNeta': 12500.0,
      'derechoPoliza': 650.0,
    },
    {
      'aseguradora': 'GNP Seguros',
      'paquete': 'Línea Azul Auto',
      'deducibleDM': '5% Deducible',
      'deducibleRT': '10% Robo Total',
      'rc': '\$3,500,000 MXN',
      'gm': '\$250,000 MXN',
      'primaNeta': 13200.0,
      'derechoPoliza': 700.0,
    },
    {
      'aseguradora': 'AXA Seguros',
      'paquete': 'Amplia Integral',
      'deducibleDM': '5% Deducible',
      'deducibleRT': '10% Robo Total',
      'rc': '\$4,000,000 MXN',
      'gm': '\$300,000 MXN',
      'primaNeta': 11900.0,
      'derechoPoliza': 620.0,
    },
  ];

  Map<String, double> _calcularDesglose(double primaNeta, double derecho) {
    final subtotal = primaNeta + derecho;
    final totalAnual = subtotal * 1.16;
    final semestral = (primaNeta * 1.04 + derecho) * 1.16 / 2;
    final trimestral = (primaNeta * 1.06 + derecho) * 1.16 / 4;
    final mensual = (primaNeta * 1.08 + derecho) * 1.16 / 12;

    return {
      'anual': totalAnual,
      'semestral': semestral,
      'trimestral': trimestral,
      'mensual': mensual,
    };
  }

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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cotizador Comparativo de Autos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  SizedBox(height: 4),
                  Text('Comparativa formal multi-aseguradora con opciones de financiamiento.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: const Color(0xFFD4AF37),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.picture_as_pdf, size: 18),
                label: const Text('DESCARGAR COMPARATIVA (PDF)', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  final selec = _opciones.take(_cantidadOpciones).map((op) {
                    final calc = _calcularDesglose(op['primaNeta'] as double, op['derechoPoliza'] as double);
                    return {
                      'aseguradora': '${op['aseguradora']}\n(${op['paquete']})',
                      'deducibleDM': op['deducibleDM'] as String,
                      'deducibleRT': op['deducibleRT'] as String,
                      'rc': op['rc'] as String,
                      'gm': op['gm'] as String,
                      'anual': calc['anual']!.toStringAsFixed(2),
                      'semestral': calc['semestral']!.toStringAsFixed(2),
                      'trimestral': calc['trimestral']!.toStringAsFixed(2),
                      'mensual': calc['mensual']!.toStringAsFixed(2),
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
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_cantidadOpciones, (i) {
              final op = _opciones[i];
              final calc = _calcularDesglose(op['primaNeta'] as double, op['derechoPoliza'] as double);

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < _cantidadOpciones - 1 ? 14 : 0),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: i == 0 ? const Color(0xFFD4AF37) : const Color(0xFFE2E8F0), width: i == 0 ? 2 : 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(op['aseguradora'].toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      Text(op['paquete'].toString(), style: const TextStyle(fontSize: 12, color: Color(0xFF0284C7), fontWeight: FontWeight.w600)),
                      const Divider(height: 20),
                      Text('Daños: ${op['deducibleDM']}', style: const TextStyle(fontSize: 11)),
                      Text('Robo: ${op['deducibleRT']}', style: const TextStyle(fontSize: 11)),
                      Text('RC: ${op['rc']}', style: const TextStyle(fontSize: 11)),
                      Text('GM: ${op['gm']}', style: const TextStyle(fontSize: 11)),
                      const SizedBox(height: 12),
                      Text('Total Anual: \$ ${calc['anual']!.toStringAsFixed(2)} MXN', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
