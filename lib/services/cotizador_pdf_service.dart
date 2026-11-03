import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'empresa_config_service.dart';

class CotizadorPdfService {
  static Future<void> imprimirPropuesta({
    required String cliente,
    required String tipoBien,
    required List> opcionesSeleccionadas,
  }) async {
    final pdf = pw.Document();
    final conf = EmpresaConfigService();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter.landscape,
        build: (pw.Context ctx) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          conf.nombreDespacho,
                          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
                        ),
                        pw.Text(conf.lemaDespacho, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                        pw.Text('Asesor: ${conf.brokerTitular}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('PROPUESTA COMPARATIVA', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
                        pw.Text('Cliente: $cliente', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Ramo / Bien: $tipoBien', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                      ],
                    ),
                  ],
                ),
                pw.Divider(thickness: 1.5, color: PdfColors.blueGrey800),
                pw.SizedBox(height: 16),
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                  headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF0F172A)),
                  cellStyle: const pw.TextStyle(fontSize: 9),
                  cellAlignment: pw.Alignment.centerLeft,
                  headers: [
                    'Aseguradora / Plan',
                    'Deducible / Coaseguro',
                    'Responsabilidad Civil',
                    'Gasto Médico / Tabulador',
                    'Contado (Anual)',
                    'Semestral',
                    'Trimestral',
                    'Mensual',
                  ],
                  data: opcionesSeleccionadas.map((op) {
                    return [
                      op['aseguradora'] ?? '',
                      '${op['deducibleDM'] ?? ''}\n${op['deducibleRT'] ?? ''}',
                      op['rc'] ?? '',
                      op['gm'] ?? '',
                      '\$ ${op['anual'] ?? ''}',
                      '\$ ${op['semestral'] ?? ''}',
                      '\$ ${op['trimestral'] ?? ''}',
                      '\$ ${op['mensual'] ?? ''}',
                    ];
                  }).toList(),
                ),
                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Validez de la oferta: 15 días hábiles.', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                    pw.Text('Contacto: ${conf.correoContacto}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Propuesta_${cliente.replaceAll(' ', '_')}.pdf',
    );
  }
}
