import 'package:flutter/foundation.dart' hide Category;
import '../modelos/categoria.dart';
import '../services/categoria.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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
  Future<void> deleteCategory(String id) async {
    final supabase = Supabase.instance.client;
    await supabase.from('categorias').delete().eq('id', id);
    // Remova da lista local
    categories.removeWhere((cat) => cat.id == id);
    notifyListeners();
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
  Future<void> loadCategories() async {
      _setLoading(true);
      try {
        final supabase = Supabase.instance.client;
        final response = await supabase.from('categorias').select();
        _categories = (response as List)
            .map((data) => Category(
                  id: data['id'],
                  name: data['nome'],
                  description: '', // ajuste se tiver descrição
                  color: const Color(0xFFB983FF), // ajuste se tiver cor salva
                  icon: Icons.category, // ajuste se tiver ícone salvo
                  createdAt: DateTime.now(), // ajuste se tiver data salva
                  updatedAt: DateTime.now(), // ajuste se tiver data salva
                ))
            .toList();
        _setLoading(false);
      } catch (e) {
        _setError('Erro ao carregar categorias: $e');
        _setLoading(false);
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

/// Exemplo de uso ao criar uma nova categoria:
final novaCategoria = Category(
  id: const Uuid().v4(), // Gera um UUID válido
  name: 'Saúde',
  description: '', // ajuste se tiver descrição
  color: const Color(0xFFB983FF), // ajuste se tiver cor salva
  icon: Icons.category, // ajuste se tiver ícone salvo
  createdAt: DateTime.now(), // ajuste se tiver data salva
  updatedAt: DateTime.now(), // ajuste se tiver data salva
);
