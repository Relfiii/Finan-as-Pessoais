class Gasto {
  final String id;
  final String descricao;
  final double valor;
  final DateTime data;
  final String categoriaId;

  Gasto({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.data,
    required this.categoriaId,
  });
}