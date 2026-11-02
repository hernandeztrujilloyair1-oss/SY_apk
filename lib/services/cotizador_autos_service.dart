class CotizacionAutoResultado {
  final double primaNeta;
  final double derechoPoliza;
  final double iva;
  final double primaTotalAnual;
  final double pagoSemestral;
  final double pagoTrimestral;
  final double pagoMensual;

  CotizacionAutoResultado({
    required this.primaNeta,
    required this.derechoPoliza,
    required this.iva,
    required this.primaTotalAnual,
    required this.pagoSemestral,
    required this.pagoTrimestral,
    required this.pagoMensual,
  });
}

class CotizadorAutosService {
  /// Calcula el desglose completo emulando las fórmulas de la macro de Excel
  static CotizacionAutoResultado cotizar({
    required double primaNeta,
    double derechoPoliza = 650.0,
    double recargoPagoFraccionado = 0.08, // 8% habitual
    double factorIva = 0.16,
  }) {
    final subtotal = primaNeta + derechoPoliza;
    final totalIva = subtotal * factorIva;
    final totalAnual = subtotal + totalIva;

    // Cálculo de pagos fraccionados con recargo
    final totalConRecargo = (primaNeta * (1 + recargoPagoFraccionado)) + derechoPoliza;
    final totalIvaFraccionado = totalConRecargo * (1 + factorIva);

    return CotizacionAutoResultado(
      primaNeta: primaNeta,
      derechoPoliza: derechoPoliza,
      iva: totalIva,
      primaTotalAnual: totalAnual,
      pagoSemestral: (totalIvaFraccionado / 2),
      pagoTrimestral: (totalIvaFraccionado / 4),
      pagoMensual: (totalIvaFraccionado / 12),
    );
  }
}