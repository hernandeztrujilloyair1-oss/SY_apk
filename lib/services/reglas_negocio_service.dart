class ReglasNegocioService {
  /// Genera el texto del mensaje para WhatsApp según el medio, el tipo de aviso y los datos del cliente/póliza.
  static String armarMensajeWhatsApp({
    required String cliente,
    required String ramo,
    String? folio,
    String? avisoTipo, // '1°', '2°', '3°', 'SR RAUL', etc.
    String? nuevoCorreo,
    String? ejecutivo,
    bool esGrupo = false,
    bool llevaComparativa = false,
  }) {
    final buffer = StringBuffer();

    // 1. Saludo y presentación
    final nombreAtendio = (ejecutivo != null && ejecutivo.isNotEmpty)
        ? ejecutivo
        : 'Yair Hernández';

    if (!esGrupo) {
      buffer.writeln(
        'Hola $cliente, soy $nombreAtendio de Enfoque Seguro, le hablo por parte de su broker Raúl Martínez.',
      );
    } else {
      buffer.writeln('Estimado(a) $cliente:');
    }
    buffer.writeln();

    // 2. Traductor inteligente de ramo
    final ramoAjustado = _ajustarTextoRamo(ramo);

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
          'Por indicación directa del Sr. Raúl Martínez, le compartimos la actualización sobre su $ramoAjustado.',
        );
        break;
      default:
        buffer.writeln(
          'Le compartimos la información correspondiente a su $ramoAjustado.',
        );
    }

    // 4. Inclusión de folio o referencia
    if (folio != null && folio.isNotEmpty) {
      buffer.writeln('Referencia / Folio: $folio');
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