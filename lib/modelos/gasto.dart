class Gasto {
  String id;
  String categoriaId;
  String descricao;
  double valor;
  DateTime data;
  DateTime? dataCompra; // Data original da compra (para parcelamentos)
  int parcelaAtual;
  int totalParcelas;
  bool recorrente;
  int? intervalo_meses;

  Gasto({
    required this.id,
    required this.categoriaId,
    required this.descricao,
    required this.valor,
    required this.data,
    this.dataCompra,
    this.parcelaAtual = 1,
    this.totalParcelas = 1,
    this.recorrente = false,
    this.intervalo_meses,
  });

  // Método para criar um objeto Gasto a partir de um Map
  factory Gasto.fromMap(Map<String, dynamic> map) {
    return Gasto(
      id: map['id'] as String,
      categoriaId: map['categoria_id'] as String,
      descricao: map['descricao'] ?? '',
      valor: (map['valor'] as num).toDouble(),
      data: DateTime.parse(map['data']),
      dataCompra: map['data_compra'] != null ? DateTime.parse(map['data_compra']) : null,
      parcelaAtual: map['parcela_atual'] ?? 1,
      totalParcelas: map['total_parcelas'] ?? 1,
      recorrente: map['recorrente'] ?? false,
      intervalo_meses: map['intervalo_meses'],
    );
  }
}