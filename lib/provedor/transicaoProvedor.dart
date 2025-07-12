import 'package:flutter/foundation.dart';
import '../modelos/transicao.dart';
import '../services/transicao.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider para gerenciar o estado das transações
class TransactionProvider with ChangeNotifier {
  /// Retorna o ano mais antigo das transações do usuário
  Future<int?> getAnoMaisAntigo() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    print('🔍 Buscando ano mais antigo para usuário: $userId');
    
    // Buscar o ano mais antigo em todas as tabelas
    List<int> anos = [];
    
    // Tabela entradas
    try {
      final entradas = await Supabase.instance.client
          .from('entradas')
          .select('data')
          .eq('user_id', userId)
          .order('data');
      
      if (entradas.isNotEmpty) {
        final data = DateTime.parse(entradas.first['data']);
        anos.add(data.year);
        print('📅 Ano mais antigo em entradas: ${data.year}');
      } else {
        print('⚠️ Nenhuma entrada encontrada');
      }
    } catch (e) {
      print('❌ Erro ao buscar ano mais antigo em entradas: $e');
    }
    
    // Tabela investimentos
    try {
      final investimentos = await Supabase.instance.client
          .from('investimentos')
          .select('data')
          .eq('user_id', userId)
          .order('data');
      
      if (investimentos.isNotEmpty) {
        final data = DateTime.parse(investimentos.first['data']);
        anos.add(data.year);
        print('📅 Ano mais antigo em investimentos: ${data.year}');
      } else {
        print('⚠️ Nenhum investimento encontrado');
      }
    } catch (e) {
      print('❌ Erro ao buscar ano mais antigo em investimentos: $e');
    }
    
    // Tabela gastos
    try {
      final gastos = await Supabase.instance.client
          .from('gastos')
          .select('data')
          .eq('user_id', userId)
          .order('data');
      
      if (gastos.isNotEmpty) {
        final data = DateTime.parse(gastos.first['data']);
        anos.add(data.year);
        print('📅 Ano mais antigo em gastos: ${data.year}');
      } else {
        print('⚠️ Nenhum gasto encontrado');
      }
    } catch (e) {
      print('❌ Erro ao buscar ano mais antigo em gastos: $e');
    }
    
