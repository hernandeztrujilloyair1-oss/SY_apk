import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/empresa_config_service.dart';

class LogoEmpresaWidget extends StatelessWidget {
  final double size;

  const LogoEmpresaWidget({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: EmpresaConfigService(),
      builder: (context, _) {
        final conf = EmpresaConfigService();

        if (conf.logoBase64 != null && conf.logoBase64!.isNotEmpty) {
          try {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFD4AF37).withValues(alpha: 0.2), blurRadius: 8),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.memory(
                  base64Decode(conf.logoBase64!),
                  fit: BoxFit.cover,
                ),
              ),
            );
          } catch (_) {}
        }

        final partes = conf.nombreDespacho.trim().split(' ');
        String iniciales = 'SC';
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
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              iniciales.toUpperCase(),
              style: TextStyle(
                color: const Color(0xFFF5E6BE),
                fontWeight: FontWeight.w700,
                fontSize: size * 0.40,
                letterSpacing: 1.2,
              ),
            ),
          ),
        );
      },
    );
  }
}