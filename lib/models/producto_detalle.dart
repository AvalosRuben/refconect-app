class GrupoEquivalencia {
  const GrupoEquivalencia({required this.id, required this.descripcion, required this.existenciaTotal});

  factory GrupoEquivalencia.fromJson(Map<String, dynamic> json) => GrupoEquivalencia(
        id: json['id'] as int,
        descripcion: json['descripcion'] as String,
        existenciaTotal: json['existencia_total'] as int,
      );

  final int id;
  final String descripcion;
  final int existenciaTotal;
}

class Equivalente {
  const Equivalente({
    required this.id,
    required this.numeroParte,
    required this.marca,
    required this.descripcion,
    required this.existencia,
    required this.ubicacion,
  });

  factory Equivalente.fromJson(Map<String, dynamic> json) => Equivalente(
        id: json['id'] as int,
        numeroParte: json['numero_parte'] as String,
        marca: json['marca'] as String,
        descripcion: json['descripcion'] as String,
        existencia: json['existencia'] as int,
        ubicacion: json['ubicacion'] as String?,
      );

  final int id;
  final String numeroParte;
  final String marca;
  final String descripcion;
  final int existencia;
  final String? ubicacion;
}

class ProductoDetalle {
  const ProductoDetalle({
    required this.id,
    required this.numeroParte,
    required this.marca,
    required this.categoria,
    required this.descripcion,
    required this.existencia,
    required this.ubicacion,
    required this.grupo,
    required this.equivalentes,
  });

  factory ProductoDetalle.fromJson(Map<String, dynamic> json) => ProductoDetalle(
        id: json['id'] as int,
        numeroParte: json['numero_parte'] as String,
        marca: json['marca'] as String,
        categoria: json['categoria'] as String,
        descripcion: json['descripcion'] as String,
        existencia: json['existencia'] as int,
        ubicacion: json['ubicacion'] as String?,
        grupo: json['grupo'] == null ? null : GrupoEquivalencia.fromJson(json['grupo'] as Map<String, dynamic>),
        // La API ya los entrega por existencia descendente.
        equivalentes: (json['equivalentes'] as List)
            .map((e) => Equivalente.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final int id;
  final String numeroParte;
  final String marca;
  final String categoria;
  final String descripcion;
  final int existencia;
  final String? ubicacion;
  final GrupoEquivalencia? grupo;
  final List<Equivalente> equivalentes;
}