    print('📊 Anos encontrados: $anos');
    if (anos.isEmpty) {
      print('⚠️ Nenhum ano encontrado, retornando null');
      return null;
    }
    final anoMaisAntigo = anos.reduce((a, b) => a < b ? a : b);
    print('✅ Ano mais antigo final: $anoMaisAntigo');
    return anoMaisAntigo;
  }

  /// Retorna o ano mais recente das transações do usuário
  Future<int?> getAnoMaisRecente() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    print('🔍 Buscando ano mais recente para usuário: $userId');
    
    // Buscar o ano mais recente em todas as tabelas
    List<int> anos = [];
    
    // Tabela entradas
    try {
      final entradas = await Supabase.instance.client
          .from('entradas')
          .select('data')
          .eq('user_id', userId)
          .order('data', ascending: false);
      
      if (entradas.isNotEmpty) {
        final data = DateTime.parse(entradas.first['data']);
        anos.add(data.year);
        print('📅 Ano mais recente em entradas: ${data.year}');
      } else {
        print('⚠️ Nenhuma entrada encontrada');
      }
    } catch (e) {
      print('❌ Erro ao buscar ano mais recente em entradas: $e');
    }
    
    // Tabela investimentos
    try {
      final investimentos = await Supabase.instance.client
          .from('investimentos')
          .select('data')
          .eq('user_id', userId)
          .order('data', ascending: false);
      
      if (investimentos.isNotEmpty) {
        final data = DateTime.parse(investimentos.first['data']);
        anos.add(data.year);
        print('📅 Ano mais recente em investimentos: ${data.year}');
      } else {
        print('⚠️ Nenhum investimento encontrado');
      }
    } catch (e) {
      print('❌ Erro ao buscar ano mais recente em investimentos: $e');
    }
    
    // Tabela gastos
    try {
      final gastos = await Supabase.instance.client
          .from('gastos')
          .select('data')
          .eq('user_id', userId)
          .order('data', ascending: false);
      
      if (gastos.isNotEmpty) {
        final data = DateTime.parse(gastos.first['data']);
        anos.add(data.year);
        print('📅 Ano mais recente em gastos: ${data.year}');
      } else {
        print('⚠️ Nenhum gasto encontrado');
      }
    } catch (e) {
      print('❌ Erro ao buscar ano mais recente em gastos: $e');
    }
    
    print('📊 Anos encontrados: $anos');
    if (anos.isEmpty) {
      print('⚠️ Nenhum ano encontrado, retornando null');
      return null;
    }
    final anoMaisRecente = anos.reduce((a, b) => a > b ? a : b);
    print('✅ Ano mais recente final: $anoMaisRecente');
    return anoMaisRecente;
  }

  /// Soma todas as receitas do ano informado
  Future<double> getReceitaPorAno(int ano) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final inicio = DateTime(ano, 1, 1);
    final fim = DateTime(ano, 12, 31);
    
    // Buscar na tabela entradas
    final dataEntradas = await Supabase.instance.client
        .from('entradas')
        .select('valor')
        .gte('data', inicio.toIso8601String())
        .lte('data', fim.toIso8601String())
        .eq('user_id', userId);
    
    // Buscar na tabela transacoes com tipo receita (caso exista)
    final dataTransacoes = await Supabase.instance.client
        .from('transacoes')
        .select('valor')
        .gte('data', inicio.toIso8601String())
        .lte('data', fim.toIso8601String())
        .eq('tipo', 'receita')
        .eq('user_id', userId);
    
    final listEntradas = dataEntradas as List<dynamic>;
    final listTransacoes = dataTransacoes as List<dynamic>;
    
    double totalEntradas = listEntradas.fold<double>(
      0.0,
      (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
    );
    
    double totalTransacoes = listTransacoes.fold<double>(
      0.0,
      (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
    );
    
    return totalEntradas + totalTransacoes;
  }

  /// Soma todos os investimentos do ano informado
  Future<double> getInvestimentoPorAno(int ano) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final inicio = DateTime(ano, 1, 1);
    final fim = DateTime(ano, 12, 31);
    
    // Buscar na tabela investimentos
    final dataInvestimentos = await Supabase.instance.client
        .from('investimentos')
        .select('valor')
        .gte('data', inicio.toIso8601String())
        .lte('data', fim.toIso8601String())
        .eq('user_id', userId);
    
    // Buscar na tabela transacoes com tipo investimento (caso exista)
    final dataTransacoes = await Supabase.instance.client
        .from('transacoes')
        .select('valor')
        .gte('data', inicio.toIso8601String())
        .lte('data', fim.toIso8601String())
        .eq('tipo', 'investimento')
        .eq('user_id', userId);
    
    final listInvestimentos = dataInvestimentos as List<dynamic>;
    final listTransacoes = dataTransacoes as List<dynamic>;
    
    double totalInvestimentos = listInvestimentos.fold<double>(
      0.0,
      (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
    );
    
    double totalTransacoes = listTransacoes.fold<double>(
      0.0,
      (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
    );
    
    return totalInvestimentos + totalTransacoes;
  }
  /// Retorna o total de receitas para um dia específico
  Future<double> getReceitaPorDia(DateTime dia) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final inicio = DateTime(dia.year, dia.month, dia.day, 0, 0, 0);
    final fim = DateTime(dia.year, dia.month, dia.day, 23, 59, 59);
    
    // Buscar na tabela entradas
    final dataEntradas = await Supabase.instance.client
        .from('entradas')
        .select('valor')
        .gte('data', inicio.toIso8601String())
        .lte('data', fim.toIso8601String())
        .eq('user_id', userId);
    
    // Buscar na tabela transacoes com tipo receita (caso exista)
    final dataTransacoes = await Supabase.instance.client
        .from('transacoes')
        .select('valor')
        .gte('data', inicio.toIso8601String())
        .lte('data', fim.toIso8601String())
        .eq('tipo', 'receita')
        .eq('user_id', userId);
    
    final listEntradas = dataEntradas as List<dynamic>;
    final listTransacoes = dataTransacoes as List<dynamic>;
    
    double totalEntradas = listEntradas.fold<double>(
      0.0,
      (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
    );
    
    double totalTransacoes = listTransacoes.fold<double>(
      0.0,
      (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
    );
    
    return totalEntradas + totalTransacoes;
  }

  /// Retorna o total de investimentos para um dia específico
  Future<double> getInvestimentoPorDia(DateTime dia) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final inicio = DateTime(dia.year, dia.month, dia.day, 0, 0, 0);
    final fim = DateTime(dia.year, dia.month, dia.day, 23, 59, 59);
    
    // Buscar na tabela investimentos
    final dataInvestimentos = await Supabase.instance.client
        .from('investimentos')
        .select('valor')
        .gte('data', inicio.toIso8601String())
        .lte('data', fim.toIso8601String())
        .eq('user_id', userId);
    
    // Buscar na tabela transacoes com tipo investimento (caso exista)
    final dataTransacoes = await Supabase.instance.client
        .from('transacoes')
        .select('valor')
        .gte('data', inicio.toIso8601String())
        .lte('data', fim.toIso8601String())
        .eq('tipo', 'investimento')
        .eq('user_id', userId);
    
    final listInvestimentos = dataInvestimentos as List<dynamic>;
    final listTransacoes = dataTransacoes as List<dynamic>;
    
    double totalInvestimentos = listInvestimentos.fold<double>(
      0.0,
      (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
    );
    
    double totalTransacoes = listTransacoes.fold<double>(
      0.0,
      (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
    );
    
    return totalInvestimentos + totalTransacoes;
  }
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
    
    // Buscar na tabela entradas
    final dataEntradas = await Supabase.instance.client
        .from('entradas')
        .select('valor')
        .gte('data', inicio.toIso8601String())
        .lte('data', fim.toIso8601String())
        .eq('user_id', userId);
    
    // Buscar na tabela transacoes com tipo receita (caso exista)
    final dataTransacoes = await Supabase.instance.client
        .from('transacoes')
        .select('valor')
        .gte('data', inicio.toIso8601String())
        .lte('data', fim.toIso8601String())
        .eq('tipo', 'receita')
        .eq('user_id', userId);
    
    final listEntradas = dataEntradas as List<dynamic>;
    final listTransacoes = dataTransacoes as List<dynamic>;
    
    double totalEntradas = listEntradas.fold<double>(
      0.0,
      (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
    );
    
    double totalTransacoes = listTransacoes.fold<double>(
      0.0,
      (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
    );
    
    return totalEntradas + totalTransacoes;
  }

  Future<double> getInvestimentoPorMes(DateTime referencia) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final inicio = DateTime(referencia.year, referencia.month, 1);
    final fim = DateTime(referencia.year, referencia.month + 1, 0);
    
    // Buscar na tabela investimentos
    final dataInvestimentos = await Supabase.instance.client
        .from('investimentos')
        .select('valor')
        .gte('data', inicio.toIso8601String())
        .lte('data', fim.toIso8601String())
        .eq('user_id', userId);
    
    // Buscar na tabela transacoes com tipo investimento (caso exista)
    final dataTransacoes = await Supabase.instance.client
        .from('transacoes')
        .select('valor')
        .gte('data', inicio.toIso8601String())
        .lte('data', fim.toIso8601String())
        .eq('tipo', 'investimento')
        .eq('user_id', userId);
    
    final listInvestimentos = dataInvestimentos as List<dynamic>;
    final listTransacoes = dataTransacoes as List<dynamic>;
    
    double totalInvestimentos = listInvestimentos.fold<double>(
      0.0,
      (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
    );
    
    double totalTransacoes = listTransacoes.fold<double>(
      0.0,
      (sum, item) => sum + ((item['valor'] ?? 0) as num).toDouble(),
    );
    
    return totalInvestimentos + totalTransacoes;
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
}
