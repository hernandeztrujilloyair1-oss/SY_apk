import 'package:flutter/material.dart';
import '../models/aseguradora_model.dart';
import '../services/cotizador_autos_service.dart';

class CotizadorAutosVista extends StatefulWidget {
  const CotizadorAutosVista({super.key});

  @override
  State<CotizadorAutosVista> createState() => _CotizadorAutosVistaState();
}

class _CotizadorAutosVistaState extends State<CotizadorAutosVista> {
  final _primaCtrl = TextEditingController(text: '7500');
  final _derechoCtrl = TextEditingController(text: '650');
  AseguradoraInfo _aseguradora = CatalogoAseguradoras.autos.first;
  CotizacionAutoResultado? _resultado;

  @override
  void initState() {
    super.initState();
    _calcular();
  }

  void _calcular() {
    final neta = double.tryParse(_primaCtrl.text) ?? 0.0;
    final derecho = double.tryParse(_derechoCtrl.text) ?? 0.0;
    setState(() {
      _resultado = CotizadorAutosService.cotizar(primaNeta: neta, derechoPoliza: derecho);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cotizador de Autos - Cobertura Amplia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<AseguradoraInfo>(
                    initialValue: _aseguradora,
                    decoration: const InputDecoration(labelText: 'Aseguradora', border: OutlineInputBorder()),
                    items: CatalogoAseguradoras.autos.map((a) {
                      return DropdownMenuItem(
                        value: a,
                        child: Row(
                          children: [
                            Image.network(
                              a.logoUrl,
                              width: 24,
                              height: 24,
                              errorBuilder: (_, __, ___) => const Icon(Icons.business, size: 20, color: Colors.grey),
                            ),
                            const SizedBox(width: 10),
                            Text(a.nombre, style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _aseguradora = v!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _primaCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Prima Neta (\$ MXN)', border: OutlineInputBorder()),
                    onChanged: (_) => _calcular(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _derechoCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Derecho de Póliza (\$ MXN)', border: OutlineInputBorder()),
                    onChanged: (_) => _calcular(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_resultado != null) ...[
            _tarjetaResumen('Prima Total Anual', '\$ ${_resultado!.primaTotalAnual.toStringAsFixed(2)} MXN', const Color(0xFF047857), true),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _tarjetaResumen('Semestral (x2)', '\$ ${_resultado!.pagoSemestral.toStringAsFixed(2)}', const Color(0xFF0284C7), false)),
                const SizedBox(width: 8),
                Expanded(child: _tarjetaResumen('Trimestral (x4)', '\$ ${_resultado!.pagoTrimestral.toStringAsFixed(2)}', const Color(0xFFD97706), false)),
                const SizedBox(width: 8),
                Expanded(child: _tarjetaResumen('Mensual (x12)', '\$ ${_resultado!.pagoMensual.toStringAsFixed(2)}', const Color(0xFF7C3AED), false)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _tarjetaResumen(String titulo, String monto, Color color, bool grande) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: grande ? 18 : 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: TextStyle(color: Colors.black54, fontSize: grande ? 13 : 11)),
          const SizedBox(height: 4),
          Text(monto, style: TextStyle(color: color, fontSize: grande ? 20 : 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}