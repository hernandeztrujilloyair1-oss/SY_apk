import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';

class AuditoriaPortalesVista extends StatefulWidget {
  const AuditoriaPortalesVista({super.key});

  @override
  State<AuditoriaPortalesVista> createState() => _AuditoriaPortalesVistaState();
}

class _AuditoriaPortalesVistaState extends State<AuditoriaPortalesVista> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _endpointCtrl = TextEditingController(
    text: 'https://script.google.com/macros/s/AKfycbx0_EtCpa4kd4xWQ3exYT_18PH6YXhEcAUgWxl0h242elBfzs5WUiaEmuueJRLfDHSg/exec',
  );

  bool _cargando = false;
  List> _portales = [
    {
      'portal': 'QUALITAS',
      'totalPolizas': 42,
      'primaTotal': 485230.50,
      'vigentes': 38,
      'canceladas': 4,
      'discrepancias': 1,
    },
    {
      'portal': 'GNP SEGUROS',
      'totalPolizas': 29,
      'primaTotal': 612400.00,
      'vigentes': 27,
      'canceladas': 2,
      'discrepancias': 0,
    },
    {
      'portal': 'AXA SEGUROS',
      'totalPolizas': 18,
      'primaTotal': 234100.80,
      'vigentes': 15,
      'canceladas': 3,
      'discrepancias': 2,
    },
    {
      'portal': 'MAPFRE',
      'totalPolizas': 35,
      'primaTotal': 410900.00,
      'vigentes': 34,
      'canceladas': 1,
      'discrepancias': 0,
    },
  ];

  final TextEditingController _polizaTargetCtrl = TextEditingController(text: '5157914');
  final TextEditingController _titularTargetCtrl = TextEditingController(text: 'CRISOFORO ROBERTO PEREZ ONOFRE');
  final TextEditingController _ciaTargetCtrl = TextEditingController(text: 'QUALITAS');
  final TextEditingController _ramoTargetCtrl = TextEditingController(text: 'Autos / Amplia Plus');

  final List> _checklistDocs = [
    {'doc': 'Carátula de Póliza Oficial Emitida', 'incluido': true},
    {'doc': 'Aviso de Cobro o Comprobante de Pago', 'incluido': true},
    {'doc': 'Identificación Oficial Vigente (INE / Pasaporte)', 'incluido': true},
    {'doc': 'Constancia de Situación Fiscal (SAT)', 'incluido': true},
    {'doc': 'Formato Identificación Art. 492 Firmado', 'incluido': true},
    {'doc': 'Factura o Carta Factura Vehicular', 'incluido': false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _endpointCtrl.dispose();
    _polizaTargetCtrl.dispose();
    _titularTargetCtrl.dispose();
    _ciaTargetCtrl.dispose();
    _ramoTargetCtrl.dispose();
    super.dispose();
  }

  Future<void> _consultarAuditoriaSheets() async {
    final url = _endpointCtrl.text.trim();
    if (url.isEmpty) return;

    setState(() => _cargando = true);
    try {
      final res = await http.get(Uri.parse('$url?accion=OBTENER_AUDITORIA_PORTALES'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map && data.containsKey('portales')) {
          final listRaw = data['portales'] as List;
          setState(() {
            _portales = listRaw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          });
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _imprimirExpedienteFisico() {
    Printing.layoutPdf(
      onLayout: (format) async {
        final itemsHtml = _checklistDocs.map((d) {
          final String docNom = d['doc']?.toString() ?? '';
          final bool inc = d['incluido'] == true;
          return '<li>$docNom: <strong>${inc ? "INTEGRADO" : "PENDIENTE"}</strong></li>';
        }).join('');

        return await Printing.convertHtml(
          format: format,
          html: '''
            <div style="font-family: Arial; padding: 25px; border: 2px solid #091428; border-radius: 8px;">
              <h2 style="text-align: center; color: #091428; margin-bottom: 5px;">ENFOQUE SEGURO</h2>
              <div style="text-align: center; font-size: 11px; color: #64748B; margin-bottom: 20px;">CARÁTULA DE EXPEDIENTE FÍSICO</div>
              <p><strong>CONTRATANTE:</strong> ${_titularTargetCtrl.text}</p>
              <p><strong>PÓLIZA:</strong> ${_polizaTargetCtrl.text} \vert{} <strong>COMPAÑÍA:</strong> ${_ciaTargetCtrl.text}</p>
              <p><strong>RAMO:</strong> ${_ramoTargetCtrl.text}</p>
              <hr/>
              <h4>DOCUMENTACIÓN INTEGRADA:</h4>
              <ul>$itemsHtml</ul>
              <br/><br/>
              <div style="border: 2px dashed #0284C7; padding: 12px; text-align: center; width: 80%; margin: 0 auto;">
                <strong>PESTAÑA FÓLDER:</strong> ${_titularTargetCtrl.text} | PÓLIZA ${_polizaTargetCtrl.text} (${_ciaTargetCtrl.text})
              </div>
            </div>
          ''',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Auditoría de Portales & Expedientes Físicos',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF091428),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFFD4AF37),
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.fact_check_outlined), text: 'AUDITORÍA PORTAL POR PORTAL'),
            Tab(icon: Icon(Icons.folder_shared_outlined), text: 'CARÁTULA & PESTAÑAS FÍSICAS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _construirAuditoriaPortales(),
          _construirExpedientesFisicos(),
        ],
      ),
    );
  }

  Widget _construirAuditoriaPortales() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.cloud_sync, color: Color(0xFF0284C7)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _endpointCtrl,
                    decoration: const InputDecoration(
                      hintText: 'URL de Apps Script Web App...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF091428),
                    foregroundColor: const Color(0xFFD4AF37),
                  ),
                  icon: _cargando
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.sync, size: 16),
                  label: const Text('Auditar con Sheets'),
                  onPressed: _cargando ? null : _consultarAuditoriaSheets,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Estado de Conciliación por Portal Activo:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _portales.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final p = _portales[i];
              final bool hayDiscrepancia = (p['discrepancias'] as int? ?? 0) > 0;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: hayDiscrepancia ? Colors.orange : const Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: hayDiscrepancia ? Colors.orange.withOpacity(0.12) : const Color(0xFFECFDF5),
                        child: Icon(
                          hayDiscrepancia ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                          color: hayDiscrepancia ? Colors.orange : const Color(0xFF059669),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p['portal'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(
                              'Pólizas: ${p['totalPolizas']} | Vigentes: ${p['vigentes']} \vert{} Canceladas:${p['canceladas']}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$ ${(p['primaTotal'] as num? ?? 0).toStringAsFixed(2)} MXN',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                          ),
                          Text(
                            hayDiscrepancia ? '${p['discrepancias']} por conciliar' : 'Cuadre Exacto',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: hayDiscrepancia ? Colors.orange : const Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _construirExpedientesFisicos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Datos para Generación de Carátula y Pestaña Física:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: _polizaTargetCtrl, decoration: const InputDecoration(labelText: 'Póliza', border: OutlineInputBorder(), isDense: true))),
                    const SizedBox(width: 10),
                    Expanded(flex: 2, child: TextField(controller: _titularTargetCtrl, decoration: const InputDecoration(labelText: 'Contratante / Razón Social', border: OutlineInputBorder(), isDense: true))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: _ciaTargetCtrl, decoration: const InputDecoration(labelText: 'Compañía', border: OutlineInputBorder(), isDense: true))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Relación de Documentos que Lleva la Carpeta Física:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 10),
                ..._checklistDocs.map((item) {
                  final String titulo = item['doc']?.toString() ?? '';
                  final bool valor = item['incluido'] == true;
                  return CheckboxListTile(
                    dense: true,
                    title: Text(titulo, style: const TextStyle(fontSize: 12)),
                    value: valor,
                    activeColor: const Color(0xFF091428),
                    onChanged: (v) => setState(() => item['incluido'] = v ?? false),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF091428),
                foregroundColor: const Color(0xFFD4AF37),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.print_outlined),
              label: const Text('IMPRIMIR CARÁTULA Y PESTAÑAS PARA CARPETA'),
              onPressed: _imprimirExpedienteFisico,
            ),
          ),
        ],
      ),
    );
  }
}
