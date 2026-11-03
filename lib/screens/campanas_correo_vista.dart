import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/tenant_service.dart';

class CampanasCorreoVista extends StatefulWidget {
  const CampanasCorreoVista({super.key});

  @override
  State<CampanasCorreoVista> createState() => _CampanasCorreoVistaState();
}

class _CampanasCorreoVistaState extends State<CampanasCorreoVista> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _endpointCtrl = TextEditingController(
    text: 'https://script.google.com/macros/s/AKfycbyHo6br-Ykseaoq0_B_Gfh78b5W2F58Sv8GYikP7V5xBTq9O73QaUwmgOl9TX_ja63K/exec',
  );

  final TextEditingController _asuntoCtrl = TextEditingController(text: 'Información Importante sobre su Cobertura - {COMPANIA}');
  final TextEditingController _imagenUrlCtrl = TextEditingController(text: 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=600');
  final TextEditingController _cuerpoTextoCtrl = TextEditingController(
    text: 'Estimado(a) {TITULAR},\n\nNos complace comunicarle que contamos con nuevas actualizaciones y beneficios para su protección en el rubro de {RUBRO}.\n\nPara cualquier duda o aclaración sobre su póliza {POLIZA}, estamos a sus órdenes.\n\nAtentamente,\nDirección de Operaciones',
  );
  
  final TextEditingController _htmlPersonalizadoCtrl = TextEditingController(text: '''
<div style="font-family: Arial, sans-serif; max-width: 600px; margin: auto; border: 1px solid #E2E8F0; border-radius: 10px; overflow: hidden;">
  <div style="background-color: #091428; padding: 25px; text-align: center; color: white;">
    <h2 style="margin: 0; color: #D4AF37;">COMUNICADO OFICIAL</h2>
    <p style="margin: 5px 0 0 0; font-size: 12px; color: #94A3B8;">ENFOQUE SEGURO | ASESORÍA PATRIMONIAL</p>
  </div>
  <div style="padding: 25px; color: #1E293B; line-height: 1.6;">
    <p>Estimado(a) <strong>{TITULAR}</strong>,</p>
    <p>Le informamos sobre las nuevas condiciones y beneficios aplicables a su póliza <strong>{POLIZA}</strong> contratada con <strong>{COMPANIA}</strong>.</p>
    <div style="text-align: center; margin: 20px 0;">
      <img src="{IMAGEN_URL}" style="max-width: 100%; border-radius: 8px; border: 1px solid #CBD5E1;" alt="Campaña" />
    </div>
    <p>Recuerde que su protección en <strong>{RUBRO}</strong> cuenta con asistencia 24/7 y respaldo directo de nuestro despacho.</p>
    <br/>
    <p style="font-size: 12px; color: #64748B;">Atentamente,<br/><strong>Equipo de Operaciones & Cartera</strong></p>
  </div>
</div>
''');

  String _rubroSeleccionado = 'TODOS';
  String _companiaSeleccionada = 'TODAS';
  bool _modoHtmlLibre = false;
  bool _enviando = false;

  final List<String> _rubros = const ['TODOS', 'AUTOS', 'GMM', 'VIDA', 'DAÑOS'];
  final List<String> _companias = const ['TODAS', 'QUALITAS', 'GNP', 'AXA', 'MAPFRE', 'BANORTE', 'HDI'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _endpointCtrl.dispose();
    _asuntoCtrl.dispose();
    _imagenUrlCtrl.dispose();
    _cuerpoTextoCtrl.dispose();
    _htmlPersonalizadoCtrl.dispose();
    super.dispose();
  }

  Future<void> _dispararCampana() async {
    final endpoint = _endpointCtrl.text.trim();
    if (endpoint.isEmpty) return;

    setState(() => _enviando = true);

    String cuerpoFinal = '';
    if (_modoHtmlLibre) {
      cuerpoFinal = _htmlPersonalizadoCtrl.text.replaceAll('{IMAGEN_URL}', _imagenUrlCtrl.text.trim());
    } else {
      // Ensamblaje automático: Texto + Imagen + Firma
      final imgHtml = _imagenUrlCtrl.text.trim().isNotEmpty
          ? '<div style="margin: 15px 0;"><img src="${_imagenUrlCtrl.text.trim()}" style="max-width: 100%; border-radius: 8px;" /></div>'
          : '';
      final parrafos = _cuerpoTextoCtrl.text.trim().replaceAll('\n', '<br/>');
      cuerpoFinal = '''
      <div style="font-family: Arial, sans-serif; max-width: 600px; color: #1E293B;">
        $imgHtml
        <div>$parrafos</div>
      </div>
      ''';
    }

    final payload = {
      'accion': 'AUTOMATIZAR_ENVIOS',
      'id_empresa': TenantService().empresaActiva.idEmpresa,
      'asunto': _asuntoCtrl.text.trim(),
      'cuerpo': cuerpoFinal,
      'esHtml': true,
      'filtros': {
        'rubro': _rubroSeleccionado,
        'compania': _companiaSeleccionada,
        'frecuencia': 'TODAS',
      }
    };

    try {
      final res = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (mounted) {
        setState(() => _enviando = false);
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final enviados = data['enviados'] ?? 0;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Campaña ejecutada: Se enviaron $enviados correos con éxito.'),
              backgroundColor: const Color(0xFF059669),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error del servidor: ${res.statusCode}'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _enviando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Campañas Masivas de Correo por Rubro',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF091428),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFFD4AF37),
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.edit_note_outlined), text: 'DISEÑADOR DE CAMPAÑA'),
            Tab(icon: Icon(Icons.preview_outlined), text: 'SEGMENTACIÓN & DISPARO'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _construirEditorCampana(),
          _construirFiltrosYEnvio(),
        ],
      ),
    );
  }

  Widget _construirEditorCampana() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _asuntoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Asunto de la Campaña',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Row(
                children: [
                  const Text('Código HTML Libre: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Switch(
                    value: _modoHtmlLibre,
                    activeThumbColor: const Color(0xFF091428),
                    onChanged: (v) => setState(() => _modoHtmlLibre = v),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _imagenUrlCtrl,
            decoration: const InputDecoration(
              labelText: 'URL de Imagen Principal / Banner de la Campaña',
              prefixIcon: Icon(Icons.image_outlined, size: 18),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Variables dinámicas automáticas: {TITULAR}, {POLIZA}, {COMPANIA}, {RUBRO}',
            style: TextStyle(fontSize: 11, color: Color(0xFF0284C7), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          if (!_modoHtmlLibre) ...[
            const Text('Cuerpo del Mensaje (Texto):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _cuerpoTextoCtrl,
              maxLines: 8,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Redacta aquí el comunicado para tus clientes...',
              ),
            ),
          ] else ...[
            const Text('Código HTML Personalizado:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _htmlPersonalizadoCtrl,
              maxLines: 12,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Pega tu plantilla HTML corporativa aquí...',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _construirFiltrosYEnvio() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Segmentación de la Base de Datos:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _rubroSeleccionado,
                        decoration: const InputDecoration(labelText: 'Filtrar por Rubro', border: OutlineInputBorder(), isDense: true),
                        items: _rubros.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                        onChanged: (v) => setState(() => _rubroSeleccionado = v!),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _companiaSeleccionada,
                        decoration: const InputDecoration(labelText: 'Filtrar por Compañía', border: OutlineInputBorder(), isDense: true),
                        items: _companias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setState(() => _companiaSeleccionada = v!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: Color(0xFF059669), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Copia fija de auditoría (CC): direccion@enfoqueseguro.mx, cobranza@enfoqueseguro.mx',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF091428),
                foregroundColor: const Color(0xFFD4AF37),
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: _enviando
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded),
              label: Text(_enviando ? 'DISPARANDO CORREOS...' : 'ENVIAR CAMPAÑA A LA BASE SELECCIONADA'),
              onPressed: _enviando ? null : _dispararCampana,
            ),
          ),
        ],
      ),
    );
  }
}
