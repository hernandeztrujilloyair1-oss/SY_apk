import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlantillasScreen extends StatefulWidget {
  const PlantillasScreen({super.key});

  @override
  State<PlantillasScreen> createState() => _PlantillasScreenState();
}

class _PlantillasScreenState extends State<PlantillasScreen> {
  final List> _plantillas = const [
    {
      'titulo': 'Recordatorio 1° Cobranza Preventiva',
      'categoria': 'COBRANZA',
      'cuerpo': 'Estimado(a) asegurado(a),\n\nLe saludamos de Enfoque Seguro para recordarle que el próximo recibo de su póliza se encuentra próximo a vencer.\n\nQuedamos a sus órdenes para proporcionarle su aviso de cobro o apoyarle con su pago en línea.',
    },
    {
      'titulo': 'Aviso 2° Vencimiento de Pago (Límite)',
      'categoria': 'COBRANZA',
      'cuerpo': 'Aviso Importante: Su póliza presenta fecha límite de pago al día de hoy. Le recordamos liquidar a la brevedad para evitar la suspensión temporal de coberturas ante cualquier siniestro.',
    },
    {
      'titulo': 'Aviso 3° Alerta de Cancelación',
      'categoria': 'COBRANZA',
      'cuerpo': 'URGENTE: La aseguradora emitirá cancelación automática por falta de pago. Por favor comuníquese de inmediato para coordinar la reactivación de su protección.',
    },
    {
      'titulo': 'Felicitación de Cumpleaños',
      'categoria': 'FIDELIZACIÓN',
      'cuerpo': '¡Feliz Cumpleaños! En Enfoque Seguro le enviamos nuestros mejores deseos en su día, lleno de salud, prosperidad y alegría junto a sus seres queridos. ¡Un fuerte abrazo!',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Plantillas de Mensajes & Cobranza', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18)),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(p['titulo']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                        child: Text(p['categoria']!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(p['cuerpo']!, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.copy, size: 14),
                      label: const Text('Copiar Texto', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: p['cuerpo']!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Plantilla "${p['titulo']}" copiada al portapapeles.')),
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