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
      title: 'Enfoque Seguro | Tablero Ejecutivo',
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

class _MasterDashboardPageState extends State<MasterDashboardPage> with TickerProviderStateMixin {
  final fMoneda = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
  int _seccionActual = 0;
  bool _cargando = true;
  int _filtroPeriodo = 0;

  List _polizas = [];
  List _recibos = [];
  List _aseguradoras = [];
  Map _contratantesMap = {};

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
  // Variables de Suma Asegurada y Cotizador Pro
  String _tipoValorAuto = 'VALOR COMERCIAL';
  final _montoFacturaAutoCtrl = TextEditingController(text: '350000');
  final _sumaAseguradaGmmCtrl = TextEditingController(text: '100000000');


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

  final _datosRamos = [
    {'ramo': 'Gastos Médicos Mayores', 'p25': 284, 'r25': 228, 'c25': 26, 'tRet25': 80.3, 'tCanc25': 9.2, 'p26': 315, 'r26': 264, 'c26': 39, 'tRet26': 83.8, 'tCanc26': 12.4, 'perdida26': 3360844.13, 'res': 'PÉRDIDA EN PRIMA ⚠️'},
    {'ramo': 'Automóviles', 'p25': 560, 'r25': 412, 'c25': 108, 'tRet25': 73.6, 'tCanc25': 19.3, 'p26': 645, 'r26': 432, 'c26': 174, 'tRet26': 67.0, 'tCanc26': 27.0, 'perdida26': 2439323.56, 'res': 'PÉRDIDA CRÍTICA 🔴'},
    {'ramo': 'Camiones y Carga', 'p25': 24, 'r25': 18, 'c25': 4, 'tRet25': 75.0, 'tCanc25': 16.7, 'p26': 28, 'r26': 21, 'c26': 5, 'tRet26': 75.0, 'tCanc26': 17.9, 'perdida26': 374848.91, 'res': 'PÉRDIDA LEVE 🔴'},
    {'ramo': 'Vida', 'p25': 152, 'r25': 124, 'c25': 14, 'tRet25': 81.6, 'tCanc25': 9.2, 'p26': 173, 'r26': 163, 'c26': 6, 'tRet26': 94.2, 'tCanc26': 3.5, 'perdida26': 33015.24, 'res': 'GANANCIA 🟢'},
    {'ramo': 'Daños Empresariales', 'p25': 58, 'r25': 42, 'c25': 9, 'tRet25': 72.4, 'tCanc25': 15.5, 'p26': 62, 'r26': 48, 'c26': 8, 'tRet26': 77.4, 'tCanc26': 12.9, 'perdida26': 142096.60, 'res': 'GANANCIA 🟢'},
    {'ramo': 'Responsabilidad Civil', 'p25': 42, 'r25': 34, 'c25': 5, 'tRet25': 81.0, 'tCanc25': 11.9, 'p26': 46, 'r26': 32, 'c26': 9, 'tRet26': 69.6, 'tCanc26': 19.6, 'perdida26': 65425.87, 'res': 'PÉRDIDA 🔴'},
    {'ramo': 'RC Profesional', 'p25': 22, 'r25': 18, 'c25': 3, 'tRet25': 81.8, 'tCanc25': 13.6, 'p26': 24, 'r26': 15, 'c26': 7, 'tRet26': 62.5, 'tCanc26': 29.2, 'perdida26': 51381.60, 'res': 'PÉRDIDA ALTA 🔴'},
    {'ramo': 'Casa Habitación', 'p25': 18, 'r25': 14, 'c25': 3, 'tRet25': 77.8, 'tCanc25': 16.7, 'p26': 20, 'r26': 11, 'c26': 7, 'tRet26': 55.0, 'tCanc26': 35.0, 'perdida26': 92422.68, 'res': 'PÉRDIDA CRÍTICA 🔴'},
    {'ramo': 'Motocicletas', 'p25': 18, 'r25': 12, 'c25': 4, 'tRet25': 66.7, 'tCanc25': 22.2, 'p26': 22, 'r26': 12, 'c26': 8, 'tRet26': 54.5, 'tCanc26': 36.4, 'perdida26': 42273.09, 'res': 'PÉRDIDA ALTA 🔴'},
    {'ramo': 'Plan Ahorro / Educación', 'p25': 14, 'r25': 11, 'c25': 2, 'tRet25': 78.6, 'tCanc25': 14.3, 'p26': 16, 'r26': 12, 'c26': 3, 'tRet26': 75.0, 'tCanc26': 18.8, 'perdida26': 108000.00, 'res': 'PÉRDIDA 🔴'},
    {'ramo': 'Mascotas', 'p25': 6, 'r25': 5, 'c25': 1, 'tRet25': 83.3, 'tCanc25': 16.7, 'p26': 8, 'r26': 5, 'c26': 2, 'tRet26': 62.5, 'tCanc26': 25.0, 'perdida26': 10985.55, 'res': 'PÉRDIDA 🔴'},
  ];

