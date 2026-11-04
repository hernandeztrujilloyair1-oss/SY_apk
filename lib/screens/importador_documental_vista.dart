import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ImportadorDocumentalVista extends StatefulWidget {
  const ImportadorDocumentalVista({super.key});

  @override
  State<ImportadorDocumentalVista> createState() => _ImportadorDocumentalVistaState();
}

class _ImportadorDocumentalVistaState extends State<ImportadorDocumentalVista> {
  bool _procesando = false;
  String _resultado = '';

  Future<void> _sincronizar() async {
    setState(() => _procesando = true);
    try {
      final res = await http.get(Uri.parse('${ApiConfig.appsScriptUrl}?accion=SINCRONIZAR_SIGA'));
      if (mounted) {
        setState(() {
          _resultado = 'Respuesta del servidor: ${res.body}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _resultado = 'Error de conexión: $e');
      }
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Importador y Sincronizador SIGA', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
          const SizedBox(height: 8),
          const Text('Sincroniza la cartera importada directamente con la base central.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF091428),
              foregroundColor: const Color(0xFFD4AF37),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            icon: _procesando ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 2)) : const Icon(Icons.sync),
            label: Text(_procesando ? 'SINCRONIZANDO...' : 'SINCRONIZAR CARTERA SIGA'),
            onPressed: _procesando ? null : _sincronizar,
          ),
          if (_resultado.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Text(_resultado, style: const TextStyle(fontSize: 12, color: Color(0xFF091428))),
            ),
          ]
        ],
      ),
    );
  }
}
