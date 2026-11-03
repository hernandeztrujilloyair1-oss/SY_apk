import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/tenant_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _empresaSeleccionada = 'EMP_ENFOQUE';
  final TextEditingController _correoCtrl = TextEditingController(text: 'direccion@enfoqueseguro.mx');
  final TextEditingController _passCtrl = TextEditingController(text: 'Master2026*');
  bool _ocultarPass = true;
  bool _cargando = false;
  String _errorMsg = '';

  void _cambiarTenant(String nuevoId) {
    setState(() {
      _empresaSeleccionada = nuevoId;
      TenantService().cambiarEmpresa(nuevoId);
      if (nuevoId == 'EMP_ENFOQUE') {
        _correoCtrl.text = 'direccion@enfoqueseguro.mx';
        _passCtrl.text = 'Master2026*';
      } else {
        _correoCtrl.text = 'contacto@britopatrimonial.mx';
        _passCtrl.text = 'Master2026*';
      }
    });
  }

  void _autenticar() async {
    setState(() {
      _cargando = true;
      _errorMsg = '';
    });

    final exito = await AuthService().iniciarSesion(
      _correoCtrl.text.trim(),
      _passCtrl.text.trim(),
    );

    setState(() => _cargando = false);

    if (exito) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } else {
      setState(() => _errorMsg = 'Credenciales no autorizadas para este despacho.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenant = TenantService().empresaActiva;

    return Scaffold(
      backgroundColor: tenant.colorPrimario,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 440,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Selector de Empresa Contratante (Multi-Tenant)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _empresaSeleccionada,
                      isExpanded: true,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 13),
                      items: TenantService().empresasDisponibles.map((emp) {
                        return DropdownMenuItem<String>(
                          value: emp['id'],
                          child: Row(
                            children: [
                              const Icon(Icons.business_outlined, size: 16, color: Color(0xFF0284C7)),
                              const SizedBox(width: 8),
                              Text('Empresa: ${emp['nombre']}'),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => _cambiarTenant(v!),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Logo y Marca de la Empresa Contratante
                CircleAvatar(
                  radius: 34,
                  backgroundColor: tenant.colorPrimario,
                  child: Text(
                    tenant.nombre.isNotEmpty ? tenant.nombre.substring(0, 1) : 'S',
                    style: TextStyle(color: tenant.colorAcento, fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  tenant.nombre,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                Text(
                  tenant.lema,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 24),

                if (_errorMsg.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_errorMsg, style: const TextStyle(color: Colors.red, fontSize: 12))),
                      ],
                    ),
                  ),

                TextField(
                  controller: _correoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Correo de Usuario',
                    prefixIcon: Icon(Icons.person_outline, size: 18),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passCtrl,
                  obscureText: _ocultarPass,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(_ocultarPass ? Icons.visibility_off : Icons.visibility, size: 18),
                      onPressed: () => setState(() => _ocultarPass = !_ocultarPass),
                    ),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _autenticar(),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tenant.colorPrimario,
                      foregroundColor: tenant.colorAcento,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _cargando ? null : _autenticar,
                    child: _cargando
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('ENTRAR AL ESPACIO AISLADO', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Espacio blindado e independiente por empresa cliente.',
                  style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}