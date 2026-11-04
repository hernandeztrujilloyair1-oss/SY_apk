import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class CalendarioOperativoVista extends StatefulWidget {
  const CalendarioOperativoVista({super.key});

  @override
  State<CalendarioOperativoVista> createState() => _CalendarioOperativoVistaState();
}

class _CalendarioOperativoVistaState extends State<CalendarioOperativoVista> {
  final Map<String, List<dynamic>> _pendientesPorFecha = {};
  bool _cargando = true;
  List<dynamic> _eventos = [];

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  Future<void> _cargarEventos() async {
    try {
      final res = await http.get(Uri.parse('${ApiConfig.appsScriptUrl}?accion=OBTENER_CALENDARIO'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List) {
          setState(() {
            _eventos = data;
          });
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
          const Text('Calendario Operativo & Citas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
          const SizedBox(height: 8),
          const Text('Seguimiento de citas, compromisos y vencimientos de pólizas.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 20),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF091428)))
                : _eventos.isEmpty
                    ? const Center(child: Text('No hay eventos registrados en el calendario.', style: TextStyle(color: Color(0xFF64748B))))
                    : ListView.builder(
                        itemCount: _eventos.length,
                        itemBuilder: (context, i) {
                          final ev = _eventos[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: const Icon(Icons.event, color: Color(0xFFD4AF37)),
                              title: Text(ev['titulo']?.toString() ?? 'Evento', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Fecha: ${ev['fecha'] ?? ''} | Responsable: ${ev['responsable'] ?? ''}'),
                              trailing: Chip(label: Text(ev['prioridad']?.toString() ?? 'MEDIA')),
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
