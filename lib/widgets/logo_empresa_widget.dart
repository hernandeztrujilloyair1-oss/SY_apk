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
        final config = EmpresaConfigService();

        // 1. Prioridad: Si el cliente cargó su logo personalizado
        if (config.logoBase64 != null && config.logoBase64!.isNotEmpty) {
          try {
            return ClipRRect(
              borderRadius: BorderRadius.circular(size * 0.2),
              child: Image.memory(
                base64Decode(config.logoBase64!),
                width: size,
                height: size,
                fit: BoxFit.contain,
              ),
            );
          } catch (_) {
            // Si el Base64 viniera corrupto, pasa al logo por defecto
          }
        }

        // 2. Si no hay logo del cliente, se muestra TU LOGOTIPO corporativo
        // Puedes colocar tu archivo en 'assets/images/logo_enfoque.png' o usar tu enlace web
        return ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.2),
          child: Image.asset(
            'assets/images/logo.png', // Tu logo local en el proyecto
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              // Si no encuentra el asset local, lo toma de tu URL directa
              return Image.network(
                config.logoDefaultUrl,
                width: size,
                height: size,
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, stack) {
                  // Fallback: Insignia corporativa con tus iniciales
                  return Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: config.colorAcento,
                      borderRadius: BorderRadius.circular(size * 0.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'ES', // Enfoque Seguro
                      style: TextStyle(
                        color: config.colorNavbar,
                        fontWeight: FontWeight.w900,
                        fontSize: size * 0.45,
                        letterSpacing: 0.5,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}