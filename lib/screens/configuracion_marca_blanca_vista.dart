import 'package:flutter/material.dart';

class ConfiguracionMarcaBlancaVista extends StatefulWidget {
  const ConfiguracionMarcaBlancaVista({super.key});

  @override
  State<ConfiguracionMarcaBlancaVista> createState() => _ConfiguracionMarcaBlancaVistaState();
}

class _ConfiguracionMarcaBlancaVistaState extends State<ConfiguracionMarcaBlancaVista> {
  final _nombreCtrl = TextEditingController(text: 'Enfoque Seguro');
  final _lemaCtrl = TextEditingController(text: 'Gestión Integral y Asesoría Patrimonial');
  final _brokerCtrl = TextEditingController(text: 'Raúl Martínez');
  final _contactoCtrl = TextEditingController(text: 'direccion@enfoqueseguro.mx');
  final _cobranzaCtrl = TextEditingController(text: 'cobranza@enfoqueseguro.mx');

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _lemaCtrl.dispose();
    _brokerCtrl.dispose();
    _contactoCtrl.dispose();
    _cobranzaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Configuración Central - Enfoque Seguro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF091428),
        foregroundColor: const Color(0xFFD4AF37),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Parámetros Institucionales', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre Comercial', border: OutlineInputBorder(), isDense: true)),
            const SizedBox(height: 12),
            TextField(controller: _lemaCtrl, decoration: const InputDecoration(labelText: 'Lema', border: OutlineInputBorder(), isDense: true)),
            const SizedBox(height: 12),
            TextField(controller: _brokerCtrl, decoration: const InputDecoration(labelText: 'Titular / Director', border: OutlineInputBorder(), isDense: true)),
            const SizedBox(height: 12),
            TextField(controller: _contactoCtrl, decoration: const InputDecoration(labelText: 'Correo Dirección', border: OutlineInputBorder(), isDense: true)),
            const SizedBox(height: 12),
            TextField(controller: _cobranzaCtrl, decoration: const InputDecoration(labelText: 'Correo Cobranza', border: OutlineInputBorder(), isDense: true)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF091428),
                foregroundColor: const Color(0xFFD4AF37),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Configuración guardada exitosamente.')),
                );
              },
              child: const Text('GUARDAR PARÁMETROS'),
            ),
          ],
        ),
      ),
    );
  }
}
