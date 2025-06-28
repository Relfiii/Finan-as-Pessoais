import 'package:decimal/decimal.dart';

/// Enum para tipos de transação
enum TransactionType {
  expense,
  income,
}

/// Modelo para transações financeiras
class Transaction {
  final String id;
  final String description;
  final Decimal amount;
  final TransactionType type;
  final String categoryId;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Converte o objeto para Map para armazenamento no banco
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount.toString(),
      'type': type.name,
      'categoryId': categoryId,
      'date': date.millisecondsSinceEpoch,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Cria um objeto Transaction a partir de um Map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      description: map['description'],
      amount: Decimal.parse(map['amount']),
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
      categoryId: map['categoryId'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      notes: map['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  /// Cria uma cópia do objeto com novos valores
  Transaction copyWith({
    String? id,
    String? description,
    Decimal? amount,
    TransactionType? type,
    String? categoryId,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Transaction{id: $id, description: $description, amount: $amount, type: $type, categoryId: $categoryId, date: $date}';
  }
}
