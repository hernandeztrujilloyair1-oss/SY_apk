import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
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
    MenuItemModel(titulo: 'ASEGURADOS', icono: Icons.groups_outlined),
    MenuItemModel(titulo: 'BUSCADOR', icono: Icons.manage_search),
    MenuItemModel(titulo: 'PÓLIZAS', icono: Icons.description_outlined),
    MenuItemModel(titulo: 'COBRANZA', icono: Icons.account_balance_wallet_outlined),
    MenuItemModel(titulo: 'SINIESTROS', icono: Icons.car_crash_outlined),
    MenuItemModel(titulo: 'REPORTES', icono: Icons.insert_chart_outlined),
    MenuItemModel(titulo: 'Flotillas e Incisos', icono: Icons.directions_car_outlined),
    MenuItemModel(titulo: 'CRM Prospectos', icono: Icons.filter_alt_outlined),
    MenuItemModel(titulo: 'TAREAS', icono: Icons.checklist_outlined),
    MenuItemModel(titulo: 'About', icono: Icons.info_outline),
    MenuItemModel(titulo: 'App Gallery', icono: Icons.grid_view_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() async {
    final list = await ApiService.obtenerPolizas(
      tabla: _seccionActiva == 'COBRANZA' ? 'RECIBOS_COBRANZA' : _seccionActiva,
    );
    if (mounted) setState(() => _polizas = list);
  }

  void _copiarTexto(String texto, String campo) {
    Clipboard.setData(ClipboardData(text: texto));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$campo copiado: $texto'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF091428),
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

  void _configurarEmpresa() {
    final conf = EmpresaConfigService();
    final nom = TextEditingController(text: conf.nombreDespacho);
    final lema = TextEditingController(text: conf.lemaDespacho);
    final broker = TextEditingController(text: conf.brokerTitular);
    final contacto = TextEditingController(text: conf.correoContacto);
    final cobranza = TextEditingController(text: conf.correoCobranza);
    String? imgTemp = conf.logoBase64;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlg) => AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
          ),
          title: const Row(
            children: [
              Icon(Icons.workspace_premium, color: Color(0xFFD4AF37)),
              SizedBox(width: 10),
              Text(
                'Personalización de Marca (SaaS)',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: imgTemp != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(base64Decode(imgTemp!), width: 68, height: 68, fit: BoxFit.cover),
                        )
                      : const LogoEmpresaWidget(size: 68),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD4AF37),
                    side: const BorderSide(color: Color(0xFFD4AF37)),
                  ),
                  icon: const Icon(Icons.upload_file, size: 16),
                  label: const Text('Subir Logotipo del Despacho'),
                  onPressed: () async {
                    final r = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
                    if (r != null && r.files.single.bytes != null) {
                      setDlg(() => imgTemp = base64Encode(r.files.single.bytes!));
                    }
                  },
                ),
                const SizedBox(height: 14),
                _campoModal('Razón Social / Nombre Comercial', nom),
                const SizedBox(height: 8),
                _campoModal('Lema o Slogan', lema),
                const SizedBox(height: 8),
                _campoModal('Broker Director / Titular', broker),
                const SizedBox(height: 8),
                _campoModal('Correo Notificaciones Admin', contacto),
                const SizedBox(height: 8),
                _campoModal('Correo Cobranza CC', cobranza),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF0F172A),
              ),
              onPressed: () async {
                await conf.guardar(
                  nuevoNombre: nom.text,
                  nuevoLema: lema.text,
                  nuevoBroker: broker.text,
                  nuevoCorreoContacto: contacto.text,
                  nuevoCorreoCobranza: cobranza.text,
                  nuevoLogo: imgTemp,
                );
                if (mounted) setState(() {});
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Guardar Marca', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoModal(String label, TextEditingController c) {
    return TextField(
      controller: c,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
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
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
          ),
          title: const Text('Gestión de Cobranza y Atención', style: TextStyle(color: Colors.white, fontSize: 16)),
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
                  fillColor: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: medioSeleccionado,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(filled: true, fillColor: Color(0xFF1E293B)),
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
                activeColor: const Color(0xFFD4AF37),
                onChanged: (v) => setDlg(() => llevaComparativa = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF0F172A),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                final msg = ReglasNegocioService.armarMensajeWhatsApp(
                  cliente: item.titular,
                  poliza: item.numeroPoliza,
                  ramo: item.ramo,
                  ejecutivo: atendioCtrl.text.trim(),
                  esGrupo: medioSeleccionado.contains('Grupo'),
                  llevaComparativa: llevaComparativa,
                );

                if (medioSeleccionado.contains('WhatsApp')) {
                  final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(msg)}');
                  if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  final correosCC = ReglasNegocioService.obtenerCorreosCC().join(',');
                  final uri = Uri.parse('mailto:?cc=$correosCC&subject=${Uri.encodeComponent("Gestión de Póliza ${item.numeroPoliza} - ${conf.nombreDespacho}")}&body=${Uri.encodeComponent(msg)}');
                  if (await canLaunchUrl(uri)) launchUrl(uri);
                }
              },
              child: const Text('Enviar Notificación', style: TextStyle(fontWeight: FontWeight.bold)),
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
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF091428),
        elevation: 0,
        titleSpacing: 0,
        leading: esPantallaAncha
            ? null
            : Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
        title: Row(
          children: [
            const SizedBox(width: 14),
            GestureDetector(
              onTap: _configurarEmpresa,
              child: const LogoEmpresaWidget(size: 34),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  conf.nombreDespacho,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: Colors.white,
                  ),
                ),
                Text(
                  conf.lemaDespacho,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, letterSpacing: 0.2),
                ),
              ],
            ),
            const SizedBox(width: 28),
            Expanded(
              child: Container(
                height: 38,
                margin: const EdgeInsets.symmetric(vertical: 8),
                constraints: const BoxConstraints(maxWidth: 620),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search $_seccionActiva (Titular, Póliza, Serie)...',
                    hintStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFD4AF37), size: 18),
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
            icon: const Icon(Icons.sync, color: Color(0xFFD4AF37), size: 20),
            tooltip: 'Sincronizar Cloud Sheets',
            onPressed: _cargarDatos,
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined, color: Colors.white70, size: 20),
            tooltip: 'Marca Blanca',
            onPressed: _configurarEmpresa,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 18, left: 6),
            child: CircleAvatar(
              radius: 15,
              backgroundColor: const Color(0xFFD4AF37),
              child: Text(
                conf.brokerTitular.isNotEmpty ? conf.brokerTitular[0].toUpperCase() : 'D',
                style: const TextStyle(color: Color(0xFF091428), fontSize: 12, fontWeight: FontWeight.bold),
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
              width: 250,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF0B192C),
                  border: Border(right: BorderSide(color: Color(0xFF1E293B))),
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
    return Container(
      color: const Color(0xFF0B192C),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        children: _menuItems.map((item) {
          final bool seleccionada = _seccionActiva == item.titulo;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: seleccionada ? const Color(0xFF1E293B) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: seleccionada
                  ? const Border(left: BorderSide(color: Color(0xFFD4AF37), width: 3.5))
                  : null,
            ),
            child: ListTile(
              dense: true,
              leading: Icon(
                item.icono,
                size: 20,
                color: seleccionada ? const Color(0xFFD4AF37) : const Color(0xFF94A3B8),
              ),
              title: Text(
                item.titulo,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: seleccionada ? FontWeight.bold : FontWeight.w500,
                  color: seleccionada ? Colors.white : const Color(0xFFCBD5E1),
                  letterSpacing: 0.2,
                ),
              ),
              onTap: () {
                setState(() => _seccionActiva = item.titulo);
                _cargarDatos();
                if (Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _construirContenidoCentral() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              Text(
                _seccionActiva,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF091428),
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF091428),
                  foregroundColor: const Color(0xFFD4AF37),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFFD4AF37), width: 0.8),
                  ),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Recibo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                onPressed: _abrirModalNuevoRegistro,
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.filter_list, size: 20, color: Color(0xFF64748B)),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.check_box_outlined, size: 20, color: Color(0xFF64748B)),
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
          p.serie.toLowerCase().contains(q) ||
          p.aseguradora.toLowerCase().contains(q);
    }).toList();

    if (filtradas.isEmpty) {
      return const Center(
        child: Text(
          'No items',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w500),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: filtradas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final item = filtradas[i];
        final bool esPagado = item.avisoEstado.toLowerCase().contains('pagado') ||
            item.avisoEstado.toLowerCase().contains('cobrado');

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: esPagado ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: esPagado
                            ? const Color(0xFF059669).withOpacity(0.3)
                            : const Color(0xFFD97706).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      item.avisoEstado.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        color: esPagado ? const Color(0xFF047857) : const Color(0xFFB45309),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.tipoPersona,
                      style: const TextStyle(color: Color(0xFF475569), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\$ ${item.primaNeta.toStringAsFixed(2)} MXN',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF091428)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
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
                'Vehículo: ${item.bienAsegurado} | Placas: ${item.placas.isEmpty ? "N/A" : item.placas} | Serie: ${item.serie.isEmpty ? "N/A" : item.serie}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Responsable: ${item.atendio}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF0369A1), fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF64748B)),
                    tooltip: 'Copiar Póliza',
                    onPressed: () => _copiarTexto(item.numeroPoliza, 'Póliza'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, size: 16, color: Color(0xFF059669)),
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