  final _datosMeses = [
    {'mes': 'Enero', 'p25': 98, 'r25': 74, 'c25': 18, 'ret25': '75.50%', 'fuga25': 385400.00, 'p26': 114, 'r26': 72, 'c26': 34, 'ret26': '63.20%', 'fuga26': 479870.83, 'dif': r'+$94,470.83'},
    {'mes': 'Febrero', 'p25': 86, 'r25': 65, 'c25': 14, 'ret25': '75.60%', 'fuga25': 310200.00, 'p26': 98, 'r26': 66, 'c26': 26, 'ret26': '67.30%', 'fuga26': 376600.78, 'dif': r'+$66,400.78'},
    {'mes': 'Marzo', 'p25': 104, 'r25': 79, 'c25': 19, 'ret25': '76.00%', 'fuga25': 440150.00, 'p26': 118, 'r26': 76, 'c26': 32, 'ret26': '64.40%', 'fuga26': 908461.24, 'dif': r'+$468,311.24 🔴'},
    {'mes': 'Abril', 'p25': 92, 'r25': 70, 'c25': 15, 'ret25': '76.10%', 'fuga25': 390800.00, 'p26': 96, 'r26': 68, 'c26': 23, 'ret26': '70.80%', 'fuga26': 905831.23, 'dif': r'+$515,031.23 🔴'},
    {'mes': 'Mayo', 'p25': 78, 'r25': 62, 'c25': 10, 'ret25': '79.50%', 'fuga25': 245600.00, 'p26': 82, 'r26': 65, 'c26': 13, 'ret26': '79.30%', 'fuga26': 256860.12, 'dif': r'+$11,260.12'},
    {'mes': 'Junio', 'p25': 96, 'r25': 72, 'c25': 16, 'ret25': '75.00%', 'fuga25': 365400.00, 'p26': 106, 'r26': 74, 'c26': 24, 'ret26': '69.80%', 'fuga26': 273812.26, 'dif': r'-$91,587.74 🟢'},
    {'mes': 'Julio', 'p25': 112, 'r25': 81, 'c25': 22, 'ret25': '72.30%', 'fuga25': 512300.00, 'p26': 122, 'r26': 84, 'c26': 29, 'ret26': '68.90%', 'fuga26': 1078079.20, 'dif': r'+$565,779.20 🔴'},
    {'mes': 'Agosto', 'p25': 88, 'r25': 68, 'c25': 12, 'ret25': '77.30%', 'fuga25': 290100.00, 'p26': 94, 'r26': 74, 'c26': 16, 'ret26': '78.70%', 'fuga26': 306888.44, 'dif': r'+$16,788.44'},
    {'mes': 'Septiembre', 'p25': 94, 'r25': 71, 'c25': 15, 'ret25': '75.50%', 'fuga25': 345800.00, 'p26': 102, 'r26': 74, 'c26': 22, 'ret26': '72.50%', 'fuga26': 315502.57, 'dif': r'-$30,297.43 🟢'},
    {'mes': 'Octubre', 'p25': 102, 'r25': 76, 'c25': 16, 'ret25': '74.50%', 'fuga25': 380450.00, 'p26': 108, 'r26': 84, 'c26': 17, 'ret26': '77.80%', 'fuga26': 321624.45, 'dif': r'-$58,825.55 🟢'},
    {'mes': 'Noviembre', 'p25': 84, 'r25': 64, 'c25': 11, 'ret25': '76.20%', 'fuga25': 295400.00, 'p26': 88, 'r26': 72, 'c26': 12, 'ret26': '81.80%', 'fuga26': 705580.23, 'dif': r'+$410,180.23 🔴'},
    {'mes': 'Diciembre', 'p25': 134, 'r25': 83, 'c25': 15, 'ret25': '61.90%', 'fuga25': 448610.00, 'p26': 109, 'r26': 79, 'c26': 20, 'ret26': '72.50%', 'fuga26': 791505.88, 'dif': r'+$342,895.88 🔴'},
  ];

