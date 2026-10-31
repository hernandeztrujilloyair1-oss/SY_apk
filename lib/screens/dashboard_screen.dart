import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/poliza_model.dart';
import '../services/api_service.dart';
import '../services/empresa_config_service.dart';
import '../services/reglas_negocio_service.dart';
import '../widgets/logo_empresa_widget.dart';
import 'modal_carga_ia.dart';

class MenuItemModel {
  final String titulo;
  final IconData icono;

  const MenuItemModel({required this.titulo, required this.icono});
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _seccionActiva = 'COBRANZA';
  List<PolizaModel> _polizas = [];
  String _busquedaGlobal = '';
  final TextEditingController _searchCtrl = TextEditingController();

  final List<MenuItemModel> _menuItems = const [
    MenuItemModel(titulo: 'ASEGURADOS', icono: Icons.groups),
    MenuItemModel(titulo: 'BUSCADOR', icono: Icons.person_search),
    MenuItemModel(titulo: 'PÓLIZAS', icono: Icons.description),
    MenuItemModel(titulo: 'COBRANZA', icono: Icons.payments),
    MenuItemModel(titulo: 'SINIESTROS', icono: Icons.car_crash),
    MenuItemModel(titulo: 'REPORTES', icono: Icons.bar_chart),
    MenuItemModel(titulo: 'Flotillas e Incisos', icono: Icons.directions_car),
    MenuItemModel(titulo: 'CRM Prospectos', icono: Icons.filter_alt),
    MenuItemModel(titulo: 'TAREAS', icono: Icons.checklist),
    MenuItemModel(titulo: 'About', icono: Icons.info_outline),
    MenuItemModel(titulo: 'App Gallery', icono: Icons.apps),
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() async {
    final list = await ApiService.obtenerPolizas();
    if (mounted) setState(() => _polizas = list);
  }

  void _copiarTexto(String texto, String campo) {
    Clipboard.setData(ClipboardData(text: texto));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$campo copiado: $texto'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF1B365D),
      ),
    );
  }

  void _abrirModalNuevoRegistro() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ModalCargaIa(onGuardado: _cargarDatos),
    );
  }

  void _procesarAtencionCliente(PolizaModel item) {
    final conf = EmpresaConfigService();
    final atendioCtrl = TextEditingController(text: item.atendio.isNotEmpty ? item.atendio : conf.brokerTitular);
    String medioSeleccionado = '2. WhatsApp Directo';
    bool llevaComparativa = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlg) => AlertDialog(
          backgroundColor: const Color(0xFF131F37),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Registro de Atención CRM', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: atendioCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  labelText: '¿Quién atiende?',
                  labelStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Color(0xFF0B1528),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: medioSeleccionado,
                dropdownColor: const Color(0xFF0F172A),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(filled: true, fillColor: Color(0xFF0B1528)),
                items: const [
                  DropdownMenuItem(value: '1. Correo', child: Text('1. Correo Electrónico (con CC)')),
                  DropdownMenuItem(value: '2. WhatsApp Directo', child: Text('2. WhatsApp Directo')),
                  DropdownMenuItem(value: '3. WhatsApp Grupo', child: Text('3. WhatsApp Grupo')),
                ],
                onChanged: (v) => setDlg(() => medioSeleccionado = v!),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('¿Lleva Comparativa?', style: TextStyle(color: Colors.white, fontSize: 13)),
                value: llevaComparativa,
                activeColor: Colors.cyanAccent,
                onChanged: (v) => setDlg(() => llevaComparativa = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.white60))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
              onPressed: () async {
                Navigator.pop(ctx);
                final msg = ReglasNegocioService.armarMensajeWhatsApp(
                  cliente: item.titular,
                  poliza: item.numeroPoliza,
                  ramo: item.ramo,
                  ejecutivoAtencion: atendioCtrl.text.trim(),
                  esGrupo: medioSeleccionado.contains('Grupo'),
                  llevaComparativa: llevaComparativa,
                );

                if (medioSeleccionado.contains('WhatsApp')) {
                  final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(msg)}');
                  if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  final correosCC = ReglasNegocioService.obtenerCorreosCC().join(',');
                  final uri = Uri.parse('mailto:?cc=$correosCC&subject=${Uri.encodeComponent("Gestión de Cobranza ${item.numeroPoliza} - ${conf.nombreDespacho}")}&body=${Uri.encodeComponent(msg)}');
                  if (await canLaunchUrl(uri)) launchUrl(uri);
                }
              },
              child: const Text('Enviar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conf = EmpresaConfigService();
    final bool esPantallaAncha = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2537),
        elevation: 1,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            const LogoEmpresaWidget(size: 32),
            const SizedBox(width: 12),
            Text(
              conf.nombreDespacho.isNotEmpty && conf.nombreDespacho != 'Despacho de Seguros'
                  ? conf.nombreDespacho
                  : 'Sistema Cartera y Operaciones',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Container(
                height: 38,
                margin: const EdgeInsets.symmetric(vertical: 8),
                constraints: const BoxConstraints(maxWidth: 600),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search $_seccionActiva',
                    hintStyle: const TextStyle(color: Colors.white60, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Colors.white60, size: 18),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (val) => setState(() => _busquedaGlobal = val),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white70, size: 20),
            tooltip: 'Sincronizar',
            onPressed: _cargarDatos,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 8),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF0284C7),
              child: Text(
                conf.brokerTitular.isNotEmpty ? conf.brokerTitular[0].toUpperCase() : 'H',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      drawer: esPantallaAncha ? null : Drawer(child: _construirMenuLateral()),
      body: Row(
        children: [
          if (esPantallaAncha)
            SizedBox(
              width: 240,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: _construirMenuLateral(),
              ),
            ),
          Expanded(child: _construirContenidoCentral()),
        ],
      ),
    );
  }

  Widget _construirMenuLateral() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: _menuItems.map((item) {
        final bool seleccionada = _seccionActiva == item.titulo;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: seleccionada ? const Color(0xFFE2E8F0) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            dense: true,
            leading: Icon(
              item.icono,
              size: 20,
              color: seleccionada ? const Color(0xFF0F2537) : const Color(0xFF64748B),
            ),
            title: Text(
              item.titulo,
              style: TextStyle(
                fontSize: 13,
                fontWeight: seleccionada ? FontWeight.bold : FontWeight.w500,
                color: seleccionada ? const Color(0xFF0F2537) : const Color(0xFF334155),
              ),
            ),
            onTap: () {
              setState(() => _seccionActiva = item.titulo);
              if (Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _construirContenidoCentral() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              Text(
                _seccionActiva,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F2537),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                onPressed: _abrirModalNuevoRegistro,
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.filter_list, size: 20, color: Color(0xFF64748B)),
                tooltip: 'Filtrar',
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.check_box_outlined, size: 20, color: Color(0xFF64748B)),
                tooltip: 'Selección múltiple',
                onPressed: () {},
              ),
            ],
          ),
        ),
        Expanded(child: _renderizarDatosSeccion()),
      ],
    );
  }

  Widget _renderizarDatosSeccion() {
    final filtradas = _polizas.where((p) {
      final q = _busquedaGlobal.toLowerCase();
      return p.titular.toLowerCase().contains(q) ||
          p.numeroPoliza.toLowerCase().contains(q) ||
          p.placas.toLowerCase().contains(q) ||
          p.aseguradora.toLowerCase().contains(q);
    }).toList();

    if (filtradas.isEmpty) {
      return const Center(
        child: Text(
          'No items',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtradas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final item = filtradas[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Col B: ${item.avisoEstado}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF334155)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.tipoPersona,
                      style: const TextStyle(color: Color(0xFF0369A1), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\$ ${item.primaNeta.toStringAsFixed(2)} MXN',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.titular,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.aseguradora} | ${item.ramo} | Póliza: ${item.numeroPoliza}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
              Text(
                'Placas: ${item.placas.isEmpty ? "N/A" : item.placas} | Serie: ${item.serie.isEmpty ? "N/A" : item.serie} | Vigencia: ${item.inicioVigencia} al ${item.finVigencia}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('Atiende: ${item.atendio}', style: const TextStyle(fontSize: 11, color: Color(0xFF0284C7), fontWeight: FontWeight.w600)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16, color: Color(0xFF64748B)),
                    tooltip: 'Copiar Póliza',
                    onPressed: () => _copiarTexto(item.numeroPoliza, 'Póliza'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, size: 16, color: Colors.green),
                    tooltip: 'Atención WhatsApp / Correo',
                    onPressed: () => _procesarAtencionCliente(item),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}