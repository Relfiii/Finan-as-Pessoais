import 'package:flutter/foundation.dart' hide Category;
import '../models/category.dart';
import '../services/category_service.dart';

/// Provider para gerenciar o estado das categorias
class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  /// Lista de categorias
  List<Category> get categories => _categories;

  /// Estado de carregamento
  bool get isLoading => _isLoading;

  /// Mensagem de erro
  String? get error => _error;

  /// Carrega todas as categorias
  Future<void> loadCategories() async {
    _setLoading(true);
    _setError(null);

    try {
      _categories = await CategoryService.getAll();
      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar categorias: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Adiciona uma nova categoria
  Future<void> addCategory(Category category) async {
    try {
      await CategoryService.insert(category);
      _categories.add(category);
      notifyListeners();
    } catch (e) {
      _setError('Erro ao adicionar categoria: $e');
    }
  }

  /// Atualiza uma categoria
  Future<void> updateCategory(Category category) async {
    try {
      await CategoryService.update(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
    } catch (e) {
      _setError('Erro ao atualizar categoria: $e');
    }
  }

  /// Remove uma categoria
  Future<void> deleteCategory(String id) async {
    try {
      // Verifica se a categoria tem transações associadas
      final hasTransactions = await CategoryService.hasTransactions(id);
      if (hasTransactions) {
        _setError('Não é possível remover uma categoria que possui transações.');
        return;
      }

      await CategoryService.delete(id);
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      _setError('Erro ao remover categoria: $e');
    }
  }

  /// Busca uma categoria por ID
  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
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
