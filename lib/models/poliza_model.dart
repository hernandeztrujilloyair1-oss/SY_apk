class PolizaModel {
  final String idPoliza;
  final String avisoEstado;
  final String numeroPoliza;
  final String titular;
  final String rfc;
  final String aseguradora;
  final String ramo;
  final String bienAsegurado;
  final String serie;
  final String placas;
  final String inicioVigencia;
  final String finVigencia;
  final double primaNeta;
  final String formaPago;
  final String claveAgenteAsignada;
  final String vendedor;
  final String tipoVendedor;
  final String estatusArt492;
  final bool esRenovacion;
  final String polizaAnteriorNumero;
  final String atendio;
  final String tipoPersona;

  PolizaModel({
    required this.idPoliza,
    required this.avisoEstado,
    required this.numeroPoliza,
    required this.titular,
    required this.rfc,
    required this.aseguradora,
    required this.ramo,
    required this.bienAsegurado,
    required this.serie,
    required this.placas,
    required this.inicioVigencia,
    required this.finVigencia,
    required this.primaNeta,
    required this.formaPago,
    required this.claveAgenteAsignada,
    required this.vendedor,
    required this.tipoVendedor,
    required this.estatusArt492,
    required this.esRenovacion,
    required this.polizaAnteriorNumero,
    required this.atendio,
    required this.tipoPersona,
  });

  factory PolizaModel.fromJson(Map<String, dynamic> json) {
    final rfcVal = (json['RFC'] ?? '').toString().replaceAll(' ', '').replaceAll('-', '').trim();
    final bool esMoral = rfcVal.length == 12 || (json['Titulo'] == null || json['Titulo'].toString().isEmpty);

    return PolizaModel(
      idPoliza: json['ID_Poliza'] ?? '',
      avisoEstado: json['Aviso_Estado'] ?? (json['Columna_B'] ?? '1°'),
      numeroPoliza: json['Numero_Poliza'] ?? '',
      titular: json['Titular'] ?? '',
      rfc: rfcVal,
      aseguradora: json['Aseguradora'] ?? '',
      ramo: json['Ramo_o_Rubro'] ?? 'Autos',
      bienAsegurado: json['Bien_Asegurado'] ?? '',
      serie: json['Serie'] ?? '',
      placas: json['Placas'] ?? '',
      inicioVigencia: json['Inicio_Vigencia'] ?? '',
      finVigencia: json['Fin_Vigencia'] ?? '',
      primaNeta: double.tryParse(json['Prima_Neta']?.toString() ?? '0') ?? 0.0,
      formaPago: json['Forma_Pago'] ?? 'Anual',
      claveAgenteAsignada: json['Clave_Agente_Asignada'] ?? 'DIRECTO DESPACHO',
      vendedor: json['Vendedor'] ?? 'Titular Broker',
      tipoVendedor: json['Tipo_Vendedor'] ?? 'Interno',
      estatusArt492: json['Expediente_Completo_492'] ?? 'PENDIENTE',
      esRenovacion: json['Es_Renovacion'] == true || json['Es_Renovacion'] == 'SI',
      polizaAnteriorNumero: json['Poliza_Renovada_Numero'] ?? '',
      atendio: json['Atendio'] ?? 'Asesor Comercial',
      tipoPersona: esMoral ? 'MORAL' : 'FISICA',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID_Poliza': idPoliza,
      'Aviso_Estado': avisoEstado,
      'Numero_Poliza': numeroPoliza,
      'Titular': titular,
      'RFC': rfc,
      'Aseguradora': aseguradora,
      'Ramo_o_Rubro': ramo,
      'Bien_Asegurado': bienAsegurado,
      'Serie': serie,
      'Placas': placas,
      'Inicio_Vigencia': inicioVigencia,
      'Fin_Vigencia': finVigencia,
      'Prima_Neta': primaNeta,
      'Forma_Pago': formaPago,
      'Clave_Agente_Asignada': claveAgenteAsignada,
      'Vendedor': vendedor,
      'Tipo_Vendedor': tipoVendedor,
      'Expediente_Completo_492': estatusArt492,
      'Es_Renovacion': esRenovacion ? 'SI' : 'NO',
      'Poliza_Renovada_Numero': polizaAnteriorNumero,
      'Atendio': atendio,
      'Tipo_Persona': tipoPersona,
    };
  }
}