  final _datosAseguradoras = [
    {'cia': 'ALLIANZ', 'p25': 358, 'r25': 292, 'c25': 34, 'p26': 376, 'ren26': 284, 'vig26': 47, 'ret26': 331, 'canc26': 41, 'fuga26': 1111696.82},
    {'cia': 'CHUBB', 'p25': 242, 'r25': 162, 'c25': 58, 'p26': 264, 'ren26': 154, 'vig26': 14, 'ret26': 168, 'canc26': 94, 'fuga26': 999843.20},
    {'cia': 'GNP', 'p25': 148, 'r25': 108, 'c25': 26, 'p26': 156, 'ren26': 97, 'vig26': 9, 'ret26': 106, 'canc26': 50, 'fuga26': 1019825.27},
    {'cia': 'QUALITAS', 'p25': 104, 'r25': 74, 'c25': 22, 'p26': 96, 'ren26': 62, 'vig26': 3, 'ret26': 65, 'canc26': 30, 'fuga26': 1000181.73},
    {'cia': 'METLIFE', 'p25': 72, 'r25': 61, 'c25': 5, 'p26': 65, 'ren26': 53, 'vig26': 10, 'ret26': 63, 'canc26': 2, 'fuga26': 317329.36},
    {'cia': 'AXA SEGUROS', 'p25': 68, 'r25': 52, 'c25': 10, 'p26': 70, 'ren26': 51, 'vig26': 8, 'ret26': 59, 'canc26': 9, 'fuga26': 1046599.01},
    {'cia': 'MAPFRE', 'p25': 46, 'r25': 35, 'c25': 7, 'p26': 50, 'ren26': 36, 'vig26': 6, 'ret26': 42, 'canc26': 8, 'fuga26': 191189.75},
    {'cia': 'BX+', 'p25': 38, 'r25': 29, 'c25': 6, 'p26': 40, 'ren26': 31, 'vig26': 1, 'ret26': 32, 'canc26': 8, 'fuga26': 337462.19},
    {'cia': 'RED ENLACE A.C', 'p25': 28, 'r25': 24, 'c25': 2, 'p26': 34, 'ren26': 26, 'vig26': 5, 'ret26': 31, 'canc26': 3, 'fuga26': 15413.70},
    {'cia': 'BANORTE', 'p25': 16, 'r25': 9, 'c25': 5, 'p26': 13, 'ren26': 5, 'vig26': 1, 'ret26': 6, 'canc26': 7, 'fuga26': 74937.93},
    {'cia': 'NEW YORK LIFE', 'p25': 12, 'r25': 10, 'c25': 1, 'p26': 11, 'ren26': 10, 'vig26': 0, 'ret26': 10, 'canc26': 1, 'fuga26': 36953.86},
    {'cia': 'ANA SEGUROS', 'p25': 10, 'r25': 7, 'c25': 1, 'p26': 10, 'ren26': 7, 'vig26': 0, 'ret26': 7, 'canc26': 3, 'fuga26': 33239.51},
    {'cia': 'HDI SEGUROS', 'p25': 10, 'r25': 6, 'c25': 2, 'p26': 9, 'ren26': 6, 'vig26': 1, 'ret26': 7, 'canc26': 2, 'fuga26': 51180.33},
    {'cia': 'BUPA MÉXICO', 'p25': 10, 'r25': 7, 'c25': 2, 'p26': 9, 'ren26': 4, 'vig26': 2, 'ret26': 6, 'canc26': 3, 'fuga26': 120107.37},
    {'cia': 'AFIRME', 'p25': 8, 'r25': 8, 'c25': 0, 'p26': 6, 'ren26': 6, 'vig26': 0, 'ret26': 6, 'canc26': 0, 'fuga26': 0.0},
    {'cia': 'PLAN SEGURO', 'p25': 4, 'r25': 1, 'c25': 2, 'p26': 3, 'ren26': 1, 'vig26': 0, 'ret26': 1, 'canc26': 2, 'fuga26': 259361.04},
    {'cia': 'OTRAS COMPAÑÍAS', 'p25': 22, 'r25': 17, 'c25': 3, 'p26': 17, 'ren26': 12, 'vig26': 4, 'ret26': 16, 'canc26': 1, 'fuga26': 195679.56},
  ];

