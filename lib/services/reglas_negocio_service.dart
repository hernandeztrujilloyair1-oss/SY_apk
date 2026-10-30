import '../services/empresa_config_service.dart';

class ReglasNegocioService {
  static List<String> obtenerCorreosCC() {
    final conf = EmpresaConfigService();
    final List<String> lista = [];
    if (conf.correoContacto.isNotEmpty) lista.add(conf.correoContacto);
    if (conf.correoCobranza.isNotEmpty && conf.correoCobranza != conf.correoContacto) {
      lista.add(conf.correoCobranza);
    }
    return lista;
  }

  static String traducirRubroInteligente(String ramoOriginal) {
    final r = ramoOriginal.toLowerCase().trim();
    if (r.contains('auto') || r.contains('vehic') || r.contains('camion') || r.contains('flot')) {
      return 'Seguro de Autos';
    } else if (r.contains('gmm') || r.contains('medico') || r.contains('salud') || r.contains('gastos')) {
      return 'Protección para Gastos Médicos Mayores';
    } else if (r.contains('vida')) {
      return 'Seguro de Vida';
    } else if (r.contains('daño') || r.contains('hogar') || r.contains('empresa') || r.contains('inmueble')) {
      return 'Protección para Bienes y Daños';
    }
    return 'Seguro de $ramoOriginal';
  }

  static bool esPersonaMoral({String? titulo, required String rfc}) {
    if (titulo == null || titulo.trim().isEmpty) return true;
    final rfcLimpio = rfc.replaceAll(' ', '').replaceAll('-', '').trim();
    return rfcLimpio.length == 12;
  }

  static String armarMensajeWhatsApp({
    required String cliente,
    required String poliza,
    required String ramo,
    required String ejecutivoAtencion,
    required bool esGrupo,
    required bool llevaComparativa,
  }) {
    final conf = EmpresaConfigService();
    final rubroTraduccion = traducirRubroInteligente(ramo);

    String intro = esGrupo
        ? 'Estimados miembros del grupo, compartimos actualización referente al $rubroTraduccion de $cliente (Póliza: $poliza).'
        : 'Hola $cliente, le contacta $ejecutivoAtencion de ${conf.nombreDespacho}, por parte de su broker titular ${conf.brokerTitular}.';

    String cuerpo = '\n\nLe informamos sobre el estatus de su $rubroTraduccion con número de póliza: *$poliza*.';

    if (llevaComparativa) {
      cuerpo += '\n\nAdjuntamos la tabla comparativa con las cotizaciones cotejadas para su renovación.';
    }

    String pie = '\n\nLe atiende: *$ejecutivoAtencion*\n*${conf.nombreDespacho}*';
    return '$intro$cuerpo$pie';
  }

  static bool debeAlertarViernesImpresion() {
    final now = DateTime.now();
    return now.weekday == DateTime.friday && now.hour >= 16;
  }
}