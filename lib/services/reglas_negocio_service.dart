import 'empresa_config_service.dart';

class ReglasNegocioService {
  /// Obtiene los correos en copia (CC) directamente de la configuración activa de Marca Blanca.
  static List<String> obtenerCorreosCC() {
    final conf = EmpresaConfigService();
    final List<String> correos = [];

    final contacto = conf.correoContacto.trim();
    final cobranza = conf.correoCobranza.trim();

    if (contacto.isNotEmpty) {
      correos.add(contacto);
    }
    if (cobranza.isNotEmpty && cobranza.toLowerCase() != contacto.toLowerCase()) {
      correos.add(cobranza);
    }

    return correos;
  }

  /// Genera el texto del mensaje para WhatsApp adaptado a la Marca Blanca del despacho.
  static String armarMensajeWhatsApp({
    required String cliente,
    String? ramo,
    String? poliza,
    String? folio,
    String? avisoTipo, // '1°', '2°', '3°', 'SR RAUL', etc.
    String? nuevoCorreo,
    String? ejecutivo,
    bool esGrupo = false,
    bool llevaComparativa = false,
  }) {
    final conf = EmpresaConfigService();
    final buffer = StringBuffer();

    // 1. Identidad dinámica del despacho y ejecutivo
    final nombreAtendio = (ejecutivo != null && ejecutivo.isNotEmpty)
        ? ejecutivo
        : (conf.brokerTitular.isNotEmpty ? conf.brokerTitular : 'su Asesor de Seguros');

    final nombreDespacho = conf.nombreDespacho.isNotEmpty
        ? conf.nombreDespacho
        : 'su Despacho de Seguros';

    // Saludo y presentación
    if (!esGrupo) {
      buffer.writeln(
        'Hola $cliente, le saluda $nombreAtendio de $nombreDespacho.',
      );
    } else {
      buffer.writeln('Estimado(a) $cliente:');
    }
    buffer.writeln();

    // 2. Traductor inteligente de ramo
    final ramoTexto = (ramo != null && ramo.isNotEmpty) ? ramo : 'Póliza';
    final ramoAjustado = _ajustarTextoRamo(ramoTexto);

    // 3. Redacción según el tipo de aviso o gestión
    switch (avisoTipo) {
      case '1°':
        buffer.writeln(
          'Nos ponemos en contacto para darle seguimiento a su $ramoAjustado.',
        );
        break;
      case '2°':
        buffer.writeln(
          'Le enviamos un recordatorio sobre el estado de su $ramoAjustado.',
        );
        break;
      case '3°':
        buffer.writeln(
          'Le hacemos una última llamada de atención referente a su $ramoAjustado para evitar cualquier inconveniente con su cobertura.',
        );
        break;
      case 'SR RAUL':
        buffer.writeln(
          'Por indicación directa de la Dirección ($nombreAtendio), le compartimos la actualización sobre su $ramoAjustado.',
        );
        break;
      default:
        buffer.writeln(
          'Le compartimos la información correspondiente a su $ramoAjustado.',
        );
    }

    // 4. Inclusión de póliza si fue proporcionada
    final refPoliza = poliza ?? folio;
    if (refPoliza != null && refPoliza.isNotEmpty) {
      buffer.writeln('Póliza / Referencia: $refPoliza');
    }

    // 5. Inclusión de nuevo correo si fue registrado
    if (nuevoCorreo != null && nuevoCorreo.isNotEmpty) {
      buffer.writeln('Correo de contacto registrado: $nuevoCorreo');
    }

    // 6. Mensaje de comparativa si aplica
    if (llevaComparativa) {
      buffer.writeln(
        'Anexamos la comparativa de opciones disponibles para su revisión.',
      );
    }

    buffer.writeln();
    buffer.write(
      'Quedamos a sus órdenes ante cualquier duda o aclaración. ¡Que tenga un excelente día!',
    );

    return buffer.toString();
  }

  /// Ajusta la redacción del ramo para anteceder "Seguro de..." o "Protección para..."
  static String _ajustarTextoRamo(String ramoOriginal) {
    final limpio = ramoOriginal.trim();
    final lower = limpio.toLowerCase();

    if (lower.startsWith('seguro de') || lower.startsWith('protección para')) {
      return limpio;
    }

    if (lower.contains('auto') ||
        lower.contains('camion') ||
        lower.contains('moto') ||
        lower.contains('vehiculo')) {
      return 'Seguro de $limpio';
    }

    if (lower.contains('gmm') ||
        lower.contains('gastos medicos') ||
        lower.contains('salud') ||
        lower.contains('vida')) {
      return 'Protección para $limpio';
    }

    return 'Seguro de $limpio';
  }
}