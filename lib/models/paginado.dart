class Paginado<T> {
  const Paginado({required this.datos, required this.pagina, required this.limite, required this.total});

  factory Paginado.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) item) => Paginado(
        datos: (json['datos'] as List).map((e) => item(e as Map<String, dynamic>)).toList(),
        pagina: json['pagina'] as int,
        limite: json['limite'] as int,
        total: json['total'] as int,
      );

  final List<T> datos;
  final int pagina;
  final int limite;
  final int total;

  bool get hayMas => pagina * limite < total;
}
