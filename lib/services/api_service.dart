import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/poliza_model.dart';

class ApiService {
  // Pega aquí la URL de tu Web App de Apps Script terminada en /exec
  static String appsScriptUrl = "https://script.google.com/macros/s/AKfycbx0_EtCpa4kd4xWQ3exYT_18PH6YXhEcAUgWxl0h242elBfzs5WUiaEmuueJRLfDHSg/exec";

  static Future<List<PolizaModel>> obtenerPolizas({String tabla = "RECIBOS_COBRANZA"}) async {
    if (appsScriptUrl.isNotEmpty && !appsScriptUrl.contains("TU_ID_AQUI")) {
      try {
        final res = await http.get(Uri.parse('$appsScriptUrl?tabla=$tabla'));
        if (res.statusCode == 200 || res.statusCode == 302) {
          final List datos = jsonDecode(res.body);
          return datos.map((e) => PolizaModel.fromJson(e)).toList();
        }
      } catch (_) {}
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return _datosLocales();
  }

  static Future<bool> guardarPoliza(PolizaModel poliza) async {
    if (appsScriptUrl.isNotEmpty && !appsScriptUrl.contains("TU_ID_AQUI")) {
      try {
        await http.post(
          Uri.parse(appsScriptUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "accion": "GUARDAR_COBRANZA",
            "numero_poliza": poliza.numeroPoliza,
            "titular": poliza.titular,
            "monto": poliza.primaNeta,
            "estatus": poliza.avisoEstado,
            "aseguradora": poliza.aseguradora,
            "ramo": poliza.ramo,
          }),
        );
      } catch (_) {}
    }
    return true;
  }

  static List<PolizaModel> _datosLocales() {
    return [
      PolizaModel(
        idPoliza: 'REC-001',
        avisoEstado: 'Pendiente',
        numeroPoliza: '01-554-998234',
        titular: 'GRUPO INDUSTRIAL MEXICANO SA DE CV',
        rfc: 'GIM180312AA1',
        aseguradora: 'GNP',
        ramo: 'Autos',
        bienAsegurado: 'BMW SERIE 3 330E 2024',
        serie: '3N1CN7AP5KL881923',
        placas: 'NWY-4819',
        inicioVigencia: '2026-01-15',
        finVigencia: '2027-01-15',
        primaNeta: 48950.00,
        formaPago: 'Semestral',
        claveAgenteAsignada: 'CLV-DIRECTO',
        vendedor: 'Dirección Broker',
        tipoVendedor: 'Interno',
        estatusArt492: 'SI',
        esRenovacion: false,
        polizaAnteriorNumero: '',
        atendio: 'Dirección General',
        tipoPersona: 'MORAL',
      ),
    ];
  }
}