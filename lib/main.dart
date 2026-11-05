import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:html' as html;
import 'config/api_config.dart';

void main() {
  runApp(const EnfoqueSeguroApp());
}

class EnfoqueSeguroApp extends StatelessWidget {
  const EnfoqueSeguroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enfoque Seguro | Power BI & Cartera',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Segoe UI',
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        primaryColor: const Color(0xFF091428),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF091428),
          primary: const Color(0xFF091428),
          secondary: const Color(0xFFD4AF37),
        ),
      ),
      home: const MasterDashboardPage(),
    );
  }
}

class MasterDashboardPage extends StatefulWidget {
  const MasterDashboardPage({super.key});

  @override
  State<MasterDashboardPage> createState() => _MasterDashboardPageState();
}

class _MasterDashboardPageState extends State<MasterDashboardPage> with SingleTickerProviderStateMixin {
  final fMoneda = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
  int _seccionActual = 0;
  bool _cargando = true;

  Map<String, dynamic> _kpis = {
    'totalPolizas': 7025,
    'polizasVigentes': 981,
    'polizasCanceladas': 2015,
    'clientesUnicos': 1881,
    'primaTotalCartera': 296433000.0,
    'recibosPendientes': 1954,
    'importeCobranzaMora': 24680600.0,
  };
  Map<String, dynamic> _cobranzaAvisos = {'1°': 412, '2°': 320, '3°': 184, 'SR RAUL': 95};

  List<dynamic> _polizas = [];
  List<dynamic> _recibos = [];
  List<dynamic> _aseguradoras = [];
  Map<String, Map<String, dynamic>> _contratantesMap = {};

  final TextEditingController _searchCtrl = TextEditingController();
  String _busqueda = '';

  late TabController _tabCotizador;
  final _clienteGmmCtrl = TextEditingController(text: 'María Esther Ramos');
  final _edadGmmCtrl = TextEditingController(text: '45');
  String _frecuenciaGmm = 'ANUAL';
  bool _anexarRedGmm = true;

  final _clienteAutoCtrl = TextEditingController(text: 'Luz María López');
  final _vehiculoAutoCtrl = TextEditingController(text: 'JETTA A4 GLS TURBO L4 TELA');
  final _modeloAutoCtrl = TextEditingController(text: '2021');
  final _cpAutoCtrl = TextEditingController(text: '08200');
  String _frecuenciaAuto = 'MENSUAL';
  bool _anexarRedAuto = true;
  bool _generandoPdf = false;

  final _opcionesGmm = [
    {'aseguradora': 'BX+', 'plan': 'PLUS', 'gama': 'GAMA ALTA', 'deducible': 35000.0, 'coaseguro': '10%', 'tope': r'$48,000', 'urgencias': 'EXCLUIDO', 'prima': 24548.12, 'sel': true},
    {'aseguradora': 'ALLIANZ', 'plan': 'AMPLIA', 'gama': 'GAMA ALTA', 'deducible': 32000.0, 'coaseguro': '10%', 'tope': r'$100,000', 'urgencias': 'INCLUIDO', 'prima': 30226.67, 'sel': true},
    {'aseguradora': 'GNP', 'plan': 'AMPLIO', 'gama': 'GAMA ALTA', 'deducible': 32000.0, 'coaseguro': '10%', 'tope': r'$75,000', 'urgencias': 'INCLUIDO', 'prima': 32831.94, 'sel': true},
    {'aseguradora': 'BUPA', 'plan': 'PLUS', 'gama': 'GAMA MEDIA', 'deducible': 37000.0, 'coaseguro': '10%', 'tope': 'SIN LIMITE', 'urgencias': 'EXCLUIDO', 'prima': 57204.0, 'sel': false},
    {'aseguradora': 'METLIFE', 'plan': 'PLAN EJECUTIVO', 'gama': 'GAMA ALTA', 'deducible': 32000.0, 'coaseguro': '10%', 'tope': r'$100,000', 'urgencias': 'EXCLUIDO', 'prima': 72367.0, 'sel': false},
    {'aseguradora': 'AXA', 'plan': 'PLUS', 'gama': 'GAMA MEDIA', 'deducible': 72500.0, 'coaseguro': '10%', 'tope': r'$64,000', 'urgencias': 'EXCLUIDO', 'prima': 96639.88, 'sel': false},
  ];

