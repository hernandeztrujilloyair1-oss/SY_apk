import 'package:flutter/material.dart';
import '../models/poliza_model.dart';
import '../services/reglas_negocio_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardMetricasVista extends StatelessWidget {
  final List<PolizaModel> polizas;
  final VoidCallback onAbrirCargaIa;

  const DashboardMetricasVista({
    super.key,
    required this.polizas,
    required this.onAbrirCargaIa,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Cálculos de Cartera
    double totalCobrado = 0.0;
    double pendienteHoy15 = 0.0;
    int cantHoy15 = 0;
    int cantRenovar30 = 0;

    final ahora = DateTime.now();

    for (var p in polizas) {
      final esLiquidada = p.avisoEstado.toLowerCase().contains('pagado') ||
          p.avisoEstado.toLowerCase().contains('cobrado') ||
          p.avisoEstado.toLowerCase().contains('liquidada');

      if (esLiquidada) {
        totalCobrado += p.primaNeta;
      } else {
        pendienteHoy15 += p.primaNeta;
        cantHoy15++;
      }

      // Cálculo por renovar en 30 días
      cantRenovar30++;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner de bienvenida con botón de Carga IA
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFFD4AF37), size: 36),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Centro Operativo de Seguros & Cobranza',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Monitoreo en tiempo real de recibos, renovaciones y cumpleaños.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  icon: const Icon(Icons.document_scanner_outlined, size: 20),
                  label: const Text('CARGAR PÓLIZA CON IA', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: onAbrirCargaIa,
                )
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4 Tarjetas KPI
          LayoutBuilder(
            builder: (context, constraints) {
              final double cardWidth = (constraints.maxWidth - 42) / 4;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _kpiCard(
                    'Cobros Hoy y 15 Días',
                    '$cantHoy15 Recibos',
                    '\$ ${pendienteHoy15.toStringAsFixed(2)} MXN',
                    Icons.warning_amber_rounded,
                    const Color(0xFFEF4444),
                    cardWidth > 200 ? cardWidth : constraints.maxWidth,
                  ),
                  _kpiCard(
                    'Por Renovar en 30 Días',
                    '$cantRenovar30 Pólizas',
                    'Alerta preventiva',
                    Icons.autorenew_rounded,
                    const Color(0xFFF59E0B),
                    cardWidth > 200 ? cardWidth : constraints.maxWidth,
                  ),
                  _kpiCard(
                    '🎂 Cumpleaños Próximos',
                    '3 Asegurados',
                    'Felicitar por WhatsApp',
                    Icons.cake_outlined,
                    const Color(0xFF0284C7),
                    cardWidth > 200 ? cardWidth : constraints.maxWidth,
                  ),
                  _kpiCard(
                    'Total Ya Cobrado',
                    '\$ ${totalCobrado.toStringAsFixed(2)}',
                    'Avance anual',
                    Icons.check_circle_outline,
                    const Color(0xFF10B981),
                    cardWidth > 200 ? cardWidth : constraints.maxWidth,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Gráfica de Progreso y Cumpleaños
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de Cumplimiento
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Estatus General de la Cartera', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          children: [
                            Expanded(
                              flex: totalCobrado > 0 ? totalCobrado.toInt() : 1,
                              child: Container(height: 30, color: const Color(0xFF10B981), alignment: Alignment.center,
                                child: const Text('COBRADO', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                            ),
                            Expanded(
                              flex: pendienteHoy15 > 0 ? pendienteHoy15.toInt() : 1,
                              child: Container(height: 30, color: const Color(0xFFEF4444), alignment: Alignment.center,
                                child: const Text('PENDIENTE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Participación por Compañía:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      _aseguradoraItem('Mapfre', 0.45, const Color(0xFFDC2626)),
                      _aseguradoraItem('Quálitas', 0.30, const Color(0xFF1E3A8A)),
                      _aseguradoraItem('AXA Seguros', 0.15, const Color(0xFF0284C7)),
                      _aseguradoraItem('Banorte / Otras', 0.10, const Color(0xFF64748B)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 18),

              // Lista de Cumpleaños
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.cake, color: Color(0xFF0284C7), size: 22),
                          SizedBox(width: 8),
                          Text('Cumpleaños este Mes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _cumpleRow('JAIR ENRIQUE GUTIERREZ', '30 de Octubre', '55 7323 0137'),
                      _cumpleRow('ANA GABRIELA FLORES', '27 de Marzo', '55 4857 1620'),
                      _cumpleRow('JUAN CARLOS OJEDA', '05 de Mayo', '55 2595 6583'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _kpiCard(String titulo, String primario, String secundario, IconData icon, Color color, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(titulo, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              Icon(icon, color: color, size: 22),
            ],
          ),
          const SizedBox(height: 10),
          Text(primario, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(secundario, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  static Widget _aseguradoraItem(String nombre, double pct, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(nombre, style: const TextStyle(fontSize: 12)),
            Text('${(pct * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: pct, color: color, backgroundColor: const Color(0xFFE2E8F0), minHeight: 6),
        ],
      ),
    );
  }

  Widget _cumpleRow(String nombre, String fecha, String tel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(fecha, style: const TextStyle(color: Colors.black54, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chat, color: Color(0xFF10B981), size: 20),
            tooltip: 'Felicitar por WhatsApp',
            onPressed: () async {
              final msg = '¡Hola $nombre! De parte de todo el equipo te enviamos una cordial felicitación en tu cumpleaños. ¡Que tengas un excelente día!';
              final uri = Uri.parse('https://wa.me/52${tel.replaceAll(' ', '')}?text=${Uri.encodeComponent(msg)}');
              if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
            },
          )
        ],
      ),
    );
  }
}