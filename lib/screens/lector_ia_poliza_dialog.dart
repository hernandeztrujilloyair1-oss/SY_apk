import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class LectorIaPolizaDialog extends StatefulWidget {
  final String? polizaOrigen;
  final String? contratanteOrigen;
  final String? aseguradoraOrigen;
  final String? rfcOrigen;

  const LectorIaPolizaDialog({
    super.key,
    this.polizaOrigen,
    this.contratanteOrigen,
    this.aseguradoraOrigen,
    this.rfcOrigen,
  });

  @override
  State<LectorIaPolizaDialog> createState() => _LectorIaPolizaDialogState();
}

class _LectorIaPolizaDialogState extends State<LectorIaPolizaDialog> {
  late bool _esRenovacion;
  late TextEditingController _polizaAnteriorCtrl;
  final _polizaNuevaCtrl = TextEditingController();
  final _contratanteCtrl = TextEditingController();
  final _rfcCtrl = TextEditingController();
  final _aseguradoraCtrl = TextEditingController(text: 'QUALITAS');
  final _vigInicioCtrl = TextEditingController();
  final _vigFinCtrl = TextEditingController();
  final _primaNetaCtrl = TextEditingController();
  final _primaTotalCtrl = TextEditingController();
  final _bienAseguradoCtrl = TextEditingController();
  final _atendidoPorCtrl = TextEditingController(text: 'Raúl Martínez');

  bool _tieneAvisoCobro = true;
  bool _tieneComprobantePago = true;
  bool _procesando = false;
  String _resultadoIA = '';

  @override
  void initState() {
    super.initState();
    _esRenovacion = widget.polizaOrigen != null;
    _polizaAnteriorCtrl = TextEditingController(text: widget.polizaOrigen ?? '');
    _contratanteCtrl.text = widget.contratanteOrigen ?? '';
    _rfcCtrl.text = widget.rfcOrigen ?? '';
    _aseguradoraCtrl.text = widget.aseguradoraOrigen ?? 'QUALITAS';
  }

  void _simularExtraccionIA(String textoPegado) {
    setState(() {
      _resultadoIA = 'Analizando estructura del documento...';
    });

    final polRegex = RegExp(r'(?:p[oó]liza|no\.?)\s*[:#]?\s*([A-Za-z0-9\-\/]{6,20})', caseSensitive: false);
    final rfcRegex = RegExp(r'[A-Z&Ñ]{3,4}\d{6}[A-Z0-9]{3}', caseSensitive: false);
    final primaRegex = RegExp(r'(?:total|prima)\s*[:\$]?\s*([\d,]+\.?\d*)', caseSensitive: false);

    final mPol = polRegex.firstMatch(textoPegado);
    final mRfc = rfcRegex.firstMatch(textoPegado);
    final mPrima = primaRegex.firstMatch(textoPegado);

    setState(() {
      if (mPol != null) _polizaNuevaCtrl.text = mPol.group(1)!;
      if (mRfc != null && _rfcCtrl.text.isEmpty) _rfcCtrl.text = mRfc.group(0)!.toUpperCase();
      if (mPrima != null) _primaTotalCtrl.text = mPrima.group(1)!.replaceAll(',', '');

      _tieneAvisoCobro = textoPegado.toLowerCase().contains('aviso de cobro') || textoPegado.toLowerCase().contains('formato de pago');
      _tieneComprobantePago = textoPegado.toLowerCase().contains('comprobante de pago');

      _resultadoIA = 'Lectura completada. Campos autocompletados con éxito.';
    });
  }

