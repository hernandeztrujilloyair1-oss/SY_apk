import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/empresa_config_service.dart';

class CotizadorGmmVista extends StatefulWidget {
  const CotizadorGmmVista({super.key});

  @override
  State<CotizadorGmmVista> createState() => _CotizadorGmmVistaState();
}

class _CotizadorGmmVistaState extends State<CotizadorGmmVista> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _titularCtrl = TextEditingController(text: 'FAMILIA CONTRERAS FLORES');
  final TextEditingController _perfilCtrl = TextEditingController(text: 'Titular (42 años) + Cónyuge (39 años) + 2 Hijos menores');
  final TextEditingController _telefonoCtrl = TextEditingController(text: '55 7323 0137');
  final TextEditingController _atendioCtrl = TextEditingController(text: 'Yair Hernández');

  final List> _aseguradorasGmm = [
    {
      'nombre': 'GNP Seguros',
      'plan': 'Línea Azul Premier',
      'deducible': '\$18,000.00 MXN',
      'coaseguro': '10% (Tope \$45,000)',
      'gamaHospitalaria': 'Nivel Amplio / Hospitales Top',
      'tabulador': 'Tabulador Alto Médico',
      'primaNeta': 48500.00,
      'derecho': 850.00,
      'seleccionada': true,
    },
    {
      'nombre': 'AXA Seguros',
      'plan': 'Flex Plus Médica',
      'deducible': '\$20,000.00 MXN',
      'coaseguro': '10% (Tope \$50,000)',
      'gamaHospitalaria': 'Nivel Óptimo Integral',
      'tabulador': 'Tabulador Premier Nacional',
      'primaNeta': 46200.00,
      'derecho': 800.00,
      'seleccionada': true,
    },
    {
      'nombre': 'MetLife',
      'plan': 'Medicalife Familiar',
      'deducible': '\$15,000.00 MXN',
      'coaseguro': '10% (Tope \$40,000)',
      'gamaHospitalaria': 'Red Médica Preferente',
      'tabulador': 'Tabulador Élite Médico',
      'primaNeta': 51000.00,
      'derecho': 900.00,
      'seleccionada': false,
    },
  ];

  final List> _bitacoraGmm = [
    {
      'id': 'GMM-201',
      'titular': 'FAMILIA CONTRERAS FLORES',
      'plan': 'GNP Línea Azul Premier',
      'primaAnual': 57246.00,
      'columnaB_aviso': '1°',
      'atendio': 'Yair Hernández',
      'estatus': 'EN_SEGUIMIENTO',
    },
    {
      'id': 'GMM-202',
      'titular': 'DR. CARLOS MENDEZ SANDOVAL',
      'plan': 'AXA Flex Plus Médica',
      'primaAnual': 28400.00,
      'columnaB_aviso': '2°',
      'atendio': 'Raúl Martínez',
      'estatus': 'EN_SEGUIMIENTO',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Map<String, double> _calcularDesglose(double neta, double derecho) {
    final subtotal = neta + derecho;
    final totalAnual = subtotal * 1.16;
    final semestral = (neta * 1.04 + derecho) * 1.16 / 2;
    final trimestral = (neta * 1.06 + derecho) * 1.16 / 4;
    final mensual = (neta * 1.08 + derecho) * 1.16 / 12;
    return {
      'anual': totalAnual,
      'semestral': semestral,
      'trimestral': trimestral,
      'mensual': mensual,
    };
  }

  void _abrirAtencionGmm(Map<String, dynamic> item) {
    String aviso = item['columnaB_aviso'] ?? '1°';
    String medio = '2. WhatsApp Directo';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlg) => AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          title: const Text('Seguimiento Cotización GMM (Columna B)', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Aviso Columna B:', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: aviso,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(filled: true, fillColor: Color(0xFF1E293B)),
                items: const [
                  DropdownMenuItem(value: '1°', child: Text('1° - Primer Envío')),
                  DropdownMenuItem(value: '2°', child: Text('2° - En Negociación')),
                  DropdownMenuItem(value: '3°', child: Text('3° - Urgencia de Cierre')),
                  DropdownMenuItem(value: 'SR RAUL', child: Text('SR RAUL - Escalamiento')),
                ],
                onChanged: (v) => setDlg(() => aviso = v!),
              ),
              const SizedBox(height: 12),
              const Text('Medio de Contacto:', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: medio,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(filled: true, fillColor: Color(0xFF1E293B)),
                items: const [
                  DropdownMenuItem(value: '1. Correo', child: Text('1. Correo con CC')),
                  DropdownMenuItem(value: '2. WhatsApp Directo', child: Text('2. WhatsApp Directo')),
                  DropdownMenuItem(value: '3. WhatsApp Grupo', child: Text('3. WhatsApp Grupo')),
                ],
                onChanged: (v) => setDlg(() => medio = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0F172A)),
              onPressed: () async {
                Navigator.pop(ctx);
                setState(() => item['columnaB_aviso'] = aviso);
                final mensaje = 'Soy Yair Hernández de Enfoque Seguro, le hablo por parte de su broker Raúl Martínez.\n\n'
                    'Estimado(a) ${item['titular']}, le comparto el seguimiento a su cotización para Protección de Gastos Médicos Mayores '
                    '(${item['plan']}) por un total anual de \$ ${item['primaAnual']} MXN.\n\n'
                    '¿Gusta que revisemos el desglose de deducibles y gama hospitalaria?';

                if (medio.contains('WhatsApp')) {
                  final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(mensaje)}');
                  if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  final uri = Uri.parse('mailto:?cc=direccion@enfoqueseguro.mx,cobranza@enfoqueseguro.mx&subject=${Uri.encodeComponent("Propuesta GMM - ${item['titular']}")}&body=${Uri.encodeComponent(mensaje)}');
                  if (await canLaunchUrl(uri)) launchUrl(uri);
                }
              },
              child: const Text('Actualizar y Enviar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conf = EmpresaConfigService();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Cotizador de Gastos Médicos Mayores (GMM)', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF091428),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: conf.colorAcento,
          indicatorWeight: 3,
          tabs: [
            const Tab(icon: Icon(Icons.health_and_safety_outlined), text: 'COTIZADOR DE PLANES'),
            Tab(icon: const Icon(Icons.assignment_outlined), text: 'SEGUIMIENTO GMM (${_bitacoraGmm.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _construirFormularioGmm(),
          _construirSeguimientoGmm(),
        ],
      ),
    );
  }

  Widget _construirFormularioGmm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Datos del Grupo Asegurado:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(flex: 3, child: TextField(controller: _titularCtrl, decoration: const InputDecoration(labelText: 'Familia o Titular', border: OutlineInputBorder(), isDense: true))),
                    const SizedBox(width: 10),
                    Expanded(flex: 3, child: TextField(controller: _perfilCtrl, decoration: const InputDecoration(labelText: 'Edades / Miembros', border: OutlineInputBorder(), isDense: true))),
                    const SizedBox(width: 10),
                    Expanded(flex: 2, child: TextField(controller: _atendioCtrl, decoration: const InputDecoration(labelText: 'Atiende', border: OutlineInputBorder(), isDense: true))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Comparativa de Planes Médicos:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF091428), foregroundColor: const Color(0xFFD4AF37)),
                icon: const Icon(Icons.save_outlined, size: 16),
                label: const Text('GUARDAR EN SEGUIMIENTO GMM'),
                onPressed: () {
                  final sel = _aseguradorasGmm.firstWhere((a) => a['seleccionada'] == true, orElse: () => _aseguradorasGmm.first);
                  final calc = _calcularDesglose(sel['primaNeta'] as double, sel['derecho'] as double);
                  setState(() {
                    _bitacoraGmm.insert(0, {
                      'id': 'GMM-${_bitacoraGmm.length + 201}',
                      'titular': _titularCtrl.text.trim(),
                      'plan': '${sel['nombre']} ${sel['plan']}',
                      'primaAnual': calc['anual'],
                      'columnaB_aviso': '1°',
                      'atendio': _atendioCtrl.text.trim(),
                      'estatus': 'EN_SEGUIMIENTO',
                    });
                    _tabController.animateTo(1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (ctx, constraints) {
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: _aseguradorasGmm.map((op) {
                final calc = _calcularDesglose(op['primaNeta'] as double, op['derecho'] as double);
                final bool sel = op['seleccionada'] as bool;

                return Container(
                  width: constraints.maxWidth > 800 ? (constraints.maxWidth - 28) / 3 : constraints.maxWidth,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sel ? const Color(0xFFD4AF37) : const Color(0xFFE2E8F0), width: sel ? 2 : 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(op['nombre'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Checkbox(
                            value: sel,
                            activeColor: const Color(0xFF091428),
                            onChanged: (v) => setState(() => op['seleccionada'] = v),
                          )
                        ],
                      ),
                      Text(op['plan'].toString(), style: const TextStyle(color: Color(0xFF0284C7), fontSize: 12, fontWeight: FontWeight.bold)),
                      const Divider(height: 18),
                      Text('Deducible: ${op['deducible']}', style: const TextStyle(fontSize: 11)),
                      Text('Coaseguro: ${op['coaseguro']}', style: const TextStyle(fontSize: 11)),
                      Text('Gama Hospitalaria: ${op['gamaHospitalaria']}', style: const TextStyle(fontSize: 11)),
                      Text('Tabulador: ${op['tabulador']}', style: const TextStyle(fontSize: 11)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          children: [
                            Text('\$ ${calc['anual']!.toStringAsFixed(2)} MXN', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF059669))),
                            const Divider(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Semestral:', style: TextStyle(fontSize: 10)),
                                Text('\$ ${calc['semestral']!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Mensual:', style: TextStyle(fontSize: 10)),
                                Text('\$ ${calc['mensual']!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _construirSeguimientoGmm() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: ListView.separated(
          itemCount: _bitacoraGmm.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (ctx, i) {
            final item = _bitacoraGmm[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: const Color(0xFFD4AF37),
                child: Text(item['columnaB_aviso'].toString()),
              ),
              title: Text(item['titular'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text('${item['plan']} | Atiende: ${item['atendio']}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('\$ ${(item['primaAnual'] as num).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: Color(0xFF059669), size: 18),
                    onPressed: () => _abrirAtencionGmm(item),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}