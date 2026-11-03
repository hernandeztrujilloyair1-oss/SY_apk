import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProspectosTarjetasVista extends StatefulWidget {
  const ProspectosTarjetasVista({super.key});

  @override
  State<ProspectosTarjetasVista> createState() => _ProspectosTarjetasVistaState();
}

class _ProspectosTarjetasVistaState extends State<ProspectosTarjetasVista> {
  String _filtroBusqueda = '';

  final List> _prospectos = [
    {
      'id': 'PROSP-001',
      'nombre': 'CRISOFORO ROBERTO PEREZ ONOFRE',
      'empresa': 'Transportes del Centro',
      'rfc': 'PEOC720708QN7',
      'telefono': '55 4257 4136',
      'correo': 'crisoforo.perez@empresa.com',
      'totalPolizas': 3,
      'estatus': 'Cliente Activo',
      'etapa': 'Cierre Ganado',
      'montoEstimado': 34500.0,
    },
    {
      'id': 'PROSP-002',
      'nombre': 'JAIR ENRIQUE GUTIERREZ QUINTANA',
      'empresa': 'Gutiérrez Logistics',
      'rfc': 'GUQJ721030M41',
      'telefono': '55 7323 0137',
      'correo': 'jair.gutierrez@logistics.com',
      'totalPolizas': 5,
      'estatus': 'Cliente VIP',
      'etapa': 'En Seguimiento',
      'montoEstimado': 82300.0,
    },
    {
      'id': 'PROSP-003',
      'nombre': 'ANA GABRIELA FLORES BARRERA',
      'empresa': 'Consultoría Jurídica FB',
      'rfc': 'FOBA9303274B2',
      'telefono': '55 4857 1620',
      'correo': 'gabriela.flores@derecho.mx',
      'totalPolizas': 2,
      'estatus': 'Prospecto Calificado',
      'etapa': 'Cotización Enviada',
      'montoEstimado': 21400.0,
    },
    {
      'id': 'PROSP-004',
      'nombre': 'SALAS MANRRIQUEZ SAMUEL',
      'empresa': 'Comercializadora SMS',
      'rfc': 'SAMS850128KL9',
      'telefono': '55 6431 7019',
      'correo': 'samuel.salas@comercializadora.mx',
      'totalPolizas': 1,
      'estatus': 'Cancelada',
      'etapa': 'Recuperación',
      'montoEstimado': 19989.90,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtrados = _prospectos.where((p) {
      final q = _filtroBusqueda.toLowerCase();
      return p['nombre'].toString().toLowerCase().contains(q) ||
          p['empresa'].toString().toLowerCase().contains(q) ||
          p['rfc'].toString().toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Directorio de Prospectos & Asegurados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    SizedBox(height: 4),
                    Text('Tarjetas de identificación ejecutiva con conteo de pólizas y contacto directo.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: 320,
                  height: 40,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre, RFC o negocio...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                    ),
                    onChanged: (v) => setState(() => _filtroBusqueda = v),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: const Color(0xFFD4AF37)),
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Nuevo Prospecto'),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.55,
                ),
                itemCount: filtrados.length,
                itemBuilder: (context, i) {
                  final p = filtrados[i];
                  return _tarjetaIdentificacion(p);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaIdentificacion(Map<String, dynamic> p) {
    final bool esCancelado = p['estatus'] == 'Cancelada';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: esCancelado ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          // Banda superior
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: esCancelado ? const Color(0xFFFEF2F2) : const Color(0xFF0F172A),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(p['id'], style: TextStyle(color: esCancelado ? Colors.red : const Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: esCancelado ? Colors.red : const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    p['estatus'],
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFE2E8F0),
                      child: Text(
                        p['nombre'].substring(0, 1),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['nombre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
                          Text('${p['empresa']} | RFC: ${p['rfc']}', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _kpiMini('Total Pólizas', '${p['totalPolizas']} Activas', Icons.folder_shared),
                    _kpiMini('Monto Cartera', '\$ ${p['montoEstimado']}', Icons.payments_outlined),
                  ],
                ),
                const Divider(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(p['telefono'], style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                    IconButton(
                      icon: const Icon(Icons.chat, color: Color(0xFF10B981), size: 18),
                      onPressed: () async {
                        final tel = p['telefono'].replaceAll(' ', '');
                        final uri = Uri.parse('https://wa.me/52$tel');
                        if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                      tooltip: 'WhatsApp Directo',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiMini(String titulo, String valor, IconData icono) {
    return Row(
      children: [
        Icon(icono, size: 14, color: const Color(0xFF0284C7)),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
            Text(valor, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          ],
        ),
      ],
    );
  }
}