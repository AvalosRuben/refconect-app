class ProductoResumen {
  const ProductoResumen({
    required this.id,
    required this.numeroParte,
    required this.marca,
    required this.categoria,
    required this.descripcion,
    required this.existencia,
    required this.ubicacion,
    required this.tieneEquivalentes,
  });

  factory ProductoResumen.fromJson(Map<String, dynamic> json) => ProductoResumen(
        id: json['id'] as int,
        numeroParte: json['numero_parte'] as String,
        marca: json['marca'] as String,
        categoria: json['categoria'] as String,
        descripcion: json['descripcion'] as String,
        existencia: json['existencia'] as int,
        ubicacion: json['ubicacion'] as String?,
        tieneEquivalentes: json['tiene_equivalentes'] as bool,
      );

  final int id;
  final String numeroParte;
  final String marca;
  final String categoria;
  final String descripcion;
  final int existencia;
  final String? ubicacion;
  final bool tieneEquivalentes;
}
