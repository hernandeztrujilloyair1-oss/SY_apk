import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/tenant_service.dart';

class CobranzaSeguimientoVista extends StatefulWidget {
  const CobranzaSeguimientoVista({super.key});

  @override
  State<CobranzaSeguimientoVista> createState() => _CobranzaSeguimientoVistaState();
}

class _CobranzaSeguimientoVistaState extends State<CobranzaSeguimientoVista> {
  bool _cargando = false;
  String _filtroSeguimiento = 'TODOS';
  int _filtroDiasAtraso = 0;
  String _busqueda = '';

  List<Map<String, dynamic>> _registros = [];

  final List<Map<String, dynamic>> _datosDefault = [
    {
      'poliza': '4112500270025',
      'titular': 'SUAJES Y PREPARACIONES DIVISION BAJIO SA DE CV',
      'rfc': 'SPD140730CY3',
      'compania': 'MAPFRE',
      'subramo': 'Flotilla de Vehículos',
      'primaTotal': 123970.27,
      'proximoPago': '2026-09-03',
      'statusCobranza': 'URGE PAGO VENCIDO',
      'seguimiento': 'REQUIERE ATENCIÓN URGENTE',
      'diasAtraso': 62,
    },
    {
      'poliza': '190232033',
      'titular': 'SUAJES Y PREPARACIONES DIVISION BAJIO SA DE CV',
      'rfc': 'SPD140730CY3',
      'compania': 'QUALITAS',
      'subramo': 'Camiones individuales',
      'primaTotal': 12940.92,
      'proximoPago': '2026-09-23',
      'statusCobranza': 'URGE PAGO VENCIDO',
      'seguimiento': 'REQUIERE ATENCIÓN URGENTE',
      'diasAtraso': 42,
    },
    {
      'poliza': 'EL46003728',
      'titular': 'LOPEZ MARTINEZ INGRID',
      'rfc': 'LOMI010407LA6',
      'compania': 'CHUBB',
      'subramo': 'Automóviles individuales',
      'primaTotal': 7971.48,
      'proximoPago': '2026-09-25',
      'statusCobranza': 'URGE PAGO VENCIDO',
      'seguimiento': '3°',
      'diasAtraso': 40,
    },
    {
      'poliza': '5157914',
      'titular': 'CRISOFORO ROBERTO PEREZ ONOFRE',
      'rfc': 'PEOC720708QN7',
      'compania': 'QUALITAS',
      'subramo': 'Automóviles individuales',
      'primaTotal': 7427.31,
      'proximoPago': '2026-08-11',
      'statusCobranza': 'LIQUIDADA',
      'seguimiento': 'LIQUIDADA',
      'diasAtraso': 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _registros = List.from(_datosDefault);
    _cargarCobranzaDesdeApi();
  }

  Future<void> _cargarCobranzaDesdeApi() async {
    setState(() => _cargando = true);
    final tenant = TenantService().empresaActiva;

    try {
      final uri = Uri.parse(
        ApiConfig.appsScriptUrl + '?accion=OBTENER_COBRANZA_SEGUIMIENTO&id_empresa=' + tenant.idEmpresa,
      );
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List && data.isNotEmpty) {
          setState(() {
            _registros = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          });
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _cambiarSeguimiento(Map<String, dynamic> item, String nuevoEstado) async {
    setState(() {
      item['seguimiento'] = nuevoEstado;
    });

    try {
      final tenant = TenantService().empresaActiva;
      await http.post(
        Uri.parse(ApiConfig.appsScriptUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accion': 'ACTUALIZAR_SEGUIMIENTO_COBRANZA',
          'id_empresa': tenant.idEmpresa,
          'poliza': item['poliza'],
          'seguimiento': nuevoEstado,
        }),
      );
    } catch (_) {}
  }

  Color _obtenerColorSeguimiento(String estatus) {
    switch (estatus.toUpperCase()) {
      case 'REQUIERE ATENCIÓN URGENTE':
        return const Color(0xFFDC2626);
      case '3°':
        return const Color(0xFFEA580C);
      case '2°':
        return const Color(0xFFD97706);
      case '1°':
        return const Color(0xFF0284C7);
      case 'LIQUIDADA':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenant = TenantService().empresaActiva;

    final filtrados = _registros.where((r) {
      final q = _busqueda.toLowerCase();
      final matchText = r['poliza'].toString().toLowerCase().contains(q) ||
          r['titular'].toString().toLowerCase().contains(q) ||
          r['compania'].toString().toLowerCase().contains(q);

      final matchSeguimiento = _filtroSeguimiento == 'TODOS' ||
          r['seguimiento'].toString().toUpperCase() == _filtroSeguimiento;

      final int dias = (r['diasAtraso'] as num?)?.toInt() ?? 0;
      final matchDias = _filtroDiasAtraso == 0 || dias <= _filtroDiasAtraso;

      return matchText && matchSeguimiento && matchDias;
    }).toList();

    double sumaPrimas = 0;
    int urgentes = 0;
    int liquidadas = 0;

    for (var r in _registros) {
      sumaPrimas += (r['primaTotal'] as num?)?.toDouble() ?? 0.0;
      if (r['seguimiento'] == 'REQUIERE ATENCIÓN URGENTE') urgentes++;
      if (r['seguimiento'] == 'LIQUIDADA') liquidadas++;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: tenant.colorPrimario,
                  child: Icon(Icons.credit_card_rounded, color: tenant.colorAcento, size: 20),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cobranza Activa & Seguimiento Directo',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: tenant.colorPrimario),
                    ),
                    const Text('Sincronizado con: 1162x382qGfBC-PSMEP9dDSaBukBsr_cOaAjZbcdThXs', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                  ],
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Recargar desde Sheets',
                  icon: _cargando
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.sync_rounded),
                  onPressed: _cargando ? null : _cargarCobranzaDesdeApi,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _kpiMini('Monto Cartera en Riesgo', r'$ ' + sumaPrimas.toStringAsFixed(2) + ' MXN', Icons.attach_money, const Color(0xFF0F172A)),
                const SizedBox(width: 12),
                _kpiMini('Requiere Atención Urgente', urgentes.toString() + ' Casos', Icons.error_outline_rounded, const Color(0xFFDC2626)),
                const SizedBox(width: 12),
                _kpiMini('Pólizas Liquidadas', liquidadas.toString(), Icons.check_circle_outline_rounded, const Color(0xFF16A34A)),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar por póliza, cliente o aseguradora...',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      onChanged: (v) => setState(() => _busqueda = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _filtroSeguimiento,
                      decoration: const InputDecoration(labelText: 'Aviso de Seguimiento', border: OutlineInputBorder(), isDense: true),
                      items: const [
                        DropdownMenuItem(value: 'TODOS', child: Text('Todos los Registros')),
                        DropdownMenuItem(value: '1°', child: Text('1° Aviso')),
                        DropdownMenuItem(value: '2°', child: Text('2° Aviso')),
                        DropdownMenuItem(value: '3°', child: Text('3° Aviso')),
                        DropdownMenuItem(value: 'REQUIERE ATENCIÓN URGENTE', child: Text('REQUIERE ATENCIÓN URGENTE')),
                        DropdownMenuItem(value: 'LIQUIDADA', child: Text('LIQUIDADA')),
                      ],
                      onChanged: (v) => setState(() => _filtroSeguimiento = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<int>(
                      value: _filtroDiasAtraso,
                      decoration: const InputDecoration(labelText: 'Filtrar Atraso (días)', border: OutlineInputBorder(), isDense: true),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Sin filtro (Todos)')),
                        DropdownMenuItem(value: 15, child: Text('Hasta 15 días')),
                        DropdownMenuItem(value: 30, child: Text('Hasta 30 días')),
                        DropdownMenuItem(value: 60, child: Text('Hasta 60 días')),
                      ],
                      onChanged: (v) => setState(() => _filtroDiasAtraso = v!),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: filtrados.isEmpty
                    ? const Center(child: Text('No hay registros de cobranza con los filtros seleccionados.', style: TextStyle(color: Color(0xFF94A3B8))))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(const Color(0xFF091428)),
                            headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                            columns: const [
                              DataColumn(label: Text('SEGUIMIENTO')),
                              DataColumn(label: Text('PÓLIZA')),
                              DataColumn(label: Text('CONTRATANTE / CLIENTE')),
                              DataColumn(label: Text('COMPAÑÍA')),
                              DataColumn(label: Text('PRIMA TOTAL')),
                              DataColumn(label: Text('PRÓXIMO PAGO')),
                              DataColumn(label: Text('DÍAS ATRASO')),
                              DataColumn(label: Text('ACCIONES')),
                            ],
                            rows: filtrados.map((it) {
                              final String segActual = it['seguimiento']?.toString() ?? '1°';
                              final colorSeg = _obtenerColorSeguimiento(segActual);
                              final int dias = (it['diasAtraso'] as num?)?.toInt() ?? 0;

                              return DataRow(cells: [
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: colorSeg.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: colorSeg.withOpacity(0.4)),
                                    ),
                                    child: Text(segActual, style: TextStyle(color: colorSeg, fontWeight: FontWeight.w800, fontSize: 10)),
                                  ),
                                ),
                                DataCell(Text(it['poliza'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                                DataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(it['titular'].toString(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11)),
                                      Text(it['subramo'].toString(), style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                    ],
                                  ),
                                ),
                                DataCell(Text(it['compania'].toString(), style: const TextStyle(fontSize: 11))),
                                DataCell(Text(r'$ ' + (it['primaTotal'] as num).toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                                DataCell(Text(it['proximoPago'].toString(), style: const TextStyle(fontSize: 11))),
                                DataCell(
                                  Text(
                                    dias.toString() + ' días',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: dias > 30 ? Colors.red : (dias > 0 ? Colors.orange : Colors.green),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  PopupMenuButton<String>(
                                    tooltip: 'Cambiar Estatus',
                                    icon: const Icon(Icons.more_vert, size: 16),
                                    onSelected: (nuevoVal) => _cambiarSeguimiento(it, nuevoVal),
                                    itemBuilder: (ctx) => const [
                                      PopupMenuItem(value: '1°', child: Text('Marcar 1° Aviso')),
                                      PopupMenuItem(value: '2°', child: Text('Marcar 2° Aviso')),
                                      PopupMenuItem(value: '3°', child: Text('Marcar 3° Aviso')),
                                      PopupMenuItem(value: 'REQUIERE ATENCIÓN URGENTE', child: Text('REQUIERE ATENCIÓN URGENTE')),
                                      PopupMenuItem(value: 'LIQUIDADA', child: Text('Marcar como LIQUIDADA')),
                                    ],
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpiMini(String label, String valor, IconData icono, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color.withOpacity(0.12), child: Icon(icono, color: color, size: 18)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                Text(valor, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