  final _opcionesAutos = [
    {'aseguradora': 'MAPFRE', 'plan': 'AMPLIA', 'deducibleDM': '5%', 'deducibleRobo': '10%', 'rcLuc': r'$3,000,000', 'gastosMedicos': r'$200,000', 'prima': 7667.72, 'sel': true},
    {'aseguradora': 'AXA', 'plan': 'AMPLIA PLUS', 'deducibleDM': '5%', 'deducibleRobo': '10%', 'rcLuc': r'$4,000,000', 'gastosMedicos': r'$300,000', 'prima': 8907.85, 'sel': true},
    {'aseguradora': 'QUALITAS', 'plan': 'AMPLIA', 'deducibleDM': '5%', 'deducibleRobo': '10%', 'rcLuc': r'$3,000,000', 'gastosMedicos': r'$200,000', 'prima': 9259.17, 'sel': true},
    {'aseguradora': 'GNP', 'plan': 'PREMIUM', 'deducibleDM': '5%', 'deducibleRobo': '10%', 'rcLuc': r'$4,000,000', 'gastosMedicos': r'$250,000', 'prima': 11813.45, 'sel': false},
    {'aseguradora': 'CHUBB', 'plan': 'AMPLIA', 'deducibleDM': '5%', 'deducibleRobo': '10%', 'rcLuc': r'$3,500,000', 'gastosMedicos': r'$200,000', 'prima': 12310.0, 'sel': false},
  ];

  @override
  void initState() {
    super.initState();
    _tabCotizador = TabController(length: 2, vsync: this);
    _cargarTodo();
  }

  @override
  void dispose() {
    _tabCotizador.dispose();
    super.dispose();
  }

  Future<void> _cargarTodo() async {
    setState(() => _cargando = true);
    try {
      final resKpi = await http.get(Uri.parse('${ApiConfig.appsScriptUrl}?accion=KPI_DASHBOARD'));
      if (resKpi.statusCode == 200) {
        final data = jsonDecode(resKpi.body);
        if (data is Map && data['kpis'] != null) {
          _kpis = Map<String, dynamic>.from(data['kpis']);
          if (data['cobranzaAvisos'] != null) {
            _cobranzaAvisos = Map<String, dynamic>.from(data['cobranzaAvisos']);
          }
        }
      }

      final resCias = await http.get(Uri.parse('${ApiConfig.appsScriptUrl}?accion=GRAFICA_ASEGURADORAS'));
      if (resCias.statusCode == 200) {
        final data = jsonDecode(resCias.body);
        if (data is List) _aseguradoras = data;
      }

      final resPol = await http.get(Uri.parse('${ApiConfig.appsScriptUrl}?tabla=POLIZAS'));
      if (resPol.statusCode == 200) {
        final data = jsonDecode(resPol.body);
        if (data is List) {
          _polizas = data;
          _agruparContratantes();
        }
      }

      final resRec = await http.get(Uri.parse('${ApiConfig.appsScriptUrl}?tabla=RECIBOS_COBRANZA'));
      if (resRec.statusCode == 200) {
        final data = jsonDecode(resRec.body);
        if (data is List) _recibos = data;
      }
    } catch (_) {}
    if (mounted) setState(() => _cargando = false);
  }

