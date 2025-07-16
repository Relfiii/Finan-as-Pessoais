import 'package:flutter/foundation.dart';
import '../modelos/transicao.dart';
import '../services/transicao.dart' show TransactionService;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider para gerenciar o estado das transações
class TransactionProvider with ChangeNotifier {
  // Cache estruturado para melhorar performance
  final Map<String, double> _cacheReceitas = {}; // "2025-01" -> valor
  final Map<String, double> _cacheInvestimentos = {}; // "2025-01" -> valor
  final Map<String, double> _cacheReceitasDia = {}; // "2025-01-15" -> valor
  final Map<String, double> _cacheInvestimentosDia = {}; // "2025-01-15" -> valor
  final Map<String, double> _cacheReceitasAno = {}; // "2025" -> valor
  final Map<String, double> _cacheInvestimentosAno = {}; // "2025" -> valor
  final Map<String, List<int>> _cacheAnosComDados = {}; // "receitas"/"investimentos" -> [2023, 2024, 2025]
  
  // Timestamp do último carregamento para invalidar cache se necessário
  DateTime? _lastFullLoad;
  static const Duration _cacheValidityDuration = Duration(minutes: 15);
  
  /// Limpa todo o cache - usar após inserções/atualizações/exclusões
  void clearCache() {
    _cacheReceitas.clear();
    _cacheInvestimentos.clear();
    _cacheReceitasDia.clear();
    _cacheInvestimentosDia.clear();
    _cacheReceitasAno.clear();
    _cacheInvestimentosAno.clear();
    _cacheAnosComDados.clear();
    _lastFullLoad = null;
    print('🧹 Cache do TransactionProvider limpo');
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
  /// Retorna o ano mais antigo das transações do usuário (OTIMIZADO - LOTE)
  Future<int?> getAnoMaisAntigo() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    print('🔍 Buscando ano mais antigo para usuário: $userId');
    
    _setLoadingYearRange(true);
    
    // OTIMIZAÇÃO: Fazer consultas em paralelo e buscar apenas o primeiro registro
    try {
      final futures = await Future.wait([
        // Buscar apenas o primeiro registro (mais antigo) de cada tabela
        Supabase.instance.client
            .from('entradas')
            .select('data')
            .eq('user_id', userId)
            .order('data')
            .limit(1),
        Supabase.instance.client
            .from('investimentos')
            .select('data')
            .eq('user_id', userId)
            .order('data')
            .limit(1),
        Supabase.instance.client
            .from('gastos')
            .select('data')
            .eq('user_id', userId)
            .order('data')
            .limit(1),
      ]);
      
      final List<int> anos = [];
      
      // Processar resultados
      for (int i = 0; i < futures.length; i++) {
        final result = futures[i] as List<dynamic>;
        if (result.isNotEmpty) {
          final data = DateTime.parse(result.first['data']);
          anos.add(data.year);
          final tabela = ['entradas', 'investimentos', 'gastos'][i];
          print('📅 Ano mais antigo em $tabela: ${data.year}');
        }
      }
      
      if (anos.isEmpty) {
        print('⚠️ Nenhum ano encontrado, retornando null');
        return null;
      }
      
      final anoMaisAntigo = anos.reduce((a, b) => a < b ? a : b);
      print('✅ Ano mais antigo final: $anoMaisAntigo (consulta em lote)');
      return anoMaisAntigo;
    } catch (e) {
      print('❌ Erro ao buscar ano mais antigo em lote: $e');
      return null;
    } finally {
      _setLoadingYearRange(false);
    }
  }

  /// Retorna o ano mais recente das transações do usuário (OTIMIZADO - LOTE)
  Future<int?> getAnoMaisRecente() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    print('🔍 Buscando ano mais recente para usuário: $userId');
    
    _setLoadingYearRange(true);
    
