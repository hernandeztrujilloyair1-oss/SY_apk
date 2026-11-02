import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/poliza_model.dart';
import '../services/api_service.dart';
import '../services/reglas_negocio_service.dart';

class ModalCargaIa extends StatefulWidget {
  final VoidCallback onGuardado;
  const ModalCargaIa({super.key, required this.onGuardado});

  @override
  State<ModalCargaIa> createState() => _ModalCargaIaState();
}

class _ModalCargaIaState extends State<ModalCargaIa> {
  bool _cargando = false;
  String? _archivoNombre;
  bool _tieneComprobantePago = false;

  final _polizaCtrl = TextEditingController();
  final _titularCtrl = TextEditingController();
  final _rfcCtrl = TextEditingController();
  final _aseguradoraCtrl = TextEditingController();
  final _ramoCtrl = TextEditingController(text: 'Autos');
  final _serieCtrl = TextEditingController();
  final _placasCtrl = TextEditingController();
  final _bienCtrl = TextEditingController();
  final _inicioCtrl = TextEditingController();
  final _finCtrl = TextEditingController();
  final _primaCtrl = TextEditingController();

  String _avisoEstado = '1°';
  String _vendedor = 'SR RAUL';
  String _claveAgente = '123456 - RAUL MARTINEZ (DIRECTO)';
  bool _esRenovacion = false;
  String _polizaAnterior = '';

  // Checks obligatorios
  bool _chkPoliza = false;
  bool _chkVigencias = false;
  bool _chkImporte = false;
  bool _chkAuto = false;

