import 'package:flutter/material.dart';
import '../services/cotizador_pdf_service.dart';

class CotizadorGmmVista extends StatefulWidget {
  const CotizadorGmmVista({super.key});

  @override
  State<CotizadorGmmVista> createState() => _CotizadorGmmVistaState();
}

class _CotizadorGmmVistaState extends State<CotizadorGmmVista> {
  final _titularCtrl = TextEditingController(text: 'FAMILIA CONTRERAS');
  final _perfilCtrl = TextEditingController(text: 'Titular (42) + Cónyuge (39)');
  int _cantidadOpciones = 2;

  final List> _opcionesGmm = [
    {
      'aseguradora': 'GNP Seguros',
      'plan': 'Línea Azul Premier',
      'deducible': '\$18,000 MXN',
      'coaseguro': '10% (Tope \$45,000)',
      'gamaHospitalaria': 'Nivel Amplio / Hospitales Top',
      'tabulador': 'Tabulador Alto',
      'primaNeta': 48500.0,
      'derechoPoliza': 750.0,
    },
    {
      'aseguradora': 'AXA Seguros',
      'plan': 'Flex Plus Médica',
      'deducible': '\$20,000 MXN',
      'coaseguro': '10% (Tope \$50,000)',
      'gamaHospitalaria': 'Nivel Óptimo Integral',
      'tabulador': 'Tabulador Premier Nacional',
      'primaNeta': 46200.0,
      'derechoPoliza': 720.0,
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
                  Text('Cotizador Comparativo GMM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  SizedBox(height: 4),
                  Text('Comparativa de pólizas médicas particulares y familiares.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
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
                label: const Text('IMPRIMIR COMPARATIVA (PDF)', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  final selec = _opcionesGmm.take(_cantidadOpciones).map((op) {
                    final calc = _calcularDesglose(op['primaNeta'] as double, op['derechoPoliza'] as double);
                    return {
                      'aseguradora': '${op['aseguradora']}\n(${op['plan']})',
                      'deducibleDM': 'Deducible: ${op['deducible']}',
                      'deducibleRT': 'Coaseguro: ${op['coaseguro']}',
                      'rc': 'Red: ${op['gamaHospitalaria']}',
                      'gm': 'Tab: ${op['tabulador']}',
                      'anual': calc['anual']!.toStringAsFixed(2),
                      'semestral': calc['semestral']!.toStringAsFixed(2),
                      'trimestral': calc['trimestral']!.toStringAsFixed(2),
                      'mensual': calc['mensual']!.toStringAsFixed(2),
                    };
                  }).toList();

                  CotizadorPdfService.imprimirPropuesta(
                    cliente: _titularCtrl.text,
                    tipoBien: _perfilCtrl.text,
                    opcionesSeleccionadas: selec,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: List.generate(_cantidadOpciones, (i) {
              final op = _opcionesGmm[i];
              final calc = _calcularDesglose(op['primaNeta'] as double, op['derechoPoliza'] as double);

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < _cantidadOpciones - 1 ? 14 : 0),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(op['aseguradora'].toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      Text(op['plan'].toString(), style: const TextStyle(fontSize: 12, color: Color(0xFF0284C7))),
                      const Divider(height: 20),
                      Text('Deducible: ${op['deducible']}', style: const TextStyle(fontSize: 11)),
                      Text('Coaseguro: ${op['coaseguro']}', style: const TextStyle(fontSize: 11)),
                      const SizedBox(height: 10),
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
