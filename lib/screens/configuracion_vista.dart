import 'package:flutter/material.dart';
import '../services/tenant_service.dart';

class ConfiguracionVista extends StatefulWidget {
  const ConfiguracionVista({super.key});

  @override
  State<ConfiguracionVista> createState() => _ConfiguracionVistaState();
}

class _ConfiguracionVistaState extends State<ConfiguracionVista> {
  final _nombreCtrl = TextEditingController(text: 'Enfoque Seguro');
  final _lemaCtrl = TextEditingController(text: 'Gestión Integral y Asesoría Patrimonial');
  final _titularCtrl = TextEditingController(text: 'Raúl Martínez');
  final _dirCorreoCtrl = TextEditingController(text: 'direccion@enfoqueseguro.mx');
  final _cobCorreoCtrl = TextEditingController(text: 'cobranza@enfoqueseguro.mx');

  @override
  Widget build(BuildContext context) {
    final tenant = TenantService().empresaActiva;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuración Central - Enfoque Seguro',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF091428)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Parámetros institucionales, correos de auditoría y cuentas maestras.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Identidad Institucional', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF091428))),
                const Divider(height: 24),
                _campo('Nombre Comercial', _nombreCtrl),
                const SizedBox(height: 16),
                _campo('Lema / Eslogan', _lemaCtrl),
                const SizedBox(height: 16),
                _campo('Titular / Director Responsable', _titularCtrl),
                const SizedBox(height: 16),
                _campo('Correo de Dirección (CC Auditoría)', _dirCorreoCtrl),
                const SizedBox(height: 16),
                _campo('Correo de Cobranza (CC Auditoría)', _cobCorreoCtrl),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF091428),
                    foregroundColor: tenant.colorAcento,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('GUARDAR PARÁMETROS', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Parámetros guardados y sincronizados correctamente.'),
                        backgroundColor: Color(0xFF059669),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _campo(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
        ),
      ],
    );
  }
}
