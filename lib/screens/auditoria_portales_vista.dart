import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../config/api_config.dart';

class AuditoriaPortalesVista extends StatefulWidget {
  const AuditoriaPortalesVista({super.key});
  @override
  State<AuditoriaPortalesVista> createState() => _AuditoriaPortalesVistaState();
}

class _AuditoriaPortalesVistaState extends State<AuditoriaPortalesVista> {
  final fMoneda = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
  bool _cargando = true;
  List<dynamic> _aseguradoras = [];
  List<dynamic> _discrepancias = [];

  @override
  void initState() {
    super.initState();
    _cargarAuditoriaCompleta();
  }

  Future<void> _cargarAuditoriaCompleta() async {
    setState(() => _cargando = true);
    try {
      final resCias = await http.get(Uri.parse('${ApiConfig.appsScriptUrl}?accion=GRAFICA_ASEGURADORAS'));
      if (resCias.statusCode == 200) {
        final dataCias = jsonDecode(resCias.body);
        if (dataCias is List) _aseguradoras = dataCias;
      }
      final resDisc = await http.get(Uri.parse('${ApiConfig.appsScriptUrl}?accion=AUDITORIA_PORTALES'));
      if (resDisc.statusCode == 200) {
        final dataDisc = jsonDecode(resDisc.body);
        if (dataDisc is Map && dataDisc['discrepancias'] != null) {
          _discrepancias = dataDisc['discrepancias'];
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: ColoredBox(
            color: Color(0xFF091428),
            child: TabBar(
              labelColor: Color(0xFFD4AF37),
              unselectedLabelColor: Color(0xFF94A3B8),
              indicatorColor: Color(0xFFD4AF37),
              indicatorWeight: 3,
              tabs: [
                Tab(text: 'PORTAL POR PORTAL (TODAS LAS COMPAÑÍAS)'),
                Tab(text: 'AUDITORÍA DE CAPTURA & DISCREPANCIAS'),
              ],
            ),
          ),
        ),
        body: _cargando
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF091428)))
            : TabBarView(
                children: [
                  ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _aseguradoras.length,
                    itemBuilder: (context, i) {
                      final cia = _aseguradoras[i];
                      final nombre = (cia['aseguradora'] ?? 'OTRAS').toString();
                      final vigentes = cia['vigentes'] ?? 0;
                      final canceladas = cia['canceladas'] ?? 0;
                      final prima = double.tryParse((cia['primaTotal'] ?? '0').toString()) ?? 0.0;
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFFCBD5E1))),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(color: const Color(0xFF091428), borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: [
                              CircleAvatar(backgroundColor: const Color(0xFFD4AF37), radius: 18, child: Text(nombre.isNotEmpty ? nombre[0] : 'C', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428)))),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                                    const SizedBox(height: 4),
                                    Text('Vigentes: $vigentes | Canceladas: $canceladas | Total: ${vigentes + canceladas}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(fMoneda.format(prima), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF34D399))),
                                  const SizedBox(height: 2),
                                  const Text('Prima Acumulada', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _discrepancias.length,
                    itemBuilder: (context, i) {
                      final d = _discrepancias[i];
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFFFECACA))),
                        child: ListTile(
                          leading: const Icon(Icons.error_outline, color: Colors.red),
                          title: Text('Póliza: ${d['poliza']} - ${d['contratante']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF091428))),
                          subtitle: Text(d['descripcion'].toString(), style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          trailing: Chip(
                            label: Text(d['gravedad'].toString(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                            backgroundColor: d['gravedad'] == 'CRÍTICA' ? Colors.red : Colors.orange,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
