import 'package:flutter/material.dart';

class ReportesCobranzaVista extends StatefulWidget {
  const ReportesCobranzaVista({super.key});

  @override
  State<ReportesCobranzaVista> createState() => _ReportesCobranzaVistaState();
}

class _ReportesCobranzaVistaState extends State<ReportesCobranzaVista> {
  // Categoría seleccionada del menú lateral
  String _categoriaSeleccionada = 'Pólizas';
  
  // Vista actual: 'MENU' o 'LISTADO_POLIZAS'
  String _vistaActual = 'MENU';

  // Controladores y Filtros de la vista "Listado de Pólizas"
  final TextEditingController _rangoFechasCtrl = TextEditingController(text: '05/10/2026 - 03/11/2026');
  String _filtroTipoReporte = 'Listar póliza';
  String _filtroGrupos = 'Todas';
  String _filtroContratante = 'Todos';
  String _filtroPoliza = 'Todas';
  String _filtroRamos = 'Todos';
  String _filtroAseguradora = 'Todas';
  String _filtroEstatus = 'Todas';
  String _filtroConductoPago = 'Todos';
  String _filtroDivisa = 'Todas divisas';
  String _numResultados = '10';

  // Datos de las tarjetas superiores (KPIs)
  final Map<String, dynamic> _kpis = {
    'polizas': {'valor': '9888', 'sub': 'Todas', 'label': 'PÓLIZAS', 'accion': 'Lista pólizas'},
    'contratantes': {'valor': '2562', 'sub': 'Todos', 'label': 'CONTRATANTES', 'accion': 'Total clientes'},
    'nuevas': {'valor': '27', 'sub': 'Del 04 Oct. 2026 al 03 Nov. 2026', 'label': 'NUEVAS', 'accion': 'Pólizas nuevas'},
    'renovadas': {'valor': '54', 'sub': 'Del 04 Oct. 2026 al 03 Nov. 2026', 'label': 'RENOVADAS', 'accion': 'Pólizas renovadas'},
  };

  // Menú lateral de categorías
  final List<String> _categorias = const [
    'Cobranza',
    'Contratantes',
    'Comisiones',
    'Pólizas',
    'CRM',
    'Cancelaciones',
    'Estadísticos',
    'Siniestros',
    'Metas',
    'CHATS',
    'Prospectos',
  ];

