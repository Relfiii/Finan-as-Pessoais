import 'package:flutter/foundation.dart';
import '../modelos/transicao.dart';
import '../services/transicao.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<double> getSaldoAtual() async {
    final userId = Supabase.instance.client.auth.currentUser!.id; // Obtém o ID do usuário logado
    final data = await Supabase.instance.client
        .from('transacoes')
        .select('valor')
        .eq('user_id', userId); // Filtra as transações pelo ID do usuário
    final list = data as List<dynamic>;
    return list.fold<double>(
      0.0,
      (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
    );
  }
  
  Future<double> getGastoMesAtual() async {
    final userId = Supabase.instance.client.auth.currentUser!.id; // Obtém o ID do usuário logado
    final now = DateTime.now();
    final inicio = DateTime(now.year, now.month, 1);
    final fim = DateTime(now.year, now.month + 1, 0);
    final data = await Supabase.instance.client
        .from('transacoes')
        .select('valor')
        .gte('data', inicio.toIso8601String())
        .lte('data', fim.toIso8601String())
        .eq('tipo', 'gasto')
        .eq('user_id', userId); // Filtra as transações pelo ID do usuário
    final list = data as List<dynamic>;
    return list.fold<double>(
      0.0,
      (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
    );
  }
  
  Future<double> getReceitaPorMes(DateTime referencia) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final inicio = DateTime(referencia.year, referencia.month, 1);
    final fim = DateTime(referencia.year, referencia.month + 1, 0);
    final data = await Supabase.instance.client
        .from('transacoes')
        .select('valor')
        .gte('data', inicio.toIso8601String())
        .lte('data', fim.toIso8601String())
        .eq('tipo', 'receita')
        .eq('user_id', userId);
    final list = data as List<dynamic>;
    return list.fold<double>(
      0.0,
      (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
    );
  }

  Future<double> getInvestimentoPorMes(DateTime referencia) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final inicio = DateTime(referencia.year, referencia.month, 1);
    final fim = DateTime(referencia.year, referencia.month + 1, 0);
    final data = await Supabase.instance.client
        .from('transacoes')
        .select('valor')
        .gte('data', inicio.toIso8601String())
        .lte('data', fim.toIso8601String())
        .eq('tipo', 'investimento')
        .eq('user_id', userId);
    final list = data as List<dynamic>;
    return list.fold<double>(
      0.0,
      (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
    );
  }
}
