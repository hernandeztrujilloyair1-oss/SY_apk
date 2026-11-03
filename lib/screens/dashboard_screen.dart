import 'package:flutter/material.dart';

// Servicios del Sistema
import '../services/auth_service.dart';
import '../services/empresa_config_service.dart';
import '../services/tenant_service.dart';

// Vistas del Sistema
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
import 'campanas_correo_vista.dart';
import 'configuracion_marca_blanca_vista.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Sección activa en la barra lateral
  String _seccionActiva = 'DASHBOARD';

  // Buscador global en el Header
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
          // ==================================================================
          // 1. SIDEBAR EJECUTIVO SUPER PREMIUM
          // ==================================================================
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Encabezado Corporativo (Marca Blanca)
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
                          boxShadow: [
                            BoxShadow(
                              color: tenant.colorAcento.withOpacity(0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
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
                                letterSpacing: 0.3,
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
                                fontWeight: FontWeight.w400,
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
                      _itemSidebar(Icons.campaign_outlined, 'CAMPAÑAS POR CORREO'),
                      _itemSidebar(Icons.settings_outlined, 'CONFIGURACIÓN'),
                    ],
                  ),
                ),

                // Widget Monopolio de Almacenamiento (5 TB Workspace vs 250 GB Clientes)
                _construirIndicadorAlmacenamiento(tenant),

                // Perfil de Usuario Logueado (Footer Sidebar)
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
                                letterSpacing: 0.5,
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

          // ==================================================================
          // 2. ÁREA CENTRAL DE CONTENIDO Y HEADER SUPERIOR
          // ==================================================================
          Expanded(
            child: Column(
              children: [
                // Header Ejecutivo
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x05000000),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Buscador Global
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
                              hintText: 'Buscar en $_seccionActiva (Titular, Póliza, Serie, RFC)...',
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

                      // Badge de Despacho Activo
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
                      const SizedBox(width: 14),

                      // Indicador de Alertas / Campana
                      IconButton(
                        icon: const Icon(Icons.notifications_none_outlined, size: 20, color: Color(0xFF475569)),
                        tooltip: 'Notificaciones del Sistema',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sin alertas operativas pendientes al momento.'),
                              behavior: SnackBarBehavior.floating,
                            ),
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

  // Componente de ítem lateral con efecto activo e iluminación
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
              boxShadow: activo
                  ? [
                      BoxShadow(
                        color: tenant.colorAcento.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
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
                      letterSpacing: 0.2,
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

  // Widget Medidor de Almacenamiento Monopolizado
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

  // Router Dinámico de Vistas con RBAC
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

      case 'CAMPAÑAS POR CORREO':
        return const CampanasCorreoVista();

      case 'CONFIGURACIÓN':
        if (usuario != null && usuario.esEjecutivo) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.gpp_bad_outlined, size: 40, color: Colors.red),
                  SizedBox(height: 10),
                  Text(
                    'Acceso Restringido',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Solo el Director General (Maestro) o Cobranza pueden modificar comisiones y configuración.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          );
        }
        return const ConfiguracionMarcaBlancaVista();

      default:
        return const Center(child: Text('Módulo no encontrado.'));
    }
  }

  // Vista 1: Dashboard Ejecutivo con KPIs Corporativos
  Widget _construirDashboardPrincipal() {
    final tenant = TenantService().empresaActiva;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(26),
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
                    'Panel de Control - ${tenant.nombre}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Resumen ejecutivo de cartera, cobranza y comisiones en tiempo real.',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: tenant.colorPrimario,
                  foregroundColor: tenant.colorAcento,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 2,
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text(
                  'NUEVA COTIZACIÓN',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
                onPressed: () => setState(() => _seccionActiva = 'COTIZADOR AUTOS'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // KPIs Principales
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
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Accesos Operativos Frecuentes',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    _botonAccesoRapido(
                      'Cotizador Multiasiguradora Autos',
                      Icons.directions_car_outlined,
                      () => setState(() => _seccionActiva = 'COTIZADOR AUTOS'),
                    ),
                    _botonAccesoRapido(
                      'Auditoría Portales vs Sheets',
                      Icons.fact_check_outlined,
                      () => setState(() => _seccionActiva = 'AUDITORÍA CONTRATANTES'),
                    ),
                    _botonAccesoRapido(
                      'Reporte General de Cobranza',
                      Icons.bar_chart_outlined,
                      () => setState(() => _seccionActiva = 'REPORTES COBRANZA'),
                    ),
                    _botonAccesoRapido(
                      'Campañas de Correo por Rubro',
                      Icons.campaign_outlined,
                      () => setState(() => _seccionActiva = 'CAMPAÑAS POR CORREO'),
                    ),
                    _botonAccesoRapido(
                      'Plantillas y Cobranza Preventiva',
                      Icons.mark_email_read_outlined,
                      () => setState(() => _seccionActiva = 'PLANTILLAS'),
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

  Widget _tarjetaKpi(String label, String valor, IconData icono, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
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
            Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
            ),
          ],
        ),
      ),
    );
  }

  // Vista 2: Carga Inteligente con Gemini OCR
  Widget _construirModuloCargarIA() {
    return Center(
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(34),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Icon(Icons.auto_awesome, color: Color(0xFF0284C7), size: 30),
            ),
            const SizedBox(height: 18),
            const Text(
              'Carga Inteligente con OCR (Gemini 2.5 Flash)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sube una carátula en PDF o fotografía para extraer automáticamente número de póliza, vigencias, contratante y desglose de primas sin captura manual.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF091428),
                foregroundColor: const Color(0xFFD4AF37),
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text(
                'SUBIR CARÁTULA EN PDF / IMAGEN',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Abriendo selector de archivos para análisis OCR con Gemini...'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}