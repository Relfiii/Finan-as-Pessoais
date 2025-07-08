class Gasto {
  String id;
  String descricao; // Removido o modificador final
  double valor; // Removido o modificador final
  DateTime data;
  String categoriaId;

  Gasto({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.data,
    required this.categoriaId,
  });
}