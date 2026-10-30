import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/poliza_model.dart';

class ApiService {
  // Configura aqui la URL publicada de Google Apps Script
  static String appsScriptUrl = "";

  static final List<PolizaModel> _memoriaLocal = [
    PolizaModel(
      idPoliza: 'POL-901',
      avisoEstado: '1°',
      numeroPoliza: '01-554-998234',
      titular: 'JUAN MANUEL PEREZ LOPEZ',
      rfc: 'PELJ840211AA1',
      aseguradora: 'GNP',
      ramo: 'Autos',
      bienAsegurado: 'NISSAN VERSA ADVANCE 2023',
      serie: '3N1CN7AP5KL881923',
      placas: 'NWY-4819',
      inicioVigencia: '2026-01-15',
      finVigencia: '2027-01-15',
      primaNeta: 14200.0,
      formaPago: 'Semestral',
      claveAgenteAsignada: 'CLV-9941 - DIRECTO RAUL MARTINEZ',
      vendedor: 'SR RAUL',
      tipoVendedor: 'Interno',
      estatusArt492: 'SI',
      esRenovacion: false,
      polizaAnteriorNumero: '',
      atendio: 'Yair Hernández',
      tipoPersona: 'FISICA',
    ),
    PolizaModel(
      idPoliza: 'POL-902',
      avisoEstado: '2°',
      numeroPoliza: '9920184712',
      titular: 'LOGISTICA EMPRESARIAL SA DE CV',
      rfc: 'LEM120510XX1',
      aseguradora: 'QUALITAS',
      ramo: 'Autos',
      bienAsegurado: 'FORD TRANSIT CUSTOM 2022',
      serie: '1FTBR1Y84NKA77123',
      placas: 'LF-91823',
      inicioVigencia: '2026-02-01',
      finVigencia: '2027-02-01',
      primaNeta: 28900.0,
      formaPago: 'Anual',
      claveAgenteAsignada: 'AG-123 - ENFOQUE SEGURO',
      vendedor: 'Broker Externo',
      tipoVendedor: 'Externo',
      estatusArt492: 'PENDIENTE',
      esRenovacion: true,
      polizaAnteriorNumero: '9910041289',
      atendio: 'Yair Hernández',
      tipoPersona: 'MORAL',
    ),
  ];

  static Future<List<PolizaModel>> obtenerPolizas() async {
    if (appsScriptUrl.isNotEmpty) {
      try {
        final res = await http.get(Uri.parse(appsScriptUrl));
        if (res.statusCode == 200) {
          final List datos = jsonDecode(res.body);
          return datos.map((e) => PolizaModel.fromJson(e)).toList();
        }
      } catch (_) {}
    }
    await Future.delayed(const Duration(milliseconds: 150));
    return List.from(_memoriaLocal);
  }

  static Future<bool> guardarPoliza(PolizaModel poliza) async {
    _memoriaLocal.insert(0, poliza);
    if (appsScriptUrl.isNotEmpty) {
      try {
        await http.post(
          Uri.parse(appsScriptUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(poliza.toJson()),
        );
      } catch (_) {}
    }
    return true;
  }
}
