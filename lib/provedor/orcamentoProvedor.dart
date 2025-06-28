import 'package:flutter/foundation.dart';
import '../modelos/orcamento.dart';
import '../services/orcamento.dart';

/// Provider para gerenciar o estado dos orçamentos
class BudgetProvider with ChangeNotifier {
  List<Budget> _budgets = [];
  bool _isLoading = false;
  String? _error;

  /// Lista de orçamentos
  List<Budget> get budgets => _budgets;

  /// Estado de carregamento
  bool get isLoading => _isLoading;

  /// Mensagem de erro
  String? get error => _error;

  /// Carrega todos os orçamentos
  Future<void> loadBudgets() async {
    _setLoading(true);
    _setError(null);

    try {
      _budgets = await BudgetService.getAll();
      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar orçamentos: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega orçamentos ativos
  Future<void> loadActiveBudgets() async {
    _setLoading(true);
    _setError(null);

    try {
      _budgets = await BudgetService.getActive();
      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar orçamentos ativos: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Adiciona um novo orçamento
  Future<void> addBudget(Budget budget) async {
    try {
      await BudgetService.insert(budget);
      _budgets.add(budget);
      notifyListeners();
    } catch (e) {
      _setError('Erro ao adicionar orçamento: $e');
    }
  }

  /// Atualiza um orçamento
  Future<void> updateBudget(Budget budget) async {
    try {
      await BudgetService.update(budget);
      final index = _budgets.indexWhere((b) => b.id == budget.id);
      if (index != -1) {
        _budgets[index] = budget;
        notifyListeners();
      }
    } catch (e) {
      _setError('Erro ao atualizar orçamento: $e');
    }
  }

  /// Remove um orçamento
  Future<void> deleteBudget(String id) async {
    try {
      await BudgetService.delete(id);
      _budgets.removeWhere((b) => b.id == id);
      notifyListeners();
    } catch (e) {
      _setError('Erro ao remover orçamento: $e');
    }
  }

  /// Busca orçamentos por categoria
  List<Budget> getBudgetsByCategory(String categoryId) {
    return _budgets.where((b) => b.categoryId == categoryId).toList();
  }

  /// Busca um orçamento por ID
  Budget? getBudgetById(String id) {
    try {
      return _budgets.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
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
