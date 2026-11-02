class AlertasService {
  /// Valida si es momento de alertar la impresión de pestañas físicas
  static bool verificarAlertaViernes() {
    final ahora = DateTime.now();
    // 5 = Viernes en DateTime de Dart
    if (ahora.weekday == DateTime.friday && ahora.hour >= 16) {
      return true;
    }
    return false;
  }
}