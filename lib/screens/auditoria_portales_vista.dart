import 'package:flutter/material.dart';
import '../services/empresa_config_service.dart';
import '../services/auth_service.dart';

class ConfiguracionMarcaBlancaVista extends StatefulWidget {
  const ConfiguracionMarcaBlancaVista({super.key});

  @override
  State<ConfiguracionMarcaBlancaVista> createState() => _ConfiguracionMarcaBlancaVistaState();
}

class _ConfiguracionMarcaBlancaVistaState extends State<ConfiguracionMarcaBlancaVista> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _tipoCalendario = 'Google Calendar';
  final _urlCalendarioCtrl = TextEditingController(text: 'https://calendar.google.com/calendar/ical/.../basic.ics');
  final _nombreRemitenteCtrl = TextEditingController(text: 'Enfoque Seguro - Notificaciones');
  final _correoSalienteCtrl = TextEditingController(text: 'notificaciones@enfoqueseguro.mx');
  final _smtpHostCtrl = TextEditingController(text: 'smtp.gmail.com');
  final _smtpPuertoCtrl = TextEditingController(text: '587');
  final _whatsappNumeroCtrl = TextEditingController(text: '525542574136');
  final _whatsappTokenCtrl = TextEditingController(text: 'EAAQ...WA_TOKEN');

  final _nombreCtrl = TextEditingController(text: 'Enfoque Seguro');
  final _lemaCtrl = TextEditingController(text: 'Gestión Integral y Asesoría Patrimonial');
  final _brokerCtrl = TextEditingController(text: 'Raúl Martínez');
  final _contactoCtrl = TextEditingController(text: 'direccion@enfoqueseguro.mx');
  final _cobranzaCtrl = TextEditingController(text: 'cobranza@enfoqueseguro.mx');
  final _logoUrlCtrl = TextEditingController(text: 'https://enfoqueseguro.mx/logo.png');

  final List> _equipoTrabajo = [
    {
      'id': 'USR-001',
      'nombre': 'Raúl Martínez',
      'correo': 'direccion@enfoqueseguro.mx',
      'rol': 'MAESTRO (Director)',
      'comisionPct': 100.0,
      'estatus': 'ACTIVO',
    },
    {
      'id': 'USR-002',
      'nombre': 'Yair Hernández',
      'correo': 'cobranza@enfoqueseguro.mx',
      'rol': 'COBRANZA',
      'comisionPct': 0.0,
      'estatus': 'ACTIVO',
    },
    {
      'id': 'USR-003',
      'nombre': 'Ejecutivo 1 - Autos & Flotillas',
      'correo': 'ventas1@enfoqueseguro.mx',
      'rol': 'EJECUTIVO',
      'comisionPct': 15.0,
      'estatus': 'ACTIVO',
    },
  ];

  final List> _companiasRegistradas = [
    {
      'nombreComercial': 'Quálitas',
      'razonSocial': 'Quálitas Compañía de Seguros S.A. de C.V.',
      'rfc': 'QCS931209G48',
      'clavePortal': 'SIMA-ENFOQUE',
      'comisionAutos': 16.0,
      'comisionGMM': 0.0,
      'comisionVida': 0.0,
      'comisionDanos': 18.0,
    },
    {
      'nombreComercial': 'GNP Seguros',
      'razonSocial': 'Grupo Nacional Provincial S.A.B.',
      'rfc': 'GNP9211244Z0',
      'clavePortal': 'INTERNET-GNP',
      'comisionAutos': 14.5,
      'comisionGMM': 15.0,
      'comisionVida': 20.0,
      'comisionDanos': 16.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlCalendarioCtrl.dispose();
    _nombreRemitenteCtrl.dispose();
    _correoSalienteCtrl.dispose();
    _smtpHostCtrl.dispose();
    _smtpPuertoCtrl.dispose();
    _whatsappNumeroCtrl.dispose();
    _whatsappTokenCtrl.dispose();
    _nombreCtrl.dispose();
    _lemaCtrl.dispose();
    _brokerCtrl.dispose();
    _contactoCtrl.dispose();
    _cobranzaCtrl.dispose();
    _logoUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conf = EmpresaConfigService();
    final usuario = AuthService().usuarioActual;
    final bool esMaestro = usuario?.puedeEditarParametrosYComisiones() ?? true;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Configuración Central & Canales de Comunicación',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: conf.colorNavbar,
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: conf.colorAcento,
          indicatorWeight: 3,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.sync_alt_outlined), text: 'CANALES & CALENDARIOS'),
            Tab(icon: Icon(Icons.people_outline), text: 'EQUIPO & COMISIONES'),
            Tab(icon: Icon(Icons.apartment_outlined), text: 'COMPAÑÍAS & RUBROS'),
            Tab(icon: Icon(Icons.palette_outlined), text: 'MARCA BLANCA'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _construirCanalesTab(conf, esMaestro),
          _construirEquipoTab(esMaestro),
          _construirCompaniasTab(esMaestro),
          _construirMarcaBlancaTab(conf, esMaestro),
        ],
      ),
    );
  }

  Widget _construirCanalesTab(EmpresaConfigService conf, bool esMaestro) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFEFF6FF),
                      child: Icon(Icons.calendar_month_outlined, color: Color(0xFF0284C7)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Sincronización de Calendario', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('Conecta Google Calendar o Apple Calendar para sincronizar recordatorios.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _tipoCalendario,
                        decoration: const InputDecoration(labelText: 'Proveedor', border: OutlineInputBorder(), isDense: true),
                        items: const [
                          DropdownMenuItem(value: 'Google Calendar', child: Text('Google Calendar (iCal)')),
                          DropdownMenuItem(value: 'Apple Calendar', child: Text('Apple Calendar (WebCal)')),
                        ],
                        onChanged: esMaestro ? (v) => setState(() => _tipoCalendario = v!) : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: _urlCalendarioCtrl,
                        enabled: esMaestro,
                        decoration: const InputDecoration(
                          labelText: 'Enlace de Sincronización',
                          border: OutlineInputBorder(),
                          isDense: true,
                          prefixIcon: Icon(Icons.link, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFECFDF5),
                      child: Icon(Icons.mark_email_read_outlined, color: Color(0xFF059669)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Cuenta de Correo Saliente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('Los correos de cobranza se enviarán con este nombre y dirección.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nombreRemitenteCtrl,
                        enabled: esMaestro,
                        decoration: const InputDecoration(labelText: 'Nombre Remitente', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _correoSalienteCtrl,
                        enabled: esMaestro,
                        decoration: const InputDecoration(labelText: 'Correo Emisor', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _smtpHostCtrl,
                        enabled: esMaestro,
                        decoration: const InputDecoration(labelText: 'Servidor SMTP', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _smtpPuertoCtrl,
                        enabled: esMaestro,
                        decoration: const InputDecoration(labelText: 'Puerto Seguro (587)', border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFF0FDF4),
                      child: Icon(Icons.chat_outlined, color: Color(0xFF10B981)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('WhatsApp Emisor Oficial', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('Línea para enlaces directos y notificaciones automáticas.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _whatsappNumeroCtrl,
                        enabled: esMaestro,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Número con Lada (Ej: 525542574136)',
                          prefixIcon: Icon(Icons.phone_android, size: 18),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _whatsappTokenCtrl,
                        enabled: esMaestro,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Token / Clave de API (Opcional)',
                          prefixIcon: Icon(Icons.vpn_key_outlined, size: 18),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (esMaestro)
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF091428),
                  foregroundColor: const Color(0xFFD4AF37),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.save_outlined),
                label: const Text('GUARDAR CANALES DE COMUNICACIÓN', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Configuración de canales e integraciones actualizada correctamente.'),
                      backgroundColor: Color(0xFF059669),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _construirEquipoTab(bool esMaestro) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Equipo de Trabajo y Asesores Registrados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: _equipoTrabajo.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final ag = _equipoTrabajo[i];
                final String nombreAg = ag['nombre']?.toString() ?? '';
                final String correoAg = ag['correo']?.toString() ?? '';
                final String rolAg = ag['rol']?.toString() ?? '';
                final num pct = (ag['comisionPct'] as num?) ?? 0;

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF091428),
                      child: Text(ag['id'].toString().replaceAll('USR-00', '#'), style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                    ),
                    title: Text(nombreAg, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('$correoAg • Rol: $rolAg'),
                    trailing: Text('$pct% Comisión', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirCompaniasTab(bool esMaestro) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Aseguradoras y Comisiones por Rubro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: _companiasRegistradas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final cia = _companiasRegistradas[i];
                final String nomCia = cia['nombreComercial']?.toString() ?? '';
                final String rzCia = cia['razonSocial']?.toString() ?? '';
                final String rfcCia = cia['rfc']?.toString() ?? '';

                return Card(
                  child: ListTile(
                    title: Text(nomCia, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('$rzCia • RFC: $rfcCia'),
                    trailing: Text('Autos: ${cia['comisionAutos']}% | GMM: ${cia['comisionGMM']}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirMarcaBlancaTab(EmpresaConfigService conf, bool esMaestro) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Personalización de Marca Blanca', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(controller: _nombreCtrl, enabled: esMaestro, decoration: const InputDecoration(labelText: 'Nombre Comercial del Despacho', border: OutlineInputBorder(), isDense: true)),
          const SizedBox(height: 12),
          TextField(controller: _lemaCtrl, enabled: esMaestro, decoration: const InputDecoration(labelText: 'Lema / Slogan Oficial', border: OutlineInputBorder(), isDense: true)),
          const SizedBox(height: 12),
          TextField(controller: _brokerCtrl, enabled: esMaestro, decoration: const InputDecoration(labelText: 'Broker Titular / Director', border: OutlineInputBorder(), isDense: true)),
          const SizedBox(height: 12),
          TextField(controller: _contactoCtrl, enabled: esMaestro, decoration: const InputDecoration(labelText: 'Correo Dirección', border: OutlineInputBorder(), isDense: true)),
          const SizedBox(height: 12),
          TextField(controller: _cobranzaCtrl, enabled: esMaestro, decoration: const InputDecoration(labelText: 'Correo Cobranza (CC)', border: OutlineInputBorder(), isDense: true)),
          const SizedBox(height: 12),
          TextField(controller: _logoUrlCtrl, enabled: esMaestro, decoration: const InputDecoration(labelText: 'URL Logotipo Oficial', border: OutlineInputBorder(), isDense: true)),
          const SizedBox(height: 20),
          if (esMaestro)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF091428),
                foregroundColor: const Color(0xFFD4AF37),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Marca Blanca actualizada.')),
                );
              },
              child: const Text('GUARDAR CAMBIOS'),
            ),
        ],
      ),
    );
  }
}