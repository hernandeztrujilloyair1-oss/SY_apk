import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/empresa_config_service.dart';

class LogoEmpresaWidget extends StatelessWidget {
  final double size;

  const LogoEmpresaWidget({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final conf = EmpresaConfigService();
    final logoBase64 = conf.logoBase64;

    // 1. Si el usuario subió un logo personalizado en la app, lo mostramos
    if (logoBase64 != null && logoBase64.isNotEmpty) {
      try {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            base64Decode(logoBase64),
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        );
      } catch (_) {}
    }

    // 2. Si no, mostramos tu logo oficial predeterminado de assets
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        'assets/images/logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (ctx, err, stack) {
          // Si por alguna razón la imagen aún no está colocada, muestra ícono temporal
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD4AF37)),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Color(0xFFD4AF37),
              size: 20,
            ),
          );
        },
      ),
    );
  }
}