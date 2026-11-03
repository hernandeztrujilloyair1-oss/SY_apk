import 'package:flutter/material.dart';

// Servicios del Sistema
import '../services/auth_service.dart';
import '../services/empresa_config_service.dart';
import '../services/tenant_service.dart';

// Vistas Integradas del CRM
import 'login_screen.dart';
import 'calendario_screen.dart';
import 'prospectos_tarjetas_vista.dart';
import 'auditoria_portales_vista.dart';
import 'reportes_cobranza_vista.dart';
import 'portales_aseguradoras_vista.dart';
import 'reporte_contratantes_vista.dart';
import 'cotizador_autos_vista.dart';
import 'cotizador_gmm_vista.dart';
import 'plantillas_screen.dart';
import 'configuracion_marca_blanca_vista.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Sección activa en la barra lateral
  String _seccionActiva = 'DASHBOARD';

  // Buscador global del Header
  final TextEditingController _buscadorGlobalCtrl = TextEditingController();

  @override
  void dispose() {
    _buscadorGlobalCtrl.dispose();
    super.dispose();
  }

  // Cierre de sesión seguro
  void _cerrarSesion() {
    AuthService().cerrarSesion();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conf = EmpresaConfigService();
    final tenant = TenantService().empresaActiva;
    final usuario = AuthService().usuarioActual;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // ==================================================================
          // 1. BARRA LATERAL (SIDEBAR DE NAVEGACIÓN COMPLETO)
          // ==================================================================
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: tenant.colorPrimario,
              border: const Border(right: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Column(
              children: [
                // Identidad de Marca Blanca / Despacho Activo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: tenant.colorAcento,
                        child: Text(
                          tenant.nombre.isNotEmpty ? tenant.nombre.substring(0, 1) : 'S',
                          style: TextStyle(
                            color: tenant.colorPrimario,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              tenant.lema,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 9.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFF1E293B)),

                // Menú de Navegación Lateral
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _itemSidebar(Icons.dashboard_outlined, 'DASHBOARD'),
                      _itemSidebar(Icons.calendar_month_outlined, 'CALENDARIO'),
                      _itemSidebar(Icons.badge_outlined, 'PROSPECTOS & TARJETAS'),
                      _itemSidebar(Icons.fact_check_outlined, 'AUDITORÍA CONTRATANTES'),
                      _itemSidebar(Icons.bar_chart_outlined, 'REPORTES COBRANZA'),
                      _itemSidebar(Icons.description_outlined, 'PÓLIZAS'),
                      _itemSidebar(Icons.credit_card_outlined, 'COBRANZA'),
                      _itemSidebar(Icons.directions_car_outlined, 'COTIZADOR AUTOS'),
                      _itemSidebar(Icons.medical_services_outlined, 'COTIZADOR GMM'),
                      _itemSidebar(Icons.auto_awesome, 'CARGAR CON IA'),
                      _itemSidebar(Icons.mark_email_read_outlined, 'PLANTILLAS'),
                      _itemSidebar(Icons.settings_outlined, 'CONFIGURACIÓN'),
                    ],
                  ),
                ),

                // Perfil de Usuario Logueado (Footer Sidebar)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: Color(0xFF070F1E),
                    border: Border(top: BorderSide(color: Color(0xFF1E293B))),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: tenant.colorAcento.withOpacity(0.2),
                        child: Text(
                          usuario != null && usuario.nombre.isNotEmpty ? usuario.nombre.substring(0, 1) : 'U',
                          style: TextStyle(color: tenant.colorAcento, fontWeight: FontWeight.bold, fontSize: 13),
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
                              style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              usuario?.rol.name.toUpperCase() ?? 'EJECUTIVO',
                              style: TextStyle(color: tenant.colorAcento, fontSize: 9.5, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, size: 16, color: Color(0xFF94A3B8)),
                        tooltip: 'Cerrar Sesión',
                        onPressed: _cerrarSesion,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ==================================================================
          // 2. ÁREA CENTRAL DE CONTENIDO Y HEADER SUPERIOR
          // ==================================================================
          Expanded(
            child: Column(
              children: [
                // Header Superior Ejecutivo
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: Row(
                    children: [
                      // Buscador Global contextual
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: TextField(
                            controller: _buscadorGlobalCtrl,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: 'Buscar en $_seccionActiva (Titular, Póliza, Serie, RFC)...',
                              hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                              prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF64748B)),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Indicador de Despacho y Tenant
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.business, size: 14, color: Color(0xFF059669)),
                            const SizedBox(width: 6),
                            Text(
                              tenant.nombre,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Botón de Acciones Rápidas / Notificaciones
                      IconButton(
                        icon: const Icon(Icons.notifications_none_outlined, size: 20, color: Color(0xFF475569)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sin alertas críticas pendientes al momento.')),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Vista Dinámica Central
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

  // Componente de ítem en la barra lateral
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: activo ? const Color(0xFF14233D) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: activo ? tenant.colorAcento : Colors.transparent,
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
                      fontWeight: activo ? FontWeight.bold : FontWeight.w500,
                      letterSpacing: 0.3,
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

  // Router Dinámico de Vistas
  Widget _construirContenidoCentral(UsuarioSesion? usuario) {
    switch (_seccionActiva) {
      case 'DASHBOARD':
        return _construirDashboardPrincipal();

      case 'CALENDARIO':
        return const CalendarioScreen();

      case 'PROSPECTOS & TARJETAS':
        return const ProspectosTarjetasVista();

      case 'AUDITORÍA CONTRATANTES':
        return const AuditoriaPortalesVista();

      case 'REPORTES COBRANZA':
        return const ReportesCobranzaVista();

      case 'PÓLIZAS':
        return const PortalesAseguradorasVista();

      case 'COBRANZA':
        return const ReporteContratantesVista();

      case 'COTIZADOR AUTOS':
        return const CotizadorAutosVista();

      case 'COTIZADOR GMM':
        return const CotizadorGmmVista();

      case 'CARGAR CON IA':
        return _construirModuloCargarIA();

      case 'PLANTILLAS':
        return const PlantillasScreen();

      case 'CONFIGURACIÓN':
        // Protección RBAC: Solo MAESTRO o COBRANZA pueden gestionar configuración
        if (usuario != null && usuario.esEjecutivo) {
          return const Center(
            child: Text(
              'Acceso restringido: Solo el Director General (Maestro) puede modificar parámetros.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          );
        }
        return const ConfiguracionMarcaBlancaVista();

      default:
        return const Center(child: Text('Módulo en proceso...'));
    }
  }

  // 1. Dashboard Principal (Métricas y Resumen Ejecutivo)
  Widget _construirDashboardPrincipal() {
    final tenant = TenantService().empresaActiva;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Panel Principal - ${tenant.nombre}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  const Text('Resumen ejecutivo de cartera, cobranza y comisiones en tiempo real.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: tenant.colorPrimario,
                  foregroundColor: tenant.colorAcento,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('NUEVA COTIZACIÓN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: () => setState(() => _seccionActiva = 'COTIZADOR AUTOS'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // KPIs de Cartera General
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
          const SizedBox(height: 24),

          // Accesos Directos a Operaciones
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
                const Text('Accesos Operativos Rápidos', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    _botonAccesoRapido('Cotizador de Autos', Icons.directions_car_outlined, () => setState(() => _seccionActiva = 'COTIZADOR AUTOS')),
                    _botonAccesoRapido('Auditoría Portales vs Sheets', Icons.fact_check_outlined, () => setState(() => _seccionActiva = 'AUDITORÍA CONTRATANTES')),
                    _botonAccesoRapido('Reportes y Pólizas', Icons.bar_chart_outlined, () => setState(() => _seccionActiva = 'REPORTES COBRANZA')),
                    _botonAccesoRapido('Plantillas de Cobranza', Icons.mark_email_read_outlined, () => setState(() => _seccionActiva = 'PLANTILLAS')),
                  ],
                ),
              ],
            ),
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
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icono, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(valor, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botonAccesoRapido(String titulo, IconData icono, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 16, color: const Color(0xFF091428)),
            const SizedBox(width: 8),
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
          ],
        ),
      ),
    );
  }

  // 2. Módulo Auxiliar: Cargar con IA
  Widget _construirModuloCargarIA() {
    return Center(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFFEFF6FF),
              child: Icon(Icons.auto_awesome, color: Color(0xFF0284C7), size: 30),
            ),
            const SizedBox(height: 16),
            const Text(
              'Carga Inteligente con OCR (Gemini 2.5 Flash)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sube una carátula en PDF o imagen para extraer automáticamente póliza, vigencias, contratante y primas sin captura manual.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF091428),
                foregroundColor: const Color(0xFFD4AF37),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.upload_file),
              label: const Text('SUBIR CARÁTULA EN PDF / IMAGEN'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Abriendo selector de archivos para análisis OCR...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}