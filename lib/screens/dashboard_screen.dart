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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tabSeleccionada = 0; // 0: BASE, 1: COTIZADOR, 2: ALTAS-BAJAS
  List<PolizaModel> _polizas = [];
  String _busqueda = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargar();
    _revisarAlertaViernes();
  }

  void _revisarAlertaViernes() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ReglasNegocioService.debeAlertarViernesImpresion()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.print, color: Colors.amber),
                SizedBox(width: 10),
                Expanded(child: Text('Alerta de Viernes 4:00 PM: Revisar e imprimir pestañas físicas pendientes.')),
              ],
            ),
            backgroundColor: Color(0xFF1E293B),
            duration: Duration(seconds: 6),
          ),
        );
      }
    });
  }

  void _cargar() async {
    final res = await ApiService.obtenerPolizas();
    if (mounted) setState(() => _polizas = res);
  }

  void _copiar(String txt, String tipo) {
    Clipboard.setData(ClipboardData(text: txt));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$tipo copiado: $txt'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF1B365D),
      ),
    );
  }

  void _procesarEnvio(PolizaModel item) {
    final conf = EmpresaConfigService();
    final atendioCtrl = TextEditingController(text: item.atendio.isNotEmpty ? item.atendio : conf.brokerTitular);
    String medio = 'WhatsApp Directo';
    bool llevaComparativa = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF131F37),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: const Text('¿Qué medio usarás para contactar?', style: TextStyle(color: Colors.white, fontSize: 16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: atendioCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: '¿Quién atiende?',
                    labelStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF0B1528),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: medio,
                  dropdownColor: const Color(0xFF0F172A),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Medio de Comunicación',
                    filled: true,
                    fillColor: const Color(0xFF0B1528),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'WhatsApp Directo', child: Text('WhatsApp Directo')),
                    DropdownMenuItem(value: 'WhatsApp Grupo', child: Text('WhatsApp Grupo')),
                    DropdownMenuItem(value: 'Correo', child: Text('Correo Electrónico (con CC)')),
                  ],
                  onChanged: (v) => setDlgState(() => medio = v!),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('¿Lleva Comparativa?', style: TextStyle(color: Colors.white, fontSize: 13)),
                  value: llevaComparativa,
                  activeColor: Colors.cyanAccent,
                  onChanged: (v) => setDlgState(() => llevaComparativa = v),
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
                    esGrupo: medio == 'WhatsApp Grupo',
                    llevaComparativa: llevaComparativa,
                  );

                  if (medio.contains('WhatsApp')) {
                    final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(msg)}');
                    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    final correosCC = ReglasNegocioService.obtenerCorreosCC().join(',');
                    final uri = Uri.parse('mailto:?cc=$correosCC&subject=${Uri.encodeComponent("Actualización de Póliza ${item.numeroPoliza} - ${conf.nombreDespacho}")}&body=${Uri.encodeComponent(msg)}');
                    if (await canLaunchUrl(uri)) launchUrl(uri);
                  }
                },
                child: const Text('Enviar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
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
          backgroundColor: const Color(0xFF131F37),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Row(
            children: [
              Icon(Icons.palette, color: Colors.cyanAccent),
              SizedBox(width: 8),
              Text('Marca Blanca del Despacho', style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: imgTemp != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Image.memory(base64Decode(imgTemp!), width: 64, height: 64, fit: BoxFit.cover),
                        )
                      : const LogoEmpresaWidget(size: 64),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.cyanAccent),
                  icon: const Icon(Icons.upload, size: 16),
                  label: const Text('Subir Logo del Despacho (PNG/JPG)'),
                  onPressed: () async {
                    final r = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
                    if (r != null && r.files.single.bytes != null) {
                      setDlg(() => imgTemp = base64Encode(r.files.single.bytes!));
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nom,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(labelText: 'Nombre Comercial del Despacho', filled: true, fillColor: Color(0xFF0B1528)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: lema,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(labelText: 'Lema o Giro', filled: true, fillColor: Color(0xFF0B1528)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: broker,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(labelText: 'Broker Director o Titular', filled: true, fillColor: Color(0xFF0B1528)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: contacto,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(labelText: 'Correo Dirección / Contacto CC', filled: true, fillColor: Color(0xFF0B1528)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: cobranza,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(labelText: 'Correo Cobranza CC', filled: true, fillColor: Color(0xFF0B1528)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.white60))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
              onPressed: () async {
                await conf.guardar(
                  nuevoNombre: nom.text,
                  nuevoLema: lema.text,
                  nuevoBroker: broker.text,
                  nuevoCorreoContacto: contacto.text,
                  nuevoCorreoCobranza: cobranza.text,
                  nuevoLogo: imgTemp,
                );
                setState(() {});
                Navigator.pop(ctx);
              },
              child: const Text('Guardar y Aplicar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conf = EmpresaConfigService();
    final filtradas = _polizas.where((p) {
      final q = _busqueda.toLowerCase();
      return p.numeroPoliza.toLowerCase().contains(q) ||
          p.titular.toLowerCase().contains(q) ||
          p.placas.toLowerCase().contains(q) ||
          p.rfc.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A1120),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131F37),
        elevation: 1,
        title: Row(
          children: [
            GestureDetector(onTap: _configurarEmpresa, child: const LogoEmpresaWidget(size: 34)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(conf.nombreDespacho, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                  Text(conf.lemaDespacho, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.palette, color: Colors.cyanAccent, size: 20), tooltip: 'Marca Blanca', onPressed: _configurarEmpresa),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
              icon: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
              label: const Text('Llenar Póliza / IA', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: () => showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => ModalCargaIa(onGuardado: _cargar),
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF131F37),
        indicatorColor: const Color(0xFF0284C7),
        selectedIndex: _tabSeleccionada,
        onDestinationSelected: (idx) => setState(() => _tabSeleccionada = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.table_chart, color: Colors.white70), label: 'BASE'),
          NavigationDestination(icon: Icon(Icons.calculate, color: Colors.white70), label: 'COTIZADOR'),
          NavigationDestination(icon: Icon(Icons.swap_horiz, color: Colors.white70), label: 'ALTAS-BAJAS'),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                _kpi('Activas', '${_polizas.length}', Icons.shield, Colors.blue),
                const SizedBox(width: 8),
                _kpi('Avisos Col B', '${_polizas.where((e) => e.avisoEstado != conf.brokerTitular).length}', Icons.notifications_active, Colors.orange),
                const SizedBox(width: 8),
                _kpi('Art. 492', '94% OK', Icons.verified_user, Colors.green),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: const Color(0xFF131F37), borderRadius: BorderRadius.circular(10)),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Buscar por titular, póliza, RFC o placas...',
                  hintStyle: TextStyle(color: Colors.white54, fontSize: 12),
                  prefixIcon: Icon(Icons.search, color: Colors.white54, size: 18),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onChanged: (v) => setState(() => _busqueda = v),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtradas.isEmpty
                  ? const Center(child: Text('Sin registros disponibles', style: TextStyle(color: Colors.white54)))
                  : ListView.separated(
                      itemCount: filtradas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        final item = filtradas[i];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF131F37),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: item.avisoEstado == conf.brokerTitular ? Colors.purple.withOpacity(0.3) : Colors.amber.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text('Col B: ${item.avisoEstado}',
                                        style: TextStyle(
                                          color: item.avisoEstado == conf.brokerTitular ? Colors.purpleAccent : Colors.amberAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        )),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(item.tipoPersona, style: const TextStyle(color: Colors.cyanAccent, fontSize: 10)),
                                  ),
                                  const Spacer(),
                                  Text('\$ ${item.primaNeta.toStringAsFixed(2)} MXN',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(item.titular, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text('${item.aseguradora} | ${item.ramo} | Póliza: ${item.numeroPoliza}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              Text('Vigencia: ${item.inicioVigencia} al ${item.finVigencia} | Placas: ${item.placas.isEmpty ? "N/A" : item.placas}',
                                  style: const TextStyle(color: Colors.white54, fontSize: 11)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text('Atiende: ${item.atendio}', style: const TextStyle(color: Colors.cyanAccent, fontSize: 11)),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 16, color: Colors.white70),
                                    tooltip: 'Copiar Póliza',
                                    onPressed: () => _copiar(item.numeroPoliza, 'Póliza'),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.send, size: 16, color: Colors.greenAccent),
                                    tooltip: 'Notificar WhatsApp/Correo',
                                    onPressed: () => _procesarEnvio(item),
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
        ),
      ),
    );
  }

  Widget _kpi(String titulo, String valor, IconData ico, Color c) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFF131F37), borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            CircleAvatar(radius: 14, backgroundColor: c.withOpacity(0.2), child: Icon(ico, size: 14, color: c)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(titulo, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  Text(valor, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}