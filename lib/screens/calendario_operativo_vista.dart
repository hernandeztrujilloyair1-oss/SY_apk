import 'package:flutter/material.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  DateTime _mesActual = DateTime(2026, 11, 1);
  DateTime _diaSeleccionado = DateTime(2026, 11, 3); // Martes 3 Nov 2026

  // Filtros laterales activos
  bool _filtroCitasProspectos = true;
  bool _filtroCitasContratantes = true;
  bool _filtroTareas = true;
  bool _filtroCobranza = true;
  bool _filtroLimitePago = true;
  bool _filtroCumpleanos = true;
  bool _filtroFeriados = true;

  // Base de tareas y pendientes interactiva
  Map<String, List>> _pendientesPorFecha = {
    '2026-11-03': [
      {
        'tipo': 'Cobranza',
        'titulo': 'Recibo Póliza 5157914 - CRISOFORO PEREZ',
        'hora': '10:00 AM',
        'monto': 7427.31,
        'color': Color(0xFF059669),
        'icono': Icons.monetization_on_outlined,
      },
      {
        'tipo': 'Límite de pago',
        'titulo': 'URGENCIA PAGO - SUAJES Y PREPARACIONES (Mapfre)',
        'hora': '12:00 PM',
        'monto': 123970.27,
        'color': Color(0xFFDC2626),
        'icono': Icons.hourglass_bottom_rounded,
      },
      {
        'tipo': 'Cumpleaños',
        'titulo': 'Cumpleaños: Ing. Gabriel Cortés Fernández',
        'hora': '09:00 AM',
        'color': Color(0xFF0284C7),
        'icono': Icons.cake_outlined,
      },
      {
        'tipo': 'Tarea',
        'titulo': 'Revisión y cotejo de pólizas físicas con portales',
        'hora': '04:00 PM',
        'responsable': 'Yair Hernández',
        'color': Color(0xFF7C3AED),
        'icono': Icons.assignment_outlined,
      },
    ],
    '2026-11-04': [
      {
        'tipo': 'Cobranza',
        'titulo': 'Recibo Quálitas - Jetta Sportline',
        'hora': '11:00 AM',
        'monto': 13989.24,
        'color': Color(0xFF059669),
        'icono': Icons.monetization_on_outlined,
      },
    ],
  };

  String _formatearKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _abrirModalAgregarTarea(DateTime fecha) {
    final tituloCtrl = TextEditingController();
    final horaCtrl = TextEditingController(text: '10:00 AM');
    final descCtrl = TextEditingController();
    String tipoSeleccionado = 'Tarea';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlg) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Row(
            children: [
              const Icon(Icons.add_task_rounded, color: Color(0xFF091428)),
              const SizedBox(width: 8),
              Text(
                'Agregar Pendiente (${fecha.day}/${fecha.month}/${fecha.year})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: tipoSeleccionado,
                  decoration: const InputDecoration(labelText: 'Tipo de Actividad', border: OutlineInputBorder(), isDense: true),
                  items: const [
                    DropdownMenuItem(value: 'Tarea', child: Text('Tarea Operativa / Seguimiento')),
                    DropdownMenuItem(value: 'Citas con prospectos', child: Text('Cita con Prospecto')),
                    DropdownMenuItem(value: 'Citas con contratantes', child: Text('Cita con Contratante')),
                    DropdownMenuItem(value: 'Cobranza', child: Text('Gestión de Cobranza')),
                    DropdownMenuItem(value: 'Límite de pago', child: Text('Alerta de Vencimiento de Pago')),
                  ],
                  onChanged: (v) => setDlg(() => tipoSeleccionado = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tituloCtrl,
                  decoration: const InputDecoration(labelText: 'Título o Detalle del Pendiente', border: OutlineInputBorder(), isDense: true),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: horaCtrl,
                  decoration: const InputDecoration(labelText: 'Hora Programada (ej. 11:30 AM)', border: OutlineInputBorder(), isDense: true),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Notas adicionales o Póliza', border: OutlineInputBorder(), isDense: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF091428),
                foregroundColor: const Color(0xFFD4AF37),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (tituloCtrl.text.trim().isEmpty) return;

                final key = _formatearKey(fecha);
                Color colorItem = const Color(0xFF7C3AED);
                IconData iconoItem = Icons.assignment_outlined;

                if (tipoSeleccionado == 'Cobranza') {
                  colorItem = const Color(0xFF059669);
                  iconoItem = Icons.monetization_on_outlined;
                } else if (tipoSeleccionado == 'Límite de pago') {
                  colorItem = const Color(0xFFDC2626);
                  iconoItem = Icons.hourglass_bottom_rounded;
                } else if (tipoSeleccionado.contains('Cita')) {
                  colorItem = const Color(0xFF0284C7);
                  iconoItem = Icons.calendar_today_outlined;
                }

                setState(() {
                  if (!_pendientesPorFecha.containsKey(key)) {
                    _pendientesPorFecha[key] = [];
                  }
                  _pendientesPorFecha[key]!.add({
                    'tipo': tipoSeleccionado,
                    'titulo': tituloCtrl.text.trim(),
                    'hora': horaCtrl.text.trim(),
                    'desc': descCtrl.text.trim(),
                    'color': colorItem,
                    'icono': iconoItem,
                  });
                });

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pendiente agregado al día ${fecha.day}/${fecha.month}/${fecha.year}.'),
                    backgroundColor: const Color(0xFF059669),
                  ),
                );
              },
              child: const Text('Guardar Tarea'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keySeleccionada = _formatearKey(_diaSeleccionado);
    final listaPendientesDelDia = _pendientesPorFecha[keySeleccionada] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. PANEL LATERAL IZQUIERDO (MINI CALENDARIO Y FILTROS LIMPIOS SIN SIGA-SEGUROS)
          Container(
            width: 260,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _construirMiniCalendario(),
                const SizedBox(height: 16),
                const Divider(),
                
                // AGENDA
                const Text('AGENDA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                _checkboxItem('Citas con prospectos', _filtroCitasProspectos, const Color(0xFF7C3AED), (v) => setState(() => _filtroCitasProspectos = v!)),
                _checkboxItem('Citas con contratantes', _filtroCitasContratantes, const Color(0xFF7C3AED), (v) => setState(() => _filtroCitasContratantes = v!)),
                _checkboxItem('Tareas y Pendientes', _filtroTareas, const Color(0xFF0284C7), (v) => setState(() => _filtroTareas = v!)),

                const SizedBox(height: 14),
                // COBRANZA
                const Text('COBRANZA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                _checkboxItem('Cobranza Activa', _filtroCobranza, const Color(0xFF059669), (v) => setState(() => _filtroCobranza = v!)),
                _checkboxItem('Límite de pago (Urgente)', _filtroLimitePago, const Color(0xFFDC2626), (v) => setState(() => _filtroLimitePago = v!)),

                const SizedBox(height: 14),
                // CLIENTES
                const Text('CLIENTES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                _checkboxItem('Cumpleaños', _filtroCumpleanos, const Color(0xFF0284C7), (v) => setState(() => _filtroCumpleanos = v!)),

                const SizedBox(height: 14),
                // GOOGLE CALENDAR SIN SIGA-SEGUROS
                const Text('CALENDARIOS ACTIVOS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                _checkboxItem('Días feriados oficiales', _filtroFeriados, const Color(0xFF475569), (v) => setState(() => _filtroFeriados = v!)),
              ],
            ),
          ),

          // 2. CUADRÍCULA DEL CALENDARIO PRINCIPAL
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _construirBarraSuperiorCalendario(),
                Expanded(child: _construirGridMes()),
              ],
            ),
          ),

          // 3. PANEL LATERAL DERECHO: PENDIENTES DEL DÍA SELECCIONADO & ACCIÓN DE AGREGAR
          Container(
            width: 320,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Día: ${_diaSeleccionado.day} Nov 2026',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          Text(
                            '${listaPendientesDelDia.length} pendientes programados',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF091428),
                          foregroundColor: const Color(0xFFD4AF37),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        tooltip: 'Agregar nueva tarea a este día',
                        onPressed: () => _abrirModalAgregarTarea(_diaSeleccionado),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: listaPendientesDelDia.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_available_outlined, size: 40, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              const Text('Sin tareas en este día', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.add, size: 14),
                                label: const Text('Crear Tarea'),
                                onPressed: () => _abrirModalAgregarTarea(_diaSeleccionado),
                              )
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: listaPendientesDelDia.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (ctx, i) {
                            final item = listaPendientesDelDia[i];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: (item['color'] as Color).withOpacity(0.3)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: (item['color'] as Color).withOpacity(0.15),
                                    child: Icon(item['icono'] as IconData, size: 15, color: item['color'] as Color),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['titulo'].toString(),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${item['hora']} • ${item['tipo']}',
                                          style: TextStyle(fontSize: 10, color: item['color'] as Color, fontWeight: FontWeight.bold),
                                        ),
                                        if (item['monto'] != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(
                                              '\$ ${(item['monto'] as num).toStringAsFixed(2)} MXN',
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF059669)),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
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

  Widget _construirBarraSuperiorCalendario() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          OutlinedButton(
            onPressed: () => setState(() => _diaSeleccionado = DateTime(2026, 11, 3)),
            child: const Text('Hoy', style: TextStyle(color: Color(0xFF091428), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: () => setState(() => _mesActual = DateTime(_mesActual.year, _mesActual.month - 1)),
          ),
          Text(
            'Noviembre 2026',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: () => setState(() => _mesActual = DateTime(_mesActual.year, _mesActual.month + 1)),
          ),
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF091428),
              foregroundColor: const Color(0xFFD4AF37),
            ),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('NUEVA TAREA'),
            onPressed: () => _abrirModalAgregarTarea(_diaSeleccionado),
          ),
        ],
      ),
    );
  }

  Widget _construirGridMes() {
    final diasSemana = ['LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO', 'DOMINGO'];

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: diasSemana.map((d) {
              return Expanded(
                child: Center(
                  child: Text(d, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.25,
            ),
            itemCount: 35, // 5 semanas
            itemBuilder: (ctx, i) {
              final diaNumero = (i >= 6 && i <= 34) ? (i - 5) : (i < 6 ? (26 + i) : (i - 34));
              final esMesActual = i >= 6 && i <= 34 && diaNumero <= 30;
              final dateCelda = DateTime(2026, 11, esMesActual ? diaNumero : 1);
              final esSeleccionado = esMesActual && diaNumero == _diaSeleccionado.day;
              final keyCelda = _formatearKey(dateCelda);
              final listaItems = esMesActual ? (_pendientesPorFecha[keyCelda] ?? []) : [];

              return InkWell(
                onTap: () {
                  if (esMesActual) {
                    setState(() => _diaSeleccionado = dateCelda);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: esSeleccionado ? const Color(0xFFF0FDF4) : Colors.white,
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: esSeleccionado ? const Color(0xFF091428) : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$diaNumero',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: esSeleccionado ? Colors.white : (esMesActual ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1)),
                              ),
                            ),
                          ),
                          if (esMesActual && diaNumero == 3)
                            const CircleAvatar(radius: 3, backgroundColor: Color(0xFF059669)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (esMesActual && listaItems.isNotEmpty)
                        ...listaItems.take(2).map((it) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: (it['color'] as Color).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              it['titulo'].toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: it['color'] as Color),
                            ),
                          );
                        }),
                      if (listaItems.length > 2)
                        Text('+${listaItems.length - 2} más...', style: const TextStyle(fontSize: 8, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _construirMiniCalendario() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Noviembre 2026', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Icon(Icons.unfold_more, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('L', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('M', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('M', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('J', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('V', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('S', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('D', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _checkboxItem(String titulo, bool valor, Color color, ValueChanged<bool?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: valor,
              activeColor: color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(fontSize: 11, color: Color(0xFF334155)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}