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
      // Só marca como carregando se não estiver já carregando
      if (!_isLoading) {
        _setLoading(true);
      }
      
      try {
        final supabase = Supabase.instance.client;
        final user = supabase.auth.currentUser;
        
        if (user == null) {
          print('⚠️ Usuário não logado, não carregando categorias');
          _setLoading(false);
          return;
        }
        
        final userId = user.id;
        print('📁 Carregando categorias para usuário: $userId');
        
        final response = await supabase
            .from('categorias')
            .select()
            .eq('user_id', userId)
            .timeout(Duration(seconds: 10)); // Timeout de 10 segundos
            
        _categories = (response as List)
            .map((data) => Category(
                  id: data['id'],
                  name: data['nome'],
                  description: data['descricao'] ?? '', 
                  color: const Color(0xFFB983FF), 
                  icon: Icons.category, 
                  createdAt: DateTime.now(), 
                  updatedAt: DateTime.now(), 
                ))
            .toList();
        print('✅ ${_categories.length} categorias carregadas');
        _setLoading(false);
      } catch (e) {
        print('❌ Erro ao carregar categorias: $e');
        _setError('Erro ao carregar categorias: $e');
        _setLoading(false);
        // Não bloqueia o app, apenas define lista vazia
        _categories = [];
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

    /// Atualiza o nome de uma categoria
    Future<void> updateCategoryName(String id, String novoNome) async {
      final supabase = Supabase.instance.client;
      await supabase.from('categorias').update({'nome': novoNome}).eq('id', id);

      final idx = _categories.indexWhere((c) => c.id == id);
      if (idx != -1) {
        _categories[idx] = _categories[idx].copyWith(name: novoNome);
        notifyListeners();
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
