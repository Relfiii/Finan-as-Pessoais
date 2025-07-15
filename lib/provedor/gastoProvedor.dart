import 'package:flutter/material.dart';
import '../modelos/gasto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GastoProvider with ChangeNotifier {
  /// Soma todos os gastos do ano informado
  Future<double> totalGastoAno({required int ano}) async {
    if (_gastos.isEmpty) await loadGastos();
    return _gastos.where((g) => g.data.year == ano).fold<double>(0.0, (sum, g) => sum + g.valor);
  }
  /// Retorna o total de gastos para um dia específico
  double totalGastoDia({DateTime? referencia}) {
    final now = referencia ?? DateTime.now();
    return _gastos
        .where((g) =>
            g.data.year == now.year &&
            g.data.month == now.month &&
            g.data.day == now.day)
        .fold(0.0, (soma, g) => soma + g.valor);
  }
  final List<Gasto> _gastos = [];
  final Map<String, List<Gasto>> _gastosPorCategoria = {};
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Gasto> get gastos => _gastos;

  Future<void> loadGastos() async {
    // Só marca como carregando se não estiver já carregando
    if (!_isLoading) {
      _setLoading(true);
    }
    _setError(null);

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      print('⚠️ Usuário não logado, não carregando gastos');
      _setError('Usuário não autenticado.');
      _setLoading(false);
      return;
    }

    try {
      print('💰 Carregando gastos para usuário: ${user.id}');
      final data = await Supabase.instance.client
          .from('gastos')
          .select('*')
          .eq('user_id', user.id)
          .timeout(Duration(seconds: 10));

      _gastos.clear();
      _gastosPorCategoria.clear();

      for (final item in data) {
        final gasto = Gasto(
          id: item['id'],
          descricao: item['descricao'],
          valor: (item['valor'] as num).toDouble(),
          data: DateTime.parse(item['data']),
          categoriaId: item['categoria_id'],
          parcelaAtual: item['parcela_atual'] ?? 1,
          totalParcelas: item['total_parcelas'] ?? 1,
        );
        _gastos.add(gasto);

        _gastosPorCategoria[gasto.categoriaId] ??= [];
        _gastosPorCategoria[gasto.categoriaId]!.add(gasto);
      }
      print('✅ ${_gastos.length} gastos carregados');
      notifyListeners();
    } catch (e) {
      print('❌ Erro ao carregar gastos: $e');
      _setError('Erro ao carregar gastos: $e');
      // Não bloqueia o app, apenas limpa as listas
      _gastos.clear();
      _gastosPorCategoria.clear();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  List<Gasto> gastosPorCategoria(String categoryId) {
    return _gastosPorCategoria[categoryId] ?? [];
  }

  void addGasto(Gasto gasto) {
    _gastos.add(gasto);
    _gastosPorCategoria[gasto.categoriaId] ??= [];
    _gastosPorCategoria[gasto.categoriaId]!.add(gasto);
    notifyListeners();
  }

  Future<void> deleteGasto(String gastoId) async {
    try {
      await Supabase.instance.client
          .from('gastos')
          .delete()
          .eq('id', gastoId);

      final gastoRemovido = _gastos.firstWhere((g) => g.id == gastoId);
      _gastos.remove(gastoRemovido);
      _gastosPorCategoria[gastoRemovido.categoriaId]?.remove(gastoRemovido);
      notifyListeners();
    } catch (e) {
      throw Exception('Erro ao deletar gasto: $e');
    }
  }

  Future<void> updateGasto(String id, String novaDescricao, double novoValor) async {
    try {
      // Atualiza na base de dados primeiro
      await Supabase.instance.client
          .from('gastos')
          .update({
            'descricao': novaDescricao,
            'valor': novoValor,
          })
          .eq('id', id);

      // Atualiza no cache local
      final index = _gastos.indexWhere((gasto) => gasto.id == id);
      if (index != -1) {
        final categoriaId = _gastos[index].categoriaId;
        _gastos[index].descricao = novaDescricao;
        _gastos[index].valor = novoValor;

        // Atualiza no cache da categoria
        final cache = _gastosPorCategoria[categoriaId];
        if (cache != null) {
          final i = cache.indexWhere((g) => g.id == id);
          if (i != -1) {
            cache[i].descricao = novaDescricao;
            cache[i].valor = novoValor;
          }
        }

        notifyListeners();
      }
    } catch (e) {
      throw Exception('Erro ao atualizar gasto: $e');
    }
  }

  double totalPorCategoria(String categoriaId) {
    final gastos = _gastosPorCategoria[categoriaId] ?? [];
    return gastos.fold(0.0, (soma, g) => soma + g.valor);
  }

  double totalPorCategoriaMes(String categoriaId, DateTime mes) {
    final gastos = _gastosPorCategoria[categoriaId] ?? [];
    return gastos
        .where((g) => g.data.month == mes.month && g.data.year == mes.year)
        .fold(0.0, (sum, g) => sum + g.valor);
  }

  double totalGastoMes({DateTime? referencia}) {
    final now = referencia ?? DateTime.now();
    return _gastos
        .where((g) => g.data.month == now.month && g.data.year == now.year)
        .fold(0.0, (soma, g) => soma + g.valor);
  }

  double get totalGastos {
    return _gastos.fold(0.0, (sum, gasto) => sum + gasto.valor);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    if (error != null) notifyListeners();
  }

  Future<List<Gasto>> getGastosPorMes(String? categoryId, DateTime mes) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado.');

      final inicioMes = DateTime(mes.year, mes.month, 1);
      final fimMes = DateTime(mes.year, mes.month + 1, 1).subtract(const Duration(days: 1));

      var query = Supabase.instance.client
          .from('gastos')
          .select()
          .eq('user_id', user.id)
          .gte('data', inicioMes.toIso8601String())
          .lte('data', fimMes.toIso8601String());

      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.eq('categoria_id', categoryId);
      }

      final response = await query;
      final lista = List<Map<String, dynamic>>.from(response);

      return lista.map((item) => Gasto(
        id: item['id'],
        descricao: item['descricao'],
        valor: (item['valor'] as num).toDouble(),
        data: DateTime.parse(item['data']),
        dataCompra: item['data_compra'] != null ? DateTime.parse(item['data_compra']) : null,
        categoriaId: item['categoria_id'],
        parcelaAtual: item['parcela_atual'] ?? 1,
        totalParcelas: item['total_parcelas'] ?? 1,
      )).toList();
    } catch (e) {
      throw Exception('Erro ao buscar gastos por mês: $e');
    }
  }

  Future<void> getGastosPorCategoria(String categoryId) async {
    _setLoading(true);
    _setError(null);

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _setError('Usuário não autenticado.');
      _setLoading(false);
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('gastos')
          .select('*')
          .eq('user_id', user.id)
          .eq('categoria_id', categoryId);

      final lista = List<Map<String, dynamic>>.from(response);
      _gastos.clear();

      for (final item in lista) {
        _gastos.add(Gasto(
          id: item['id'],
          descricao: item['descricao'] ?? '',
          valor: (item['valor'] as num).toDouble(),
          data: DateTime.parse(item['data']),
          dataCompra: item['data_compra'] != null ? DateTime.parse(item['data_compra']) : null,
          categoriaId: item['categoria_id'],
          parcelaAtual: item['parcela_atual'] ?? 1,
          totalParcelas: item['total_parcelas'] ?? 1,
        ));
      }

      notifyListeners();
    } catch (e) {
      _setError('Erro ao buscar gastos por categoria: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Retorna lista de anos que possuem gastos
  Future<List<int>> getAnosComGasto() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await Supabase.instance.client
          .from('gastos')
          .select('data')
          .eq('user_id', userId);

      final Set<int> anos = {};
      for (final item in response) {
        final data = DateTime.parse(item['data']);
        anos.add(data.year);
      }

      final List<int> anosOrdenados = anos.toList()..sort();
      print('📅 Anos com gastos: $anosOrdenados');
      return anosOrdenados;
    } catch (e) {
      print('❌ Erro ao buscar anos com gastos: $e');
      return [];
    }
  }

  // Função genérica para buscar por tipo (ex: receita, investimento)
  static Future<List<Gasto>> _buscarPorTipoEMes(String tipo, DateTime mes) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];

    final inicioMes = DateTime(mes.year, mes.month, 1);
    final fimMes = DateTime(mes.year, mes.month + 1, 1).subtract(const Duration(days: 1));

    final response = await Supabase.instance.client
        .from('gastos')
        .select()
        .eq('user_id', user.id)
        .eq('tipo', tipo)
        .gte('data', inicioMes.toIso8601String())
        .lte('data', fimMes.toIso8601String());

    final lista = List<Map<String, dynamic>>.from(response);
    return lista.map((item) => Gasto(
      id: item['id'],
      descricao: item['descricao'],
      valor: (item['valor'] as num).toDouble(),
      data: DateTime.parse(item['data']),
      dataCompra: item['data_compra'] != null ? DateTime.parse(item['data_compra']) : null,
      categoriaId: item['categoria_id'],
      parcelaAtual: item['parcela_atual'] ?? 1,
      totalParcelas: item['total_parcelas'] ?? 1,
    )).toList();
  }

  static Future<List<Gasto>> buscarInvestimentosPorMes(DateTime mes) =>
      _buscarPorTipoEMes('investimento', mes);

  static Future<List<Gasto>> buscarReceitasPorMes(DateTime mes) =>
      _buscarPorTipoEMes('receita', mes);

  static Future<double> buscarTotalInvestimentos({required DateTime mes}) async {
    final investimentos = await buscarInvestimentosPorMes(mes);
    return investimentos.fold<double>(0.0, (soma, i) => soma + i.valor); // <-- Removido "as double"
  }

  static Future<double> buscarTotalReceitas({required DateTime mes}) async {
    final receitas = await buscarReceitasPorMes(mes);
    return receitas.fold<double>(0.0, (soma, r) => soma + r.valor); // <-- Removido "as double"
  }
}