  // Subreportes disponibles para "Pólizas"
  final List> final _reportesPolizas = const [
    {'titulo': 'Listado de pólizas', 'icono': Icons.featured_play_list_outlined, 'id': 'LISTADO_POLIZAS'},
    {'titulo': 'Pólizas con endosos con recibos', 'icono': Icons.receipt_long_outlined, 'id': 'ENDOSOS'},
    {'titulo': 'Renovaciones a 45 días', 'icono': Icons.calendar_month_outlined, 'id': 'RENOVACIONES_45'},
    {'titulo': 'Renovaciones por fechas', 'icono': Icons.event_available_outlined, 'id': 'RENOVACIONES_FECHAS'},
    {'titulo': 'Producción emitido', 'icono': Icons.payments_outlined, 'id': 'PRODUCCION'},
    {'titulo': 'Listado de emisión', 'icono': Icons.assignment_outlined, 'id': 'EMISION'},
    {'titulo': 'Reporte autos', 'icono': Icons.directions_car_outlined, 'id': 'AUTOS'},
    {'titulo': 'Reporte GMM', 'icono': Icons.medical_services_outlined, 'id': 'GMM'},
    {'titulo': 'Reporte vida', 'icono': Icons.favorite_border_outlined, 'id': 'VIDA'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título Principal
            const Text(
              'Reportes',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 18),

            // Tarjetas KPI Superiores
            _construirTarjetasKpi(),
            const SizedBox(height: 24),

            // Contenido dinámico (Menú o Filtros de Listado de Pólizas)
            if (_vistaActual == 'MENU')
              _construirPanelMenuReportes()
            else
              _construirVistaListadoPolizas(),
          ],
        ),
      ),
    );
  }

  // 1. Tarjetas KPI
  Widget _construirTarjetasKpi() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = (constraints.maxWidth - (3 * 16)) / 4;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _tarjetaKpiItem(_kpis['polizas'], cardWidth, () {
              setState(() {
                _categoriaSeleccionada = 'Pólizas';
                _vistaActual = 'LISTADO_POLIZAS';
              });
            }),
            _tarjetaKpiItem(_kpis['contratantes'], cardWidth, () {
              setState(() => _categoriaSeleccionada = 'Contratantes');
            }),
            _tarjetaKpiItem(_kpis['nuevas'], cardWidth, () {
              setState(() {
                _categoriaSeleccionada = 'Pólizas';
                _vistaActual = 'LISTADO_POLIZAS';
              });
            }),
            _tarjetaKpiItem(_kpis['renovadas'], cardWidth, () {
              setState(() {
                _categoriaSeleccionada = 'Pólizas';
                _vistaActual = 'LISTADO_POLIZAS';
              });
            }),
          ],
        );
      },
    );
  }

  Widget _tarjetaKpiItem(Map<String, dynamic> data, double width, VoidCallback onTap) {
    return Container(
      width: width < 220 ? double.infinity : width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['valor'],
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      data['label'],
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B), letterSpacing: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  data['sub'],
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    data['accion'],
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
                  ),
                  const Icon(Icons.chevron_right, size: 16, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Panel Principal de Menú de Reportes (2 Columnas)
  Widget _construirPanelMenuReportes() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Menú reportes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna Izquierda: Categorías
              SizedBox(
                width: 220,
                child: Column(
                  children: _categorias.map((cat) {
                    final bool seleccionada = _categoriaSeleccionada == cat;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: InkWell(
                        onTap: () => setState(() => _categoriaSeleccionada = cat),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: seleccionada ? const Color(0xFF2C3E50) : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: seleccionada ? FontWeight.bold : FontWeight.w500,
                              color: seleccionada ? Colors.white : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 24),

              // Columna Derecha: Subreportes correspondientes
              Expanded(
                child: Column(
                  children: _reportesPolizas.map((rep) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: ListTile(
                        dense: true,
                        leading: Icon(rep['icono'] as IconData, size: 18, color: const Color(0xFF475569)),
                        title: Text(
                          rep['titulo'].toString(),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 16, color: Color(0xFF94A3B8)),
                        onTap: () {
                          if (rep['id'] == 'LISTADO_POLIZAS') {
                            setState(() => _vistaActual = 'LISTADO_POLIZAS');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Generando ${rep['titulo']}...')),
                            );
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Vista de Formulario de Filtros: "LISTADO DE POLIZAS"
  Widget _construirVistaListadoPolizas() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado de Listado de Pólizas con Botones
          Row(
            children: [
              const Text(
                'LISTADO DE POLIZAS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: 0.5),
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF409BA5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: const Text('Previsualizar reporte', style: TextStyle(fontSize: 12)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Previsualizando reporte de pólizas...')),
                  );
                },
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF409BA5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.link, size: 16),
                label: const Text('Exportar reporte', style: TextStyle(fontSize: 12)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exportando datos a Excel / CSV...')),
                  );
                },
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.visibility_off_outlined, size: 16),
                label: const Text('Ocultar', style: TextStyle(fontSize: 12)),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF475569),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.chevron_left, size: 16),
                label: const Text('Regresar', style: TextStyle(fontSize: 12)),
                onPressed: () => setState(() => _vistaActual = 'MENU'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Fila 1: Tipo Reporte, Rango Fechas
          Row(
            children: [
              Expanded(
                child: _campoDropdown(
                  'TIPO REPORTE',
                  _filtroTipoReporte,
                  const ['Listar póliza', 'Listar recibos', 'Listar comisiones'],
                  (v) => setState(() => _filtroTipoReporte = v!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _campoTexto('Rango de fechas', _rangoFechasCtrl),
              ),
              const Expanded(child: SizedBox()),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 16),

          // Fila 2: Grupos, Subgrupos, Contratante, Póliza, Ramos, Subramo
          Row(
            children: [
              Expanded(
                child: _campoDropdown(
                  'Grupos',
                  _filtroGrupos,
                  const ['Todas', 'Flotillas', 'Individual', 'Corporativo'],
                  (v) => setState(() => _filtroGrupos = v!),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _campoDropdown(
                  'Subgrupos',
                  'Selecciona una opción',
                  const ['Selecciona una opción', 'Sub 1', 'Sub 2'],
                  (v) {},
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _campoDropdown(
                  'Contratante',
                  _filtroContratante,
                  const ['Todos', 'GRUPO INDUSTRIAL MEXICANO', 'CRISOFORO PEREZ', 'JAIR GUTIERREZ'],
                  (v) => setState(() => _filtroContratante = v!),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _campoDropdown(
                  'Póliza',
                  _filtroPoliza,
                  const ['Todas', '01-554-998234', '5157914', '4112500297698'],
                  (v) => setState(() => _filtroPoliza = v!),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _campoDropdown(
                  'Ramos',
                  _filtroRamos,
                  const ['Todos', 'Autos', 'Gastos Médicos', 'Vida', 'Daños'],
                  (v) => setState(() => _filtroRamos = v!),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _campoDropdown(
                  'Subramo',
                  'Selecciona una opción',
                  const ['Selecciona una opción', 'Sedán', 'Pick Up', 'Flotilla'],
                  (v) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Fila 3: Tipo ramo, Estatus póliza, Conducto de pago, Vendedor, Personal asignado, Aseguradora
          Row(
            children: [
              Expanded(
                child: _campoDropdown(
                  'Tipo ramo',
                  'Selecciona una opción',
                  const ['Selecciona una opción', 'Tradicional', 'Especial'],
                  (v) {},
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _campoDropdown(
                  'Estatus póliza',
                  _filtroEstatus,
                  const ['Todas', 'Vigente', 'Cancelada', 'Por renovar'],
                  (v) => setState(() => _filtroEstatus = v!),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _campoDropdown(
                  'Conducto de pago',
                  _filtroConductoPago,
                  const ['Todos', 'Tarjeta Débito/Crédito', 'Transferencia', 'Efectivo'],
                  (v) => setState(() => _filtroConductoPago = v!),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _campoDropdown(
                  'Vendedor',
                  'Selecciona una opción',
                  const ['Selecciona una opción', 'Raúl Martínez', 'Yair Hernández'],
                  (v) {},
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _campoDropdown(
                  'Personal asignado póliza',
                  'Selecciona una opción',
                  const ['Selecciona una opción', 'Dirección General', 'Cobranza'],
                  (v) {},
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _campoDropdown(
                  'Aseguradora',
                  _filtroAseguradora,
                  const ['Todas', 'Quálitas', 'GNP', 'AXA', 'Mapfre'],
                  (v) => setState(() => _filtroAseguradora = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Fila 4: Divisa, Póliza maestra, Cis
          Row(
            children: [
              Expanded(
                child: _campoDropdown(
                  'Divisa',
                  _filtroDivisa,
                  const ['Todas divisas', 'MXN', 'USD'],
                  (v) => setState(() => _filtroDivisa = v!),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _campoDropdown(
                  'Póliza maestra',
                  'Todas',
                  const ['Todas', 'Maestra 1', 'Maestra 2'],
                  (v) {},
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _campoDropdown(
                  'Cis',
                  'Buscar',
                  const ['Buscar', 'Opción 1', 'Opción 2'],
                  (v) {},
                ),
              ),
              const Expanded(child: SizedBox()),
              const Expanded(child: SizedBox()),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 16),

          // Fila 5: # de resultados
          Row(
            children: [
              SizedBox(
                width: 180,
                child: _campoDropdown(
                  '# de resultados',
                  _numResultados,
                  const ['10', '25', '50', '100'],
                  (v) => setState(() => _numResultados = v!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Componente de Campo Dropdown con borde punteado suave
  Widget _campoDropdown(String label, String valor, List<String> opciones, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: valor,
              isExpanded: true,
              style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
              items: opciones.map((op) {
                return DropdownMenuItem<String>(
                  value: op,
                  child: Text(op, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // Componente de Campo de Texto
  Widget _campoTexto(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}