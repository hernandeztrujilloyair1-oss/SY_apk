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

  // 1. Controladores de Identidad de Marca Blanca
  final _nombreCtrl = TextEditingController();
  final _lemaCtrl = TextEditingController();
  final _brokerCtrl = TextEditingController();
  final _contactoCtrl = TextEditingController();
  final _cobranzaCtrl = TextEditingController();
  final _logoUrlCtrl = TextEditingController();

  // 2. Equipo de Trabajo y Vendedores (Comisiones por Agente)
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
    {
      'id': 'USR-004',
      'nombre': 'Ejecutivo 2 - Gastos Médicos',
      'correo': 'ventas2@enfoqueseguro.mx',
      'rol': 'EJECUTIVO',
      'comisionPct': 12.5,
      'estatus': 'ACTIVO',
    },
  ];

  // 3. Compañías Registradas, Razón Social y Comisión por Rubro
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
    {
      'nombreComercial': 'AXA Seguros',
      'razonSocial': 'AXA Seguros S.A. de C.V.',
      'rfc': 'ASE931116231',
      'clavePortal': 'AXA-ONLINE',
      'comisionAutos': 15.0,
      'comisionGMM': 14.0,
      'comisionVida': 18.0,
      'comisionDanos': 15.0,
    },
    {
      'nombreComercial': 'Mapfre',
      'razonSocial': 'Mapfre México S.A.',
      'rfc': 'MMX920227I85',
      'clavePortal': 'MAPFRE-NET',
      'comisionAutos': 14.0,
      'comisionGMM': 12.0,
      'comisionVida': 15.0,
      'comisionDanos': 15.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _cargarValoresIniciales();
  }

  void _cargarValoresIniciales() {
    final conf = EmpresaConfigService();
    _nombreCtrl.text = conf.nombreDespacho;
    _lemaCtrl.text = conf.lemaDespacho;
    _brokerCtrl.text = conf.brokerTitular;
    _contactoCtrl.text = conf.correoContacto;
    _cobranzaCtrl.text = conf.correoCobranza;
    _logoUrlCtrl.text = conf.logoDefaultUrl;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Diálogo para editar agente o comisión
  void _editarAgenteDialog(Map<String, dynamic> agente) {
    final nombreCtrl = TextEditingController(text: agente['nombre']);
    final pctCtrl = TextEditingController(text: agente['comisionPct'].toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Modificar: ${agente['rol']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre Completo del Asesor', border: OutlineInputBorder(), isDense: true)),
            const SizedBox(height: 12),
            TextField(controller: pctCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '% Comisión Asignada', suffixText: '%', border: OutlineInputBorder(), isDense: true)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF091428), foregroundColor: const Color(0xFFD4AF37)),
            onPressed: () {
              setState(() {
                agente['nombre'] = nombreCtrl.text.trim();
                agente['comisionPct'] = double.tryParse(pctCtrl.text) ?? agente['comisionPct'];
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Porcentaje y datos del asesor actualizados.'), backgroundColor: Color(0xFF059669)),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // Diálogo para editar comisiones de aseguradora por rubro
  void _editarCompaniaDialog(Map<String, dynamic> cia) {
    final razonCtrl = TextEditingController(text: cia['razonSocial']);
    final rfcCtrl = TextEditingController(text: cia['rfc']);
    final autosCtrl = TextEditingController(text: cia['comisionAutos'].toString());
    final gmmCtrl = TextEditingController(text: cia['comisionGMM'].toString());
    final vidaCtrl = TextEditingController(text: cia['comisionVida'].toString());
    final danosCtrl = TextEditingController(text: cia['comisionDanos'].toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Comisiones: ${cia['nombreComercial']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: razonCtrl, decoration: const InputDecoration(labelText: 'Razón Social Fiscal', border: OutlineInputBorder(), isDense: true)),
              const SizedBox(height: 10),
              TextField(controller: rfcCtrl, decoration: const InputDecoration(labelText: 'RFC Compañía', border: OutlineInputBorder(), isDense: true)),
              const Divider(height: 20),
              const Text('% Comisión por Rubro para el Despacho:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextField(controller: autosCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Autos %', border: OutlineInputBorder(), isDense: true))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: gmmCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'GMM %', border: OutlineInputBorder(), isDense: true))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextField(controller: vidaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Vida %', border: OutlineInputBorder(), isDense: true))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: danosCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Daños %', border: OutlineInputBorder(), isDense: true))),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF091428), foregroundColor: const Color(0xFFD4AF37)),
            onPressed: () {
              setState(() {
                cia['razonSocial'] = razonCtrl.text.trim();
                cia['rfc'] = rfcCtrl.text.trim();
                cia['comisionAutos'] = double.tryParse(autosCtrl.text) ?? cia['comisionAutos'];
                cia['comisionGMM'] = double.tryParse(gmmCtrl.text) ?? cia['comisionGMM'];
                cia['comisionVida'] = double.tryParse(vidaCtrl.text) ?? cia['comisionVida'];
                cia['comisionDanos'] = double.tryParse(danosCtrl.text) ?? cia['comisionDanos'];
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Comisiones por rubro actualizadas.'), backgroundColor: Color(0xFF059669)),
              );
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
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
        title: const Text('Configuración Central & Marca Blanca', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: conf.colorNavbar,
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: conf.colorAcento,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.people_outline), text: 'EQUIPO & COMISIONES'),
            Tab(icon: Icon(Icons.apartment_outlined), text: 'COMPAÑÍAS & RUBROS'),
            Tab(icon: Icon(Icons.palette_outlined), text: 'MARCA BLANCA & COLORES'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _construirEquipoTab(esMaestro),
          _construirCompaniasTab(esMaestro),
          _construirMarcaBlancaTab(conf, esMaestro),
        ],
      ),
    );
  }

  // 1. Pestaña: Equipo de Trabajo y Comisiones por Vendedor
  Widget _construirEquipoTab(bool esMaestro) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gestión del Equipo de Trabajo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  SizedBox(height: 2),
                  Text('Asigna vendedores y ajusta su porcentaje de comisión para reportes de liquidación.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
              if (esMaestro)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF091428), foregroundColor: const Color(0xFFD4AF37)),
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
                  label: const Text('Agregar Asesor'),
                  onPressed: () {
                    setState(() {
                      _equipoTrabajo.add({
                        'id': 'USR-00${_equipoTrabajo.length + 1}',
                        'nombre': 'Nuevo Asesor / Vendedor',
                        'correo': 'asesor${_equipoTrabajo.length + 1}@enfoqueseguro.mx',
                        'rol': 'EJECUTIVO',
                        'comisionPct': 10.0,
                        'estatus': 'ACTIVO',
                      });
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.separated(
              itemCount: _equipoTrabajo.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final ag = _equipoTrabajo[i];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFFE2E8F0))),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF091428),
                      child: Text(ag['id'].toString().replaceAll('USR-00', '#'), style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    title: Text(ag['nombre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('${ag['correo']} • Rol: ${ag['rol']}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
                          child: Text('${ag['comisionPct']}% Comisión', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669), fontSize: 12)),
                        ),
                        if (esMaestro) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18, color: Color(0xFF0284C7)),
                            onPressed: () => _editarAgenteDialog(ag),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 2. Pestaña: Compañías Aseguradoras y Comisiones por Rubro
  Widget _construirCompaniasTab(bool esMaestro) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Aseguradoras Registradas & Esquema por Rubro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          const Text('Porcentajes de comisión base que la aseguradora paga al despacho para cuadre de comisiones.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.separated(
              itemCount: _companiasRegistradas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final cia = _companiasRegistradas[i];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFFE2E8F0))),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(cia['nombreComercial'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
                            const Spacer(),
                            if (esMaestro)
                              TextButton.icon(
                                icon: const Icon(Icons.tune, size: 16),
                                label: const Text('Ajustar Comisiones'),
                                onPressed: () => _editarCompaniaDialog(cia),
                              ),
                          ],
                        ),
                        Text('${cia['razonSocial']} • RFC: ${cia['rfc']}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        const Divider(height: 20),
                        Row(
                          children: [
                            _chipComision('Autos', cia['comisionAutos']),
                            const SizedBox(width: 8),
                            _chipComision('GMM', cia['comisionGMM']),
                            const SizedBox(width: 8),
                            _chipComision('Vida', cia['comisionVida']),
                            const SizedBox(width: 8),
                            _chipComision('Daños', cia['comisionDanos']),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipComision(String rubro, dynamic pct) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
      child: Text('$rubro: $pct%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
    );
  }

  // 3. Pestaña: Identidad Visual y Colores (Marca Blanca)
  Widget _construirMarcaBlancaTab(EmpresaConfigService conf, bool esMaestro) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
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
            Row(
              children: [
                Expanded(child: TextField(controller: _contactoCtrl, enabled: esMaestro, decoration: const InputDecoration(labelText: 'Correo Dirección', border: OutlineInputBorder(), isDense: true))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _cobranzaCtrl, enabled: esMaestro, decoration: const InputDecoration(labelText: 'Correo Cobranza (CC)', border: OutlineInputBorder(), isDense: true))),
              ],
            ),
            const SizedBox(height: 12),
            TextField(controller: _logoUrlCtrl, enabled: esMaestro, decoration: const InputDecoration(labelText: 'URL Logotipo Oficial', border: OutlineInputBorder(), isDense: true)),
            const SizedBox(height: 24),
            if (esMaestro)
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF091428),
                    foregroundColor: const Color(0xFFD4AF37),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  ),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('GUARDAR CONFIGURACIÓN DE MARCA BLANCA'),
                  onPressed: () {
                    conf.nombreDespacho = _nombreCtrl.text.trim();
                    conf.lemaDespacho = _lemaCtrl.text.trim();
                    conf.brokerTitular = _brokerCtrl.text.trim();
                    conf.correoContacto = _contactoCtrl.text.trim();
                    conf.correoCobranza = _cobranzaCtrl.text.trim();
                    conf.logoDefaultUrl = _logoUrlCtrl.text.trim();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Identidad de Marca Blanca actualizada.'), backgroundColor: Color(0xFF059669)),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}