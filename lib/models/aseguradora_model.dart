class AseguradoraInfo {
  final String nombre;
  final String dominio;
  final String logoUrl;

  const AseguradoraInfo({
    required this.nombre,
    required this.dominio,
  }) : logoUrl = 'https://logo.clearbit.com/$dominio';
}

class CatalogoAseguradoras {
  static const List<AseguradoraInfo> autos = [
    AseguradoraInfo(nombre: 'Quálitas Compañía de Seguros', dominio: 'qualitas.com.mx'),
    AseguradoraInfo(nombre: 'GNP Seguros', dominio: 'gnp.com.mx'),
    AseguradoraInfo(nombre: 'AXA Seguros', dominio: 'axa.mx'),
    AseguradoraInfo(nombre: 'Mapfre México', dominio: 'mapfre.com.mx'),
    AseguradoraInfo(nombre: 'Seguros Banorte', dominio: 'segurosbanorte.com.mx'),
    AseguradoraInfo(nombre: 'HDI Seguros', dominio: 'hdi.com.mx'),
    AseguradoraInfo(nombre: 'Chubb Seguros México', dominio: 'chubb.com'),
    AseguradoraInfo(nombre: 'General de Seguros', dominio: 'generaldeseguros.mx'),
    AseguradoraInfo(nombre: 'Seguros Afirme', dominio: 'afirme.com'),
    AseguradoraInfo(nombre: 'El Águila Compañía de Seguros', dominio: 'elaguila.com.mx'),
    AseguradoraInfo(nombre: 'Zurich Santander Seguros', dominio: 'zurichsantander.com.mx'),
    AseguradoraInfo(nombre: 'Primero Seguros', dominio: 'primeroseguros.com'),
    AseguradoraInfo(nombre: 'ANA Seguros', dominio: 'anaseguros.com.mx'),
    AseguradoraInfo(nombre: 'Seguros Atlas', dominio: 'segurosatlas.com.mx'),
    AseguradoraInfo(nombre: 'Seguros Inbursa', dominio: 'inbursa.com'),
  ];

  static const List<AseguradoraInfo> gmm = [
    AseguradoraInfo(nombre: 'MetLife México', dominio: 'metlife.com.mx'),
    AseguradoraInfo(nombre: 'GNP Seguros', dominio: 'gnp.com.mx'),
    AseguradoraInfo(nombre: 'AXA Seguros', dominio: 'axa.mx'),
    AseguradoraInfo(nombre: 'Seguros Monterrey New York Life', dominio: 'mnyl.com.mx'),
    AseguradoraInfo(nombre: 'Mapfre México', dominio: 'mapfre.com.mx'),
    AseguradoraInfo(nombre: 'Seguros Banorte', dominio: 'segurosbanorte.com.mx'),
    AseguradoraInfo(nombre: 'Seguros Atlas', dominio: 'segurosatlas.com.mx'),
    AseguradoraInfo(nombre: 'Bupa México', dominio: 'bupa.com.mx'),
    AseguradoraInfo(nombre: 'Pan-American México', dominio: 'palig.com'),
    AseguradoraInfo(nombre: 'Allianz México', dominio: 'allianz.com.mx'),
    AseguradoraInfo(nombre: 'Seguros Inbursa', dominio: 'inbursa.com'),
  ];
}