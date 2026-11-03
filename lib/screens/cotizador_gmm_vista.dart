import 'package:flutter/material.dart';
import '../models/aseguradora_model.dart';
import '../services/cotizador_pdf_service.dart';

class CotizadorGmmVista extends StatefulWidget {
  const CotizadorGmmVista({super.key});

  @override
  State<CotizadorGmmVista> createState() => _CotizadorGmmVistaState();
}

class _CotizadorGmmVistaState extends State<CotizadorGmmVista> {
  final _titularCtrl = TextEditingController(text: 'TITULAR ASEGURADO');
  final _edadCtrl = TextEditingController(text: '35');
  int _cantidadOpciones = 3; // 2, 3 o 4 opciones

  // Opciones comparativas de GMM configurables
  final List> _opcionesGmm = [
    {
      'aseguradora': 'MetLife México',
      'plan': 'Medicalife',
      'logo': 'https://logo.clearbit.com/metlife.com.mx',
      'sumaAsegurada': '\$ 110,000,000',
      'deducible': '\$ 24,000',
      'coaseguro': '10%',
      'topeCoaseguro': '\$ 45,000',
      'gama': 'Diamante / Amplia',
      'tabulador': 'Nivel 500',
      'primaNeta': 27500.0,
      'derechoPoliza': 750.0,
    },
    {
      'aseguradora': 'GNP Seguros',
      'plan': 'Línea Azul Premier',
      'logo': 'https://logo.clearbit.com/gnp.com.mx',
      'sumaAsegurada': '\$ 125,000,000',
      'deducible': '\$ 26,000',
      'coaseguro': '10%',
      'topeCoaseguro': '\$ 50,000',
      'gama': 'Premier / Alta',
      'tabulador': 'Línea Médica 450',
      'primaNeta': 29800.0,
      'derechoPoliza': 800.0,
    },
    {
      'aseguradora': 'AXA Seguros',
      'plan': 'Flex Plus',
      'logo': 'https://logo.clearbit.com/axa.mx',
      'sumaAsegurada': '\$ 100,000,000',
      'deducible': '\$ 22,000',
      'coaseguro': '10%',
      'topeCoaseguro': '\$ 42,000',
      'gama': 'Nivel Integral',
      'tabulador': 'Rubí Plus',
      'primaNeta': 26200.0,
      'derechoPoliza': 720.0,
    },
    {
      'aseguradora': 'Seguros Monterrey NYL',
      'plan': 'Alfa Medical',
      'logo': 'https://logo.clearbit.com/mnyl.com.mx',
      'sumaAsegurada': '\$ 130,000,000',
      'deducible': '\$ 28,000',
      'coaseguro': '10%',
      'topeCoaseguro': '\$ 52,000',
      'gama': 'Platino / Total',
      'tabulador': 'Consulado Médico',
      'primaNeta': 31500.0,
      'derechoPoliza': 850.0,
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
          // Encabezado y Acción de Exportar PDF
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cotizador Comparativo de Gastos Médicos Mayores (GMM)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Planes individuales y familiares con desglose de coberturas y amortización fraccionada.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
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
                label: const Text('DESCARGAR COMPARATIVA GMM (PDF)', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  final selec = _opcionesGmm.take(_cantidadOpciones).map((op) {
                    final calc = _calcularDesglose(op['primaNeta'] as double, op['derechoPoliza'] as double);
                    return {
                      'aseguradora': '${op['aseguradora']}\n(${op['plan']})',
                      'deducibleDM': 'Deducible: ${op['deducible']}',
                      'deducibleRT': 'Coaseguro: ${op['coaseguro']} (Tope: ${op['topeCoaseguro']})',
                      'rc': 'Suma: ${op['sumaAsegurada']}',
                      'gm': 'Gama: ${op['gama']}',
                      'anual': calc['anual']!.toStringAsFixed(2),
                      'semestral': calc['semestral']!.toStringAsFixed(2),
                      'trimestral': calc['trimestral']!.toStringAsFixed(2),
                      'mensual': calc['mensual']!.toStringAsFixed(2),
                    };
                  }).toList();

                  CotizadorPdfService.imprimirPropuesta(
                    cliente: _titularCtrl.text,
                    tipoBien: 'Gastos Médicos Mayores (Titular Edad: ${_edadCtrl.text} años)',
                    opcionesSeleccionadas: selec,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Tarjeta de Configuración de la Propuesta
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _titularCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Titular / Asegurado',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: _edadCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Edad del Titular',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _cantidadOpciones,
                      decoration: const InputDecoration(
                        labelText: 'Opciones en Comparativa',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(value: 2, child: Text('2 Opciones')),
                        DropdownMenuItem(value: 3, child: Text('3 Opciones')),
                        DropdownMenuItem(value: 4, child: Text('4 Opciones')),
                      ],
                      onChanged: (v) => setState(() => _cantidadOpciones = v!),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Tarjetas de Comparativa Multi-Aseguradora
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    border: Border.all(
                      color: i == 0 ? const Color(0xFFD4AF37) : const Color(0xFFE2E8F0),
                      width: i == 0 ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado de la Tarjeta con Logo
                      Row(
                        children: [
                          Image.network(
                            op['logo'] as String,
                            width: 28,
                            height: 28,
                            errorBuilder: (_, __, ___) => const Icon(Icons.local_hospital, color: Color(0xFF0369A1), size: 24),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(op['aseguradora'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(op['plan'] as String, style: const TextStyle(color: Color(0xFF0284C7), fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // Condiciones Técnicas
                      _parametroFila('Suma Asegurada', op['sumaAsegurada'] as String),
                      _parametroFila('Deducible', op['deducible'] as String),
                      _parametroFila('Coaseguro', '${op['coaseguro']} (Tope: ${op['topeCoaseguro']})'),
                      _parametroFila('Nivel Hospitalario', op['gama'] as String),
                      _parametroFila('Tabulador Médico', op['tabulador'] as String),
                      const SizedBox(height: 12),

                      // Campo de Prima Neta Editable en Tiempo Real
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Prima Neta Anual (\$ MXN)',
                          border: const OutlineInputBorder(),
                          isDense: true,
                          suffixText: 'MXN',
                        ),
                        controller: TextEditingController(text: (op['primaNeta'] as double).toStringAsFixed(0)),
                        onChanged: (val) {
                          final n = double.tryParse(val);
                          if (n != null) {
                            setState(() => op['primaNeta'] = n);
                          }
                        },
                      ),
                      const SizedBox(height: 14),

                      // Resumen Económico
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Prima Total Anual (con IVA)', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                            const SizedBox(height: 2),
                            Text(
                              '\$ ${calc['anual']!.toStringAsFixed(2)} MXN',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF059669)),
                            ),
                            const Divider(height: 16),
                            _pagoFila('Semestral (x2):', '\$ ${calc['semestral']!.toStringAsFixed(2)}'),
                            _pagoFila('Trimestral (x4):', '\$ ${calc['trimestral']!.toStringAsFixed(2)}'),
                            _pagoFila('Mensual (x12):', '\$ ${calc['mensual']!.toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
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

  Widget _parametroFila(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          Text(valor, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _pagoFila(String periodo, String monto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(periodo, style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
          Text(monto, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
        ],
      ),
    );
  }
}