import 'package:decimal/decimal.dart';

/// Modelo para orçamentos
class Budget {
  final String id;
  final String categoryId;
  final Decimal amount;
  final DateTime startDate;
  final DateTime endDate;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Budget({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.startDate,
    required this.endDate,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Converte o objeto para Map para armazenamento no banco
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount.toString(),
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Cria um objeto Budget a partir de um Map
  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      categoryId: map['categoryId'],
      amount: Decimal.parse(map['amount']),
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate']),
      description: map['description'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  /// Cria uma cópia do objeto com novos valores
  Budget copyWith({
    String? id,
    String? categoryId,
    Decimal? amount,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Budget && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Budget{id: $id, categoryId: $categoryId, amount: $amount, startDate: $startDate, endDate: $endDate}';
  }
}