  Future<void> _subirCaratula() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg'],
      withData: true,
    );
    if (res != null && res.files.single.name.isNotEmpty) {
      setState(() {
        _cargando = true;
        _archivoNombre = res.files.single.name;
        _tieneComprobantePago = res.files.single.name.toLowerCase().contains('pago') ||
            res.files.single.name.toLowerCase().contains('comprobante') ||
            res.files.single.name.toLowerCase().contains('cobro');
      });

      await Future.delayed(const Duration(milliseconds: 600));

      setState(() {
        _polizaCtrl.text = "AUT-2026-9912";
        _aseguradoraCtrl.text = "QUALITAS";
        _titularCtrl.text = "TRANSPORTES LOGISTICOS SA DE CV";
        _rfcCtrl.text = "TLS1904128N1";
        _ramoCtrl.text = "Autos";
        _bienCtrl.text = "KENWORTH T680 2024";
        _serieCtrl.text = "3WKHD49X5PF129841";
        _placasCtrl.text = "98-AA-1K";
        _inicioCtrl.text = "2026-03-01";
        _finCtrl.text = "2027-03-01";
        _primaCtrl.text = "48250.00";
        _cargando = false;
      });
    }
  }

  void _guardar() async {
    if (!_tieneComprobantePago) {
      final aceptarSinPago = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF131F37),
          title: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.amber),
              SizedBox(width: 8),
              Text('Validación de Cobro', style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          content: const Text(
            'No se detectó un archivo con "Comprobante de Pago", "Aviso de Cobro" o "Formato de Pago". ¿Desea continuar de todos modos?',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Continuar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      if (aceptarSinPago != true) return;
    }

    final rfcLimpio = _rfcCtrl.text.replaceAll(' ', '').replaceAll('-', '').trim();
    final tipoPers = (rfcLimpio.length == 12) ? 'MORAL' : 'FISICA';

    final nueva = PolizaModel(
      idPoliza: 'POL-\${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      avisoEstado: _avisoEstado,
      numeroPoliza: _polizaCtrl.text.trim(),
      titular: _titularCtrl.text.trim(),
      rfc: rfcLimpio,
      aseguradora: _aseguradoraCtrl.text.trim(),
      ramo: _ramoCtrl.text.trim(),
      bienAsegurado: _bienCtrl.text.trim(),
      serie: _serieCtrl.text.trim(),
      placas: _placasCtrl.text.trim(),
      inicioVigencia: _inicioCtrl.text.trim(),
      finVigencia: _finCtrl.text.trim(),
      primaNeta: double.tryParse(_primaCtrl.text) ?? 0.0,
      formaPago: 'Anual',
      claveAgenteAsignada: _claveAgente,
      vendedor: _vendedor,
      tipoVendedor: 'Interno',
      estatusArt492: 'PENDIENTE',
      esRenovacion: _esRenovacion,
      polizaAnteriorNumero: _esRenovacion ? _polizaAnterior : '',
      atendio: 'Yair Hernández',
      tipoPersona: tipoPers,
    );

    await ApiService.guardarPoliza(nueva);
    widget.onGuardado();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool puedeGuardar = _chkPoliza && _chkVigencias && _chkImporte && (_chkAuto || !_ramoCtrl.text.toLowerCase().contains('auto'));

    return Dialog(
      backgroundColor: const Color(0xFF131F37),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 750),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.flash_on, color: Colors.cyanAccent),
                const SizedBox(width: 8),
                const Text('Llenador Inteligente de Póliza',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(color: Color(0xFF1E3A8A)),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
                      icon: const Icon(Icons.upload_file, color: Colors.white),
                      label: const Text('Cargar Carátula / Cotización (PDF/Imagen)', style: TextStyle(color: Colors.white)),
                      onPressed: _cargando ? null : _subirCaratula,
                    ),
                    if (_archivoNombre != null) ...[
                      const SizedBox(height: 6),
                      Text('Archivo: \$_archivoNombre', style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _avisoEstado,
                            dropdownColor: const Color(0xFF0B1528),
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              labelText: 'Estatus Aviso (Col B)',
                              filled: true,
                              fillColor: const Color(0xFF0B1528),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            items: const [
                              DropdownMenuItem(value: '1°', child: Text('1° - Primer Aviso')),
                              DropdownMenuItem(value: '2°', child: Text('2° - Segundo Aviso')),
                              DropdownMenuItem(value: '3°', child: Text('3° - Tercer Aviso')),
                              DropdownMenuItem(value: 'SR RAUL', child: Text('SR RAUL')),
                            ],
                            onChanged: (v) => setState(() => _avisoEstado = v!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _vendedor,
                            dropdownColor: const Color(0xFF0B1528),
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              labelText: 'Vendedor Responsable',
                              filled: true,
                              fillColor: const Color(0xFF0B1528),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'SR RAUL', child: Text('SR RAUL')),
                              DropdownMenuItem(value: 'Yair Hernández', child: Text('Yair Hernández')),
                              DropdownMenuItem(value: 'Agente Externo', child: Text('Agente Externo')),
                            ],
                            onChanged: (v) => setState(() => _vendedor = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _campo('Titular / Contratante', _titularCtrl),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _campo('RFC (12=Moral, 13=Física)', _rfcCtrl)),
                        const SizedBox(width: 10),
                        Expanded(child: _campo('Número de Póliza', _polizaCtrl)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _campo('Aseguradora', _aseguradoraCtrl)),
                        const SizedBox(width: 10),
                        Expanded(child: _campo('Ramo / Rubro', _ramoCtrl)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _campo('Placas', _placasCtrl)),
                        const SizedBox(width: 10),
                        Expanded(child: _campo('Número de Serie', _serieCtrl)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _campo('Bien Asegurado / Vehículo', _bienCtrl),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _campo('Inicio Vigencia (AAAA-MM-DD)', _inicioCtrl)),
                        const SizedBox(width: 10),
                        Expanded(child: _campo('Fin Vigencia (AAAA-MM-DD)', _finCtrl)),
                        const SizedBox(width: 10),
                        Expanded(child: _campo('Prima Neta (MXN)', _primaCtrl)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF08101E),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.withOpacity(0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Validación Humana Obligatoria',
                              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
                          CheckboxListTile(
                            dense: true,
                            title: const Text('Póliza, Aseguradora y RFC confirmados.', style: TextStyle(color: Colors.white, fontSize: 12)),
                            value: _chkPoliza,
                            activeColor: Colors.green,
                            onChanged: (v) => setState(() => _chkPoliza = v!),
                          ),
                          CheckboxListTile(
                            dense: true,
                            title: const Text('Vigencias cotejadas con documento oficial.', style: TextStyle(color: Colors.white, fontSize: 12)),
                            value: _chkVigencias,
                            activeColor: Colors.green,
                            onChanged: (v) => setState(() => _chkVigencias = v!),
                          ),
                          CheckboxListTile(
                            dense: true,
                            title: const Text('Prima Neta e importes validados.', style: TextStyle(color: Colors.white, fontSize: 12)),
                            value: _chkImporte,
                            activeColor: Colors.green,
                            onChanged: (v) => setState(() => _chkImporte = v!),
                          ),
                          if (_ramoCtrl.text.toLowerCase().contains('auto'))
                            CheckboxListTile(
                              dense: true,
                              title: const Text('Placas y Serie de auto cotejadas.', style: TextStyle(color: Colors.white, fontSize: 12)),
                              value: _chkAuto,
                              activeColor: Colors.green,
                              onChanged: (v) => setState(() => _chkAuto = v!),
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.white60))),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: puedeGuardar ? Colors.green : Colors.grey.shade700),
                  icon: const Icon(Icons.check_circle, color: Colors.white, size: 16),
                  label: const Text('Guardar y Trasladar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: puedeGuardar ? _guardar : null,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _campo(String lbl, TextEditingController c) {
    return TextField(
      controller: c,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: lbl,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF0B1528),
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
