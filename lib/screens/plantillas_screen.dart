import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlantillasScreen extends StatefulWidget {
  const PlantillasScreen({super.key});

  @override
  State<PlantillasScreen> createState() => _PlantillasScreenState();
}

class _PlantillasScreenState extends State<PlantillasScreen> {
  final List> _plantillas = [
    {
      'titulo': 'Recordatorio 1° Cobranza Preventiva',
      'categoria': 'COBRANZA',
      'cuerpo': 'Estimado(a) {CLIENTE},\n\nLe saludamos de Enfoque Seguro para recordarle que el próximo {FECHA} vence su recibo de la póliza {POLIZA} ({RAMO}) por un monto de \${MONTO} MXN.\n\nQuedamos a sus órdenes para cualquier duda o apoyo con su método de pago.',
    },
    {
      'titulo': 'Aviso 2° Vencimiento de Pago',
      'categoria': 'COBRANZA',
      'cuerpo': 'Aviso Importante: Estimado(a) {CLIENTE}, su recibo de la póliza {POLIZA} presenta fecha límite de pago al día de hoy. Le recordamos liquidar para evitar la suspensión de coberturas.',
    },
    {
      'titulo': 'Aviso 3° Alerta de Cancelación',
      'categoria': 'COBRANZA',
      'cuerpo': 'URGENTE: Estimado(a) {CLIENTE}, la aseguradora emitirá cancelación por falta de pago de la póliza {POLIZA}. Por favor contáctenos de inmediato para reactivar su protección.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Plantillas de Mensajes y Cobranza', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _plantillas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final p = _plantillas[i];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFFE2E8F0))),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p['titulo']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(p['cuerpo']!, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.copy, size: 14),
                      label: const Text('Copiar'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: p['cuerpo']!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Plantilla copiada')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