  final _padronCanceladas = [
    {'fecha': '2026-04-15', 'cia': 'AXA SEGUROS', 'pol': 'S8093232', 'cont': 'Ana Elisa Vazquez Rubi', 'ramo': 'Gastos Médicos Mayores', 'prima': 369866.38},
    {'fecha': '2026-11-07', 'cia': 'AXA SEGUROS', 'pol': '16785214', 'cont': 'Francisco Ruiz Carrillo', 'ramo': 'Gastos Médicos Mayores', 'prima': 280101.44},
    {'fecha': '2026-11-07', 'cia': 'AXA SEGUROS', 'pol': '16785213', 'cont': 'Francisco Ruiz Carrillo', 'ramo': 'Gastos Médicos Mayores', 'prima': 273634.65},
    {'fecha': '2026-07-29', 'cia': 'GNP', 'pol': '87535860-19-15', 'cont': 'Silvia Luz Catalayud Macias', 'ramo': 'Gastos Médicos Mayores', 'prima': 258456.81},
    {'fecha': '2026-12-27', 'cia': 'METLIFE', 'pol': '0000207834/2026', 'cont': 'Benjamin Paredes Frausto', 'ramo': 'Gastos Médicos Mayores', 'prima': 255328.11},
    {'fecha': '2026-07-31', 'cia': 'QUALITAS', 'pol': '5141835', 'cont': 'Bala Express SA de CV', 'ramo': 'Automóviles', 'prima': 255306.15},
    {'fecha': '2026-03-23', 'cia': 'ALLIANZ', 'pol': 'GMMI-24996-14', 'cont': 'Ivonne Judith Espinoza Kuri', 'ramo': 'Gastos Médicos Mayores', 'prima': 188163.94},
    {'fecha': '2026-07-03', 'cia': 'GNP', 'pol': '623499894-1-1', 'cont': 'Estela Moreno Juarez', 'ramo': 'Gastos Médicos Mayores', 'prima': 164790.80},
    {'fecha': '2026-04-02', 'cia': 'PLAN SEGURO', 'pol': 'AV1133112-1', 'cont': 'Jose Israel Reyes Cano', 'ramo': 'Gastos Médicos Mayores', 'prima': 145853.54},
    {'fecha': '2026-03-18', 'cia': 'QUALITAS', 'pol': '5026990', 'cont': 'Transportes Garcia Lara SA de CV', 'ramo': 'Automóviles', 'prima': 133465.33},
    {'fecha': '2026-04-23', 'cia': 'QUALITAS', 'pol': '5058343', 'cont': 'Transportes Garcia Lara SA de CV', 'ramo': 'Camiones', 'prima': 119694.11},
    {'fecha': '2026-12-05', 'cia': 'QUALITAS', 'pol': '5272455', 'cont': 'Bala Express SA de CV', 'ramo': 'Camiones', 'prima': 118844.55},
    {'fecha': '2026-07-21', 'cia': 'PLAN SEGURO', 'pol': 'PI1147719', 'cont': 'Irene Lopez Lozoya', 'ramo': 'Gastos Médicos Mayores', 'prima': 113507.50},
    {'fecha': '2026-12-07', 'cia': 'ALLIANZ', 'pol': 'GMMI-6054-18', 'cont': 'Leonor Duhart Novaro', 'ramo': 'Gastos Médicos Mayores', 'prima': 112596.83},
    {'fecha': '2026-02-15', 'cia': 'ALLIANZ', 'pol': 'GMMI-74871-3', 'cont': 'Gama Consulting and Security Services', 'ramo': 'Gastos Médicos Mayores', 'prima': 103362.02},
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
    final Map map = {};
    for (var p in _polizas) {
      final nom = (p['Contratante'] ?? p['contratante'] ?? 'CLIENTE GENERAL').toString().trim();
      if (nom.isEmpty || nom.toLowerCase() == 'contratante') continue;

      if (!map.containsKey(nom)) {
        map[nom] = {
          'nombre': nom,
          'rfc': (p['RFC'] ?? p['rfc'] ?? '').toString().trim(),
          'telefono': (p['Telefono_WhatsApp'] ?? p['WhatsApp'] ?? p['telefono'] ?? '').toString().trim(),
          'correo': (p['Correo'] ?? p['correo'] ?? '').toString().trim(),
          'polizas': [],
          'totalPrima': 0.0,
        };
      }
      final prima = double.tryParse((p['Prima_Total'] ?? p['primaTotal'] ?? '0').toString().replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0.0;
      map[nom]['totalPrima'] = (map[nom]['totalPrima'] as double) + prima;
      (map[nom]['polizas'] as List).add(Map.from(p));
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
          const SnackBar(content: Text('Póliza actualizada con éxito.'), backgroundColor: Color(0xFF059669)),
        );
        _cargarTodo();
      }
    } catch (_) {}
  }

  Map _calcularPagos(dynamic primaRaw, String frec, bool tieneRed) {
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
                            Text('Tablero Ejecutivo & Cartera', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.w600)),
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
                      _itemSidebar(0, Icons.dashboard_outlined, 'TABLERO EJECUTIVO MASTER'),
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
        return _vistaDashboardConsolidado();
      case 1:
        return _vistaContratantesAZ();
      case 2:
        return _vistaCobranzaSemaforo();
      case 3:
        return _vistaCotizadores();
      case 4:
        return _vistaAuditoriaPortales();
      default:
        return _vistaDashboardConsolidado();
    }
  }

  Widget _vistaDashboardConsolidado() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tablero Ejecutivo Gerencial Diluido (2025 vs 2026)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFCBD5E1))),
                child: Row(
                  children: [
                    _filtroBoton(0, 'VISTA COMPLETA INTEGRADA'),
                    _filtroBoton(1, 'SOLO EJERCICIO 2026'),
                    _filtroBoton(2, 'SOLO EJERCICIO 2025'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          const Text('1. COMPARATIVO GENERAL DE CARTERA (2025 VS 2026)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFCBD5E1))),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFF091428)),
              dataRowMinHeight: 38,
              dataRowMaxHeight: 44,
              columns: const [
                DataColumn(label: Text('EJERCICIO', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('PÓLIZAS TOTALES', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('CARTERA RETENIDA', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('CANCELADAS', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('TASA RETENCIÓN', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('TASA CANCELACIÓN', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('PRIMA TOTAL', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('PÉRDIDA CANCELADAS', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('2025', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                  DataCell(Text('1,168')),
                  DataCell(Text('985 (855 Ren + 130 No Ren)', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold))),
                  DataCell(Text('183', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                  DataCell(Text('84.30%', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold))),
                  DataCell(Text('15.70%', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                  DataCell(Text(r'$45,108,119.44', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(r'$4,077,905.21', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                ]),
                DataRow(cells: [
                  DataCell(Text('2026 (Actual)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                  DataCell(Text('1,237')),
                  DataCell(Text('959 (848 Ren + 111 Vig)', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold))),
                  DataCell(Text('268', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                  DataCell(Text('77.50%', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold))),
                  DataCell(Text('21.70%', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                  DataCell(Text(r'$42,844,358.45', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(r'$6,720,617.23', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text('2. CUADRO COMPARATIVO DE PORCENTAJES: RETENCIÓN Y CANCELACIÓN (GANANCIA / PÉRDIDA)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFCBD5E1))),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFF091428)),
              dataRowMinHeight: 36,
              dataRowMaxHeight: 42,
              columns: const [
                DataColumn(label: Text('RAMO ASEGURADO', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('% RETENCIÓN 2025', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('% RETENCIÓN 2026', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('DIF. RETENCIÓN', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('% CANCELACIÓN 2025', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('% CANCELACIÓN 2026', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('DIF. CANCELACIÓN', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('RESULTADO OPERATIVO', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
              ],
              rows: _datosRamos.map((r) {
                final difRet = (r['tRet26'] as double) - (r['tRet25'] as double);
                final difCanc = (r['tCanc26'] as double) - (r['tCanc25'] as double);
                final res = r['res'].toString();

                Color cRes = Colors.red;
                if (res.contains('GANANCIA')) cRes = const Color(0xFF059669);
                if (res.contains('PRIMA') || res.contains('⚠️')) cRes = const Color(0xFFD97706);

                return DataRow(cells: [
                  DataCell(Text(r['ramo'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                  DataCell(Text('${r['tRet25']}%')),
                  DataCell(Text('${r['tRet26']}%')),
                  DataCell(Text('${difRet >= 0 ? '+' : ''}${difRet.toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.bold, color: difRet >= 0 ? const Color(0xFF059669) : Colors.red))),
                  DataCell(Text('${r['tCanc25']}%')),
                  DataCell(Text('${r['tCanc26']}%')),
                  DataCell(Text('${difCanc >= 0 ? '+' : ''}${difCanc.toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.bold, color: difCanc <= 0 ? const Color(0xFF059669) : Colors.red))),
                  DataCell(Text(res, style: TextStyle(fontWeight: FontWeight.bold, color: cRes))),
                ]);
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          const Text('3. ANÁLISIS DE EFICIENCIA POR RAMO: RETENCIÓN VS FUGA', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFCBD5E1))),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFF091428)),
              dataRowMinHeight: 36,
              dataRowMaxHeight: 42,
              columns: const [
                DataColumn(label: Text('RAMO', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('POLS 2025', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('RET 2025', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('CANC 2025', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('POLS 2026', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('RET 2026', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('CANC 2026', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('PÉRDIDA ECONÓMICA 2026', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
              ],
              rows: _datosRamos.map((r) {
                final perdida = r['perdida26'] as double;
                return DataRow(cells: [
                  DataCell(Text(r['ramo'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                  DataCell(Text('${r['p25']}')),
                  DataCell(Text('${r['r25']}')),
                  DataCell(Text('${r['c25']}')),
                  DataCell(Text('${r['p26']}')),
                  DataCell(Text('${r['r26']}')),
                  DataCell(Text('${r['c26']}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                  DataCell(Text(fMoneda.format(perdida), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                ]);
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          const Text('4. MATRIZ MENSUAL COMPARATIVA DE CANCELACIONES Y FUGA ECONÓMICA (2025 VS 2026)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFCBD5E1))),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFF091428)),
              dataRowMinHeight: 36,
              dataRowMaxHeight: 42,
              columns: const [
                DataColumn(label: Text('MES', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('POLS 2025', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('RET 2025', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('CANC 2025', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('% RET 2025', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('FUGA 2025', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('POLS 2026', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('RET 2026', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('CANC 2026', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('% RET 2026', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('FUGA 2026', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('VARIACIÓN PÉRDIDA', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
              ],
              rows: _datosMeses.map((m) {
                final fuga25 = m['fuga25'] as double;
                final fuga26 = m['fuga26'] as double;
                return DataRow(cells: [
                  DataCell(Text(m['mes'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                  DataCell(Text('${m['p25']}')),
                  DataCell(Text('${m['r25']}')),
                  DataCell(Text('${m['c25']}')),
                  DataCell(Text(m['ret25'].toString())),
                  DataCell(Text(fMoneda.format(fuga25))),
                  DataCell(Text('${m['p26']}')),
                  DataCell(Text('${m['r26']}')),
                  DataCell(Text('${m['c26']}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                  DataCell(Text(m['ret26'].toString())),
                  DataCell(Text(fMoneda.format(fuga26))),
                  DataCell(Text(m['dif'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                ]);
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          const Text('5. BALANCE POR COMPAÑÍA ASEGURADORA: RETENCIÓN (RENOV+VIG) VS CANCELACIONES', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFCBD5E1))),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFF091428)),
              dataRowMinHeight: 36,
              dataRowMaxHeight: 42,
              columns: const [
                DataColumn(label: Text('ASEGURADORA', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('POLS 2025', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('RET 2025', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('CANC 2025', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('POLS 2026', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('RENOV 2026', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('VIG 2026', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('RETENIDAS (REN+VIG)', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('CANCELADAS 2026', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('PRIMA PERDIDA 2026', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
              ],
              rows: _datosAseguradoras.map((a) {
                final fuga = a['fuga26'] as double;
                return DataRow(cells: [
                  DataCell(Text(a['cia'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                  DataCell(Text('${a['p25']}')),
                  DataCell(Text('${a['r25']}')),
                  DataCell(Text('${a['c25']}')),
                  DataCell(Text('${a['p26']}')),
                  DataCell(Text('${a['ren26']}')),
                  DataCell(Text('${a['vig26']}')),
                  DataCell(Text('${a['ret26']}', style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold))),
                  DataCell(Text('${a['canc26']}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                  DataCell(Text(fMoneda.format(fuga), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                ]);
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          const Text('6. PADRÓN DETALLADO DE CANCELACIONES 2026 (ORDENADO POR FECHA Y COMPAÑÍA)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFCBD5E1))),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFF091428)),
              dataRowMinHeight: 36,
              dataRowMaxHeight: 42,
              columns: const [
                DataColumn(label: Text('FECHA FIN VIGENCIA', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('ASEGURADORA', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('N° PÓLIZA', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('CONTRATANTE / ASEGURADO', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('RAMO / SUBRAMO', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
                DataColumn(label: Text('PRIMA PERDIDA (MXN)', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11))),
              ],
              rows: _padronCanceladas.map((c) {
                final p = c['prima'] as double;
                return DataRow(cells: [
                  DataCell(Text(c['fecha'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                  DataCell(Text(c['cia'].toString())),
                  DataCell(Text(c['pol'].toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(c['cont'].toString())),
                  DataCell(Text(c['ramo'].toString())),
                  DataCell(Text(fMoneda.format(p), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filtroBoton(int idx, String txt) {
    final sel = _filtroPeriodo == idx;
    return InkWell(
      onTap: () => setState(() => _filtroPeriodo = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF091428) : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          txt,
          style: TextStyle(color: sel ? const Color(0xFFD4AF37) : const Color(0xFF091428), fontWeight: FontWeight.bold, fontSize: 11),
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

  void _abrirExpedienteModal(Map c) {
    final polizas = c['polizas'] as List;
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
                    final p = polizas[i] as Map;
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

  
  void _editarOpcionModal(Map<String, dynamic> op, bool esGmm) {
    final planCtrl = TextEditingController(text: op['plan']?.toString() ?? '');
    final primaCtrl = TextEditingController(text: op['prima']?.toString() ?? '10000');
    final dedCtrl = TextEditingController(text: (esGmm ? op['deducible'] : op['deducibleDM'])?.toString() ?? '5%');
    final coaseguroRoboCtrl = TextEditingController(text: (esGmm ? op['coaseguro'] : op['deducibleRobo'])?.toString() ?? '10%');
    final topeRcCtrl = TextEditingController(text: (esGmm ? op['tope'] : op['rcLuc'])?.toString() ?? '4,000,000');
    final extraCtrl = TextEditingController(text: (esGmm ? op['urgencias'] : op['gastosMedicos'])?.toString() ?? 'Amparado');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF091428),
              radius: 16,
              child: Text(op['aseguradora'].toString()[0], style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Text('Editar ${op['aseguradora']}', style: const TextStyle(color: Color(0xFF091428), fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: planCtrl, decoration: const InputDecoration(labelText: 'Plan Comercial', border: OutlineInputBorder(), isDense: true)),
                const SizedBox(height: 12),
                TextField(controller: primaCtrl, decoration: const InputDecoration(labelText: 'Costo / Prima Neta Anual (MXN)', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                TextField(controller: dedCtrl, decoration: InputDecoration(labelText: esGmm ? 'Deducible (MXN)' : 'Deducible Daños Materiales (%)', border: const OutlineInputBorder(), isDense: true)),
                const SizedBox(height: 12),
                TextField(controller: coaseguroRoboCtrl, decoration: InputDecoration(labelText: esGmm ? 'Coaseguro (%)' : 'Deducible Robo Total (%)', border: const OutlineInputBorder(), isDense: true)),
                const SizedBox(height: 12),
                TextField(controller: topeRcCtrl, decoration: InputDecoration(labelText: esGmm ? 'Tope de Coaseguro' : 'Responsabilidad Civil (L.U.C.)', border: const OutlineInputBorder(), isDense: true)),
                const SizedBox(height: 12),
                TextField(controller: extraCtrl, decoration: InputDecoration(labelText: esGmm ? 'Urgencias en el Extranjero' : 'Gastos Médicos / Cobertura Adicional', border: const OutlineInputBorder(), isDense: true)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('CANCELAR', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF091428), foregroundColor: const Color(0xFFD4AF37)),
            onPressed: () {
              setState(() {
                op['plan'] = planCtrl.text.trim();
                op['prima'] = double.tryParse(primaCtrl.text.replaceAll(RegExp(r'[^0-9.-]'), '')) ?? op['prima'];
                if (esGmm) {
                  op['deducible'] = double.tryParse(dedCtrl.text.replaceAll(RegExp(r'[^0-9.-]'), '')) ?? op['deducible'];
                  op['coaseguro'] = coaseguroRoboCtrl.text.trim();
                  op['tope'] = topeRcCtrl.text.trim();
                  op['urgencias'] = extraCtrl.text.trim();
                } else {
                  op['deducibleDM'] = dedCtrl.text.trim();
                  op['deducibleRobo'] = coaseguroRoboCtrl.text.trim();
                  op['rcLuc'] = topeRcCtrl.text.trim();
                  op['gastosMedicos'] = extraCtrl.text.trim();
                }
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('GUARDAR CAMBIOS', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
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
                      const DataCell(Text('TOTAL ANUALIZADO', style: TextStyle(fontWeight: FontWeight.bold))),
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
