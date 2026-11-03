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
import 'dashboard_metricas_vista.dart';
import 'calendario_operativo_vista.dart';
import 'prospectos_tarjetas_vista.dart';
import 'reporte_contratantes_vista.dart';
import 'reportes_cobranza_vista.dart';
import 'cotizador_autos_vista.dart';
import 'cotizador_gmm_vista.dart';
import 'plantillas_screen.dart';

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
  String _seccionActiva = 'DASHBOARD';
  List<PolizaModel> _polizas = [];
  String _busquedaGlobal = '';
  final TextEditingController _searchCtrl = TextEditingController();

  final List<MenuItemModel> _menuItems = const [
    MenuItemModel(titulo: 'DASHBOARD', icono: Icons.dashboard_outlined),
    MenuItemModel(titulo: 'CALENDARIO', icono: Icons.calendar_month_outlined),
    MenuItemModel(titulo: 'PROSPECTOS & TARJETAS', icono: Icons.badge_outlined),
    MenuItemModel(titulo: 'AUDITORÍA CONTRATANTES', icono: Icons.checklist_rtl_outlined),
    MenuItemModel(titulo: 'REPORTES COBRANZA', icono: Icons.insert_chart_outlined),
    MenuItemModel(titulo: 'CARGAR CON IA', icono: Icons.auto_awesome),
    MenuItemModel(titulo: 'BUSCADOR', icono: Icons.manage_search),
    MenuItemModel(titulo: 'PÓLIZAS', icono: Icons.description_outlined),
    MenuItemModel(titulo: 'COBRANZA', icono: Icons.account_balance_wallet_outlined),
    MenuItemModel(titulo: 'COTIZADOR AUTOS', icono: Icons.directions_car),
    MenuItemModel(titulo: 'COTIZADOR GMM', icono: Icons.health_and_safety_outlined),
    MenuItemModel(titulo: 'PLANTILLAS', icono: Icons.message_outlined),
    MenuItemModel(titulo: 'CONFIGURACIÓN', icono: Icons.palette_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    EmpresaConfigService().addListener(_onConfigCambiada);
  }

  @override
  void dispose() {
    EmpresaConfigService().removeListener(_onConfigCambiada);
    super.dispose();
  }

  void _onConfigCambiada() {
    if (mounted) setState(() {});
  }

  void _cargarDatos() async {
    if (_seccionActiva == 'COTIZADOR AUTOS' ||
        _seccionActiva == 'COTIZADOR GMM' ||
        _seccionActiva == 'PLANTILLAS' ||
        _seccionActiva == 'CALENDARIO' ||
        _seccionActiva == 'PROSPECTOS & TARJETAS' ||
        _seccionActiva == 'AUDITORÍA CONTRATANTES' ||
        _seccionActiva == 'REPORTES COBRANZA' ||
        _seccionActiva == 'CONFIGURACIÓN') {
      return;
    }
    final list = await ApiService.obtenerPolizas(
      tabla: _seccionActiva == 'COBRANZA' ? 'RECIBOS_COBRANZA' : 'POLIZAS',
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
    Color colorNavbarTemp = conf.colorNavbar;
    Color colorAcentoTemp = conf.colorAcento;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlg) => AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colorAcentoTemp, width: 1.2),
          ),
          title: Row(
            children: [
              Icon(Icons.palette_outlined, color: colorAcentoTemp),
              const SizedBox(width: 10),
              const Text(
                'Personalización Marca Blanca y Colores (No-Code)',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: imgTemp != null && imgTemp!.isNotEmpty
                              ? Image.memory(base64Decode(imgTemp!), width: 72, height: 72, fit: BoxFit.contain)
                              : const LogoEmpresaWidget(size: 72),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorAcentoTemp,
                            side: BorderSide(color: colorAcentoTemp),
                          ),
                          icon: const Icon(Icons.upload_file, size: 16),
                          label: const Text('Subir Nuevo Logotipo (PNG / JPG)'),
                          onPressed: () async {
                            final r = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
                            if (r != null && r.files.single.bytes != null) {
                              setDlg(() => imgTemp = base64Encode(r.files.single.bytes!));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Identidad Comercial:', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _campoModal('Razón Social / Nombre Comercial', nom),
                  const SizedBox(height: 8),
                  _campoModal('Lema o Slogan', lema),
                  const SizedBox(height: 8),
                  _campoModal('Broker Director / Titular', broker),
                  const SizedBox(height: 8),
                  _campoModal('Correo Notificaciones Admin', contacto),
                  const SizedBox(height: 8),
                  _campoModal('Correo Cobranza (CC)', cobranza),
                  const SizedBox(height: 16),
                  const Text('Paletas de Color (Adaptables al Logo):', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: [
                      _paletaOpcion('Azul Noche / Oro', const Color(0xFF091428), const Color(0xFFD4AF37), () {
                        setDlg(() {
                          colorNavbarTemp = const Color(0xFF091428);
                          colorAcentoTemp = const Color(0xFFD4AF37);
                        });
                      }),
                      _paletaOpcion('Grafito / Esmeralda', const Color(0xFF1E293B), const Color(0xFF10B981), () {
                        setDlg(() {
                          colorNavbarTemp = const Color(0xFF1E293B);
                          colorAcentoTemp = const Color(0xFF10B981);
                        });
                      }),
                      _paletaOpcion('Vino / Ámbar', const Color(0xFF3B0715), const Color(0xFFF59E0B), () {
                        setDlg(() {
                          colorNavbarTemp = const Color(0xFF3B0715);
                          colorAcentoTemp = const Color(0xFFF59E0B);
                        });
                      }),
                      _paletaOpcion('Cobalto / Platino', const Color(0xFF0369A1), const Color(0xFFE2E8F0), () {
                        setDlg(() {
                          colorNavbarTemp = const Color(0xFF0369A1);
                          colorAcentoTemp = const Color(0xFFE2E8F0);
                        });
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorAcentoTemp,
                foregroundColor: const Color(0xFF0F172A),
              ),
              onPressed: () async {
                await conf.guardar(
                  nuevoNombre: nom.text.trim(),
                  nuevoLema: lema.text.trim(),
                  nuevoBroker: broker.text.trim(),
                  nuevoCorreoContacto: contacto.text.trim(),
                  nuevoCorreoCobranza: cobranza.text.trim(),
                  nuevoLogo: imgTemp,
                  nuevoNavbar: colorNavbarTemp,
                  nuevoAcento: colorAcentoTemp,
                );
                if (mounted) setState(() {});
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Guardar y Aplicar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paletaOpcion(String label, Color nav, Color acento, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 14, height: 14, decoration: BoxDecoration(color: nav, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Container(width: 14, height: 14, decoration: BoxDecoration(color: acento, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
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
            side: BorderSide(color: conf.colorAcento, width: 1),
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
                initialValue: medioSeleccionado,
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
                activeThumbColor: conf.colorAcento,
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
                backgroundColor: conf.colorAcento,
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
        backgroundColor: conf.colorNavbar,
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
                    hintText: 'Buscar en $_seccionActiva (Titular, Póliza, Serie)...',
                    hintStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                    prefixIcon: Icon(Icons.search, color: conf.colorAcento, size: 18),
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
            icon: Icon(Icons.auto_awesome, color: conf.colorAcento, size: 20),
            tooltip: 'Cargar Póliza con IA',
            onPressed: _abrirModalNuevoRegistro,
          ),
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white70, size: 20),
            tooltip: 'Sincronizar Cloud Sheets',
            onPressed: _cargarDatos,
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined, color: Colors.white70, size: 20),
            tooltip: 'Personalización No-Code',
            onPressed: _configurarEmpresa,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 18, left: 6),
            child: InkWell(
              onTap: _configurarEmpresa,
              borderRadius: BorderRadius.circular(16),
              child: CircleAvatar(
                radius: 15,
                backgroundColor: conf.colorAcento,
                child: Text(
                  conf.brokerTitular.isNotEmpty ? conf.brokerTitular[0].toUpperCase() : 'U',
                  style: TextStyle(color: conf.colorNavbar, fontSize: 12, fontWeight: FontWeight.bold),
                ),
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
                decoration: BoxDecoration(
                  color: conf.colorSidebar,
                  border: const Border(right: BorderSide(color: Color(0xFF1E293B))),
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
    final conf = EmpresaConfigService();
    return Container(
      color: conf.colorSidebar,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        children: _menuItems.map((item) {
          final bool seleccionada = _seccionActiva == item.titulo;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.5),
            child: Material(
              color: seleccionada ? const Color(0xFF1E293B) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                dense: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: seleccionada
                      ? BorderSide(color: conf.colorAcento, width: 1.5)
                      : BorderSide.none,
                ),
                leading: Icon(
                  item.icono,
                  size: 19,
                  color: seleccionada ? conf.colorAcento : const Color(0xFF94A3B8),
                ),
                title: Text(
                  item.titulo,
                  style: TextStyle(
                    fontSize: 12.5,
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
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _construirContenidoCentral() {
    final conf = EmpresaConfigService();

    switch (_seccionActiva) {
      case 'DASHBOARD':
        return DashboardMetricasVista(
          polizas: _polizas,
          onAbrirCargaIa: _abrirModalNuevoRegistro,
        );
      case 'CALENDARIO':
        return const CalendarioOperativoVista();
      case 'PROSPECTOS & TARJETAS':
        return const ProspectosTarjetasVista();
      case 'AUDITORÍA CONTRATANTES':
        return const ReporteContratantesVista();
      case 'REPORTES COBRANZA':
        return const ReportesCobranzaVista();
      case 'COTIZADOR AUTOS':
        return const CotizadorAutosVista();
      case 'COTIZADOR GMM':
        return const CotizadorGmmVista();
      case 'PLANTILLAS':
        return const PlantillasScreen();
      case 'CARGAR CON IA':
        return Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            constraints: const BoxConstraints(maxWidth: 520),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.document_scanner, size: 54, color: conf.colorAcento),
                const SizedBox(height: 16),
                const Text('Escáner Inteligente de Pólizas y Recibos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                const Text('Sube un PDF o foto. La IA extraerá automáticamente titular, prima, fechas y vehículo para archivarlo en Sheets.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 13)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: conf.colorNavbar,
                    foregroundColor: conf.colorAcento,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('ABRIR ESCÁNER IA', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: _abrirModalNuevoRegistro,
                ),
              ],
            ),
          ),
        );
      case 'CONFIGURACIÓN':
        return Center(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: conf.colorNavbar,
              foregroundColor: conf.colorAcento,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            icon: const Icon(Icons.palette),
            label: const Text('ABRIR PANEL DE MARCA BLANCA Y COLORES'),
            onPressed: _configurarEmpresa,
          ),
        );
      default:
        return _renderizarTablaTradicional();
    }
  }

  Widget _renderizarTablaTradicional() {
    final conf = EmpresaConfigService();
    final filtradas = _polizas.where((p) {
      final q = _busquedaGlobal.toLowerCase();
      return p.titular.toLowerCase().contains(q) ||
          p.numeroPoliza.toLowerCase().contains(q) ||
          p.placas.toLowerCase().contains(q) ||
          p.serie.toLowerCase().contains(q) ||
          p.aseguradora.toLowerCase().contains(q);
    }).toList();

    return Column(
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
                  backgroundColor: conf.colorNavbar,
                  foregroundColor: conf.colorAcento,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: conf.colorAcento, width: 0.8),
                  ),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Recibo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                onPressed: _abrirModalNuevoRegistro,
              ),
            ],
          ),
        ),
        Expanded(
          child: filtradas.isEmpty
              ? const Center(
                  child: Text(
                    'No se encontraron registros en esta sección',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: filtradas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final item = filtradas[i];
                    final bool esPagado = item.avisoEstado.toLowerCase().contains('pagado') ||
                        item.avisoEstado.toLowerCase().contains('cobrado') ||
                        item.avisoEstado.toLowerCase().contains('liquidada');

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
                ),
        ),
      ],
    );
  }
}