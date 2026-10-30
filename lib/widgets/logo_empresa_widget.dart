import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/empresa_config_service.dart';

class LogoEmpresaWidget extends StatelessWidget {
  final double size;
  final bool circular;

  const LogoEmpresaWidget({
    super.key,
    this.size = 38,
    this.circular = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: EmpresaConfigService(),
      builder: (context, _) {
        final config = EmpresaConfigService();

        if (config.logoBase64 != null && config.logoBase64!.isNotEmpty) {
          try {
            final imageBytes = base64Decode(config.logoBase64!);
            return ClipRRect(
              borderRadius: BorderRadius.circular(circular ? size / 2 : 8),
              child: Image.memory(
                imageBytes,
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
            );
          } catch (_) {}
        }

        final partes = config.nombreDespacho.trim().split(' ');
        String iniciales = 'DS';
        if (partes.isNotEmpty && partes[0].isNotEmpty) {
          iniciales = partes[0][0];
          if (partes.length > 1 && partes[1].isNotEmpty) {
            iniciales += partes[1][0];
          }
        }

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: circular ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: circular ? null : BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
            gradient: const RadialGradient(
              colors: [Color(0xFF0284C7), Color(0xFF0F172A)],
            ),
          ),
          child: Center(
            child: Text(
              iniciales.toUpperCase(),
              style: TextStyle(
                color: Colors.cyanAccent,
                fontWeight: FontWeight.bold,
                fontSize: size * 0.40,
                letterSpacing: 1.1,
              ),
            ),
          ),
        );
      },
    );
  }
}