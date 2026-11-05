import '../screens/lector_ia_poliza_dialog.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ReporteContratantesVista extends StatefulWidget {
  const ReporteContratantesVista({super.key});

  @override
  State<ReporteContratantesVista> createState() => _ReporteContratantesVistaState();
}

class _ReporteContratantesVistaState extends State<ReporteContratantesVista> {
  List<dynamic> _polizas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarCartera();
  }

  Future<void> _cargarCartera() async {
    try {
      final res = await http.get(Uri.parse('${ApiConfig.appsScriptUrl}?tabla=POLIZAS'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List) {
          setState(() => _polizas = data);
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reporte de Contratantes y Cartera', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
          const SizedBox(height: 8),
          Text('Total de pólizas activas en cartera: ${_polizas.length}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 20),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF091428)))
                : _polizas.isEmpty
                    ? const Center(child: Text('Sin pólizas registradas.'))
                    : ListView.builder(
                        itemCount: _polizas.length > 500 ? 500 : _polizas.length,
                        itemBuilder: (context, i) {
                          final p = _polizas[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(p['Contratante']?.toString() ?? p['titular']?.toString() ?? 'CLIENTE GENERAL', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Póliza: ${p['No_Poliza'] ?? p['poliza'] ?? ''} | Aseguradora: ${p['Aseguradora'] ?? p['compania'] ?? ''}'),
                              trailing: Text('\$${p['Prima_Total'] ?? p['primaTotal'] ?? '0.00'}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF091428))),
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
