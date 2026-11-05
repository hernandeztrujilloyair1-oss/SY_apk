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
    {'aseguradora': 'BX+', 'plan': 'PLUS', 'gama': 'GAMA ALTA', 'deducible': 35000.0, 'coaseguro': '10%', 'topeCoaseguro': r'$48,000', 'urgencias': 'EXCLUIDO', 'eliminacionAccidente': 'INCLUIDO', 'primaNetaAnual': 24548.12, 'seleccionado': true},
    {'aseguradora': 'ALLIANZ', 'plan': 'AMPLIA', 'gama': 'GAMA ALTA', 'deducible': 32000.0, 'coaseguro': '10%', 'topeCoaseguro': r'$100,000', 'urgencias': 'INCLUIDO', 'eliminacionAccidente': 'INCLUIDO', 'primaNetaAnual': 30226.67, 'seleccionado': true},
    {'aseguradora': 'GNP', 'plan': 'AMPLIO', 'gama': 'GAMA ALTA', 'deducible': 32000.0, 'coaseguro': '10%', 'topeCoaseguro': r'$75,000', 'urgencias': 'INCLUIDO', 'eliminacionAccidente': 'INCLUIDO', 'primaNetaAnual': 32831.94, 'seleccionado': true},
    {'aseguradora': 'BUPA', 'plan': 'PLUS', 'gama': 'GAMA MEDIA', 'deducible': 37000.0, 'coaseguro': '10%', 'topeCoaseguro': 'SIN LIMITE', 'urgencias': 'EXCLUIDO', 'eliminacionAccidente': 'INCLUIDO', 'primaNetaAnual': 57204.0, 'seleccionado': false},
    {'aseguradora': 'METLIFE', 'plan': 'PLAN EJECUTIVO', 'gama': 'GAMA ALTA', 'deducible': 32000.0, 'coaseguro': '10%', 'topeCoaseguro': r'$100,000', 'urgencias': 'EXCLUIDO', 'eliminacionAccidente': 'INCLUIDO', 'primaNetaAnual': 72367.0, 'seleccionado': false},
    {'aseguradora': 'AXA', 'plan': 'PLUS', 'gama': 'GAMA MEDIA', 'deducible': 72500.0, 'coaseguro': '10%', 'topeCoaseguro': r'$64,000', 'urgencias': 'EXCLUIDO', 'eliminacionAccidente': 'EXCLUIDO', 'primaNetaAnual': 96639.88, 'seleccionado': false},
  ];

  final _opcionesAutos = [
    {'aseguradora': 'MAPFRE', 'plan': 'AMPLIA', 'deducibleDM': '5%', 'deducibleRobo': '10%', 'rcLuc': r'$3,000,000', 'gastosMedicos': r'$200,000', 'asistenciaVial': 'INCLUIDO', 'primaNetaAnual': 7667.72, 'seleccionado': true},
    {'aseguradora': 'AXA', 'plan': 'AMPLIA PLUS', 'deducibleDM': '5%', 'deducibleRobo': '10%', 'rcLuc': r'$4,000,000', 'gastosMedicos': r'$300,000', 'asistenciaVial': 'INCLUIDO', 'primaNetaAnual': 8907.85, 'seleccionado': true},
    {'aseguradora': 'QUALITAS', 'plan': 'AMPLIA', 'deducibleDM': '5%', 'deducibleRobo': '10%', 'rcLuc': r'$3,000,000', 'gastosMedicos': r'$200,000', 'asistenciaVial': 'INCLUIDO (KM 0)', 'primaNetaAnual': 9259.17, 'seleccionado': true},
    {'aseguradora': 'GNP', 'plan': 'PREMIUM', 'deducibleDM': '5%', 'deducibleRobo': '10%', 'rcLuc': r'$4,000,000', 'gastosMedicos': r'$250,000', 'asistenciaVial': 'INCLUIDO', 'primaNetaAnual': 11813.45, 'seleccionado': false},
    {'aseguradora': 'CHUBB', 'plan': 'AMPLIA', 'deducibleDM': '5%', 'deducibleRobo': '10%', 'rcLuc': r'$3,500,000', 'gastosMedicos': r'$200,000', 'asistenciaVial': 'INCLUIDO', 'primaNetaAnual': 12310.0, 'seleccionado': false},
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
    double recargo = frec == 'SEMESTRAL' ? 0.045 : (frec == 'TRIMESTRAL' ? 0.065 : (frec == 'MENSUAL' ? 0.085 : 0.0));
    int divisor = frec == 'SEMESTRAL' ? 2 : (frec == 'TRIMESTRAL' ? 4 : (frec == 'MENSUAL' ? 12 : 1));
    double derecho = frec == 'SEMESTRAL' ? 450.0 : (frec == 'TRIMESTRAL' ? 300.0 : (frec == 'MENSUAL' ? 180.0 : 650.0));
    double netoPeriodo = (base / divisor) * (1 + recargo);
    double ivaPrimer = (netoPeriodo + derecho) * 0.16;
    double ivaSubsec = netoPeriodo * 0.16;
    double primerPago = netoPeriodo + derecho + ivaPrimer;
    double subsecuente = frec == 'ANUAL' ? 0.0 : (netoPeriodo + ivaSubsec);
    double total = frec == 'ANUAL' ? primerPago : (primerPago + (subsecuente * (divisor - 1)));
    return {'primerPago': primerPago, 'subsecuente': subsecuente, 'total': total};
  }

  Future<void> _exportarPdf(bool esGmm) async {
    final seleccionadas = (esGmm ? _opcionesGmm : _opcionesAutos).where((o) => o['seleccionado'] == true).toList();
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
          'accion': esGmm ? 'EXPORTAR_PDF_COMPARATIVO' : 'GENERAR_COMPARATIVA_AUTOS_PDF',
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
      }
    } catch (_) {}
    if (mounted) setState(() => _generandoPdf = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
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
              children: [_modulo(true), _modulo(false)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modulo(bool esGmm) {
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
              Text(
                esGmm ? 'Cotizador GMM Multiaseguradora con Red Enlace' : 'Cotizador de Autos & Pickups Multicompañía',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF091428)),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF091428), foregroundColor: const Color(0xFFD4AF37), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
                icon: _generandoPdf ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 2)) : const Icon(Icons.picture_as_pdf_outlined, size: 18),
                label: const Text('DESCARGAR COMPARATIVO PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: _generandoPdf ? null : () => _exportarPdf(esGmm),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFCBD5E1))),
            child: Row(
              children: [
                Expanded(flex: 3, child: TextField(controller: esGmm ? _clienteGmmCtrl : _clienteAutoCtrl, style: const TextStyle(color: Color(0xFF091428), fontWeight: FontWeight.bold), decoration: InputDecoration(labelText: esGmm ? 'Contratante / Prospecto' : 'Asegurado / Propietario', border: const OutlineInputBorder(), isDense: true))),
                const SizedBox(width: 12),
                if (esGmm)
                  SizedBox(width: 90, child: TextField(controller: _edadGmmCtrl, style: const TextStyle(color: Color(0xFF091428), fontWeight: FontWeight.bold), decoration: const InputDecoration(labelText: 'Edad', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number))
                else ...[
                  Expanded(flex: 3, child: TextField(controller: _vehiculoAutoCtrl, style: const TextStyle(color: Color(0xFF091428), fontWeight: FontWeight.bold), decoration: const InputDecoration(labelText: 'Descripción Unidad', border: OutlineInputBorder(), isDense: true))),
                  const SizedBox(width: 12),
                  SizedBox(width: 80, child: TextField(controller: _modeloAutoCtrl, style: const TextStyle(color: Color(0xFF091428), fontWeight: FontWeight.bold), decoration: const InputDecoration(labelText: 'Modelo', border: OutlineInputBorder(), isDense: true))),
                  const SizedBox(width: 12),
                  SizedBox(width: 80, child: TextField(controller: _cpAutoCtrl, style: const TextStyle(color: Color(0xFF091428), fontWeight: FontWeight.bold), decoration: const InputDecoration(labelText: 'C.P.', border: OutlineInputBorder(), isDense: true))),
                ],
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: frec,
                    style: const TextStyle(color: Color(0xFF091428), fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(labelText: 'Frecuencia de Pago', border: OutlineInputBorder(), isDense: true),
                    items: const [
                      DropdownMenuItem(value: 'ANUAL', child: Text('ANUAL (Contado)', style: TextStyle(color: Color(0xFF091428)))),
                      DropdownMenuItem(value: 'SEMESTRAL', child: Text('SEMESTRAL (2 Pagos)', style: TextStyle(color: Color(0xFF091428)))),
                      DropdownMenuItem(value: 'TRIMESTRAL', child: Text('TRIMESTRAL (4 Pagos)', style: TextStyle(color: Color(0xFF091428)))),
                      DropdownMenuItem(value: 'MENSUAL', child: Text('MENSUAL (12 Pagos)', style: TextStyle(color: Color(0xFF091428)))),
                    ],
                    onChanged: (v) => setState(() {
                      if (esGmm) _frecuenciaGmm = v ?? 'ANUAL';
                      else _frecuenciaAuto = v ?? 'ANUAL';
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    Switch(value: tieneRed, activeColor: const Color(0xFFD4AF37), onChanged: (v) => setState(() {
                      if (esGmm) _anexarRedEnlaceGmm = v;
                      else _anexarRedEnlaceAuto = v;
                    })),
                    const Text('Red Enlace A.C.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF091428))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Selecciona las Compañías a comparar:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: opciones.map((op) {
              final sel = op['seleccionado'] == true;
              final costo = fMoneda.format(op['primaNetaAnual']);
              return FilterChip(
                label: Text(op['aseguradora'].toString() + ' (' + op['plan'].toString() + ') - ' + costo),
                selected: sel,
                selectedColor: const Color(0xFF091428),
                backgroundColor: Colors.white,
                side: BorderSide(color: sel ? const Color(0xFFD4AF37) : const Color(0xFFCBD5E1)),
                labelStyle: TextStyle(color: sel ? const Color(0xFFD4AF37) : const Color(0xFF091428), fontWeight: FontWeight.bold, fontSize: 12),
                onSelected: (val) => setState(() => op['seleccionado'] = val),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text('CUADRO COMPARATIVO MULTIASEGURADORA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF091428), width: 1.5)),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFF091428)),
                dataRowMinHeight: 38,
                dataRowMaxHeight: 46,
                columns: [
                  const DataColumn(label: Text('CONCEPTO / COBERTURA', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12))),
                  ...seleccionadas.map((o) => DataColumn(label: Text(o['aseguradora'].toString(), style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 13)))),
                ],
                rows: [
                  DataRow(cells: [
                    const DataCell(Text('Plan Cotizado', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                    ...seleccionadas.map((o) => DataCell(Text(o['plan'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428))))),
                  ]),
                  if (esGmm) ...[
                    DataRow(cells: [
                      const DataCell(Text('Nivel Hospitalario', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                      ...seleccionadas.map((o) => DataCell(Text(o['gama'].toString(), style: const TextStyle(color: Color(0xFF091428), fontWeight: FontWeight.w600)))),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text('Deducible', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                      ...seleccionadas.map((o) => DataCell(Text(fMoneda.format(o['deducible']), style: const TextStyle(color: Color(0xFF091428), fontWeight: FontWeight.w600)))),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text('Coaseguro y Tope', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                      ...seleccionadas.map((o) => DataCell(Text(o['coaseguro'].toString() + ' (Tope: ' + o['topeCoaseguro'].toString() + ')', style: const TextStyle(color: Color(0xFF091428), fontWeight: FontWeight.w600)))),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text('Urgencias en el Extranjero', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                      ...seleccionadas.map((o) => DataCell(Text(o['urgencias'].toString(), style: const TextStyle(color: Color(0xFF091428), fontWeight: FontWeight.w600)))),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text('Eliminación Deducible Accidente', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                      ...seleccionadas.map((o) => DataCell(Text(o['eliminacionAccidente'].toString(), style: TextStyle(color: o['eliminacionAccidente'] == 'INCLUIDO' ? const Color(0xFF059669) : Colors.red, fontWeight: FontWeight.bold)))),
                    ]),
                  ] else ...[
                    DataRow(cells: [
                      const DataCell(Text('Daños Materiales (Deducible)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                      ...seleccionadas.map((o) => DataCell(Text(o['deducibleDM'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428))))),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text('Robo Total (Deducible)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                      ...seleccionadas.map((o) => DataCell(Text(o['deducibleRobo'].toString(), style: const TextStyle(color: Color(0xFF091428), fontWeight: FontWeight.w600)))),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text('Responsabilidad Civil (L.U.C.)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                      ...seleccionadas.map((o) => DataCell(Text(o['rcLuc'].toString(), style: const TextStyle(color: Color(0xFF091428), fontWeight: FontWeight.w600)))),
                    ]),
                  ],
                  DataRow(cells: [
                    const DataCell(Text('Red Enlace A.C.', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                    ...seleccionadas.map((o) => DataCell(Text(tieneRed ? 'INCLUIDA' : 'NO SELECCIONADA', style: TextStyle(color: tieneRed ? const Color(0xFF059669) : Colors.grey, fontWeight: FontWeight.bold)))),
                  ]),
                  DataRow(
                    color: WidgetStateProperty.all(const Color(0xFFFEF3C7)),
                    cells: [
                      DataCell(Text('PRIMER PAGO (' + frec + ')', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                      ...seleccionadas.map((o) {
                        final des = _calcularPagos(o['primaNetaAnual'], frec, tieneRed);
                        return DataCell(Text(fMoneda.format(des['primerPago']), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428), fontSize: 13)));
                      }),
                    ],
                  ),
                  if (frec != 'ANUAL')
                    DataRow(
                      color: WidgetStateProperty.all(const Color(0xFFFFFBEB)),
                      cells: [
                        DataCell(Text('Pagos Subsecuentes (' + frec + ')', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                        ...seleccionadas.map((o) {
                          final des = _calcularPagos(o['primaNetaAnual'], frec, tieneRed);
                          return DataCell(Text(fMoneda.format(des['subsecuente']), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428))));
                        }),
                      ],
                    ),
                  DataRow(
                    color: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                    cells: [
                      const DataCell(Text('TOTAL ANUALIZADO', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                      ...seleccionadas.map((o) {
                        final des = _calcularPagos(o['primaNetaAnual'], frec, tieneRed);
                        return DataCell(Text(fMoneda.format(des['total']), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669), fontSize: 13)));
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
