import 'package:flutter/material.dart';
import '../modelos/gasto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GastoProvider with ChangeNotifier {
  final List<Gasto> _gastos = [];
  final Map<String, List<Gasto>> _gastosPorCategoria = {};
  bool _isLoading = false;
  String? _error;

  // Estados de loading granulares para melhor UX
  bool _isLoadingGastosMes = false;
  bool _isLoadingGastosDia = false;
  bool _isLoadingGastosAno = false;
  bool _isLoadingTotals = false;
  Map<String, bool> _isLoadingSpecific = {}; // Para carregamentos específicos

  // Cache estruturado para melhorar performance
  final Map<String, double> _cacheGastosMes = {}; // "2025-01" -> valor
  final Map<String, double> _cacheGastosDia = {}; // "2025-01-15" -> valor
  final Map<String, double> _cacheGastosAno = {}; // "2025" -> valor
  final Map<String, List<int>> _cacheAnosComGastos = {}; // cache de anos
  
  // Timestamp do último carregamento para invalidar cache se necessário
  DateTime? _lastFullLoad;
  static const Duration _cacheValidityDuration = Duration(minutes: 15);

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Gasto> get gastos => _gastos;
  
  // Getters para estados de loading granulares
  bool get isLoadingGastosMes => _isLoadingGastosMes;
  bool get isLoadingGastosDia => _isLoadingGastosDia;
  bool get isLoadingGastosAno => _isLoadingGastosAno;
  bool get isLoadingTotals => _isLoadingTotals;
  
  /// Verifica se está carregando um período específico
  bool isLoadingPeriod(String period) => _isLoadingSpecific[period] ?? false;
  
  /// Verifica se há qualquer carregamento ativo
  bool get hasAnyLoading => _isLoading || _isLoadingGastosMes || _isLoadingGastosDia || 
                            _isLoadingGastosAno || _isLoadingTotals ||
                            _isLoadingSpecific.values.any((loading) => loading);

  /// Limpa todo o cache - usar após inserções/atualizações/exclusões
  void clearCache() {
    _cacheGastosMes.clear();
    _cacheGastosDia.clear();
    _cacheGastosAno.clear();
    _cacheAnosComGastos.clear();
    _lastFullLoad = null;
    print('🧹 Cache do GastoProvider limpo');
  }
  
  /// Verifica se o cache ainda é válido
  bool _isCacheValid() {
    if (_lastFullLoad == null) return false;
    return DateTime.now().difference(_lastFullLoad!) < _cacheValidityDuration;
  }
  
  /// Gera chave de cache para mês
  String _getMesKey(DateTime mes) {
    return "${mes.year}-${mes.month.toString().padLeft(2, '0')}";
  }
  
  /// Gera chave de cache para dia
  String _getDiaKey(DateTime dia) {
    return "${dia.year}-${dia.month.toString().padLeft(2, '0')}-${dia.day.toString().padLeft(2, '0')}";
  }
  
  /// Gera chave de cache para ano
  String _getAnoKey(int ano) {
    return ano.toString();
  }

  /// Soma todos os gastos do ano informado (otimizado com cache)
  Future<double> totalGastoAno({required int ano}) async {
    final key = _getAnoKey(ano);
    
    // Verificar cache primeiro
    if (_cacheGastosAno.containsKey(key) && _isCacheValid()) {
      print('💸 Cache hit - Gastos ano ${key}: R\$ ${_cacheGastosAno[key]}');
      return _cacheGastosAno[key]!;
    }
    
    _setLoadingGastosAno(true);
    _setLoadingSpecific('gastos_ano_$key', true);
    
    print('💸 Cache miss - Calculando gastos ano ${key}');
    if (_gastos.isEmpty) await loadGastos();
    
    try {
      final total = _gastos.where((g) => g.data.year == ano).fold<double>(0.0, (sum, g) => sum + g.valor);
      
      // Armazenar no cache
      _cacheGastosAno[key] = total;
      print('💸 Cache set - Gastos ano ${key}: R\$ ${total}');
      
      return total;
    } finally {
      _setLoadingGastosAno(false);
      _setLoadingSpecific('gastos_ano_$key', false);
    }
  }

  /// Retorna o total de gastos para um dia específico (otimizado com cache)
  double totalGastoDia({DateTime? referencia}) {
    final now = referencia ?? DateTime.now();
    final key = _getDiaKey(now);
    
    // Verificar cache primeiro
    if (_cacheGastosDia.containsKey(key) && _isCacheValid()) {
      print('💸 Cache hit - Gastos dia ${key}: R\$ ${_cacheGastosDia[key]}');
      return _cacheGastosDia[key]!;
    }
    
    print('💸 Cache miss - Calculando gastos dia ${key}');
    
    // Calcular sem atualizar estado de loading (método síncrono)
    final total = _gastos
        .where((g) =>
            g.data.year == now.year &&
            g.data.month == now.month &&
            g.data.day == now.day)
        .fold(0.0, (soma, g) => soma + g.valor);
    
    // Armazenar no cache
    _cacheGastosDia[key] = total;
    print('💸 Cache set - Gastos dia ${key}: R\$ ${total}');
    
    return total;
  }

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
      _lastFullLoad = DateTime.now(); // Marcar timestamp do carregamento
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
    clearCache(); // Limpar cache após modificação
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
      clearCache(); // Limpar cache após modificação
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

        clearCache(); // Limpar cache após modificação
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
    final key = _getMesKey(now);
    
    // Verificar cache primeiro
    if (_cacheGastosMes.containsKey(key) && _isCacheValid()) {
      print('💸 Cache hit - Gastos mês ${key}: R\$ ${_cacheGastosMes[key]}');
      return _cacheGastosMes[key]!;
    }
    
    print('💸 Cache miss - Calculando gastos mês ${key}');
    
    // Calcular sem atualizar estado de loading (método síncrono)
    final total = _gastos
        .where((g) => g.data.month == now.month && g.data.year == now.year)
        .fold(0.0, (soma, g) => soma + g.valor);
    
    // Armazenar no cache
    _cacheGastosMes[key] = total;
    print('💸 Cache set - Gastos mês ${key}: R\$ ${total}');
    
    return total;
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

  /// Métodos para controlar estados de loading granulares
  void _setLoadingGastosAno(bool loading) {
    _isLoadingGastosAno = loading;
    notifyListeners();
  }
  
  void _setLoadingTotals(bool loading) {
    _isLoadingTotals = loading;
    notifyListeners();
  }
  
  void _setLoadingSpecific(String period, bool loading) {
    if (loading) {
      _isLoadingSpecific[period] = true;
    } else {
      _isLoadingSpecific.remove(period);
    }
    notifyListeners();
  }

  /// Versão assíncrona para quando precisar de estado de loading
  Future<double> totalGastoMesAsync({DateTime? referencia}) async {
    final now = referencia ?? DateTime.now();
    final key = _getMesKey(now);
    
    // Verificar cache primeiro
    if (_cacheGastosMes.containsKey(key) && _isCacheValid()) {
      print('💸 Cache hit - Gastos mês ${key}: R\$ ${_cacheGastosMes[key]}');
      return _cacheGastosMes[key]!;
    }
    
    _setLoadingSpecific('gastos_mes_$key', true);
    
    print('💸 Cache miss - Calculando gastos mês ${key}');
    
    try {
      final total = _gastos
          .where((g) => g.data.month == now.month && g.data.year == now.year)
          .fold(0.0, (soma, g) => soma + g.valor);
      
      // Armazenar no cache
      _cacheGastosMes[key] = total;
      print('💸 Cache set - Gastos mês ${key}: R\$ ${total}');
      
      return total;
    } finally {
      _setLoadingSpecific('gastos_mes_$key', false);
    }
  }

  /// Versão assíncrona para quando precisar de estado de loading
  Future<double> totalGastoDiaAsync({DateTime? referencia}) async {
    final now = referencia ?? DateTime.now();
    final key = _getDiaKey(now);
    
    // Verificar cache primeiro
    if (_cacheGastosDia.containsKey(key) && _isCacheValid()) {
      print('💸 Cache hit - Gastos dia ${key}: R\$ ${_cacheGastosDia[key]}');
      return _cacheGastosDia[key]!;
    }
    
    _setLoadingSpecific('gastos_dia_$key', true);
    
    print('💸 Cache miss - Calculando gastos dia ${key}');
    
    try {
      final total = _gastos
          .where((g) =>
              g.data.year == now.year &&
              g.data.month == now.month &&
              g.data.day == now.day)
          .fold(0.0, (soma, g) => soma + g.valor);
      
      // Armazenar no cache
      _cacheGastosDia[key] = total;
      print('💸 Cache set - Gastos dia ${key}: R\$ ${total}');
      
      return total;
    } finally {
      _setLoadingSpecific('gastos_dia_$key', false);
    }
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
    // OTIMIZAÇÃO: Buscar direto o total usando sum no banco em vez de trazer todos os registros
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return 0.0;

    final inicioMes = DateTime(mes.year, mes.month, 1);
    final fimMes = DateTime(mes.year, mes.month + 1, 1).subtract(const Duration(days: 1));

    try {
      final response = await Supabase.instance.client
          .from('gastos')
          .select('valor')
          .eq('user_id', user.id)
          .eq('tipo', 'investimento')
          .gte('data', inicioMes.toIso8601String())
          .lte('data', fimMes.toIso8601String());

      final list = response as List<dynamic>;
      return list.fold<double>(0.0, (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble());
    } catch (e) {
      print('❌ Erro ao buscar total investimentos: $e');
      return 0.0;
    }
  }

  static Future<double> buscarTotalReceitas({required DateTime mes}) async {
    // OTIMIZAÇÃO: Buscar direto o total usando sum no banco em vez de trazer todos os registros
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return 0.0;

    final inicioMes = DateTime(mes.year, mes.month, 1);
    final fimMes = DateTime(mes.year, mes.month + 1, 1).subtract(const Duration(days: 1));

    try {
      final response = await Supabase.instance.client
          .from('gastos')
          .select('valor')
          .eq('user_id', user.id)
          .eq('tipo', 'receita')
          .gte('data', inicioMes.toIso8601String())
          .lte('data', fimMes.toIso8601String());

      final list = response as List<dynamic>;
      return list.fold<double>(0.0, (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble());
    } catch (e) {
      print('❌ Erro ao buscar total receitas: $e');
      return 0.0;
    }
  }

  /// OTIMIZAÇÃO CRÍTICA: Busca múltiplos totais de gastos em uma única consulta
  /// Reduz de N consultas para 1 consulta quando o gráfico precisa de vários períodos
  Future<Map<String, double>> buscarTotaisGastosEmLote({
    required List<DateTime> meses,
    String? tipo, // 'gasto', 'investimento', 'receita' ou null para todos
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return {};

    _setLoadingTotals(true);
    _setLoadingSpecific('lote_gastos_${meses.length}', true);

    // Calcular range de datas que engloba todos os meses
    final primeiroMes = meses.reduce((a, b) => a.isBefore(b) ? a : b);
    final ultimoMes = meses.reduce((a, b) => a.isAfter(b) ? a : b);
    
    final inicioRange = DateTime(primeiroMes.year, primeiroMes.month, 1);
    final fimRange = DateTime(ultimoMes.year, ultimoMes.month + 1, 1).subtract(const Duration(days: 1));

    try {
      print('📊 Buscando gastos em lote: ${inicioRange.toString().substring(0, 10)} até ${fimRange.toString().substring(0, 10)}');
      
      // Fazer uma única consulta para todo o período
      final query = Supabase.instance.client
          .from('gastos')
          .select('valor, data')
          .eq('user_id', user.id)
          .gte('data', inicioRange.toIso8601String())
          .lte('data', fimRange.toIso8601String());

      if (tipo != null) {
        query.eq('tipo', tipo);
      }

      final response = await query;
      final list = response as List<dynamic>;

      // Processar resultados e agrupar por mês
      final Map<String, double> totaisPorMes = {};
      
      for (final mes in meses) {
        final key = "${mes.year}-${mes.month.toString().padLeft(2, '0')}";
        totaisPorMes[key] = 0.0;
      }

      for (final item in list) {
        final data = DateTime.parse(item['data']);
        final valor = ((item['valor'] ?? 0) as num).toDouble();
        final key = "${data.year}-${data.month.toString().padLeft(2, '0')}";
        
        if (totaisPorMes.containsKey(key)) {
          totaisPorMes[key] = totaisPorMes[key]! + valor;
        }
      }

      print('✅ Consulta em lote processada: ${list.length} registros encontrados');
      return totaisPorMes;
    } catch (e) {
      print('❌ Erro na consulta em lote de gastos: $e');
      return {};
    } finally {
      _setLoadingTotals(false);
      _setLoadingSpecific('lote_gastos_${meses.length}', false);
    }
  }
}
