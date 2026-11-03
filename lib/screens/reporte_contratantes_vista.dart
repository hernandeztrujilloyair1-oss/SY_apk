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
    {
      'documento': '4102500090220/0',
      'contratante': 'DAVID ESPINOSA LOPEZ',
      'compania': 'MAPFRE',
      'ramo': 'Autos / Renault Expression',
      'prima': 7792.15,
      'fechaPago': '24/06/2026',
      'frecuencia': 'Mensual',
      'tarjetaPago': '',
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
            Tab(text: 'PÓLIZAS ACTIVAS & RECAUDACIÓN (${activas.length})'),
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
              const SizedBox(width: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: const Color(0xFFD4AF37)),
                icon: const Icon(Icons.picture_as_pdf, size: 16),
                label: const Text('Generar Reporte de Seleccionados'),
                onPressed: _seleccionados.isEmpty
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Generando reporte para ${_seleccionados.length} contratantes seleccionados...')),
                        );
                      },
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
                    DataColumn(label: Text('Póliza / Documento')),
                    DataColumn(label: Text('Contratante')),
                    DataColumn(label: Text('Compañía / Ramo')),
                    DataColumn(label: Text('Prima Total')),
                    DataColumn(label: Text('Próxima Fecha Pago')),
                    DataColumn(label: Text('Tarjeta / Banco Registrado')),
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
                        DataCell(
                          Row(
                            children: [
                              Text(
                                tieneTarjeta ? p['tarjetaPago'].toString() : 'Sin Tarjeta (Completar)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: tieneTarjeta ? Colors.black87 : Colors.red,
                                  fontWeight: tieneTarjeta ? FontWeight.normal : FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 14, color: Color(0xFF0284C7)),
                                tooltip: 'Completar o Modificar Tarjeta Manualmente',
                                onPressed: () => _abrirModalTarjetaManual(p),
                              ),
                            ],
                          ),
                        ),
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

  void _abrirModalTarjetaManual(Map<String, dynamic> item) {
    final tarjetaCtrl = TextEditingController(text: item['tarjetaPago']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Datos de Cobro - ${item['contratante']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ingresa o corrige el banco y terminación de la tarjeta:', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 10),
            TextField(
              controller: tarjetaCtrl,
              decoration: const InputDecoration(
                labelText: 'Ej: BBVA Visa Débito **** 4321',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: const Color(0xFFD4AF37)),
            onPressed: () {
              setState(() {
                item['tarjetaPago'] = tarjetaCtrl.text.trim();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}