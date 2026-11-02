class TrasladoService {
  /// Emula la macro de traslado a ALTAS-BAJAS:
  /// - Omite columna C (Control de Cobranza)
  /// - Valida RFC de Persona Moral (12 caracteres si no tiene título/persona física)
  static Map<String, dynamic> prepararRegistroAltasBajas({
    required Map<String, dynamic> registroOriginal,
    required String atendio,
  }) {
    final Map<String, dynamic> datosLimpios = Map.from(registroOriginal);

    // Regla: Se elimina la columna C (Control de Cobranza)
    datosLimpios.remove('control_cobranza');
    datosLimpios.remove('columna_c');

    // Regla: Identificar persona moral si el RFC tiene 12 dígitos o título vacío
    final rfc = (datosLimpios['rfc'] ?? '').toString().trim();
    if (rfc.length == 12 || (datosLimpios['titulo'] ?? '').toString().isEmpty) {
      datosLimpios['tipo_persona'] = 'Moral';
    } else {
      datosLimpios['tipo_persona'] = 'Física';
    }

    // Firma invisible de auditoría
    datosLimpios['_firma_auditoria'] = 'SY_APP_${DateTime.now().millisecondsSinceEpoch}_$atendio';

    return datosLimpios;
  }
}