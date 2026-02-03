class Gasto {
  final String id;
  final double monto;
  final DateTime fecha;
  final String nota;
  final String categoriaId;

  Gasto({
    required this.id,
    required this.monto,
    required this.fecha,
    required this.nota,
    required this.categoriaId,
  });
}
