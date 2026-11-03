import 'package:flutter/material.dart';

class PlantillasScreen extends StatefulWidget {
  const PlantillasScreen({super.key});

  @override
  State<PlantillasScreen> createState() => _PlantillasScreenState();
}

class _PlantillasScreenState extends State<PlantillasScreen> {
  final List> _plantillas = [
    {
      'canal': 'WhatsApp',
      'titulo': 'Cobranza Preventiva (Aviso 1°)',
      'mensaje': 'Hola {cliente}, le saluda {ejecutivo} de {despacho}. Le recordamos que su póliza {poliza} tiene fecha límite de pago el {fecha}.',
    },
    {
      'canal': 'WhatsApp',
      'titulo': 'Último Aviso de Cobro (Aviso 3°)',
      'mensaje': 'Estimado(a) {cliente}, le hacemos una última llamada de atención sobre su póliza {poliza} para evitar la cancelación de su cobertura.',
    },
    {
      'canal': 'Correo',
      'titulo': 'Envío de Propuesta y Comparativa',
      'mensaje': 'Estimado cliente, adjuntamos la comparativa de opciones con las mejores aseguradoras para su análisis.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Plantillas de Comunicación (WhatsApp y Correo)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: const Color(0xFFD4AF37)),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Nueva Plantilla'),
                  onPressed: () {},
                )
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _plantillas.length,
                itemBuilder: (ctx, i) {
                  final p = _plantillas[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(p['canal'] == 'WhatsApp' ? Icons.chat : Icons.email, color: const Color(0xFFD4AF37)),
                      title: Text(p['titulo']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(p['mensaje']!),
                      trailing: IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () {}),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}