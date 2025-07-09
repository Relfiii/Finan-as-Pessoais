class Gasto {
  String id;
  String categoriaId;
  String descricao;
  double valor;
  DateTime data;

  Gasto({
    required this.id,
    required this.categoriaId,
    required this.descricao,
    required this.valor,
    required this.data,
  });

  // Método para criar um objeto Gasto a partir de um Map
  factory Gasto.fromMap(Map<String, dynamic> map) {
    return Gasto(
      id: map['id'] as String,
      categoriaId: map['categoria_id'] as String,
      descricao: map['descricao'] ?? '',
      valor: (map['valor'] as num).toDouble(),
      data: DateTime.parse(map['data']),
    );
  }
}