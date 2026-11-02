import 'package:flutter/material.dart';
import '../models/aseguradora_model.dart';

class CotizadorGmmVista extends StatefulWidget {
  const CotizadorGmmVista({super.key});

  @override
  State<CotizadorGmmVista> createState() => _CotizadorGmmVistaState();
}

class _CotizadorGmmVistaState extends State<CotizadorGmmVista> {
  final _primaCtrl = TextEditingController(text: '28000');
  AseguradoraInfo _aseguradora = CatalogoAseguradoras.gmm.first;
  String _deducible = '\$ 25,000';
  String _coaseguro = '10%';

  @override
  Widget build(BuildContext context) {
    final primaNeta = double.tryParse(_primaCtrl.text) ?? 0.0;
    final derecho = 750.0;
    final subtotal = primaNeta + derecho;
    final totalAnual = subtotal * 1.16;
    final semestral = (primaNeta * 1.05 + derecho) * 1.16 / 2;
    final trimestral = (primaNeta * 1.07 + derecho) * 1.16 / 4;
    final mensual = (primaNeta * 1.09 + derecho) * 1.16 / 12;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cotizador de Gastos Médicos Mayores (GMM)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF091428))),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<AseguradoraInfo>(
                    value: _aseguradora,
                    decoration: const InputDecoration(labelText: 'Aseguradora de GMM', border: OutlineInputBorder()),
                    items: CatalogoAseguradoras.gmm.map((a) {
                      return DropdownMenuItem(
                        value: a,
                        child: Row(
                          children: [
                            Image.network(
                              a.logoUrl,
                              width: 24,
                              height: 24,
                              errorBuilder: (_, __, ___) => const Icon(Icons.local_hospital, size: 20, color: Colors.grey),
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
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _deducible,
                          decoration: const InputDecoration(labelText: 'Deducible', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: '\$ 15,000', child: Text('\$ 15,000')),
                            DropdownMenuItem(value: '\$ 25,000', child: Text('\$ 25,000')),
                            DropdownMenuItem(value: '\$ 35,000', child: Text('\$ 35,000')),
                            DropdownMenuItem(value: '\$ 50,000', child: Text('\$ 50,000')),
                          ],
                          onChanged: (v) => setState(() => _deducible = v!),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _coaseguro,
                          decoration: const InputDecoration(labelText: 'Coaseguro', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: '10%', child: Text('10% (Tope \$50k)')),
                            DropdownMenuItem(value: '15%', child: Text('15% (Tope \$60k)')),
                          ],
                          onChanged: (v) => setState(() => _coaseguro = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _primaCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Prima Neta Anual (\$ MXN)', border: OutlineInputBorder()),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: const Color(0xFF091428), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Prima Total Anual (con IVA)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text('\$ ${totalAnual.toStringAsFixed(2)} MXN', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 24, fontWeight: FontWeight.bold)),
                const Divider(color: Colors.white24, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Semestral: \$ ${semestral.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    Text('Trimestral: \$ ${trimestral.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    Text('Mensual: \$ ${mensual.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}