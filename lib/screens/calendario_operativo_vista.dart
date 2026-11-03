import 'package:flutter/material.dart';

class CalendarioOperativoVista extends StatefulWidget {
  const CalendarioOperativoVista({super.key});

  @override
  State<CalendarioOperativoVista> createState() => _CalendarioOperativoVistaState();
}

class _CalendarioOperativoVistaState extends State<CalendarioOperativoVista> {
  String _vistaSeleccionada = 'Mes';
  bool _mantenerFiltros = false;

  // Filtros laterales
  final Map<String, bool> _filtros = {
    'Citas con prospectos': true,
    'Citas con contratantes': true,
    'Tareas': true,
    'Cirugía': false,
    'Cobranza': true,
    'Límite de pago': true,
    'Programación de cobranza': false,
    'Renovaciones': false,
    'Emisiones': false,
    'Inicio de vigencia': false,
    'Cumpleaños': true,
    'Saludos': false,
    'Días feriados en México': true,
    'SIGA-SEGUROS': true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PANEL LATERAL DE FILTROS & MINICALENDARIO
          Container(
            width: 250,
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: ListView(
              padding: const EdgeInsets.all(14),
              children: [
                _construirMiniCalendario(),
                const SizedBox(height: 16),
                const Divider(),
                _encabezadoSeccionFiltro('AGENDA'),
                _checkFiltro('Citas con prospectos', const Color(0xFF9333EA)),
                _checkFiltro('Citas con contratantes', const Color(0xFF7C3AED)),
                _checkFiltro('Tareas', const Color(0xFF0284C7)),
                _checkFiltro('Cirugía', const Color(0xFFE11D48)),
                const SizedBox(height: 12),
                _encabezadoSeccionFiltro('COBRANZA'),
                _checkFiltro('Cobranza', const Color(0xFF10B981)),
                _checkFiltro('Límite de pago', const Color(0xFFEF4444)),
                _checkFiltro('Programación de cobranza', const Color(0xFF059669)),
                const SizedBox(height: 12),
                _encabezadoSeccionFiltro('PÓLIZAS'),
                _checkFiltro('Renovaciones', const Color(0xFFD97706)),
                _checkFiltro('Emisiones', const Color(0xFF6366F1)),
                _checkFiltro('Inicio de vigencia', const Color(0xFF3B82F6)),
                const SizedBox(height: 12),
                _encabezadoSeccionFiltro('CLIENTES'),
                _checkFiltro('Cumpleaños', const Color(0xFF0EA5E9)),
                _checkFiltro('Saludos', const Color(0xFF64748B)),
                const SizedBox(height: 12),
                _encabezadoSeccionFiltro('GOOGLE CALENDAR'),
                _checkFiltro('Días feriados en México', const Color(0xFF475569)),
                _checkFiltro('SIGA-SEGUROS', const Color(0xFF0F172A)),
              ],
            ),
          ),

          // MATRIZ PRINCIPAL DEL CALENDARIO
          Expanded(
            child: Column(
              children: [
                // Barra Superior del Calendario
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: Row(
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () {},
                        child: const Text('Hoy', style: TextStyle(color: Color(0xFF1E293B), fontSize: 13)),
                      ),
                      const SizedBox(width: 8),
                      IconButton(icon: const Icon(Icons.chevron_left, size: 20), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.chevron_right, size: 20), onPressed: () {}),
                      const SizedBox(width: 8),
                      const Text(
                        'Noviembre 2026',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(width: 14),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF48A6A7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        icon: const Icon(Icons.filter_list, size: 16),
                        label: const Text('Filtros', style: TextStyle(fontSize: 12)),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          Switch(
                            value: _mantenerFiltros,
                            activeColor: const Color(0xFF48A6A7),
                            onChanged: (v) => setState(() => _mantenerFiltros = v),
                          ),
                          const Text('Mantener filtros', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                      const Spacer(),
                      // Botonera de Vistas
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: ['Mes', 'Semana', 'Día', 'Día por agente', 'Agenda'].map((vista) {
                            final sel = _vistaSeleccionada == vista;
                            return InkWell(
                              onTap: () => setState(() => _vistaSeleccionada = vista),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: sel ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: sel ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
                                ),
                                child: Text(
                                  vista,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                                    color: sel ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Encabezados de Días de la Semana
                Container(
                  color: const Color(0xFFF8FAFC),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: ['LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO', 'DOMINGO']
                        .map((dia) => Expanded(
                              child: Center(
                                child: Text(
                                  dia,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),

                // Cuadrícula Mensual
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1.15,
                    ),
                    itemCount: 35, // 5 semanas
                    itemBuilder: (context, index) {
                      final diaNumero = (index - 1) <= 0 ? (26 + index) : (index - 1);
                      final bool esMesActual = index >= 2 && index <= 31;
                      final bool esHoy = diaNumero == 3 && esMesActual;

                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
                          color: esHoy ? const Color(0xFFF0FDF4) : Colors.white,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: esHoy
                                    ? const BoxDecoration(color: Color(0xFF0F172A), shape: BoxShape.circle)
                                    : null,
                                child: Text(
                                  '$diaNumero',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: esHoy ? FontWeight.bold : FontWeight.w600,
                                    color: esHoy
                                        ? Colors.white
                                        : (esMesActual ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)),
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (esMesActual) ...[
                              _badgeEvento('Cobranza', '${(diaNumero * 2) % 15 + 4}', const Color(0xFFECFDF5), const Color(0xFF059669), Icons.attach_money),
                              const SizedBox(height: 2),
                              _badgeEvento('Cumpleaños', '${(diaNumero * 3) % 10 + 1}', const Color(0xFFF0F9FF), const Color(0xFF0284C7), Icons.cake),
                              const SizedBox(height: 2),
                              _badgeEvento('Límite de pago', '${(diaNumero * 4) % 8 + 1}', const Color(0xFFFEF2F2), const Color(0xFFDC2626), Icons.hourglass_bottom),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirMiniCalendario() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('« Noviembre 2026 »', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('LU', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('MA', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('MI', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('JU', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('VI', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('SA', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('DO', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: List.generate(31, (i) => SizedBox(
              width: 18,
              height: 18,
              child: Center(
                child: Text('${i + 1}', style: TextStyle(fontSize: 9, fontWeight: i + 1 == 3 ? FontWeight.bold : FontWeight.normal, color: i + 1 == 3 ? Colors.blue : Colors.black87)),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _encabezadoSeccionFiltro(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(titulo, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
    );
  }

  Widget _checkFiltro(String etiqueta, Color color) {
    final bool activo = _filtros[etiqueta] ?? false;
    return InkWell(
      onTap: () => setState(() => _filtros[etiqueta] = !activo),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: activo,
                activeColor: color,
                onChanged: (v) => setState(() => _filtros[etiqueta] = v ?? false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(etiqueta, style: const TextStyle(fontSize: 11, color: Color(0xFF334155)), overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badgeEvento(String etiqueta, String conteo, Color fondo, Color texto, IconData icono) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(4)),
      child: Row(
        children: [
          Icon(icono, size: 10, color: texto),
          const SizedBox(width: 4),
          Text(conteo, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: texto)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(etiqueta, style: TextStyle(fontSize: 9, color: texto), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}