  Future<void> _guardarPoliza() async {
    if (_polizaNuevaCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa el número de póliza nueva.')));
      return;
    }

    setState(() => _procesando = true);
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.appsScriptUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accion': 'CAPTURAR_POLIZA_IA',
          'esRenovacion': _esRenovacion,
          'polizaAnterior': _polizaAnteriorCtrl.text.trim(),
          'noPoliza': _polizaNuevaCtrl.text.trim(),
          'contratante': _contratanteCtrl.text.trim(),
          'rfc': _rfcCtrl.text.trim().toUpperCase(),
          'aseguradora': _aseguradoraCtrl.text.trim().toUpperCase(),
          'vigenciaInicio': _vigInicioCtrl.text.trim(),
          'vigenciaFin': _vigFinCtrl.text.trim(),
          'primaNeta': _primaNetaCtrl.text.trim(),
          'primaTotal': _primaTotalCtrl.text.trim(),
          'bienAsegurado': _bienAseguradoCtrl.text.trim(),
          'atendidoPor': _atendidoPorCtrl.text.trim(),
          'tieneAvisoCobro': _tieneAvisoCobro,
          'tieneComprobantePago': _tieneComprobantePago,
        }),
      );

      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Póliza ${_polizaNuevaCtrl.text} registrada correctamente con firma de auditoría.'),
              backgroundColor: const Color(0xFF059669),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al procesar: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 850,
        constraints: const BoxConstraints(maxHeight: 750),
        child: Column(
          children: [
            // Encabezado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF091428),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Color(0xFFD4AF37), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.polizaOrigen != null
                          ? 'Renovación Inteligente de Póliza: ${widget.polizaOrigen}'
                          : 'Lector y Capturador de Pólizas con IA',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cuadro de decisión: ¿Póliza nueva o renovación vinculada?
                    if (widget.polizaOrigen == null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '¿Esta póliza está vinculada a una póliza anterior de la cartera?',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF091428)),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                ChoiceChip(
                                  label: const Text('NO, ES PÓLIZA NUEVA'),
                                  selected: !_esRenovacion,
                                  selectedColor: const Color(0xFF091428),
                                  labelStyle: TextStyle(color: !_esRenovacion ? const Color(0xFFD4AF37) : const Color(0xFF091428), fontWeight: FontWeight.bold),
                                  onSelected: (val) => setState(() => _esRenovacion = !val),
                                ),
                                const SizedBox(width: 12),
                                ChoiceChip(
                                  label: const Text('SÍ, ES UNA RENOVACIÓN'),
                                  selected: _esRenovacion,
                                  selectedColor: const Color(0xFF091428),
                                  labelStyle: TextStyle(color: _esRenovacion ? const Color(0xFFD4AF37) : const Color(0xFF091428), fontWeight: FontWeight.bold),
                                  onSelected: (val) => setState(() => _esRenovacion = val),
                                ),
                              ],
                            ),
                            if (_esRenovacion) ...[
                              const SizedBox(height: 12),
                              TextField(
                                controller: _polizaAnteriorCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Número de Póliza Anterior (para vincular historial)',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  prefixIcon: Icon(Icons.link),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Zona de lectura de texto o carátula
                    const Text('Pegar Texto de Carátula o Documento para Lectura con IA:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF091428))),
                    const SizedBox(height: 8),
                    TextField(
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Pega aquí el contenido copiado del PDF, carátula o aviso de cobro...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: _simularExtraccionIA,
                    ),
                    if (_resultadoIA.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(_resultadoIA, style: const TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.bold)),
                    ],

                    const SizedBox(height: 20),
                    const Text('Datos Extraídos y Validación Operativa:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF091428))),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(child: TextField(controller: _polizaNuevaCtrl, decoration: const InputDecoration(labelText: 'No. Póliza Nueva', border: OutlineInputBorder(), isDense: true))),
                        const SizedBox(width: 12),
                        Expanded(child: TextField(controller: _aseguradoraCtrl, decoration: const InputDecoration(labelText: 'Aseguradora', border: OutlineInputBorder(), isDense: true))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(flex: 3, child: TextField(controller: _contratanteCtrl, decoration: const InputDecoration(labelText: 'Contratante', border: OutlineInputBorder(), isDense: true))),
                        const SizedBox(width: 12),
                        Expanded(flex: 2, child: TextField(controller: _rfcCtrl, decoration: const InputDecoration(labelText: 'RFC', border: OutlineInputBorder(), isDense: true))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _vigInicioCtrl, decoration: const InputDecoration(labelText: 'Inicio Vigencia (AAAA-MM-DD)', border: OutlineInputBorder(), isDense: true))),
                        const SizedBox(width: 12),
                        Expanded(child: TextField(controller: _vigFinCtrl, decoration: const InputDecoration(labelText: 'Fin Vigencia (AAAA-MM-DD)', border: OutlineInputBorder(), isDense: true))),
                        const SizedBox(width: 12),
                        Expanded(child: TextField(controller: _primaTotalCtrl, decoration: const InputDecoration(labelText: 'Prima Total', border: OutlineInputBorder(), isDense: true))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: _bienAseguradoCtrl, decoration: const InputDecoration(labelText: 'Bien Asegurado / Plan', border: OutlineInputBorder(), isDense: true)),

                    const SizedBox(height: 20),
                    // Auditoría: Quién atiende y Checklist documental
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Validación de Emisión y Firma de Auditoría', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF92400E))),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _atendidoPorCtrl,
                                  decoration: const InputDecoration(labelText: '¿Quién atiende el trámite?', border: OutlineInputBorder(), isDense: true),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Row(
                                children: [
                                  Checkbox(value: _tieneAvisoCobro, activeColor: const Color(0xFF091428), onChanged: (v) => setState(() => _tieneAvisoCobro = v ?? false)),
                                  const Text('Aviso de Cobro', style: TextStyle(fontSize: 11)),
                                  Checkbox(value: _tieneComprobantePago, activeColor: const Color(0xFF091428), onChanged: (v) => setState(() => _tieneComprobantePago = v ?? false)),
                                  const Text('Comprobante Pago', style: TextStyle(fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Botones de acción
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('CANCELAR'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF091428),
                      foregroundColor: const Color(0xFFD4AF37),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: _procesando
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 2))
                        : const Icon(Icons.save_outlined, size: 18),
                    label: Text(_procesando ? 'GUARDANDO...' : (_esRenovacion ? 'PROCESAR RENOVACIÓN' : 'REGISTRAR PÓLIZA NUEVA')),
                    onPressed: _procesando ? null : _guardarPoliza,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
