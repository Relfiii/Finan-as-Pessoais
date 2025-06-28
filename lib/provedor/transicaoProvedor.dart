import 'package:flutter/foundation.dart';
import '../modelos/transicao.dart';
import '../services/transicao.dart';

/// Provider para gerenciar o estado das transações
class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  /// Lista de transações
  List<Transaction> get transactions => _transactions;

  /// Estado de carregamento
  bool get isLoading => _isLoading;

  /// Mensagem de erro
  String? get error => _error;

  /// Carrega todas as transações
  Future<void> loadTransactions() async {
    _setLoading(true);
    _setError(null);

    try {
      _transactions = await TransactionService.getAll();
      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar transações: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega transações por período
  Future<void> loadTransactionsByDateRange(DateTime start, DateTime end) async {
    _setLoading(true);
    _setError(null);

    try {
      _transactions = await TransactionService.getByDateRange(start, end);
      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar transações: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Adiciona uma nova transação
  Future<void> addTransaction(Transaction transaction) async {
    try {
      await TransactionService.insert(transaction);
      _transactions.insert(0, transaction);
      notifyListeners();
    } catch (e) {
      _setError('Erro ao adicionar transação: $e');
    }
  }

  /// Atualiza uma transação
  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await TransactionService.update(transaction);
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        notifyListeners();
      }
    } catch (e) {
      _setError('Erro ao atualizar transação: $e');
    }
  }

  /// Remove uma transação
  Future<void> deleteTransaction(String id) async {
    try {
      await TransactionService.delete(id);
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      _setError('Erro ao remover transação: $e');
    }
  }

  /// Filtra transações por tipo
  List<Transaction> getTransactionsByType(TransactionType type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  /// Filtra transações por categoria
  List<Transaction> getTransactionsByCategory(String categoryId) {
    return _transactions.where((t) => t.categoryId == categoryId).toList();
  }

  /// Define o estado de carregamento
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Define uma mensagem de erro
  void _setError(String? error) {
    _error = error;
    if (error != null) {
      notifyListeners();
    }
  }

  /// Limpa os erros
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
