import 'package:flutter/material.dart';
import '../services/empresa_config_service.dart';

class ReportesCobranzaVista extends StatefulWidget {
  const ReportesCobranzaVista({super.key});

  @override
  State<ReportesCobranzaVista> createState() => _ReportesCobranzaVistaState();
}

class _ReportesCobranzaVistaState extends State<ReportesCobranzaVista> {
  // Estados de Filtros
  String _tipoReporte = 'Total de recibos por fecha límite';
  final TextEditingController _rangoFechasCtrl =
      TextEditingController(text: '05/07/2026 - 03/11/2027');
  int _limiteResultados = 10;
  bool _filtrarColumnas = false;

  // Filtros secundarios
  String? _grupo;
  String? _subgrupo;
  String? _contratante;
  String? _poliza;
  String? _ramo;
  String? _subramo;
  String? _tipoRamo;
  String? _estatusPoliza;
  String? _conductoPago;
  String? _formaPago;
  String? _vendedor;
  String? _aseguradora;
  String _divisa = 'Todas divisas';
  String _polizaMaestra = 'Todas';

  int _paginaActual = 1;

  // Datos simulados estructurados según tu Google Sheet / Captura
  final List> _registros = [
    {
      'poliza': '0044634A-18',
      'endoso': '',
      'cis': '',
      'carpeta': '',
      'grupos': 'POLIZA INDIVIDUAL',
      'subgrupos': '',
      'concepto': 'VINDI / Rullan Bonilla Alejandra || VIDA CRECIENTE',
      'liquidacion': 'Sin inicio de vigencia',
      'folioLiq': '',
      'folioRecibo': '',
      'vendedor': 'Raúl Alberto Martínez Monroy',
      'vigencia': '05 Oct. 2025',
      'finVigencia': '05 Oct. 2026',
    },
    {
      'poliza': '8245308-11',
      'endoso': '',
      'cis': '',
      'carpeta': '',
      'grupos': 'POLIZA INDIVIDUAL',
      'subgrupos': '',
      'concepto': 'EDUCA / Hernandez Rodriguez Paul Michael',
      'liquidacion': 'Sin inicio de vigencia',
      'folioLiq': '',
      'folioRecibo': '',
      'vendedor': 'Raúl Alberto Martínez Monroy',
      'vigencia': '15 Jun. 2026',
      'finVigencia': '15 Jun. 2027',
    },
    {
      'poliza': '898-117-1',
      'endoso': '',
      'cis': '',
      'carpeta': '',
      'grupos': 'POLIZA INDIVIDUAL',
      'subgrupos': '',
      'concepto':
          'AUTOS / CHIREY / TIGGO 2 PRO LUXURY 5P L4 1.0T. AUT. / 2024 / LVVDB22B8RE003384 / SQRE3T10AHPD00243 / LNW336A',
      'liquidacion': 'Sin inicio de vigencia',
      'folioLiq': '',
      'folioRecibo': '',
      'vendedor': 'Raúl Alberto Martínez Monroy',
      'vigencia': '05 Sep. 2025',
      'finVigencia': '05 Sep. 2026',
    },
    {
      'poliza': 'AUIN-218684-0',
      'endoso': '',
      'cis': '',
      'carpeta': '',
      'grupos': 'POLIZA INDIVIDUAL',
      'subgrupos': '',
      'concepto':
          'AUTOS / AMPLIA / NISSAN / TIIDA SEDAN ADVANCE L4 ISM AUT 4 DIS CA CE TELA CD / 2015 / 3N1BC1AD0FK216989 / MR18043624J / S47AAM',
      'liquidacion': 'Sin inicio de vigencia',
      'folioLiq': '',
      'folioRecibo': '',
      'vendedor': 'Sanchez Talavera Eloisa',
      'vigencia': '05 Mar. 2026',
      'finVigencia': '05 Mar. 2027',
    },
    {
      'poliza': 'EL45003448',
      'endoso': '',
      'cis': '',
      'carpeta': '',
      'grupos': 'POLIZA INDIVIDUAL',
      'subgrupos': '',
      'concepto':
          'AUTOS / HYUNDAI / ACCENT GL L4 MPI AUT 5 ABS CA CE TELA CD SQ CB / 2018 / 3KPC24B54JE004441 / NFE7151',
      'liquidacion': 'Sin inicio de vigencia',
      'folioLiq': '',
      'folioRecibo': '',
      'vendedor': 'Raúl Alberto Martínez Monroy',
      'vigencia': '05 Oct. 2025',
      'finVigencia': '05 Oct. 2026',
    },
    {
      'poliza': 'EL45003450',
      'endoso': '',
      'cis': '',
      'carpeta': '',
      'grupos': 'POLIZA INDIVIDUAL',
      'subgrupos': '',
      'concepto':
          'AUTOS / AMPLIA / CHRYSLER - DODGE / STRATUS TP SE L4 IMP AUT 4 D/T SA SE VELOUR / 2000 / 3B3DJ46X1YT237798 / HECHO EN MEXICO / 161MSL',
      'liquidacion': 'Sin inicio de vigencia',
      'folioLiq': '',
      'folioRecibo': '',
      'vendedor': 'Raúl Alberto Martínez Monroy',
      'vigencia': '05 Oct. 2025',
      'finVigencia': '05 Oct. 2026',
    },
    {
      'poliza': 'EL45003452',
      'endoso': '',
      'cis': '',
      'carpeta': '',
      'grupos': 'POLIZA INDIVIDUAL',
      'subgrupos': '',
      'concepto':
          'AUTOS / VOLKSWAGEN / POLO TSI DSG L4 IMP AUT 3 ABS CA CE TELA SM CQ CB / 2016 / MEX6G2600GT038644 / K76AGS',
      'liquidacion': 'Sin inicio de vigencia',
      'folioLiq': '',
      'folioRecibo': '',
      'vendedor': 'Raúl Alberto Martínez Monroy',
      'vigencia': '05 Oct. 2025',
      'finVigencia': '05 Oct. 2026',
    },
    {
      'poliza': 'GMMI-40262-11',
      'endoso': '',
      'cis': '',
      'carpeta': '',
      'grupos': 'POLIZA INDIVIDUAL',
      'subgrupos': '',
      'concepto': 'GMMI / Martinez Arias Miguel Alejandro / PLAN AMPLIO',
      'liquidacion': 'Sin inicio de vigencia',
      'folioLiq': '',
      'folioRecibo': '',
      'vendedor': 'Raúl Alberto Martínez Monroy',
      'vigencia': '15 Abr. 2026',
      'finVigencia': '15 Abr. 2027',
    },
    {
      'poliza': 'GMMI-80831-3',
      'endoso': '',
      'cis': '',
      'carpeta': '',
      'grupos': 'POLIZA INDIVIDUAL',
      'subgrupos': '',
      'concepto': 'GMMI / Lopez Perez Hector Rafael',
      'liquidacion': 'Sin inicio de vigencia',
      'folioLiq': '',
      'folioRecibo': '',
      'vendedor': 'Raúl Alberto Martínez Monroy',
      'vigencia': '30 Mar. 2026',
      'finVigencia': '30 Mar. 2027',
    },
    {
      'poliza': 'HOFP/00035587-3',
      'endoso': '',
      'cis': '',
      'carpeta': '',
      'grupos': 'RAUL MARTINEZ',
      'subgrupos': '',
      'concepto': 'Hogar // ZACAHUITZCO 112-303',
      'liquidacion': 'Sin inicio de vigencia',
      'folioLiq': '',
      'folioRecibo': '',
      'vendedor': 'Raúl Alberto Martínez Monroy',
      'vigencia': '05 Mar. 2026',
      'finVigencia': '05 Mar. 2027',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TÍTULO Y BOTONERA SUPERIOR
            Row(
              children: [
                const Text(
                  'Reportes cobranza',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF48A6A7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  icon: const Icon(Icons.table_view, size: 16),
                  label: const Text('Previsualizar reporte', style: TextStyle(fontSize: 12)),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF475569),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  icon: const Icon(Icons.link, size: 16),
                  label: const Text('Exportar reporte', style: TextStyle(fontSize: 12)),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF475569),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  icon: const Icon(Icons.chevron_left, size: 16),
                  label: const Text('Ocultar', style: TextStyle(fontSize: 12)),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF475569),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  icon: const Icon(Icons.chevron_left, size: 16),
                  label: const Text('Regresar', style: TextStyle(fontSize: 12)),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 2. MATRIZ DE FILTROS SUPERIORES
            // Fila 1: Tipo Reporte, Rango Fechas, # Resultados
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _dropdownFiltro(
                    'Tipo reporte',
                    _tipoReporte,
                    ['Total de recibos por fecha límite', 'Por fecha de emisión', 'Por fecha de cobro'],
                    (v) => setState(() => _tipoReporte = v!),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Rango de fechas', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 36,
                        child: TextField(
                          controller: _rangoFechasCtrl,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 3,
                  child: _dropdownFiltro(
                    '# de resultados',
                    '$_limiteResultados',
                    ['10', '25', '50', '100'],
                    (v) => setState(() => _limiteResultados = int.parse(v!)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Fila 2: Grupos, Subgrupos, Contratante, Póliza, Ramos, Subramo
            Row(
              children: [
                Expanded(child: _dropdownOpcion('Grupos', _grupo, ['POLIZA INDIVIDUAL', 'FLOTILLA'], (v) => setState(() => _grupo = v))),
                const SizedBox(width: 10),
                Expanded(child: _dropdownOpcion('Subgrupos', _subgrupo, ['Subgrupo 1'], (v) => setState(() => _subgrupo = v))),
                const SizedBox(width: 10),
                Expanded(child: _dropdownOpcion('Contratante', _contratante, ['Persona Física', 'Moral'], (v) => setState(() => _contratante = v))),
                const SizedBox(width: 10),
                Expanded(child: _dropdownOpcion('Póliza', _poliza, ['0044634A-18', '898-117-1'], (v) => setState(() => _poliza = v))),
                const SizedBox(width: 10),
                Expanded(child: _dropdownOpcion('Ramos', _ramo, ['Autos', 'Gastos Médicos', 'Vida', 'Daños'], (v) => setState(() => _ramo = v))),
                const SizedBox(width: 10),
                Expanded(child: _dropdownOpcion('Subramo', _subramo, ['Individual', 'Flotilla'], (v) => setState(() => _subramo = v))),
              ],
            ),
            const SizedBox(height: 12),

            // Fila 3: Tipo ramo, Estatus póliza, Conducto pago, Forma pago, Vendedor, Personal asignado
            Row(
              children: [
                Expanded(child: _dropdownOpcion('Tipo ramo', _tipoRamo, ['Tradicional'], (v) => setState(() => _tipoRamo = v))),
                const SizedBox(width: 10),
                Expanded(child: _dropdownOpcion('Estatus póliza', _estatusPoliza, ['Vigente', 'Cancelada', 'Por vencer'], (v) => setState(() => _estatusPoliza = v))),
                const SizedBox(width: 10),
                Expanded(child: _dropdownOpcion('Conducto de pago', _conductoPago, ['Agente', 'Domiciliado'], (v) => setState(() => _conductoPago = v))),
                const SizedBox(width: 10),
                Expanded(child: _dropdownOpcion('Forma de pago', _formaPago, ['Anual', 'Semestral', 'Trimestral', 'Mensual'], (v) => setState(() => _formaPago = v))),
                const SizedBox(width: 10),
                Expanded(child: _dropdownOpcion('Vendedor', _vendedor, ['Raúl Alberto Martínez Monroy', 'Sanchez Talavera Eloisa'], (v) => setState(() => _vendedor = v))),
                const SizedBox(width: 10),
                Expanded(child: _dropdownOpcion('Personal asignado póliza', null, ['Admin'], (v) {})),
              ],
            ),
            const SizedBox(height: 12),

            // Fila 4: Personal cobro, Personal liquidación, Personal comisión, Aseguradora, Divisa, Póliza maestra
            Row(
              children: [
                Expanded(child: _dropdownOpcion('Personal cobro', null, ['Cobranza 1'], (v) {})),
                const SizedBox(width: 10),
                Expanded(child: _dropdownOpcion('Personal liquidación', null, ['Liquidación 1'], (v) {})),
                const SizedBox(width: 10),
                Expanded(child: _dropdownOpcion('Personal comisión', null, ['Comisión 1'], (v) {})),
                const SizedBox(width: 10),
                Expanded(child: _dropdownOpcion('Aseguradora', _aseguradora, ['Mapfre', 'Quálitas', 'AXA', 'GNP', 'Banorte'], (v) => setState(() => _aseguradora = v))),
                const SizedBox(width: 10),
                Expanded(child: _dropdownFiltro('Divisa', _divisa, ['Todas divisas', 'MXN', 'USD', 'UDIS'], (v) => setState(() => _divisa = v!))),
                const SizedBox(width: 10),
                Expanded(child: _dropdownFiltro('Póliza maestra', _polizaMaestra, ['Todas', 'Sí', 'No'], (v) => setState(() => _polizaMaestra = v!))),
              ],
            ),
            const SizedBox(height: 12),

            // Fila 5: Cis y Checkbox
            Row(
              children: [
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cis', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 36,
                        child: TextField(
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            hintText: 'Buscar',
                            hintStyle: const TextStyle(fontSize: 11, color: Colors.black38),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Checkbox(
                  value: _filtrarColumnas,
                  onChanged: (v) => setState(() => _filtrarColumnas = v ?? false),
                ),
                const Text('Filtrar columnas', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
              ],
            ),
            const SizedBox(height: 10),

            // 3. BARRA DE TOTALES MULTI-DIVISA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(
                  top: BorderSide(color: Color(0xFFE2E8F0)),
                  bottom: BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              child: const Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Desde 05 Jul. 2026 Hasta 03 Nov. 2027', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      Text('Total resultados : 3855 Registros', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    ],
                  ),
                  Spacer(),
                  Text('Total: \$22,941,196.31 MXN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  SizedBox(width: 24),
                  Text('Total: \$71,302.42 USD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  SizedBox(width: 24),
                  Text('Total: \$3,617.37 UDIS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  SizedBox(width: 24),
                  Text('Total: \$3,187.60 UVAC', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 4. TABLA INTERACTIVA CON SCROLL HORIZONTAL
            Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFF0F172A)),
                  headingTextStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  dataRowMinHeight: 38,
                  dataRowMaxHeight: 44,
                  columnSpacing: 16,
                  columns: const [
                    DataColumn(label: Text('Póliza')),
                    DataColumn(label: Text('Endoso')),
                    DataColumn(label: Text('Cis')),
                    DataColumn(label: Text('Carpeta')),
                    DataColumn(label: Text('Grupos')),
                    DataColumn(label: Text('Subgrupos')),
                    DataColumn(label: Text('Concepto')),
                    DataColumn(label: Text('Liquidación')),
                    DataColumn(label: Text('Folio liquidación')),
                    DataColumn(label: Text('Folio recibo')),
                    DataColumn(label: Text('Vendedor')),
                    DataColumn(label: Text('Vigencia')),
                    DataColumn(label: Text('Fin de vigencia')),
                  ],
                  rows: _registros.map((item) {
                    return DataRow(
                      cells: [
                        DataCell(Text(item['poliza']!, style: const TextStyle(fontSize: 11, color: Color(0xFF0284C7), fontWeight: FontWeight.bold))),
                        DataCell(Text(item['endoso']!, style: const TextStyle(fontSize: 11))),
                        DataCell(Text(item['cis']!, style: const TextStyle(fontSize: 11))),
                        DataCell(Text(item['carpeta']!, style: const TextStyle(fontSize: 11))),
                        DataCell(Text(item['grupos']!, style: const TextStyle(fontSize: 11))),
                        DataCell(Text(item['subgrupos']!, style: const TextStyle(fontSize: 11))),
                        DataCell(
                          SizedBox(
                            width: 380,
                            child: Text(
                              item['concepto']!,
                              style: const TextStyle(fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(Text(item['liquidacion']!, style: const TextStyle(fontSize: 11))),
                        DataCell(Text(item['folioLiq']!, style: const TextStyle(fontSize: 11))),
                        DataCell(Text(item['folioRecibo']!, style: const TextStyle(fontSize: 11))),
                        DataCell(Text(item['vendedor']!, style: const TextStyle(fontSize: 11))),
                        DataCell(Text(item['vigencia']!, style: const TextStyle(fontSize: 11))),
                        DataCell(Text(item['finVigencia']!, style: const TextStyle(fontSize: 11))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 5. PAGINADOR
            Row(
              children: [
                _botonPaginador('« Anterior', false, () {}),
                const SizedBox(width: 4),
                for (int p = 1; p <= 10; p++) ...[
                  _botonPaginador('$p', _paginaActual == p, () => setState(() => _paginaActual = p)),
                  const SizedBox(width: 4),
                ],
                const Text(' ... '),
                _botonPaginador('386', false, () => setState(() => _paginaActual = 386)),
                const SizedBox(width: 4),
                _botonPaginador('Siguiente »', false, () {}),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _dropdownFiltro(String label, String valorActual, List<String> opciones, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        const SizedBox(height: 4),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCBD5E1)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: valorActual,
              isExpanded: true,
              style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
              items: opciones.map((op) => DropdownMenuItem(value: op, child: Text(op))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownOpcion(String label, String? valor, List<String> opciones, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)), overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCBD5E1)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: valor,
              hint: const Text('Selecciona una opción', style: TextStyle(fontSize: 11, color: Colors.black38)),
              isExpanded: true,
              style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
              items: opciones.map((op) => DropdownMenuItem(value: op, child: Text(op))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _botonPaginador(String texto, bool activo, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: activo ? const Color(0xFF0284C7) : Colors.white,
          border: Border.all(color: const Color(0xFFCBD5E1)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 12,
            color: activo ? Colors.white : const Color(0xFF0284C7),
            fontWeight: activo ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}