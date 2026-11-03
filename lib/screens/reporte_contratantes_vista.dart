import 'package:flutter/material.dart';

class ReporteContratantesVista extends StatefulWidget {
  const ReporteContratantesVista({super.key});

  @override
  State<ReporteContratantesVista> createState() => _ReporteContratantesVistaState();
}

class _ReporteContratantesVistaState extends State<ReporteContratantesVista> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _seleccionados = {};

  final List> _carteraCompleta = [
    {
      'documento': '5157914',
      'contratante': 'CRISOFORO ROBERTO PEREZ ONOFRE',
      'compania': 'QUALITAS',
      'ramo': 'Autos / Amplia Plus',
      'prima': 7427.31,
      'fechaPago': '11/08/2026',
      'frecuencia': 'Mensual',
      'tarjetaPago': 'BBVA Débito **** 4812',
      'estatus': 'LIQUIDADA',
    },
    {
      'documento': '5471976',
      'contratante': 'MENA CARRANZA MARIA EUGENIA',
      'compania': 'QUALITAS',
      'ramo': 'Autos / Jetta Sportline',
      'prima': 13989.24,
      'fechaPago': '31/10/2026',
      'frecuencia': 'Trimestral',
      'tarjetaPago': '',
      'estatus': 'LIQUIDADA',
    },
    {
      'documento': '4112500297698',
      'contratante': 'JAIR ENRIQUE GUTIERREZ QUINTANA',
      'compania': 'MAPFRE',
      'ramo': 'Flotilla de Vehículos',
      'prima': 13013.93,
      'fechaPago': '20/11/2026',
      'frecuencia': 'Pago Único',
      'tarjetaPago': 'Santander Crédito **** 9014',
      'estatus': 'LIQUIDADA',
    },
    {
      'documento': '160294436300',
      'contratante': 'NURIA MARLENE HERNANDEZ NUÑEZ',
      'compania': 'AXA SEGUROS',
      'ramo': 'Autos / Ford Focus',
      'prima': 12366.66,
      'fechaPago': '28/08/2026',
      'frecuencia': 'Mensual',
      'tarjetaPago': 'Banorte Débito **** 1120',
      'estatus': 'CANCELADA',
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

  @override
  Widget build(BuildContext context) {
    final activas = _carteraCompleta.where((p) => p['estatus'] != 'CANCELADA').toList();
    final canceladas = _carteraCompleta.where((p) => p['estatus'] == 'CANCELADA').toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Auditoría & Reporte por Contratantes', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0284C7),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF0284C7),
          tabs: [
            Tab(text: 'PÓLIZAS ACTIVAS (${activas.length})'),
            Tab(text: 'PÓLIZAS CANCELADAS (${canceladas.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _construirTablaAuditoria(activas, false),
          _construirTablaAuditoria(canceladas, true),
        ],
      ),
    );
  }

  Widget _construirTablaAuditoria(List> lista, bool esCanceladas) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Seleccionados: ${_seleccionados.length}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (_seleccionados.length == lista.length) {
                      _seleccionados.clear();
                    } else {
                      _seleccionados.addAll(lista.map((e) => e['documento'].toString()));
                    }
                  });
                },
                child: Text(_seleccionados.length == lista.length ? 'Deseleccionar todos' : 'Seleccionar todos'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(esCanceladas ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC)),
                  columns: const [
                    DataColumn(label: Text('Sel.')),
                    DataColumn(label: Text('Póliza')),
                    DataColumn(label: Text('Contratante')),
                    DataColumn(label: Text('Compañía / Ramo')),
                    DataColumn(label: Text('Prima Total')),
                    DataColumn(label: Text('Próxima Fecha')),
                    DataColumn(label: Text('Tarjeta Registrada')),
                    DataColumn(label: Text('Estatus')),
                  ],
                  rows: lista.map((p) {
                    final sel = _seleccionados.contains(p['documento']);
                    final bool tieneTarjeta = p['tarjetaPago'].toString().isNotEmpty;

                    return DataRow(
                      selected: sel,
                      onSelectChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _seleccionados.add(p['documento'].toString());
                          } else {
                            _seleccionados.remove(p['documento'].toString());
                          }
                        });
                      },
                      cells: [
                        DataCell(Checkbox(
                          value: sel,
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _seleccionados.add(p['documento'].toString());
                              } else {
                                _seleccionados.remove(p['documento'].toString());
                              }
                            });
                          },
                        )),
                        DataCell(Text(p['documento'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        DataCell(Text(p['contratante'].toString(), style: const TextStyle(fontSize: 11))),
                        DataCell(Text('${p['compania']} | ${p['ramo']}', style: const TextStyle(fontSize: 11))),
                        DataCell(Text('\$ ${p['prima']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        DataCell(Text(p['fechaPago'].toString(), style: const TextStyle(fontSize: 11))),
                        DataCell(Text(tieneTarjeta ? p['tarjetaPago'].toString() : 'Sin Tarjeta', style: TextStyle(fontSize: 11, color: tieneTarjeta ? Colors.black87 : Colors.red))),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: esCanceladas ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            p['estatus'].toString(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: esCanceladas ? Colors.red : Colors.green,
                            ),
                          ),
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
