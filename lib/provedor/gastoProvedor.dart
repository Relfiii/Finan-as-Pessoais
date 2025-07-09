import 'package:flutter/material.dart';
import '../modelos/gasto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GastoProvider with ChangeNotifier {
  final List<Gasto> _gastos = [];
  bool _isLoading = false;
  String? _error;

  /// Estado de carregamento
  bool get isLoading => _isLoading;

  /// Mensagem de erro
  String? get error => _error;

  /// Carrega todos os gastos da base de dados
  Future<void> loadGastos() async {
    _setLoading(true);
    _setError(null);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final data = await Supabase.instance.client
          .from('gastos')
          .select('*')
          .eq('user_id', userId);
      
      _gastos.clear();
      for (final item in data) {
        _gastos.add(Gasto(
          id: item['id'],
          descricao: item['descricao'],
          valor: (item['valor'] as num).toDouble(),
          data: DateTime.parse(item['data']),
          categoriaId: item['categoria_id'],
        ));
      }
      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar gastos: $e');
    } finally {
      _setLoading(false);
    }
  }

  List<Gasto> gastosPorCategoria(String categoryId) {
    return _gastos.where((gasto) => gasto.categoriaId == categoryId).toList();
  }

  void addGasto(Gasto gasto) {
    _gastos.add(gasto);
    notifyListeners();
  }

  // Método para deletar gasto
  Future<void> deleteGasto(String gastoId) async {
    try {
      // Remove do Supabase
      await Supabase.instance.client
          .from('gastos')
          .delete()
          .eq('id', gastoId);

      // Remove da lista local
      _gastos.removeWhere((gasto) => gasto.id == gastoId);
      notifyListeners();
    } catch (e) {
      throw Exception('Erro ao deletar gasto: $e');
    }
  }

  Future<void> updateGasto(String id, String novaDescricao, double novoValor) async {
    try {
      // Atualiza o gasto na base de dados
      final response = await Supabase.instance.client
          .from('gastos')
          .update({'descricao': novaDescricao, 'valor': novoValor})
          .eq('id', id);

      if (response.error != null) {
        throw Exception('Erro ao atualizar gasto: ${response.error!.message}');
      }

      // Atualiza o gasto na lista local
      final index = _gastos.indexWhere((gasto) => gasto.id == id);
      if (index != -1) {
        _gastos[index].descricao = novaDescricao;
        _gastos[index].valor = novoValor;
        notifyListeners(); // Notifica os consumidores sobre a mudança
      }
    } catch (e) {
      throw Exception('Erro ao atualizar gasto: $e');
    }
  }

  double totalPorCategoria(String categoriaId) {
    return _gastos
        .where((g) => g.categoriaId == categoriaId)
        .fold(0.0, (soma, g) => soma + g.valor);
  }

  double totalGastoMes({DateTime? referencia}) {
    final now = referencia ?? DateTime.now();
    return _gastos
        .where((g) => g.data.month == now.month && g.data.year == now.year)
        .fold(0.0, (soma, g) => soma + g.valor);
  }

  // Adiciona o getter totalGastos
  double get totalGastos {
    return _gastos.fold(0.0, (sum, gasto) => sum + gasto.valor);
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

  Future<List<Gasto>> getGastosPorMes(String categoryId, DateTime date) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
  
      // Consulta os gastos na base de dados para o mês/ano e categoria especificados
      final response = await Supabase.instance.client
          .from('gastos')
          .select('*')
          .eq('user_id', userId)
          .eq('categoria_id', categoryId)
          .gte('data', DateTime(date.year, date.month, 1).toIso8601String())
          .lt('data', DateTime(date.year, date.month + 1, 1).toIso8601String());
  
      // Verifica se há dados na resposta
      if (response.isEmpty) {
        return []; // Retorna uma lista vazia se não houver dados
      }
  
      // Mapeia os resultados para a lista de objetos Gasto
      return response.map((item) {
        return Gasto(
          id: item['id'] as String,
          categoriaId: item['categoria_id'] as String,
          descricao: item['descricao'] ?? '',
          valor: (item['valor'] as num).toDouble(),
          data: DateTime.parse(item['data']),
        );
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar gastos por mês: $e');
    }
  }

  Future<void> getGastosPorCategoria(String categoryId) async {
    _setLoading(true);
    _setError(null);
  
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
  
      // Consulta os gastos na base de dados para a categoria especificada
      final response = await Supabase.instance.client
          .from('gastos')
          .select('*')
          .eq('user_id', userId)
          .eq('categoria_id', categoryId) as List;
  
      // Atualiza a lista local de gastos
      _gastos.clear();
      for (final item in response) {
        _gastos.add(Gasto(
          id: item['id'] as String,
          descricao: item['descricao'] ?? '',
          valor: (item['valor'] as num).toDouble(),
          data: DateTime.parse(item['data']),
          categoriaId: item['categoria_id'] as String,
        ));
      }
  
      notifyListeners(); // Notifica os consumidores sobre a mudança
    } catch (e) {
      _setError('Erro ao buscar gastos por categoria: $e');
    } finally {
      _setLoading(false);
    }
  }
}