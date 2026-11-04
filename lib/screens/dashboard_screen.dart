import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/tenant_service.dart';
import 'login_screen.dart';
import 'auditoria_portales_vista.dart';
import 'campanas_correo_vista.dart';
import 'configuracion_marca_blanca_vista.dart';
import 'cobranza_seguimiento_vista.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _seccionActiva = 'DASHBOARD';
  final TextEditingController _buscadorGlobalCtrl = TextEditingController();

  @override
  void dispose() {
    _buscadorGlobalCtrl.dispose();
    super.dispose();
  }

  void _cerrarSesion() {
    AuthService().cerrarSesion();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tenant = TenantService().empresaActiva;
    final usuario = AuthService().usuarioActual;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Row(
        children: [
          // 1. SIDEBAR
          Container(
            width: 260,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  tenant.colorPrimario,
                  const Color(0xFF060D1A),
                ],
              ),
              border: const Border(
                right: BorderSide(color: Color(0xFF1E293B), width: 1),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [tenant.colorAcento, const Color(0xFFE2C974)],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            tenant.nombre.isNotEmpty ? tenant.nombre.substring(0, 1).toUpperCase() : 'S',
                            style: TextStyle(
                              color: tenant.colorPrimario,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tenant.nombre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tenant.lema,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFF1E293B)),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _itemSidebar(Icons.dashboard_outlined, 'DASHBOARD'),
                      _itemSidebar(Icons.fact_check_outlined, 'AUDITORÍA CONTRATANTES'),
                      _itemSidebar(Icons.campaign_outlined, 'CAMPAÑAS POR CORREO'),
                      _itemSidebar(Icons.auto_awesome, 'CARGAR CON IA'),
                      _itemSidebar(Icons.settings_outlined, 'CONFIGURACIÓN'),
                    ],
                  ),
                ),

                _construirIndicadorAlmacenamiento(tenant),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF050B14),
                    border: Border(top: BorderSide(color: Color(0xFF1E293B))),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: tenant.colorAcento.withOpacity(0.18),
                          shape: BoxShape.circle,
                          border: Border.all(color: tenant.colorAcento.withOpacity(0.5)),
                        ),
                        child: Center(
                          child: Text(
                            usuario != null && usuario.nombre.isNotEmpty
                                ? usuario.nombre.substring(0, 1).toUpperCase()
                                : 'U',
                            style: TextStyle(
                              color: tenant.colorAcento,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              usuario?.nombre ?? 'Usuario Activo',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              usuario?.rol.name.toUpperCase() ?? 'EJECUTIVO',
                              style: TextStyle(
                                color: tenant.colorAcento,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, size: 16, color: Color(0xFF94A3B8)),
                        tooltip: 'Cerrar Sesión',
                        onPressed: _cerrarSesion,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. HEADER Y CONTENIDO
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: TextField(
                            controller: _buscadorGlobalCtrl,
                            style: const TextStyle(fontSize: 12.5),
                            decoration: InputDecoration(
                              hintText: 'Buscar en $_seccionActiva...',
                              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                              prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF64748B)),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_outlined, size: 14, color: Color(0xFF16A34A)),
                            const SizedBox(width: 6),
                            Text(
                              tenant.nombre,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _construirContenidoCentral(usuario),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemSidebar(IconData icono, String titulo) {
    final bool activo = _seccionActiva == titulo;
    final tenant = TenantService().empresaActiva;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _seccionActiva = titulo),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9.5),
            decoration: BoxDecoration(
              color: activo ? const Color(0xFF13223A) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: activo ? tenant.colorAcento.withOpacity(0.85) : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icono,
                  size: 18,
                  color: activo ? tenant.colorAcento : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titulo,
                    style: TextStyle(
                      color: activo ? Colors.white : const Color(0xFFCBD5E1),
                      fontSize: 11.5,
                      fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirIndicadorAlmacenamiento(EmpresaTenant tenant) {
    final bool limiteCercano = tenant.porcentajeUso >= 0.85;
    final colorBarra = limiteCercano ? Colors.redAccent : const Color(0xFF10B981);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF091428),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    tenant.esWorkspacePropio ? Icons.cloud_done_rounded : Icons.cloud_queue_rounded,
                    size: 14,
                    color: tenant.colorAcento,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tenant.esWorkspacePropio ? 'Workspace 5 TB' : 'Bóveda 250 GB',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                '${(tenant.porcentajeUso * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: colorBarra,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: tenant.porcentajeUso,
              minHeight: 5,
              backgroundColor: const Color(0xFF1E293B),
              valueColor: AlwaysStoppedAnimation<Color>(colorBarra),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${tenant.almacenamientoUsadoGb.toStringAsFixed(1)} GB usados de ${tenant.cuotaTotalGb.toInt()} GB',
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9.5),
          ),
        ],
      ),
    );
  }

  Widget _construirContenidoCentral(UsuarioSesion? usuario) {
    switch (_seccionActiva) {
      case 'DASHBOARD':
        return _construirDashboardPrincipal();
case 'COBRANZA':
  return const CobranzaSeguimientoVista();
      case 'AUDITORÍA CONTRATANTES':
        return const AuditoriaPortalesVista();

      case 'CAMPAÑAS POR CORREO':
        return const CampanasCorreoVista();

      case 'CARGAR CON IA':
        return _construirModuloCargarIA();

      case 'CONFIGURACIÓN':
        if (usuario != null && usuario.esEjecutivo) {
          return const Center(
            child: Text(
              'Acceso restringido: Solo el Director General (Maestro) puede gestionar configuración.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          );
        }
        return const ConfiguracionMarcaBlancaVista();

      default:
        return const Center(child: Text('Módulo no encontrado.'));
    }
  }

  Widget _construirDashboardPrincipal() {
    final tenant = TenantService().empresaActiva;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panel de Control - ${tenant.nombre}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Resumen ejecutivo de cartera, cobranza y comisiones en tiempo real.',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _tarjetaKpi('Pólizas en Cartera', '9,888', Icons.folder_outlined, const Color(0xFF0284C7)),
              const SizedBox(width: 16),
              _tarjetaKpi('Prima Total Vigente', '\$ 4,892,300 MXN', Icons.payments_outlined, const Color(0xFF059669)),
              const SizedBox(width: 16),
              _tarjetaKpi('Contratantes Activos', '2,562', Icons.groups_outlined, const Color(0xFF7C3AED)),
              const SizedBox(width: 16),
              _tarjetaKpi('Cobranza por Vencer', '27 Recibos', Icons.warning_amber_rounded, const Color(0xFFDC2626)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tarjetaKpi(String label, String valor, IconData icono, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icono, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    valor,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirModuloCargarIA() {
    return Center(
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(34),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFF0284C7), size: 40),
            const SizedBox(height: 18),
            const Text(
              'Carga Inteligente con OCR (Gemini 2.5 Flash)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sube una carátula en PDF o fotografía para extraer automáticamente póliza, vigencias y primas sin captura manual.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF091428),
                foregroundColor: const Color(0xFFD4AF37),
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
              ),
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('SUBIR CARÁTULA EN PDF / IMAGEN'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Listo para análisis OCR con Gemini.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}