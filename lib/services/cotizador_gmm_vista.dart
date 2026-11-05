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

class _CotizadorGmmVistaState extends State<CotizadorGmmVista> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final fMoneda = NumberFormat.currency(symbol: r'$', decimalDigits: 2);

  final _clienteGmmCtrl = TextEditingController(text: 'María Esther Ramos');
  final _edadGmmCtrl = TextEditingController(text: '45');
  String _frecuenciaGmm = 'ANUAL';
  bool _anexarRedEnlaceGmm = true;

  final _clienteAutoCtrl = TextEditingController(text: 'Luz María López');
  final _vehiculoAutoCtrl = TextEditingController(text: 'JETTA A4 GLS TURBO L4 TELA');
  final _modeloAutoCtrl = TextEditingController(text: '2021');
  final _cpAutoCtrl = TextEditingController(text: '08200');
  String _frecuenciaAuto = 'MENSUAL';
  bool _anexarRedEnlaceAuto = true;

  bool _generandoPdf = false;

  final _opcionesGmm = [
    {
      'aseguradora': 'BX+',
      'plan': 'PLUS',
      'gama': 'GAMA ALTA',
      'deducible': 35000.0,
      'coaseguro': '10%',
      'topeCoaseguro': r',000',
      'urgencias': 'EXCLUIDO',
      'eliminacionAccidente': 'INCLUIDO',
      'primaNetaAnual': 24548.12,
      'seleccionado': true
    },
    {
      'aseguradora': 'ALLIANZ',
      'plan': 'AMPLIA',
      'gama': 'GAMA ALTA',
      'deducible': 32000.0,
      'coaseguro': '10%',
      'topeCoaseguro': r',000',
      'urgencias': 'INCLUIDO',
      'eliminacionAccidente': 'INCLUIDO',
      'primaNetaAnual': 30226.67,
      'seleccionado': true
    },
    {
      'aseguradora': 'GNP',
      'plan': 'AMPLIO',
      'gama': 'GAMA ALTA',
      'deducible': 32000.0,
      'coaseguro': '10%',
      'topeCoaseguro': r',000',
      'urgencias': 'INCLUIDO',
      'eliminacionAccidente': 'INCLUIDO',
      'primaNetaAnual': 32831.94,
      'seleccionado': true
    },
    {
      'aseguradora': 'BUPA',
      'plan': 'PLUS',
      'gama': 'GAMA MEDIA',
      'deducible': 37000.0,
      'coaseguro': '10%',
      'topeCoaseguro': 'SIN LIMITE',
      'urgencias': 'EXCLUIDO',
      'eliminacionAccidente': 'INCLUIDO',
      'primaNetaAnual': 57204.0,
      'seleccionado': false
    },
    {
      'aseguradora': 'METLIFE',
      'plan': 'PLAN EJECUTIVO',
      'gama': 'GAMA ALTA',
      'deducible': 32000.0,
      'coaseguro': '10%',
      'topeCoaseguro': r',000',
      'urgencias': 'EXCLUIDO',
      'eliminacionAccidente': 'INCLUIDO',
      'primaNetaAnual': 72367.0,
      'seleccionado': false
    },
    {
      'aseguradora': 'AXA',
      'plan': 'PLUS',
      'gama': 'GAMA MEDIA',
      'deducible': 72500.0,
      'coaseguro': '10%',
      'topeCoaseguro': r',000',
      'urgencias': 'EXCLUIDO',
      'eliminacionAccidente': 'EXCLUIDO',
      'primaNetaAnual': 96639.88,
      'seleccionado': false
    },
  ];

  final _opcionesAutos = [
    {
      'aseguradora': 'MAPFRE',
      'plan': 'AMPLIA',
      'deducibleDM': '5%',
      'deducibleRobo': '10%',
      'rcLuc': r',000,000',
      'gastosMedicos': r',000',
      'asistenciaVial': 'INCLUIDO',
      'primaNetaAnual': 7667.72,
      'seleccionado': true
    },
    {
      'aseguradora': 'AXA',
      'plan': 'AMPLIA PLUS',
      'deducibleDM': '5%',
      'deducibleRobo': '10%',
      'rcLuc': r',000,000',
      'gastosMedicos': r',000',
      'asistenciaVial': 'INCLUIDO',
      'primaNetaAnual': 8907.85,
      'seleccionado': true
    },
    {
      'aseguradora': 'QUALITAS',
      'plan': 'AMPLIA',
      'deducibleDM': '5%',
      'deducibleRobo': '10%',
      'rcLuc': r',000,000',
      'gastosMedicos': r',000',
      'asistenciaVial': 'INCLUIDO (KM 0)',
      'primaNetaAnual': 9259.17,
      'seleccionado': true
    },
    {
      'aseguradora': 'GNP',
      'plan': 'PREMIUM',
      'deducibleDM': '5%',
      'deducibleRobo': '10%',
      'rcLuc': r',000,000',
      'gastosMedicos': r',000',
      'asistenciaVial': 'INCLUIDO',
      'primaNetaAnual': 11813.45,
      'seleccionado': false
    },
    {
      'aseguradora': 'CHUBB',
      'plan': 'AMPLIA',
      'deducibleDM': '5%',
      'deducibleRobo': '10%',
      'rcLuc': r',500,000',
      'gastosMedicos': r',000',
      'asistenciaVial': 'INCLUIDO',
      'primaNetaAnual': 12310.0,
      'seleccionado': false
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Map<String, double> _calcularPagos(dynamic primaNetaRaw, String frec, bool tieneRed) {
    double primaNeta = (primaNetaRaw is num) ? primaNetaRaw.toDouble() : (double.tryParse(primaNetaRaw.toString()) ?? 0.0);
    double costoRed = tieneRed ? 1450.0 : 0.0;
    double base = primaNeta + costoRed;
    double recargo = 0.0;
    int divisor = 1;
    double derecho = 650.0;

    if (frec == 'SEMESTRAL') {
      recargo = 0.045;
      divisor = 2;
      derecho = 450.0;
    } else if (frec == 'TRIMESTRAL') {
      recargo = 0.065;
      divisor = 4;
      derecho = 300.0;
    } else if (frec == 'MENSUAL') {
      recargo = 0.085;
      divisor = 12;
      derecho = 180.0;
    }

    double netoPeriodo = (base / divisor) * (1 + recargo);
    double ivaPrimer = (netoPeriodo + derecho) * 0.16;
    double ivaSubsec = netoPeriodo * 0.16;

    double primerPago = netoPeriodo + derecho + ivaPrimer;
    double subsecuente = frec == 'ANUAL' ? 0.0 : (netoPeriodo + ivaSubsec);
    double total = frec == 'ANUAL' ? primerPago : (primerPago + (subsecuente * (divisor - 1)));

    return {
      'primerPago': primerPago,
      'subsecuente': subsecuente,
      'total': total,
    };
  }

  Future<void> _exportarPdf(bool esGmm) async {
    final seleccionadas = (esGmm ? _opcionesGmm : _opcionesAutos).where((o) => o['seleccionado'] == true).toList();
    if (seleccionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona al menos una opción para generar el comparativo.')));
      return;
    }

    setState(() => _generandoPdf = true);
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.appsScriptUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accion': esGmm ? 'GENERAR_COMPARATIVA_PDF' : 'GENERAR_COMPARATIVA_AUTOS_PDF',
          'cliente': esGmm ? _clienteGmmCtrl.text : _clienteAutoCtrl.text,
          'edad': int.tryParse(_edadGmmCtrl.text) ?? 35,
          'vehiculo': _vehiculoAutoCtrl.text,
          'modelo': _modeloAutoCtrl.text,
          'cp': _cpAutoCtrl.text,
          'frecuencia': esGmm ? _frecuenciaGmm : _frecuenciaAuto,
          'anexarRedEnlace': esGmm ? _anexarRedEnlaceGmm : _anexarRedEnlaceAuto,
          'opciones': seleccionadas,
        }),
      );

      final data = jsonDecode(res.body);
      if (data['status'] == 'success' && data['pdfUrl'] != null) {
        html.window.open(data['pdfUrl'], '_blank');
      } else {
        throw Exception(data['mensaje'] ?? 'No se recibió la URL del PDF');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al generar PDF: '), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _generandoPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF091428),
            unselectedLabelColor: const Color(0xFF64748B),
            indicatorColor: const Color(0xFFD4AF37),
            indicatorWeight: 3,
            tabs: const [
              Tab(icon: Icon(Icons.medical_services_outlined), text: 'GASTOS MÉDICOS MAYORES (GMM)'),
              Tab(icon: Icon(Icons.directions_car_outlined), text: 'SEGURO DE AUTOMÓVILES / PICKUPS'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _construirModulo(true),
              _construirModulo(false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _construirModulo(bool esGmm) {
    final opciones = esGmm ? _opcionesGmm : _opcionesAutos;
    final seleccionadas = opciones.where((o) => o['seleccionado'] == true).toList();
    final frec = esGmm ? _frecuenciaGmm : _frecuenciaAuto;
    final tieneRed = esGmm ? _anexarRedEnlaceGmm : _anexarRedEnlaceAuto;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    esGmm ? 'Cotizador GMM Multiaseguradora con Red Enlace' : 'Cotizador de Autos & Pickups Multicompañía',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF091428)),
                  ),
                  const SizedBox(height: 4),
                  const Text('Compara en tiempo real deducibles, coaseguros, primas periódicas y coberturas.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF091428),
                  foregroundColor: const Color(0xFFD4AF37),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: _generandoPdf
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 2))
                    : const Icon(Icons.picture_as_pdf_outlined, size: 18),
                label: Text(_generandoPdf ? 'GENERANDO PDF...' : 'DESCARGAR COMPARATIVO PDF', style: const TextStyle(fontWeight: FontWeight.bold)),
                onPressed: _generandoPdf ? null : () => _exportarPdf(esGmm),
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
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: esGmm ? _clienteGmmCtrl : _clienteAutoCtrl,
                        decoration: InputDecoration(
                          labelText: esGmm ? 'Contratante / Prospecto' : 'Asegurado / Propietario',
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (esGmm)
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _edadGmmCtrl,
                          decoration: const InputDecoration(labelText: 'Edad', border: OutlineInputBorder(), isDense: true),
                          keyboardType: TextInputType.number,
                        ),
                      )
                    else ...[
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _vehiculoAutoCtrl,
                          decoration: const InputDecoration(labelText: 'Descripción Unidad', border: OutlineInputBorder(), isDense: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 90,
                        child: TextField(
                          controller: _modeloAutoCtrl,
                          decoration: const InputDecoration(labelText: 'Modelo', border: OutlineInputBorder(), isDense: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 90,
                        child: TextField(
                          controller: _cpAutoCtrl,
                          decoration: const InputDecoration(labelText: 'C.P.', border: OutlineInputBorder(), isDense: true),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: frec,
                        decoration: const InputDecoration(labelText: 'Frecuencia de Pago', border: OutlineInputBorder(), isDense: true),
                        items: const [
                          DropdownMenuItem(value: 'ANUAL', child: Text('ANUAL (Contado - 1 Pago)')),
                          DropdownMenuItem(value: 'SEMESTRAL', child: Text('SEMESTRAL (2 Pagos)')),
                          DropdownMenuItem(value: 'TRIMESTRAL', child: Text('TRIMESTRAL (4 Pagos)')),
                          DropdownMenuItem(value: 'MENSUAL', child: Text('MENSUAL (12 Pagos)')),
                        ],
                        onChanged: (v) {
                          setState(() {
                            if (esGmm) _frecuenciaGmm = v ?? 'ANUAL';
                            else _frecuenciaAuto = v ?? 'ANUAL';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Row(
                      children: [
                        Switch(
                          value: tieneRed,
                          activeColor: const Color(0xFFD4AF37),
                          onChanged: (v) {
                            setState(() {
                              if (esGmm) _anexarRedEnlaceGmm = v;
                              else _anexarRedEnlaceAuto = v;
                            });
                          },
                        ),
                        const Text('Anexar Beneficios Red Enlace A.C.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF091428))),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Selecciona las Compañías que deseas comparar:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: opciones.map((op) {
              final sel = op['seleccionado'] == true;
              final costo = fMoneda.format(op['primaNetaAnual']);
              return FilterChip(
                label: Text(' () - '),
                selected: sel,
                selectedColor: const Color(0xFF091428),
                labelStyle: TextStyle(color: sel ? const Color(0xFFD4AF37) : const Color(0xFF091428), fontWeight: FontWeight.bold, fontSize: 12),
                onSelected: (val) => setState(() => op['seleccionado'] = val),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text('CUADRO COMPARATIVO MULTIASEGURADORA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
          const SizedBox(height: 12),
          if (seleccionadas.isEmpty)
            Container(
              padding: const EdgeInsets.all(30),
              alignment: Alignment.center,
              child: const Text('Por favor selecciona al menos una aseguradora arriba para ver la tabla comparativa.', style: TextStyle(color: Color(0xFF64748B))),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFCBD5E1))),
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(const Color(0xFF091428)),
                  dataRowMinHeight: 38,
                  dataRowMaxHeight: 48,
                  columns: [
                    const DataColumn(label: Text('CONCEPTO / COBERTURA', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12))),
                    ...seleccionadas.map((o) => DataColumn(
                          label: Text(o['aseguradora'].toString(), style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12)),
                        )),
                  ],
                  rows: [
                    DataRow(cells: [
                      const DataCell(Text('Plan Cotizado', style: TextStyle(fontWeight: FontWeight.bold))),
                      ...seleccionadas.map((o) => DataCell(Text(o['plan'].toString(), style: const TextStyle(fontWeight: FontWeight.w600)))),
                    ]),
                    if (esGmm) ...[
                      DataRow(cells: [
                        const DataCell(Text('Nivel Hospitalario')),
                        ...seleccionadas.map((o) => DataCell(Text(o['gama'].toString()))),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Deducible')),
                        ...seleccionadas.map((o) => DataCell(Text(fMoneda.format(o['deducible'])))),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Coaseguro y Tope')),
                        ...seleccionadas.map((o) => DataCell(Text(' (Tope: )'))),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Urgencias en el Extranjero')),
                        ...seleccionadas.map((o) => DataCell(Text(o['urgencias'].toString()))),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Eliminación Deducible Accidente')),
                        ...seleccionadas.map((o) => DataCell(Text(o['eliminacionAccidente'].toString(), style: TextStyle(color: o['eliminacionAccidente'] == 'INCLUIDO' ? Colors.green : Colors.red, fontWeight: FontWeight.bold)))),
                      ]),
                    ] else ...[
                      DataRow(cells: [
                        const DataCell(Text('Daños Materiales (Deducible)')),
                        ...seleccionadas.map((o) => DataCell(Text(o['deducibleDM'].toString(), style: const TextStyle(fontWeight: FontWeight.w600)))),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Robo Total (Deducible)')),
                        ...seleccionadas.map((o) => DataCell(Text(o['deducibleRobo'].toString()))),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Responsabilidad Civil (L.U.C.)')),
                        ...seleccionadas.map((o) => DataCell(Text(o['rcLuc'].toString()))),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Gastos Médicos Ocupantes')),
                        ...seleccionadas.map((o) => DataCell(Text(o['gastosMedicos'].toString()))),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Asistencia Vial / Grúa')),
                        ...seleccionadas.map((o) => DataCell(Text(o['asistenciaVial'].toString()))),
                      ]),
                    ],
                    DataRow(cells: [
                      const DataCell(Text('Red Enlace A.C.')),
                      ...seleccionadas.map((o) => DataCell(Text(tieneRed ? 'INCLUIDA' : 'NO SELECCIONADA', style: TextStyle(color: tieneRed ? Colors.green : Colors.grey, fontWeight: FontWeight.bold)))),
                    ]),
                    DataRow(
                      color: MaterialStateProperty.all(const Color(0xFFFEF3C7)),
                      cells: [
                        DataCell(Text('PRIMER PAGO (\)', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                        ...seleccionadas.map((o) {
                          final des = _calcularPagos(o['primaNetaAnual'], frec, tieneRed);
                          return DataCell(Text(fMoneda.format(des['primerPago']), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428))));
                        }),
                      ],
                    ),
                    if (frec != 'ANUAL')
                      DataRow(cells: [
                        DataCell(Text('Pagos Subsecuentes (\)')),
                        ...seleccionadas.map((o) {
                          final des = _calcularPagos(o['primaNetaAnual'], frec, tieneRed);
                          return DataCell(Text(fMoneda.format(des['subsecuente']), style: const TextStyle(fontWeight: FontWeight.w600)));
                        }),
                      ]),
                    DataRow(
                      color: MaterialStateProperty.all(const Color(0xFFF1F5F9)),
                      cells: [
                        const DataCell(Text('TOTAL ANUALIZADO', style: TextStyle(fontWeight: FontWeight.bold))),
                        ...seleccionadas.map((o) {
                          final des = _calcularPagos(o['primaNetaAnual'], frec, tieneRed);
                          return DataCell(Text(fMoneda.format(des['total']), style: const TextStyle(fontWeight: FontWeight.bold)));
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
