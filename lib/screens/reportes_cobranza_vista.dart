import 'package:flutter/material.dart';

class ReportesCobranzaVista extends StatefulWidget {
  const ReportesCobranzaVista({super.key});

  @override
  State<ReportesCobranzaVista> createState() => _ReportesCobranzaVistaState();
}

class _ReportesCobranzaVistaState extends State<ReportesCobranzaVista> {
  String _filtroAseguradora = 'TODAS';
  String _filtroEstado = 'TODOS';
  String _filtroMes = 'TODOS';
  String _busqueda = '';

  final List> _registros = [
    {
      'poliza': '01-554-998234',
      'aseguradora': 'GNP',
      'titular': 'GRUPO INDUSTRIAL MEXICANO SA DE CV',
      'ramo': 'Autos Flotilla',
      'monto': 48950.00,
      'fechaVencimiento': '2026-04-15',
      'estado': 'PENDIENTE',
      'tipoPersona': 'MORAL',
      'responsable': 'Dirección General',
    },
    {
      'poliza': '5157914',
      'aseguradora': 'QUALITAS',
      'titular': 'CRISOFORO ROBERTO PEREZ ONOFRE',
      'ramo': 'Autos Individual',
      'monto': 7427.31,
      'fechaVencimiento': '2026-08-11',
      'estado': 'LIQUIDADO',
      'tipoPersona': 'FÍSICA',
      'responsable': 'Raúl Martínez',
    },
    {
      'poliza': '4112500297698',
      'aseguradora': 'MAPFRE',
      'titular': 'JAIR ENRIQUE GUTIERREZ QUINTANA',
      'ramo': 'Camiones',
      'monto': 13013.93,
      'fechaVencimiento': '2026-11-20',
      'estado': 'LIQUIDADO',
      'tipoPersona': 'FÍSICA',
      'responsable': 'Raúl Martínez',
    },
    {
      'poliza': '160294436300',
      'aseguradora': 'AXA SEGUROS',
      'titular': 'NURIA MARLENE HERNANDEZ NUÑEZ',
      'ramo': 'Autos Individual',
      'monto': 12366.66,
      'fechaVencimiento': '2026-08-28',
      'estado': 'CANCELADO',
      'tipoPersona': 'FÍSICA',
      'responsable': 'Yair Hernández',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtrados = _registros.where((r) {
      final matchAseg = _filtroAseguradora == 'TODAS' || r['aseguradora'] == _filtroAseguradora;
      final matchEst = _filtroEstado == 'TODOS' || r['estado'] == _filtroEstado;
      final matchBusq = _busqueda.isEmpty ||
          r['titular'].toString().toLowerCase().contains(_busqueda.toLowerCase()) ||
          r['poliza'].toString().toLowerCase().contains(_busqueda.toLowerCase());
      return matchAseg && matchEst && matchBusq;
    }).toList();

    double totalCobrado = 0;
    double totalPendiente = 0;
    for (final r in filtrados) {
      final monto = (r['monto'] as num).toDouble();
      if (r['estado'] == 'LIQUIDADO') {
        totalCobrado += monto;
      } else if (r['estado'] == 'PENDIENTE') {
        totalPendiente += monto;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reportes y Auditoría de Cobranza',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Consolidado de primas emitidas, cartera en riesgo y recibos liquidados.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _kpiCard('Total Recaudado', '\$ ${totalCobrado.toStringAsFixed(2)} MXN', Icons.check_circle_outline, const Color(0xFF059669)),
                const SizedBox(width: 14),
                _kpiCard('Cartera Pendiente', '\$ ${totalPendiente.toStringAsFixed(2)} MXN', Icons.pending_actions_outlined, const Color(0xFFD97706)),
                const SizedBox(width: 14),
                _kpiCard('Recibos Totales', '${filtrados.length}', Icons.receipt_long_outlined, const Color(0xFF0284C7)),
              ],
            ),
            const SizedBox(height: 18),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFFE2E8F0))),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar por titular o póliza...',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        ),
                        onChanged: (v) => setState(() => _busqueda = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dropdownFiltro(
                        'Aseguradora',
                        _filtroAseguradora,
                        const ['TODAS', 'GNP', 'QUALITAS', 'MAPFRE', 'AXA SEGUROS'],
                        (v) => setState(() => _filtroAseguradora = v ?? 'TODAS'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dropdownFiltro(
                        'Estado',
                        _filtroEstado,
                        const ['TODOS', 'LIQUIDADO', 'PENDIENTE', 'CANCELADO'],
                        (v) => setState(() => _filtroEstado = v ?? 'TODOS'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(const Color(0xFF0F172A)),
                      headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                      columns: const [
                        DataColumn(label: Text('Póliza')),
                        DataColumn(label: Text('Aseguradora')),
                        DataColumn(label: Text('Titular')),
                        DataColumn(label: Text('Ramo')),
                        DataColumn(label: Text('Monto')),
                        DataColumn(label: Text('Vencimiento')),
                        DataColumn(label: Text('Estado')),
                        DataColumn(label: Text('Responsable')),
                      ],
                      rows: filtrados.map((r) {
                        final esLiq = r['estado'] == 'LIQUIDADO';
                        final esCanc = r['estado'] == 'CANCELADO';
                        final colorBadge = esLiq ? const Color(0xFF059669) : (esCanc ? Colors.red : const Color(0xFFD97706));

                        return DataRow(cells: [
                          DataCell(Text(r['poliza'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          DataCell(Text(r['aseguradora'].toString(), style: const TextStyle(fontSize: 11))),
                          DataCell(Text(r['titular'].toString(), style: const TextStyle(fontSize: 11))),
                          DataCell(Text(r['ramo'].toString(), style: const TextStyle(fontSize: 11))),
                          DataCell(Text('\$ ${(r['monto'] as num).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          DataCell(Text(r['fechaVencimiento'].toString(), style: const TextStyle(fontSize: 11))),
                          DataCell(Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: colorBadge.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                            child: Text(r['estado'].toString(), style: TextStyle(color: colorBadge, fontWeight: FontWeight.bold, fontSize: 10)),
                          )),
                          DataCell(Text(r['responsable'].toString(), style: const TextStyle(fontSize: 11))),
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

  Widget _kpiCard(String titulo, String valor, IconData icono, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icono, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                const SizedBox(height: 2),
                Text(valor, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdownFiltro(String label, String valorActual, List<String> opciones, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: valorActual,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
      ),
      items: opciones.map((op) => DropdownMenuItem(value: op, child: Text(op, style: const TextStyle(fontSize: 12)))).toList(),
      onChanged: onChanged,
    );
  }
}