    // OTIMIZAÇÃO: Fazer consultas em paralelo e buscar apenas o primeiro registro
    try {
      final futures = await Future.wait([
        // Buscar apenas o primeiro registro (mais recente) de cada tabela
        Supabase.instance.client
            .from('entradas')
            .select('data')
            .eq('user_id', userId)
            .order('data', ascending: false)
            .limit(1),
        Supabase.instance.client
            .from('investimentos')
            .select('data')
            .eq('user_id', userId)
            .order('data', ascending: false)
            .limit(1),
        Supabase.instance.client
            .from('gastos')
            .select('data')
            .eq('user_id', userId)
            .order('data', ascending: false)
            .limit(1),
      ]);
      
      final List<int> anos = [];
      
      // Processar resultados
      for (int i = 0; i < futures.length; i++) {
        final result = futures[i] as List<dynamic>;
        if (result.isNotEmpty) {
          final data = DateTime.parse(result.first['data']);
          anos.add(data.year);
          final tabela = ['entradas', 'investimentos', 'gastos'][i];
          print('📅 Ano mais recente em $tabela: ${data.year}');
        }
      }
      
      if (anos.isEmpty) {
        print('⚠️ Nenhum ano encontrado, retornando null');
        return null;
      }
      
      final anoMaisRecente = anos.reduce((a, b) => a > b ? a : b);
      print('✅ Ano mais recente final: $anoMaisRecente (consulta em lote)');
      return anoMaisRecente;
    } catch (e) {
      print('❌ Erro ao buscar ano mais recente em lote: $e');
      return null;
    } finally {
      _setLoadingYearRange(false);
    }
  }

  /// Soma todas as receitas do ano informado (OTIMIZADO - LOTE)
  Future<double> getReceitaPorAno(int ano) async {
    final key = _getAnoKey(ano);
    
    // Verificar cache primeiro
    if (_cacheReceitasAno.containsKey(key) && _isCacheValid()) {
      print('📈 Cache hit - Receitas ano ${key}: R\$ ${_cacheReceitasAno[key]}');
      return _cacheReceitasAno[key]!;
    }
    
    print('📈 Cache miss - Consultando banco para receitas ano ${key}');
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final inicio = DateTime(ano, 1, 1);
    final fim = DateTime(ano, 12, 31);
    
    try {
      // OTIMIZAÇÃO: Consultas em paralelo em vez de sequenciais
      final futures = await Future.wait([
        // Buscar na tabela entradas
        Supabase.instance.client
            .from('entradas')
            .select('valor')
            .gte('data', inicio.toIso8601String())
            .lte('data', fim.toIso8601String())
            .eq('user_id', userId),
        // Buscar na tabela transacoes com tipo receita
        Supabase.instance.client
            .from('transacoes')
            .select('valor')
            .gte('data', inicio.toIso8601String())
            .lte('data', fim.toIso8601String())
            .eq('tipo', 'receita')
            .eq('user_id', userId),
      ]);
      
      final listEntradas = futures[0] as List<dynamic>;
      final listTransacoes = futures[1] as List<dynamic>;
      
      double totalEntradas = listEntradas.fold<double>(
        0.0,
        (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
      );
      
      double totalTransacoes = listTransacoes.fold<double>(
        0.0,
        (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
      );
      
      final total = totalEntradas + totalTransacoes;
      
      // Armazenar no cache
      _cacheReceitasAno[key] = total;
      print('📈 Cache set - Receitas ano ${key}: R\$ ${total} (consulta em lote)');
      
      return total;
    } catch (e) {
      print('❌ Erro ao buscar receitas por ano em lote: $e');
      return 0.0;
    }
  }

  /// Soma todos os investimentos do ano informado (OTIMIZADO - LOTE)
  Future<double> getInvestimentoPorAno(int ano) async {
    final key = _getAnoKey(ano);
    
    // Verificar cache primeiro
    if (_cacheInvestimentosAno.containsKey(key) && _isCacheValid()) {
      print('💰 Cache hit - Investimentos ano ${key}: R\$ ${_cacheInvestimentosAno[key]}');
      return _cacheInvestimentosAno[key]!;
    }
    
    print('💰 Cache miss - Consultando banco para investimentos ano ${key}');
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final inicio = DateTime(ano, 1, 1);
    final fim = DateTime(ano, 12, 31);
    
    try {
      // OTIMIZAÇÃO: Consultas em paralelo em vez de sequenciais
      final futures = await Future.wait([
        // Buscar na tabela investimentos
        Supabase.instance.client
            .from('investimentos')
            .select('valor')
            .gte('data', inicio.toIso8601String())
            .lte('data', fim.toIso8601String())
            .eq('user_id', userId),
        // Buscar na tabela transacoes com tipo investimento
        Supabase.instance.client
            .from('transacoes')
            .select('valor')
            .gte('data', inicio.toIso8601String())
            .lte('data', fim.toIso8601String())
            .eq('tipo', 'investimento')
            .eq('user_id', userId),
      ]);
      
      final listInvestimentos = futures[0] as List<dynamic>;
      final listTransacoes = futures[1] as List<dynamic>;
      
      double totalInvestimentos = listInvestimentos.fold<double>(
        0.0,
        (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
      );
      
      double totalTransacoes = listTransacoes.fold<double>(
        0.0,
        (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
      );
      
      final total = totalInvestimentos + totalTransacoes;
      
      // Armazenar no cache
      _cacheInvestimentosAno[key] = total;
      print('💰 Cache set - Investimentos ano ${key}: R\$ ${total} (consulta em lote)');
      
      return total;
    } catch (e) {
      print('❌ Erro ao buscar investimentos por ano em lote: $e');
      return 0.0;
    }
  }
  /// Retorna o total de receitas para um dia específico (OTIMIZADO - LOTE)
  Future<double> getReceitaPorDia(DateTime dia) async {
    final key = _getDiaKey(dia);
    
    // Verificar cache primeiro
    if (_cacheReceitasDia.containsKey(key) && _isCacheValid()) {
      print('📈 Cache hit - Receitas dia ${key}: R\$ ${_cacheReceitasDia[key]}');
      return _cacheReceitasDia[key]!;
    }
    
    print('📈 Cache miss - Consultando banco para receitas dia ${key}');
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final inicio = DateTime(dia.year, dia.month, dia.day, 0, 0, 0);
    final fim = DateTime(dia.year, dia.month, dia.day, 23, 59, 59);
    
    try {
      // OTIMIZAÇÃO: Consultas em paralelo em vez de sequenciais
      final futures = await Future.wait([
        // Buscar na tabela entradas
        Supabase.instance.client
            .from('entradas')
            .select('valor')
            .gte('data', inicio.toIso8601String())
            .lte('data', fim.toIso8601String())
            .eq('user_id', userId),
        // Buscar na tabela transacoes com tipo receita
        Supabase.instance.client
            .from('transacoes')
            .select('valor')
            .gte('data', inicio.toIso8601String())
            .lte('data', fim.toIso8601String())
            .eq('tipo', 'receita')
            .eq('user_id', userId),
      ]);
      
      final listEntradas = futures[0] as List<dynamic>;
      final listTransacoes = futures[1] as List<dynamic>;
      
      double totalEntradas = listEntradas.fold<double>(
        0.0,
        (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
      );
      
      double totalTransacoes = listTransacoes.fold<double>(
        0.0,
        (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
      );
      
      final total = totalEntradas + totalTransacoes;
      
      // Armazenar no cache
      _cacheReceitasDia[key] = total;
      print('📈 Cache set - Receitas dia ${key}: R\$ ${total} (consulta em lote)');
      
      return total;
    } catch (e) {
      print('❌ Erro ao buscar receitas por dia em lote: $e');
      return 0.0;
    }
  }

  /// Retorna o total de investimentos para um dia específico (OTIMIZADO - LOTE)
  Future<double> getInvestimentoPorDia(DateTime dia) async {
    final key = _getDiaKey(dia);
    
    // Verificar cache primeiro
    if (_cacheInvestimentosDia.containsKey(key) && _isCacheValid()) {
      print('💰 Cache hit - Investimentos dia ${key}: R\$ ${_cacheInvestimentosDia[key]}');
      return _cacheInvestimentosDia[key]!;
    }
    
    print('💰 Cache miss - Consultando banco para investimentos dia ${key}');
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final inicio = DateTime(dia.year, dia.month, dia.day, 0, 0, 0);
    final fim = DateTime(dia.year, dia.month, dia.day, 23, 59, 59);
    
    try {
      // OTIMIZAÇÃO: Consultas em paralelo em vez de sequenciais
      final futures = await Future.wait([
        // Buscar na tabela investimentos
        Supabase.instance.client
            .from('investimentos')
            .select('valor')
            .gte('data', inicio.toIso8601String())
            .lte('data', fim.toIso8601String())
            .eq('user_id', userId),
        // Buscar na tabela transacoes com tipo investimento
        Supabase.instance.client
            .from('transacoes')
            .select('valor')
            .gte('data', inicio.toIso8601String())
            .lte('data', fim.toIso8601String())
            .eq('tipo', 'investimento')
            .eq('user_id', userId),
      ]);
      
      final listInvestimentos = futures[0] as List<dynamic>;
      final listTransacoes = futures[1] as List<dynamic>;
      
      double totalInvestimentos = listInvestimentos.fold<double>(
        0.0,
        (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
      );
      
      double totalTransacoes = listTransacoes.fold<double>(
        0.0,
        (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
      );
      
      final total = totalInvestimentos + totalTransacoes;
      
      // Armazenar no cache
      _cacheInvestimentosDia[key] = total;
      print('💰 Cache set - Investimentos dia ${key}: R\$ ${total} (consulta em lote)');
      
      return total;
    } catch (e) {
      print('❌ Erro ao buscar investimentos por dia em lote: $e');
      return 0.0;
    }
  }
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  // Estados de loading granulares para melhor UX
  bool _isLoadingReceitas = false;
  bool _isLoadingInvestimentos = false;
  bool _isLoadingGastos = false;
  bool _isLoadingChart = false;
  bool _isLoadingYearRange = false;
  Map<String, bool> _isLoadingSpecific = {}; // Para carregamentos específicos por período

  /// Lista de transações
  List<Transaction> get transactions => _transactions;

  /// Estado de carregamento geral
  bool get isLoading => _isLoading;
  
  /// Estados de loading granulares para UX específica
  bool get isLoadingReceitas => _isLoadingReceitas;
  bool get isLoadingInvestimentos => _isLoadingInvestimentos;
  bool get isLoadingGastos => _isLoadingGastos;
  bool get isLoadingChart => _isLoadingChart;
  bool get isLoadingYearRange => _isLoadingYearRange;
  
  /// Verifica se está carregando um período específico
  bool isLoadingPeriod(String period) => _isLoadingSpecific[period] ?? false;
  
  /// Verifica se há qualquer carregamento ativo
  bool get hasAnyLoading => _isLoading || _isLoadingReceitas || _isLoadingInvestimentos || 
                            _isLoadingGastos || _isLoadingChart || _isLoadingYearRange ||
                            _isLoadingSpecific.values.any((loading) => loading);

  /// Mensagem de erro
  String? get error => _error;

  /// Carrega todas as transações
  Future<void> loadTransactions() async {
    // Só marca como carregando se não estiver já carregando
    if (!_isLoading) {
      _setLoading(true);
    }
    _setError(null);

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        print('⚠️ Usuário não logado, não carregando transações');
        _setLoading(false);
        return;
      }
      
      print('📊 Carregando transações para usuário: ${user.id}');
      _transactions = await TransactionService.getAll().timeout(Duration(seconds: 15));
      print('✅ ${_transactions.length} transações carregadas');
      _lastFullLoad = DateTime.now(); // Marcar timestamp do carregamento
      notifyListeners();
    } catch (e) {
      print('❌ Erro ao carregar transações: $e');
      _setError('Erro ao carregar transações: $e');
      // Não bloqueia o app, apenas define lista vazia
      _transactions = [];
      notifyListeners();
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
      clearCache(); // Limpar cache após modificação
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
        clearCache(); // Limpar cache após modificação
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
      clearCache(); // Limpar cache após modificação
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
    _setLoadingGastos(true);
    
    try {
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
    } finally {
      _setLoadingGastos(false);
    }
  }
  
  Future<double> getReceitaPorMes(DateTime referencia) async {
    final key = _getMesKey(referencia);
    
    // Verificar cache primeiro
    if (_cacheReceitas.containsKey(key) && _isCacheValid()) {
      print('📈 Cache hit - Receitas ${key}: R\$ ${_cacheReceitas[key]}');
      return _cacheReceitas[key]!;
    }
    
    _setLoadingReceitas(true);
    _setLoadingSpecific('receitas_$key', true);
    
    print('📈 Cache miss - Consultando banco para receitas ${key}');
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final inicio = DateTime(referencia.year, referencia.month, 1);
    final fim = DateTime(referencia.year, referencia.month + 1, 0);
    
    try {
      // OTIMIZAÇÃO: Consultas em paralelo em vez de sequenciais
      final futures = await Future.wait([
        // Buscar na tabela entradas
        Supabase.instance.client
            .from('entradas')
            .select('valor')
            .gte('data', inicio.toIso8601String())
            .lte('data', fim.toIso8601String())
            .eq('user_id', userId),
        // Buscar na tabela transacoes com tipo receita
        Supabase.instance.client
            .from('transacoes')
            .select('valor')
            .gte('data', inicio.toIso8601String())
            .lte('data', fim.toIso8601String())
            .eq('tipo', 'receita')
            .eq('user_id', userId),
      ]);
      
      final listEntradas = futures[0] as List<dynamic>;
      final listTransacoes = futures[1] as List<dynamic>;
      
      double totalEntradas = listEntradas.fold<double>(
        0.0,
        (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
      );
      
      double totalTransacoes = listTransacoes.fold<double>(
        0.0,
        (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
      );
      
      final total = totalEntradas + totalTransacoes;
      
      // Armazenar no cache
      _cacheReceitas[key] = total;
      print('📈 Cache set - Receitas ${key}: R\$ ${total} (consulta em lote)');
      
      return total;
    } catch (e) {
      print('❌ Erro ao buscar receitas por mês em lote: $e');
      return 0.0;
    } finally {
      _setLoadingReceitas(false);
      _setLoadingSpecific('receitas_$key', false);
    }
  }

  Future<double> getInvestimentoPorMes(DateTime referencia) async {
    final key = _getMesKey(referencia);
    
    // Verificar cache primeiro
    if (_cacheInvestimentos.containsKey(key) && _isCacheValid()) {
      print('💰 Cache hit - Investimentos ${key}: R\$ ${_cacheInvestimentos[key]}');
      return _cacheInvestimentos[key]!;
    }
    
    _setLoadingInvestimentos(true);
    _setLoadingSpecific('investimentos_$key', true);
    
    print('💰 Cache miss - Consultando banco para investimentos ${key}');
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final inicio = DateTime(referencia.year, referencia.month, 1);
    final fim = DateTime(referencia.year, referencia.month + 1, 0);
    
    try {
      // OTIMIZAÇÃO: Consultas em paralelo em vez de sequenciais
      final futures = await Future.wait([
        // Buscar na tabela investimentos
        Supabase.instance.client
            .from('investimentos')
            .select('valor')
            .gte('data', inicio.toIso8601String())
            .lte('data', fim.toIso8601String())
            .eq('user_id', userId),
        // Buscar na tabela transacoes com tipo investimento
        Supabase.instance.client
            .from('transacoes')
            .select('valor')
            .gte('data', inicio.toIso8601String())
            .lte('data', fim.toIso8601String())
            .eq('tipo', 'investimento')
            .eq('user_id', userId),
      ]);
      
      final listInvestimentos = futures[0] as List<dynamic>;
      final listTransacoes = futures[1] as List<dynamic>;
      
      double totalInvestimentos = listInvestimentos.fold<double>(
        0.0,
        (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
      );
      
      double totalTransacoes = listTransacoes.fold<double>(
        0.0,
        (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
      );
      
      final total = totalInvestimentos + totalTransacoes;
      
      // Armazenar no cache
      _cacheInvestimentos[key] = total;
      print('💰 Cache set - Investimentos ${key}: R\$ ${total} (consulta em lote)');
      
      return total;
    } catch (e) {
      print('❌ Erro ao buscar investimentos por mês em lote: $e');
      return 0.0;
    } finally {
      _setLoadingInvestimentos(false);
      _setLoadingSpecific('investimentos_$key', false);
    }
  }

  /// Retorna lista de anos que possuem receitas
  Future<List<int>> getAnosComReceita() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await Supabase.instance.client
          .from('entradas')
          .select('data')
          .eq('user_id', userId);

      final Set<int> anos = {};
      for (final item in response) {
        final data = DateTime.parse(item['data']);
        anos.add(data.year);
      }

      final List<int> anosOrdenados = anos.toList()..sort();
      print('📅 Anos com receitas: $anosOrdenados');
      return anosOrdenados;
    } catch (e) {
      print('❌ Erro ao buscar anos com receitas: $e');
      return [];
    }
  }

  /// Retorna lista de anos que possuem investimentos
  Future<List<int>> getAnosComInvestimento() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await Supabase.instance.client
          .from('investimentos')
          .select('data')
          .eq('user_id', userId);

      final Set<int> anos = {};
      for (final item in response) {
        final data = DateTime.parse(item['data']);
        anos.add(data.year);
      }

      final List<int> anosOrdenados = anos.toList()..sort();
      print('📅 Anos com investimentos: $anosOrdenados');
      return anosOrdenados;
    } catch (e) {
      print('❌ Erro ao buscar anos com investimentos: $e');
      return [];
    }
  }

  /// OTIMIZAÇÃO CRÍTICA: Busca múltiplos totais em uma única consulta
  /// Usado quando o gráfico precisa carregar vários meses/períodos simultaneamente
  Future<Map<String, Map<String, double>>> buscarTotaisEmLote({
    required List<DateTime> periodos,
    required String granularidade, // 'mes', 'dia', 'ano'
  }) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    
    _setLoadingChart(true);
    _setLoadingSpecific('lote_${granularidade}_${periodos.length}', true);
    
    // Calcular range que engloba todos os períodos
    final primeiro = periodos.reduce((a, b) => a.isBefore(b) ? a : b);
    final ultimo = periodos.reduce((a, b) => a.isAfter(b) ? a : b);
    
    DateTime inicio, fim;
    if (granularidade == 'ano') {
      inicio = DateTime(primeiro.year, 1, 1);
      fim = DateTime(ultimo.year, 12, 31);
    } else if (granularidade == 'mes') {
      inicio = DateTime(primeiro.year, primeiro.month, 1);
      fim = DateTime(ultimo.year, ultimo.month + 1, 0);
    } else { // dia
      inicio = DateTime(primeiro.year, primeiro.month, primeiro.day);
      fim = DateTime(ultimo.year, ultimo.month, ultimo.day, 23, 59, 59);
    }

    try {
      print('📊 Buscando totais em lote: ${inicio.toString().substring(0, 10)} até ${fim.toString().substring(0, 10)}');
      
      // Fazer consultas em paralelo para todas as tabelas
      final futures = await Future.wait([
        // Entradas
        Supabase.instance.client
            .from('entradas')
            .select('valor, data')
            .gte('data', inicio.toIso8601String())
            .lte('data', fim.toIso8601String())
            .eq('user_id', userId),
        // Investimentos
        Supabase.instance.client
            .from('investimentos')
            .select('valor, data')
            .gte('data', inicio.toIso8601String())
            .lte('data', fim.toIso8601String())
            .eq('user_id', userId),
        // Transações receitas
        Supabase.instance.client
            .from('transacoes')
            .select('valor, data')
            .gte('data', inicio.toIso8601String())
            .lte('data', fim.toIso8601String())
            .eq('tipo', 'receita')
            .eq('user_id', userId),
        // Transações investimentos
        Supabase.instance.client
            .from('transacoes')
            .select('valor, data')
            .gte('data', inicio.toIso8601String())
            .lte('data', fim.toIso8601String())
            .eq('tipo', 'investimento')
            .eq('user_id', userId),
      ]);

      // Inicializar resultado
      final Map<String, Map<String, double>> resultado = {};
      for (final periodo in periodos) {
        String key;
        if (granularidade == 'ano') {
          key = _getAnoKey(periodo.year);
        } else if (granularidade == 'mes') {
          key = _getMesKey(periodo);
        } else {
          key = _getDiaKey(periodo);
        }
        resultado[key] = {'receitas': 0.0, 'investimentos': 0.0};
      }

      // Processar entradas
      final entradas = futures[0] as List<dynamic>;
      for (final item in entradas) {
        final data = DateTime.parse(item['data']);
        final valor = ((item['valor'] ?? 0) as num).toDouble();
        String key;
        if (granularidade == 'ano') {
          key = _getAnoKey(data.year);
        } else if (granularidade == 'mes') {
          key = _getMesKey(data);
        } else {
          key = _getDiaKey(data);
        }
        
        if (resultado.containsKey(key)) {
          resultado[key]!['receitas'] = resultado[key]!['receitas']! + valor;
        }
      }

      // Processar investimentos
      final investimentos = futures[1] as List<dynamic>;
      for (final item in investimentos) {
        final data = DateTime.parse(item['data']);
        final valor = ((item['valor'] ?? 0) as num).toDouble();
        String key;
        if (granularidade == 'ano') {
          key = _getAnoKey(data.year);
        } else if (granularidade == 'mes') {
          key = _getMesKey(data);
        } else {
          key = _getDiaKey(data);
        }
        
        if (resultado.containsKey(key)) {
          resultado[key]!['investimentos'] = resultado[key]!['investimentos']! + valor;
        }
      }

      // Processar transações receitas
      final transacoesReceitas = futures[2] as List<dynamic>;
      for (final item in transacoesReceitas) {
        final data = DateTime.parse(item['data']);
        final valor = ((item['valor'] ?? 0) as num).toDouble();
        String key;
        if (granularidade == 'ano') {
          key = _getAnoKey(data.year);
        } else if (granularidade == 'mes') {
          key = _getMesKey(data);
        } else {
          key = _getDiaKey(data);
        }
        
        if (resultado.containsKey(key)) {
          resultado[key]!['receitas'] = resultado[key]!['receitas']! + valor;
        }
      }

      // Processar transações investimentos
      final transacoesInvestimentos = futures[3] as List<dynamic>;
      for (final item in transacoesInvestimentos) {
        final data = DateTime.parse(item['data']);
        final valor = ((item['valor'] ?? 0) as num).toDouble();
        String key;
        if (granularidade == 'ano') {
          key = _getAnoKey(data.year);
        } else if (granularidade == 'mes') {
          key = _getMesKey(data);
        } else {
          key = _getDiaKey(data);
        }
        
        if (resultado.containsKey(key)) {
          resultado[key]!['investimentos'] = resultado[key]!['investimentos']! + valor;
        }
      }

      print('✅ Consulta em lote processada: ${entradas.length + investimentos.length + transacoesReceitas.length + transacoesInvestimentos.length} registros');
      
      // Armazenar no cache individual também
      for (final entry in resultado.entries) {
        if (granularidade == 'ano') {
          _cacheReceitasAno[entry.key] = entry.value['receitas']!;
          _cacheInvestimentosAno[entry.key] = entry.value['investimentos']!;
        } else if (granularidade == 'mes') {
          _cacheReceitas[entry.key] = entry.value['receitas']!;
          _cacheInvestimentos[entry.key] = entry.value['investimentos']!;
        } else {
          _cacheReceitasDia[entry.key] = entry.value['receitas']!;
          _cacheInvestimentosDia[entry.key] = entry.value['investimentos']!;
        }
      }

      return resultado;
    } catch (e) {
      print('❌ Erro na consulta em lote: $e');
      return {};
    } finally {
      _setLoadingChart(false);
      _setLoadingSpecific('lote_${granularidade}_${periodos.length}', false);
    }
  }

  /// Métodos para controlar estados de loading granulares
  void _setLoadingReceitas(bool loading) {
    _isLoadingReceitas = loading;
    notifyListeners();
  }
  
  void _setLoadingInvestimentos(bool loading) {
    _isLoadingInvestimentos = loading;
    notifyListeners();
  }
  
  void _setLoadingGastos(bool loading) {
    _isLoadingGastos = loading;
    notifyListeners();
  }
  
  void _setLoadingChart(bool loading) {
    _isLoadingChart = loading;
    notifyListeners();
  }
  
  void _setLoadingYearRange(bool loading) {
    _isLoadingYearRange = loading;
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
}