  void _agruparContratantes() {
    final Map<String, Map<String, dynamic>> map = {};
    for (var p in _polizas) {
      final nom = (p['Contratante'] ?? p['contratante'] ?? 'CLIENTE GENERAL').toString().trim();
      if (nom.isEmpty || nom.toLowerCase() == 'contratante') continue;

      if (!map.containsKey(nom)) {
        map[nom] = {
          'nombre': nom,
          'rfc': (p['RFC'] ?? p['rfc'] ?? '').toString().trim(),
          'telefono': (p['Telefono_WhatsApp'] ?? p['WhatsApp'] ?? p['telefono'] ?? '').toString().trim(),
          'correo': (p['Correo'] ?? p['correo'] ?? '').toString().trim(),
          'polizas': >[],
          'totalPrima': 0.0,
        };
      }
      final prima = double.tryParse((p['Prima_Total'] ?? p['primaTotal'] ?? '0').toString().replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0.0;
      map[nom]!['totalPrima'] = (map[nom]!['totalPrima'] as double) + prima;
      (map[nom]!['polizas'] as List>).add(Map<String, dynamic>.from(p));
    }
    _contratantesMap = map;
  }

  Future<void> _actualizarEstatusPoliza(String numPoliza, String nuevoEstatus) async {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Actualizando póliza $numPoliza a: $nuevoEstatus...'), backgroundColor: const Color(0xFF091428)),
    );
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.appsScriptUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accion': 'ACTUALIZAR_ESTATUS_POLIZA',
          'poliza': numPoliza,
          'nuevoEstatus': nuevoEstatus,
        }),
      );
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Póliza $numPoliza actualizada a $nuevoEstatus'), backgroundColor: const Color(0xFF059669)),
        );
        _cargarTodo();
      }
    } catch (_) {}
  }

  Map<String, double> _calcularPagos(dynamic primaRaw, String frec, bool tieneRed) {
    double prima = (primaRaw is num) ? primaRaw.toDouble() : (double.tryParse(primaRaw.toString()) ?? 0.0);
    double base = prima + (tieneRed ? 1450.0 : 0.0);
    double recargo = frec == 'SEMESTRAL' ? 0.045 : (frec == 'TRIMESTRAL' ? 0.065 : (frec == 'MENSUAL' ? 0.085 : 0.0));
    int divisor = frec == 'SEMESTRAL' ? 2 : (frec == 'TRIMESTRAL' ? 4 : (frec == 'MENSUAL' ? 12 : 1));
    double derecho = frec == 'SEMESTRAL' ? 450.0 : (frec == 'TRIMESTRAL' ? 300.0 : (frec == 'MENSUAL' ? 180.0 : 650.0));
    double neto = (base / divisor) * (1 + recargo);
    double p1 = neto + derecho + ((neto + derecho) * 0.16);
    double sub = frec == 'ANUAL' ? 0.0 : (neto + (neto * 0.16));
    double total = frec == 'ANUAL' ? p1 : (p1 + (sub * (divisor - 1)));
    return {'primerPago': p1, 'subsecuente': sub, 'total': total};
  }

  Future<void> _exportarPdf(bool esGmm) async {
    final seleccionadas = (esGmm ? _opcionesGmm : _opcionesAutos).where((o) => o['sel'] == true).toList();
    if (seleccionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona al menos una compañía para comparar.')));
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
          'frecuencia': esGmm ? _frecuenciaGmm : _frecuenciaAuto,
          'anexarRedEnlace': esGmm ? _anexarRedGmm : _anexarRedAuto,
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

  void _abrirModalIa({String? polizaOrigen, String? contratanteOrigen, String? aseguradoraOrigen, String? rfcOrigen}) {
    showDialog(
      context: context,
      builder: (ctx) => _DialogoCapturaIa(
        polizaOrigen: polizaOrigen,
        contratanteOrigen: contratanteOrigen,
        aseguradoraOrigen: aseguradoraOrigen,
        rfcOrigen: rfcOrigen,
        onGuardadoExitoso: _cargarTodo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 260,
            color: const Color(0xFF091428),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(0xFFD4AF37),
                        radius: 18,
                        child: Text('E', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428))),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Enfoque Seguro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            Text('Control Integral & Power BI', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFF1E293B), height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _itemSidebar(0, Icons.dashboard_outlined, 'DASHBOARD POWER BI'),
                      _itemSidebar(1, Icons.people_alt_outlined, 'CONTRATANTES (A - Z)'),
                      _itemSidebar(2, Icons.attach_money_rounded, 'COBRANZA & MORA'),
                      _itemSidebar(3, Icons.calculate_outlined, 'COTIZADOR SEGUROS'),
                      _itemSidebar(4, Icons.fact_check_outlined, 'AUDITORÍA DE PORTALES'),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF060D1A),
                  child: const Row(
                    children: [
                      CircleAvatar(backgroundColor: Color(0xFFD4AF37), radius: 14, child: Text('R', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Raúl Martínez', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('DIRECTOR GENERAL', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Column(
              children: [
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
                  child: Row(
                    children: [
                      const Text('SISTEMA INTEGRAL DE CONTROL DE CARTERA', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
                      const Spacer(),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF091428),
                          foregroundColor: const Color(0xFFD4AF37),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.auto_awesome, size: 16),
                        label: const Text('CARGAR PÓLIZA CON IA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: () => _abrirModalIa(),
                      ),
                      const SizedBox(width: 12),
                      IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF091428)), onPressed: _cargarTodo, tooltip: 'Recargar Datos'),
                    ],
                  ),
                ),
                Expanded(
                  child: _cargando
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF091428)))
                      : _renderSeccion(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemSidebar(int index, IconData icon, String label) {
    final sel = _seccionActual == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: sel ? const Color(0xFF1E293B) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: sel ? Border.all(color: const Color(0xFFD4AF37), width: 0.8) : null,
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: sel ? const Color(0xFFD4AF37) : const Color(0xFF94A3B8), size: 18),
        title: Text(label, style: TextStyle(color: sel ? Colors.white : const Color(0xFF94A3B8), fontWeight: sel ? FontWeight.bold : FontWeight.w500, fontSize: 11)),
        onTap: () => setState(() => _seccionActual = index),
      ),
    );
  }

  Widget _renderSeccion() {
    switch (_seccionActual) {
      case 0:
        return _vistaDashboardPowerBi();
      case 1:
        return _vistaContratantesAZ();
      case 2:
        return _vistaCobranzaSemaforo();
      case 3:
        return _vistaCotizadores();
      case 4:
        return _vistaAuditoriaPortales();
      default:
        return _vistaDashboardPowerBi();
    }
  }

  Widget _vistaDashboardPowerBi() {
    final vigentes = _kpis['polizasVigentes'] ?? 981;
    final clientes = _kpis['clientesUnicos'] ?? 1881;
    final primaTotal = (_kpis['primaTotalCartera'] is num) ? (_kpis['primaTotalCartera'] as num).toDouble() : 296433000.0;
    final recibosPend = _kpis['recibosPendientes'] ?? 1954;
    final importeMora = (_kpis['importeCobranzaMora'] is num) ? (_kpis['importeCobranzaMora'] as num).toDouble() : 24680600.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _kpiCard('Pólizas Vigentes Vivas', '$vigentes Pólizas', 'Cartera Activa al Corriente', Icons.verified_user_outlined, const Color(0xFF059669), const Color(0xFFECFDF5)),
              const SizedBox(width: 14),
              _kpiCard('Primas Totales Cartera', fMoneda.format(primaTotal), 'Monto Consolidado Global', Icons.account_balance_wallet_outlined, const Color(0xFF091428), Colors.white),
              const SizedBox(width: 14),
              _kpiCard('Clientes Únicos (RFC)', '$clientes Registros', 'Directorio Consolidado', Icons.people_outline, const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
              const SizedBox(width: 14),
              _kpiCard('Cobranza en Mora', '$recibosPend Recibos', fMoneda.format(importeMora), Icons.warning_amber_rounded, const Color(0xFFDC2626), const Color(0xFFFEF2F2)),
            ],
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFCBD5E1))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.traffic_outlined, color: Color(0xFF091428), size: 18),
                    SizedBox(width: 8),
                    Text('SEMÁFORO DE COBRANZA (AVISOS 1°, 2°, 3°, SR RAÚL)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF091428))),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _semaforoBadge('1° Aviso (1-10 días)', _cobranzaAvisos['1°'] ?? 412, const Color(0xFF059669), const Color(0xFFECFDF5)),
                    const SizedBox(width: 12),
                    _semaforoBadge('2° Aviso (11-20 días)', _cobranzaAvisos['2°'] ?? 320, const Color(0xFFD97706), const Color(0xFFFFFBEB)),
                    const SizedBox(width: 12),
                    _semaforoBadge('3° Aviso (21-30 días)', _cobranzaAvisos['3°'] ?? 184, const Color(0xFFDC2626), const Color(0xFFFEF2F2)),
                    const SizedBox(width: 12),
                    _semaforoBadge('SR RAÚL (>30 días Mora)', _cobranzaAvisos['SR RAUL'] ?? 95, Colors.purple, const Color(0xFFFAF5FF)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text('DISTRIBUCIÓN DE CARTERA POR ASEGURADORA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFCBD5E1))),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFF091428)),
              dataRowMinHeight: 38,
              dataRowMaxHeight: 44,
              columns: const [
                DataColumn(label: Text('COMPAÑÍA ASEGURADORA', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('PÓLIZAS TOTALES', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('VIGENTES', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('CANCELADAS', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('PRIMA TOTAL (MXN)', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
              ],
              rows: _aseguradoras.take(10).map((a) {
                final prima = double.tryParse((a['primaTotal'] ?? '0').toString()) ?? 0.0;
                return DataRow(cells: [
                  DataCell(Text(a['aseguradora'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                  DataCell(Text(a['totalPolizas'].toString(), style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF091428)))),
                  DataCell(Text(a['vigentes'].toString(), style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold))),
                  DataCell(Text(a['canceladas'].toString(), style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w600))),
                  DataCell(Text(fMoneda.format(prima), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiCard(String tit, String val, String sub, IconData ico, Color c, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFCBD5E1))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(tit, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))), Icon(ico, color: c, size: 20)]),
            const SizedBox(height: 8),
            Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
            const SizedBox(height: 2),
            Text(sub, style: TextStyle(fontSize: 10, color: c, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _semaforoBadge(String tit, dynamic cant, Color c, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: c.withOpacity(0.3))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tit, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: c)),
            const SizedBox(height: 4),
            Text('$cant Recibos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c)),
          ],
        ),
      ),
    );
  }

  Widget _vistaContratantesAZ() {
    final list = _contratantesMap.values.where((c) {
      if (_busqueda.isEmpty) return true;
      final q = _busqueda.toLowerCase();
      return c['nombre'].toString().toLowerCase().contains(q) ||
          c['rfc'].toString().toLowerCase().contains(q) ||
          c['telefono'].toString().toLowerCase().contains(q);
    }).toList();

    list.sort((a, b) => a['nombre'].toString().toLowerCase().compareTo(b['nombre'].toString().toLowerCase()));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Directorio de Contratantes (A - Z): ${list.length} Clientes', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
              SizedBox(
                width: 320,
                height: 40,
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF091428)),
                  onChanged: (val) => setState(() => _busqueda = val.trim()),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, RFC o teléfono...',
                    hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search, size: 16, color: Color(0xFF64748B)),
                    suffixIcon: _busqueda.isNotEmpty ? IconButton(icon: const Icon(Icons.close, size: 14), onPressed: () { _searchCtrl.clear(); setState(() => _busqueda = ''); }) : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (ctx, idx) {
                final c = list[idx];
                final nombre = c['nombre'].toString();
                final pols = (c['polizas'] as List).length;
                final prima = c['totalPrima'] as double;
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFFCBD5E1))),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF091428),
                      radius: 18,
                      child: Text(nombre.isNotEmpty ? nombre[0].toUpperCase() : 'C', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                    ),
                    title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF091428))),
                    subtitle: Text('RFC: ${c['rfc']}  •  Tel: ${c['telefono']}  •  ${c['correo']}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('$pols pólizas', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF091428))),
                            Text(fMoneda.format(prima), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF059669))),
                          ],
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                      ],
                    ),
                    onTap: () => _abrirExpedienteModal(c),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _abrirExpedienteModal(Map<String, dynamic> c) {
    final polizas = c['polizas'] as List>;
    final nombreCliente = c['nombre'].toString();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          width: 950,
          constraints: const BoxConstraints(maxHeight: 720),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)]),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                decoration: const BoxDecoration(color: Color(0xFF091428), borderRadius: BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14))),
                child: Row(
                  children: [
                    CircleAvatar(backgroundColor: const Color(0xFFD4AF37), radius: 20, child: Text(nombreCliente.isNotEmpty ? nombreCliente[0].toUpperCase() : 'C', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nombreCliente, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text('RFC: ${c['rfc']}  •  Tel: ${c['telefono']}  •  ${c['correo']}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.of(ctx).pop()),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(18),
                  itemCount: polizas.length,
                  itemBuilder: (context, i) {
                    final p = polizas[i];
                    final numPol = (p['No_Poliza'] ?? p['poliza'] ?? '').toString();
                    final cia = (p['Aseguradora'] ?? p['compania'] ?? 'QUALITAS').toString();
                    final ramo = (p['Subramo'] ?? p['ramo'] ?? 'Seguro').toString();
                    final estatus = (p['Estatus'] ?? p['Estatus_Poliza'] ?? 'Vigente').toString();
                    final vFin = (p['Fin_Vigencia'] ?? p['vigenciaFin'] ?? '').toString();
                    final prima = double.tryParse((p['Prima_Total'] ?? p['primaTotal'] ?? '0').toString().replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0.0;
                    final recibosPol = _recibos.where((r) => (r['No_Poliza'] ?? r['poliza'] ?? '').toString() == numPol).toList();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFCBD5E1))),
                      child: ExpansionTile(
                        initiallyExpanded: i == 0,
                        leading: const Icon(Icons.shield_outlined, color: Color(0xFF091428)),
                        title: Row(
                          children: [
                            Text(numPol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF091428))),
                            const SizedBox(width: 8),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF091428), borderRadius: BorderRadius.circular(4)), child: Text(cia.toUpperCase(), style: const TextStyle(fontSize: 10, color: Color(0xFFD4AF37), fontWeight: FontWeight.bold))),
                            const SizedBox(width: 8),
                            Text(estatus, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: estatus.toLowerCase().contains('vig') ? const Color(0xFF059669) : Colors.red)),
                          ],
                        ),
                        subtitle: Text('Ramo: $ramo  •  Vence: $vFin  •  Prima: ${fMoneda.format(prima)}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        children: [
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF091428), foregroundColor: const Color(0xFFD4AF37), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                                      icon: const Icon(Icons.auto_awesome, size: 14),
                                      label: const Text('RENOVAR CON IA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                        _abrirModalIa(polizaOrigen: numPol, contratanteOrigen: nombreCliente, aseguradoraOrigen: cia, rfcOrigen: c['rfc'].toString());
                                      },
                                    ),
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF091428), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                                      icon: const Icon(Icons.edit_note, size: 14),
                                      label: const Text('RENOVAR MANUAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      onPressed: () => _actualizarEstatusPoliza(numPol, 'RENOVACIÓN MANUAL'),
                                    ),
                                    TextButton.icon(
                                      icon: const Icon(Icons.pause_circle_outline, size: 14, color: Colors.orange),
                                      label: const Text('PAUSAR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange)),
                                      onPressed: () => _actualizarEstatusPoliza(numPol, 'PAUSADA'),
                                    ),
                                    TextButton.icon(
                                      icon: const Icon(Icons.play_circle_outline, size: 14, color: Colors.green),
                                      label: const Text('ACTIVAR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                                      onPressed: () => _actualizarEstatusPoliza(numPol, 'ACTIVA'),
                                    ),
                                    TextButton.icon(
                                      icon: const Icon(Icons.cancel_outlined, size: 14, color: Colors.red),
                                      label: const Text('CANCELAR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
                                      onPressed: () => _actualizarEstatusPoliza(numPol, 'CANCELADA'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                                        child: const Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('ENDOSOS REGISTRADOS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
                                            SizedBox(height: 2),
                                            Text('Sin endosos modificatorios activos.', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFFECACA))),
                                        child: const Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('SINIESTROS REPORTADOS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red)),
                                            SizedBox(height: 2),
                                            Text('0 siniestros abiertos. Expediente limpio.', style: TextStyle(fontSize: 10, color: Color(0xFF991B1B))),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                const Text('HISTÓRICO DE RECIBOS Y PAGOS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
                                const SizedBox(height: 6),
                                if (recibosPol.isEmpty)
                                  const Text('No hay recibos pendientes en este ciclo.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B)))
                                else
                                  Table(
                                    border: TableBorder.all(color: const Color(0xFFCBD5E1)),
                                    children: [
                                      const TableRow(
                                        decoration: BoxDecoration(color: Color(0xFFF1F5F9)),
                                        children: [
                                          Padding(padding: EdgeInsets.all(5), child: Text('Serie', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF091428)))),
                                          Padding(padding: EdgeInsets.all(5), child: Text('Vencimiento', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF091428)))),
                                          Padding(padding: EdgeInsets.all(5), child: Text('Importe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF091428)))),
                                          Padding(padding: EdgeInsets.all(5), child: Text('Aviso', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF091428)))),
                                        ],
                                      ),
                                      ...recibosPol.map((r) {
                                        final imp = double.tryParse((r['Prima_Total'] ?? r['Importe_Total'] ?? '0').toString().replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0.0;
                                        return TableRow(
                                          children: [
                                            Padding(padding: const EdgeInsets.all(5), child: Text((r['Serie_Recibo'] ?? '1/1').toString(), style: const TextStyle(fontSize: 10, color: Color(0xFF091428)))),
                                            Padding(padding: const EdgeInsets.all(5), child: Text((r['Fecha_Limite_Pago'] ?? '').toString(), style: const TextStyle(fontSize: 10, color: Color(0xFF091428)))),
                                            Padding(padding: const EdgeInsets.all(5), child: Text(fMoneda.format(imp), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                                            Padding(padding: const EdgeInsets.all(5), child: Text((r['Aviso_Seguimiento'] ?? 'AL CORRIENTE').toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vistaCobranzaSemaforo() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tablero de Cobranza & Avisos de Pago', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _recibos.length,
              itemBuilder: (ctx, i) {
                final r = _recibos[i];
                final pol = (r['No_Poliza'] ?? '').toString();
                final cont = (r['Contratante'] ?? '').toString();
                final aviso = (r['Aviso_Seguimiento'] ?? '1°').toString();
                final imp = double.tryParse((r['Prima_Total'] ?? '0').toString()) ?? 0.0;
                final mora = (r['Dias_Mora'] ?? 0).toString();

                Color cAviso = const Color(0xFF059669);
                if (aviso == '2°') cAviso = const Color(0xFFD97706);
                if (aviso == '3°') cAviso = const Color(0xFFDC2626);
                if (aviso == 'SR RAUL') cAviso = Colors.purple;

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFFCBD5E1))),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: cAviso.withOpacity(0.15),
                      child: Text(aviso, style: TextStyle(fontWeight: FontWeight.bold, color: cAviso, fontSize: 11)),
                    ),
                    title: Text('$cont  •  Póliza: $pol', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF091428))),
                    subtitle: Text('Días Mora: $mora días  •  Vence: ${r['Fecha_Limite_Pago']}  •  Tel: ${r['Telefono_WhatsApp']}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    trailing: Text(fMoneda.format(imp), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF091428))),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _vistaCotizadores() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabCotizador,
            labelColor: const Color(0xFF091428),
            indicatorColor: const Color(0xFFD4AF37),
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'GASTOS MÉDICOS MAYORES (GMM)'),
              Tab(text: 'SEGURO DE AUTOMÓVILES / PICKUPS'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabCotizador,
            children: [
              _moduloCotizador(true),
              _moduloCotizador(false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _moduloCotizador(bool esGmm) {
    final opciones = esGmm ? _opcionesGmm : _opcionesAutos;
    final seleccionadas = opciones.where((o) => o['sel'] == true).toList();
    final frec = esGmm ? _frecuenciaGmm : _frecuenciaAuto;
    final tieneRed = esGmm ? _anexarRedGmm : _anexarRedAuto;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(esGmm ? 'Cotizador GMM con Red Enlace A.C.' : 'Cotizador de Autos & Pickups', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF091428), foregroundColor: const Color(0xFFD4AF37), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12)),
                icon: _generandoPdf ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 2)) : const Icon(Icons.picture_as_pdf_outlined, size: 16),
                label: const Text('DESCARGAR COMPARATIVO PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
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
                Expanded(flex: 3, child: TextField(controller: esGmm ? _clienteGmmCtrl : _clienteAutoCtrl, style: const TextStyle(color: Color(0xFF091428), fontWeight: FontWeight.bold), decoration: InputDecoration(labelText: esGmm ? 'Prospecto' : 'Asegurado', border: const OutlineInputBorder(), isDense: true))),
                const SizedBox(width: 12),
                if (esGmm)
                  SizedBox(width: 90, child: TextField(controller: _edadGmmCtrl, style: const TextStyle(color: Color(0xFF091428), fontWeight: FontWeight.bold), decoration: const InputDecoration(labelText: 'Edad', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number))
                else ...[
                  Expanded(flex: 3, child: TextField(controller: _vehiculoAutoCtrl, style: const TextStyle(color: Color(0xFF091428), fontWeight: FontWeight.bold), decoration: const InputDecoration(labelText: 'Vehículo', border: OutlineInputBorder(), isDense: true))),
                  const SizedBox(width: 12),
                  SizedBox(width: 80, child: TextField(controller: _modeloAutoCtrl, style: const TextStyle(color: Color(0xFF091428), fontWeight: FontWeight.bold), decoration: const InputDecoration(labelText: 'Modelo', border: OutlineInputBorder(), isDense: true))),
                ],
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: frec,
                    style: const TextStyle(color: Color(0xFF091428), fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(labelText: 'Forma de Pago', border: OutlineInputBorder(), isDense: true),
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
                      if (esGmm) _anexarRedGmm = v;
                      else _anexarRedAuto = v;
                    })),
                    const Text('Red Enlace A.C.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF091428))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('Selecciona las compañías a cotejar:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: opciones.map((op) {
              final sel = op['sel'] == true;
              final costo = fMoneda.format(op['prima']);
              return FilterChip(
                label: Text('${op['aseguradora']} (${op['plan']}) - $costo'),
                selected: sel,
                selectedColor: const Color(0xFF091428),
                backgroundColor: Colors.white,
                side: BorderSide(color: sel ? const Color(0xFFD4AF37) : const Color(0xFFCBD5E1)),
                labelStyle: TextStyle(color: sel ? const Color(0xFFD4AF37) : const Color(0xFF091428), fontWeight: FontWeight.bold, fontSize: 11),
                onSelected: (val) => setState(() => op['sel'] = val),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          const Text('CUADRO COMPARATIVO MULTICOMPAÑÍA', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
          const SizedBox(height: 10),
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
                  ...seleccionadas.map((o) => DataColumn(label: Text(o['aseguradora'].toString(), style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12)))),
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
                      ...seleccionadas.map((o) => DataCell(Text('${o['coaseguro']} (Tope: ${o['tope']})', style: const TextStyle(color: Color(0xFF091428), fontWeight: FontWeight.w600)))),
                    ]),
                  ] else ...[
                    DataRow(cells: [
                      const DataCell(Text('Daños Materiales', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                      ...seleccionadas.map((o) => DataCell(Text(o['deducibleDM'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428))))),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text('Robo Total', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                      ...seleccionadas.map((o) => DataCell(Text(o['deducibleRobo'].toString(), style: const TextStyle(color: Color(0xFF091428), fontWeight: FontWeight.w600)))),
                    ]),
                  ],
                  DataRow(cells: [
                    const DataCell(Text('Red Enlace A.C.', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                    ...seleccionadas.map((o) => DataCell(Text(tieneRed ? 'INCLUIDA' : 'NO SELECCIONADA', style: TextStyle(color: tieneRed ? const Color(0xFF059669) : Colors.grey, fontWeight: FontWeight.bold)))),
                  ]),
                  DataRow(
                    color: WidgetStateProperty.all(const Color(0xFFFEF3C7)),
                    cells: [
                      DataCell(Text('PRIMER PAGO ($frec)', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                      ...seleccionadas.map((o) {
                        final des = _calcularPagos(o['prima'], frec, tieneRed);
                        return DataCell(Text(fMoneda.format(des['primerPago']), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428), fontSize: 13)));
                      }),
                    ],
                  ),
                  if (frec != 'ANUAL')
                    DataRow(
                      color: WidgetStateProperty.all(const Color(0xFFFFFBEB)),
                      cells: [
                        DataCell(Text('Pagos Subsecuentes ($frec)', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                        ...seleccionadas.map((o) {
                          final des = _calcularPagos(o['prima'], frec, tieneRed);
                          return DataCell(Text(fMoneda.format(des['subsecuente']), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428))));
                        }),
                      ],
                    ),
                  DataRow(
                    color: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                    cells: [
                      const DataCell(Text('TOTAL ANUALIZADO', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                      ...seleccionadas.map((o) {
                        final des = _calcularPagos(o['prima'], frec, tieneRed);
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

  Widget _vistaAuditoriaPortales() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Auditoría Portales vs Cartera (${_aseguradoras.length} Compañías)', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _aseguradoras.length,
              itemBuilder: (ctx, i) {
                final a = _aseguradoras[i];
                final prima = double.tryParse((a['primaTotal'] ?? '0').toString()) ?? 0.0;
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFFCBD5E1))),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: const Color(0xFF091428), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        CircleAvatar(backgroundColor: const Color(0xFFD4AF37), radius: 16, child: Text(a['aseguradora'].toString()[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a['aseguradora'].toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('Vigentes: ${a['vigentes']}  •  Canceladas: ${a['canceladas']}  •  Total: ${a['totalPolizas']}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                            ],
                          ),
                        ),
                        Text(fMoneda.format(prima), style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogoCapturaIa extends StatefulWidget {
  final String? polizaOrigen;
  final String? contratanteOrigen;
  final String? aseguradoraOrigen;
  final String? rfcOrigen;
  final VoidCallback onGuardadoExitoso;

  const _DialogoCapturaIa({
    this.polizaOrigen,
    this.contratanteOrigen,
    this.aseguradoraOrigen,
    this.rfcOrigen,
    required this.onGuardadoExitoso,
  });

  @override
  State<_DialogoCapturaIa> createState() => _DialogoCapturaIaState();
}

class _DialogoCapturaIaState extends State<_DialogoCapturaIa> {
  late bool _esRenovacion;
  final _polizaNuevaCtrl = TextEditingController();
  final _polizaAnteriorCtrl = TextEditingController();
  final _contratanteCtrl = TextEditingController();
  final _rfcCtrl = TextEditingController();
  final _aseguradoraCtrl = TextEditingController(text: 'QUALITAS');
  final _primaTotalCtrl = TextEditingController();
  final _vigFinCtrl = TextEditingController();
  final _atendidoPorCtrl = TextEditingController(text: 'Raúl Martínez');
  bool _avisoCobro = true;
  bool _comprobante = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _esRenovacion = widget.polizaOrigen != null;
    _polizaAnteriorCtrl.text = widget.polizaOrigen ?? '';
    _contratanteCtrl.text = widget.contratanteOrigen ?? '';
    _rfcCtrl.text = widget.rfcOrigen ?? '';
    _aseguradoraCtrl.text = widget.aseguradoraOrigen ?? 'QUALITAS';
  }

  Future<void> _guardar() async {
    if (_polizaNuevaCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escribe el número de póliza nueva.')));
      return;
    }
    setState(() => _guardando = true);
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.appsScriptUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accion': 'CAPTURAR_POLIZA_IA',
          'esRenovacion': _esRenovacion,
          'polizaAnterior': _polizaAnteriorCtrl.text.trim(),
          'noPoliza': _polizaNuevaCtrl.text.trim(),
          'contratante': _contratanteCtrl.text.trim(),
          'rfc': _rfcCtrl.text.trim().toUpperCase(),
          'aseguradora': _aseguradoraCtrl.text.trim().toUpperCase(),
          'vigenciaFin': _vigFinCtrl.text.trim(),
          'primaTotal': _primaTotalCtrl.text.trim(),
          'atendidoPor': _atendidoPorCtrl.text.trim(),
          'tieneAvisoCobro': _avisoCobro,
          'tieneComprobantePago': _comprobante,
        }),
      );
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        if (mounted) {
          Navigator.of(context).pop();
          widget.onGuardadoExitoso();
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _guardando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 750,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFFD4AF37)),
                const SizedBox(width: 10),
                Text(_esRenovacion ? 'Renovación Vinculada de Póliza' : 'Capturador Inteligente con IA', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const Divider(),
            if (widget.polizaOrigen == null) ...[
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('PÓLIZA NUEVA'),
                    selected: !_esRenovacion,
                    selectedColor: const Color(0xFF091428),
                    labelStyle: TextStyle(color: !_esRenovacion ? const Color(0xFFD4AF37) : const Color(0xFF091428), fontWeight: FontWeight.bold, fontSize: 11),
                    onSelected: (v) => setState(() => _esRenovacion = !v),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('RENOVACIÓN VINCULADA'),
                    selected: _esRenovacion,
                    selectedColor: const Color(0xFF091428),
                    labelStyle: TextStyle(color: _esRenovacion ? const Color(0xFFD4AF37) : const Color(0xFF091428), fontWeight: FontWeight.bold, fontSize: 11),
                    onSelected: (v) => setState(() => _esRenovacion = v),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (_esRenovacion)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(controller: _polizaAnteriorCtrl, decoration: const InputDecoration(labelText: 'Póliza Anterior a Vincular', border: OutlineInputBorder(), isDense: true)),
              ),
            Row(
              children: [
                Expanded(child: TextField(controller: _polizaNuevaCtrl, decoration: const InputDecoration(labelText: 'No. Póliza Nueva', border: OutlineInputBorder(), isDense: true))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _aseguradoraCtrl, decoration: const InputDecoration(labelText: 'Aseguradora', border: OutlineInputBorder(), isDense: true))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(flex: 2, child: TextField(controller: _contratanteCtrl, decoration: const InputDecoration(labelText: 'Contratante', border: OutlineInputBorder(), isDense: true))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _rfcCtrl, decoration: const InputDecoration(labelText: 'RFC', border: OutlineInputBorder(), isDense: true))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: _vigFinCtrl, decoration: const InputDecoration(labelText: 'Fin Vigencia (AAAA-MM-DD)', border: OutlineInputBorder(), isDense: true))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _primaTotalCtrl, decoration: const InputDecoration(labelText: 'Prima Total', border: OutlineInputBorder(), isDense: true))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _atendidoPorCtrl, decoration: const InputDecoration(labelText: '¿Quién atiende?', border: OutlineInputBorder(), isDense: true))),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Checkbox(value: _avisoCobro, activeColor: const Color(0xFF091428), onChanged: (v) => setState(() => _avisoCobro = v ?? true)),
                const Text('Aviso de Cobro', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Checkbox(value: _comprobante, activeColor: const Color(0xFF091428), onChanged: (v) => setState(() => _comprobante = v ?? true)),
                const Text('Comprobante de Pago', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF091428), foregroundColor: const Color(0xFFD4AF37), padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12)),
                icon: _guardando ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 2)) : const Icon(Icons.save_outlined, size: 16),
                label: Text(_guardando ? 'GUARDANDO...' : 'REGISTRAR PÓLIZA', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: _guardando ? null : _guardar,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
