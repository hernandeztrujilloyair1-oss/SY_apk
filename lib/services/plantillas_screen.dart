import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../services/empresa_config_service.dart';

class PlantillasScreen extends StatefulWidget {
  const PlantillasScreen({super.key});

  @override
  State<PlantillasScreen> createState() => _PlantillasScreenState();
}

class _PlantillasScreenState extends State<PlantillasScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Endpoint de integración (Google Sheets / Web App)
  final TextEditingController _webhookCtrl = TextEditingController();

  // Controladores de Edición
  final TextEditingController _asuntoCtrl = TextEditingController();
  final TextEditingController _cuerpoCtrl = TextEditingController();

  // Filtros de Segmentación
  String _filtroCompania = 'TODAS';
  String _filtroFrecuencia = 'TODAS';
  String _filtroRubro = 'TODOS';
  DateTime _fechaEnvio = DateTime.now();
  bool _esHtml = true;
  bool _enviando = false;

  // Índice de la plantilla seleccionada
  int _plantillaActivaIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarPlantilla(0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Generador de plantillas en HTML Premium con Marca Blanca
  String _generarHtmlPremium({
    required String tipo,
    required String tituloHeader,
    required String contenidoHtml,
    required String footerNota,
  }) {
    final conf = EmpresaConfigService();
    final hexNavbar = '#${conf.colorNavbar.value.toRadixString(16).substring(2)}';
    final hexAcento = '#${conf.colorAcento.value.toRadixString(16).substring(2)}';
    final logoSrc = conf.logoBase64 != null && conf.logoBase64!.isNotEmpty
        ? 'data:image/png;base64,${conf.logoBase64}'
        : conf.logoDefaultUrl;

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #F1F5F9; margin: 0; padding: 20px; }
    .card { max-width: 620px; margin: 0 auto; background-color: #FFFFFF; border-radius: 14px; overflow: hidden; border: 1px solid #E2E8F0; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
    .header { background: linear-gradient(135deg, $hexNavbar 0%, #0F172A 100%); padding: 30px 24px; text-align: center; border-bottom: 3px solid $hexAcento; }
    .logo { max-height: 65px; margin-bottom: 12px; }
    .header-title { color: #FFFFFF; font-size: 19px; font-weight: 700; margin: 0; letter-spacing: 0.5px; }
    .header-sub { color: #94A3B8; font-size: 11px; margin-top: 5px; text-transform: uppercase; letter-spacing: 1px; }
    .content { padding: 30px 28px; color: #1E293B; line-height: 1.6; font-size: 13.5px; }
    .badge { display: inline-block; background-color: $hexAcento; color: $hexNavbar; font-weight: 800; font-size: 11px; padding: 4px 10px; border-radius: 6px; text-transform: uppercase; margin-bottom: 15px; }
    .table-data { width: 100%; border-collapse: separate; border-spacing: 0; margin: 20px 0; border: 1px solid #E2E8F0; border-radius: 8px; overflow: hidden; }
    .table-data td { padding: 11px 14px; font-size: 13px; border-bottom: 1px solid #F1F5F9; }
    .table-data tr:nth-child(even) { background-color: #F8FAFC; }
    .table-data tr:last-child td { border-bottom: none; }
    .td-label { font-weight: 700; color: #475569; width: 40%; }
    .td-val { font-weight: 600; color: #0F172A; }
    .highlight-box { background-color: #FEF3C7; border-left: 4px solid #D97706; padding: 12px 16px; border-radius: 4px; margin: 20px 0; font-size: 12.5px; color: #92400E; }
    .footer { background-color: #F8FAFC; padding: 22px 28px; border-top: 1px solid #E2E8F0; text-align: center; font-size: 11px; color: #64748B; }
    .footer-brand { font-weight: 800; color: #0F172A; font-size: 12px; }
    .btn { display: inline-block; background-color: $hexNavbar; color: $hexAcento !important; text-decoration: none; font-weight: 700; padding: 11px 24px; border-radius: 7px; margin-top: 10px; border: 1px solid $hexAcento; }
  </style>
</head>
<body>
  <div class="card">
    <div class="header">
      <img src="$logoSrc" alt="${conf.nombreDespacho}" class="logo" /><br/>
      <h1 class="header-title">$tituloHeader</h1>
      <div class="header-sub">${conf.lemaDespacho}</div>
    </div>
    <div class="content">
      $contenidoHtml
    </div>
    <div class="footer">
      <div class="footer-brand">${conf.nombreDespacho}</div>
      <div>Broker Titular: ${conf.brokerTitular} | Atención: {ASESOR}</div>
      <div style="margin-top: 6px;">$footerNota</div>
      <div style="margin-top: 10px; font-size: 10px; color: #94A3B8;">Firma de Auditoría del Sistema: ES-SAAS-SECURE-ID-{POLIZA}</div>
    </div>
  </div>
</body>
</html>
''';
  }

  void _cargarPlantilla(int index) {
    final conf = EmpresaConfigService();
    setState(() {
      _plantillaActivaIndex = index;
      switch (index) {
        case 0:
          // 1. Cobranza Preventiva & Vencimiento
          _asuntoCtrl.text = 'Aviso de Pago | Póliza {POLIZA} - ${conf.nombreDespacho}';
          _cuerpoCtrl.text = _generarHtmlPremium(
            tipo: 'COBRANZA',
            tituloHeader: 'ESTADO DE CUENTA Y AVISO DE COBRO',
            contenidoHtml: '''
<div class="badge">Aviso de Cobranza Oficial</div>
<p>Estimado(a) <strong>{TITULAR}</strong>,</p>
<p>Le saludamos con gusto de parte de <strong>${conf.nombreDespacho}</strong>. Le recordamos que su póliza presenta un vencimiento próximo programado. Mantener su pago al corriente garantiza el respaldo total de sus coberturas ante cualquier eventualidad.</p>

<table class="table-data">
  <tr><td class="td-label">Titular Asegurado:</td><td class="td-val">{TITULAR}</td></tr>
  <tr><td class="td-label">Póliza / Documento:</td><td class="td-val">{POLIZA}</td></tr>
  <tr><td class="td-label">Aseguradora:</td><td class="td-val">{COMPANIA}</td></tr>
  <tr><td class="td-label">Ramo / Cobertura:</td><td class="td-val">{RUBRO}</td></tr>
  <tr><td class="td-label">Bien Asegurado:</td><td class="td-val">{VEHICULO}</td></tr>
  <tr><td class="td-label">Frecuencia de Pago:</td><td class="td-val">{FRECUENCIA}</td></tr>
  <tr><td class="td-label">Monto a Liquidar:</td><td class="td-val" style="color: #059669; font-size: 15px; font-weight: 800;">\${PRIMA} MXN</td></tr>
  <tr><td class="td-label">Fecha Límite:</td><td class="td-val" style="color: #D97706; font-weight: 800;">{FECHA_PAGO}</td></tr>
</table>

<div class="highlight-box">
  <strong>Importante:</strong> Para reportar su pago o domiciliar con tarjeta de crédito/débito bancaria, por favor responda a este correo adjuntando su comprobante.
</div>
<p style="text-align: center;">
  <a href="mailto:${conf.correoCobranza}?subject=Comprobante%20de%20Pago%20{POLIZA}" class="btn">REPORTAR COMPROBANTE DE PAGO</a>
</p>
''',
            footerNota: 'Canales oficiales: ${conf.correoContacto} | Cobranza: ${conf.correoCobranza}',
          );
          break;

        case 1:
          // 2. Renovación de Cartera
          _asuntoCtrl.text = 'Propuesta de Renovación | Póliza {POLIZA} - ${conf.nombreDespacho}';
          _cuerpoCtrl.text = _generarHtmlPremium(
            tipo: 'RENOVACION',
            tituloHeader: 'RENOVACIÓN ANUAL DE SU PÓLIZA',
            contenidoHtml: '''
<div class="badge">Continuidad Patrimonial</div>
<p>Estimado(a) <strong>{TITULAR}</strong>,</p>
<p>Es un honor acompañarle en la protección de su patrimonio. Su póliza contratada con <strong>{COMPANIA}</strong> está próxima a cumplir su vigencia anual y hemos estructurado la renovación con condiciones preferenciales.</p>

<table class="table-data">
  <tr><td class="td-label">Póliza Actual:</td><td class="td-val">{POLIZA}</td></tr>
  <tr><td class="td-label">Compañía Emisora:</td><td class="td-val">{COMPANIA}</td></tr>
  <tr><td class="td-label">Bien o Interés Cubierto:</td><td class="td-val">{VEHICULO}</td></tr>
  <tr><td class="td-label">Tipo de Cobertura:</td><td class="td-val">{RUBRO} (Amplia con Asistencia)</td></tr>
  <tr><td class="td-label">Nueva Vigencia:</td><td class="td-val">365 días a partir de {FECHA_PAGO}</td></tr>
  <tr><td class="td-label">Prima Neta Renovación:</td><td class="td-val" style="color: #059669; font-size: 15px; font-weight: 800;">\${PRIMA} MXN</td></tr>
</table>

<p>Contamos con esquemas de pago fraccionado (Semestral, Trimestral y Mensual) y opciones de comparativa ante las firmas aseguradoras líderes.</p>
<p style="text-align: center;">
  <a href="https://wa.me/?text=Hola,%20solicito%20renovar%20mi%20poliza%20{POLIZA}" class="btn">CONFIRMAR MI RENOVACIÓN</a>
</p>
''',
            footerNota: 'Conserve su antigüedad y elimine periodos de espera en reclamaciones.',
          );
          break;

        case 2:
          // 3. Emisión / Póliza Nueva
          _asuntoCtrl.text = 'Emisión Exitosa | Entrega de Póliza {POLIZA} - ${conf.nombreDespacho}';
          _cuerpoCtrl.text = _generarHtmlPremium(
            tipo: 'NUEVA',
            tituloHeader: 'BIENVENIDO - EMISIÓN DE PÓLIZA',
            contenidoHtml: '''
<div class="badge" style="background-color: #10B981; color: white;">Protección Activa</div>
<p>Estimado(a) <strong>{TITULAR}</strong>,</p>
<p>Le damos la más cordial bienvenida a <strong>${conf.nombreDespacho}</strong>. Nos complace entregarle su carátula de póliza formalmente emitida con <strong>{COMPANIA}</strong>.</p>

<table class="table-data">
  <tr><td class="td-label">Titular / Razón Social:</td><td class="td-val">{TITULAR}</td></tr>
  <tr><td class="td-label">No. de Póliza:</td><td class="td-val" style="color: #0369A1; font-weight: 800;">{POLIZA}</td></tr>
  <tr><td class="td-label">Ramo / Plan:</td><td class="td-val">{RUBRO}</td></tr>
  <tr><td class="td-label">Bien Registrado:</td><td class="td-val">{VEHICULO}</td></tr>
  <tr><td class="td-label">Inicio de Vigencia:</td><td class="td-val">{FECHA_PAGO}</td></tr>
  <tr><td class="td-label">Asesor Asignado:</td><td class="td-val">{ASESOR}</td></tr>
</table>

<div class="highlight-box" style="background-color: #ECFDF5; border-left-color: #059669; color: #065F46;">
  <strong>Soporte 24/7 en Siniestros:</strong> En caso de requerir asistencia legal, médica o vial inmediata, comuníquese directamente con su asesor o a la línea directa de la aseguradora.
</div>
<p style="text-align: center;">
  <a href="mailto:${conf.correoContacto}" class="btn">SOLICITAR CARÁTULA EN PDF</a>
</p>
''',
            footerNota: 'Documento respaldado bajo los lineamientos de la CNSF y Código de Comercio.',
          );
          break;

        case 3:
          // 4. Felicitación de Cumpleaños
          _asuntoCtrl.text = '¡Feliz Cumpleaños le desea ${conf.nombreDespacho}! 🎂';
          _cuerpoCtrl.text = _generarHtmlPremium(
            tipo: 'CUMPLE',
            tituloHeader: '¡FELIZ CUMPLEAÑOS!',
            contenidoHtml: '''
<div style="text-align: center; margin: 15px 0;">
  <span style="font-size: 42px;">🎂 🎉 ✨</span>
</div>
<p style="font-size: 15px; text-align: center;">Estimado(a) <strong>{TITULAR}</strong>,</p>
<p style="text-align: center; font-size: 14px; color: #334155;">
  Todo el equipo que conformamos <strong>${conf.nombreDespacho}</strong>, encabezado por su broker <strong>${conf.brokerTitular}</strong>, le extendemos nuestras más cálidas felicitaciones en este día especial.
</p>
<div style="background-color: #F8FAFC; border: 1px dashed #CBD5E1; padding: 18px; border-radius: 10px; margin: 20px 0; text-align: center;">
  <p style="margin: 0; font-style: italic; color: #475569;">
    "Que este nuevo año de vida esté colmado de salud, prosperidad, bienestar y momentos entrañables en compañía de sus seres queridos. Es un verdadero privilegio cuidar de lo que más valora."
  </p>
</div>
<p style="text-align: center; font-weight: 700; color: #0F172A;">
  ¡Que pase un día extraordinario!
</p>
''',
            footerNota: 'Agradecemos su confianza y lealtad con nuestra firma patrimonial.',
          );
          break;
      }
    });
  }

  // Disparo de Automatización hacia Google Apps Script
  Future<void> _ejecutarAutomatizacion() async {
    final endpoint = _webhookCtrl.text.trim();
    if (endpoint.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa la URL de Google Apps Script Web App.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _enviando = true);

    final payload = {
      'accion': 'AUTOMATIZAR_ENVIOS',
      'asunto': _asuntoCtrl.text.trim(),
      'cuerpo': _cuerpoCtrl.text.trim(),
      'esHtml': _esHtml,
      'ccObligatoria': ['direccion@enfoqueseguro.mx', 'cobranza@enfoqueseguro.mx'],
      'filtros': {
        'compania': _filtroCompania,
        'frecuencia': _filtroFrecuencia,
        'rubro': _filtroRubro,
        'fechaProgramada': _fechaEnvio.toIso8601String().split('T')[0],
      }
    };

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (mounted) {
        setState(() => _enviando = false);
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Campaña ejecutada exitosamente con Google Sheets y Gmail.'), backgroundColor: Color(0xFF059669)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Respuesta del servidor: ${response.statusCode}'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _enviando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al conectar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Disparar contacto directo WhatsApp con la plantilla institucional
  void _dispararWhatsAppDirecto() async {
    final conf = EmpresaConfigService();
    String txt = '';
    if (_plantillaActivaIndex == 0) {
      txt = 'Soy Yair Hernández de ${conf.nombreDespacho}, le hablo por parte de su broker ${conf.brokerTitular}.\n\n'
          'Estimado(a) {TITULAR}, le compartimos el aviso de cobro correspondiente a su póliza {POLIZA} ({RUBRO}) por un importe de \${PRIMA} MXN con fecha límite {FECHA_PAGO}.\n\n'
          'Quedamos atentos a su comprobante para adjuntarlo a su bitácora contable.';
    } else if (_plantillaActivaIndex == 1) {
      txt = 'Soy Yair Hernández de ${conf.nombreDespacho}, le hablo por parte de su broker ${conf.brokerTitular}.\n\n'
          'Estimado(a) {TITULAR}, nos comunicamos para presentarle su propuesta de renovación para su póliza {POLIZA} ({RUBRO}). Incluye comparativa de mercado y opciones de pago fraccionado.';
    } else if (_plantillaActivaIndex == 2) {
      txt = 'Soy Yair Hernández de ${conf.nombreDespacho}, le hablo por parte de su broker ${conf.brokerTitular}.\n\n'
          'Estimado(a) {TITULAR}, le confirmamos que su póliza {POLIZA} ({RUBRO}) ha quedado emitida satisfactoriamente con {COMPANIA}. En breve le compartimos su carátula.';
    } else {
      txt = 'Estimado(a) {TITULAR}, todo el equipo de ${conf.nombreDespacho} y su broker ${conf.brokerTitular} le deseamos un muy Feliz Cumpleaños. ¡Que tenga un excelente día lleno de salud y éxito!';
    }

    final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(txt)}');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final conf = EmpresaConfigService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: conf.colorNavbar,
        elevation: 0,
        title: Text(
          'Plantillas Premium & Automatización - ${conf.nombreDespacho}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: conf.colorAcento,
          unselectedLabelColor: Colors.white70,
          indicatorColor: conf.colorAcento,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.style_outlined), text: 'CATÁLOGO DE PLANTILLAS PREMIUM'),
            Tab(icon: Icon(Icons.hub_outlined), text: 'SEGMENTACIÓN & GOOGLE SHEETS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _construirCatalogoPlantillas(),
          _construirPanelGoogleSheets(),
        ],
      ),
    );
  }

  // Vista 1: Selector y Editor de Plantillas
  Widget _construirCatalogoPlantillas() {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selector Rápido de Plantillas
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _botonSelectorPlantilla(0, 'Cobranza / Vencimiento', Icons.receipt_long_outlined),
                const SizedBox(width: 10),
                _botonSelectorPlantilla(1, 'Renovación de Cartera', Icons.autorenew_outlined),
                const SizedBox(width: 10),
                _botonSelectorPlantilla(2, 'Emisión / Póliza Nueva', Icons.verified_user_outlined),
                const SizedBox(width: 10),
                _botonSelectorPlantilla(3, 'Felicitación Cumpleaños', Icons.cake_outlined),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Barra de Asunto y Botones de Acción
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _asuntoCtrl,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: 'Línea de Asunto Oficial',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copiar Código'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _cuerpoCtrl.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Plantilla copiada al portapapeles.')),
                  );
                },
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.chat_outlined, size: 16),
                label: const Text('Enviar WhatsApp'),
                onPressed: _dispararWhatsAppDirecto,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Editor de Código HTML
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: TextField(
                controller: _cuerpoCtrl,
                maxLines: null,
                expands: true,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.4),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                  border: InputBorder.none,
                  hintText: 'Estructura HTML de la plantilla...',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _botonSelectorPlantilla(int index, String label, IconData icono) {
    final conf = EmpresaConfigService();
    final bool activa = _plantillaActivaIndex == index;

    return InkWell(
      onTap: () => _cargarPlantilla(index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: activa ? conf.colorNavbar : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: activa ? conf.colorAcento : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icono, size: 16, color: activa ? conf.colorAcento : const Color(0xFF64748B)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: activa ? Colors.white : const Color(0xFF1E293B),
                fontSize: 12.5,
                fontWeight: activa ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Vista 2: Filtrado y Disparo hacia Google Sheets
  Widget _construirPanelGoogleSheets() {
    final conf = EmpresaConfigService();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(Icons.link, color: conf.colorAcento),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _webhookCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Pega la URL de tu Google Apps Script (Web App)...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Segmentación de la Cartera (Google Sheets):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _campoDropdown(
                        'Aseguradora',
                        _filtroCompania,
                        const ['TODAS', 'QUALITAS', 'GNP', 'AXA', 'MAPFRE', 'BANORTE', 'HDI'],
                        (v) => setState(() => _filtroCompania = v!),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _campoDropdown(
                        'Frecuencia de Pago',
                        _filtroFrecuencia,
                        const ['TODAS', 'MENSUAL', 'TRIMESTRAL', 'SEMESTRAL', 'ANUAL'],
                        (v) => setState(() => _filtroFrecuencia = v!),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _campoDropdown(
                        'Ramo / Rubro',
                        _filtroRubro,
                        const ['TODOS', 'AUTOS', 'GMM', 'VIDA', 'DAÑOS'],
                        (v) => setState(() => _filtroRubro = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Fecha Programada de Envío:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          const SizedBox(height: 6),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(42),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.calendar_month, size: 16),
                            label: Text('${_fechaEnvio.day}/${_fechaEnvio.month}/${_fechaEnvio.year}'),
                            onPressed: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: _fechaEnvio,
                                firstDate: DateTime(2025),
                                lastDate: DateTime(2030),
                              );
                              if (d != null) setState(() => _fechaEnvio = d);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Copias Fijas de Auditoría (CC):', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          const SizedBox(height: 6),
                          Container(
                            height: 42,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                            child: const Text('direccion@enfoqueseguro.mx, cobranza@enfoqueseguro.mx', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: conf.colorNavbar,
                foregroundColor: conf.colorAcento,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: _enviando
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send_rounded),
              label: Text(_enviando ? 'PROCESANDO ENVÍOS...' : 'AUTOMATIZAR & DISPARAR CAMPAÑA'),
              onPressed: _enviando ? null : _ejecutarAutomatizacion,
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoDropdown(String label, String valor, List<String> opciones, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: valor,
          decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
          items: opciones.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}