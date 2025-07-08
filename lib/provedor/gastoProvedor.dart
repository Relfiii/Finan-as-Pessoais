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
      final data = await Supabase.instance.client
          .from('gastos')
          .select('*');
      
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
}