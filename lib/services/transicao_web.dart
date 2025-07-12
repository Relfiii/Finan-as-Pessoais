import '../modelos/transicao.dart';

/// Serviço para operações CRUD com transações (versão web)
class TransactionServiceWeb {
  /// Busca todas as transações
  static Future<List<Transaction>> getAll() async {
    // Na web, usa apenas Supabase - implementar conforme necessário
    return [];
  }

  /// Busca transações por período
  static Future<List<Transaction>> getByDateRange(DateTime start, DateTime end) async {
    // Na web, usa apenas Supabase - implementar conforme necessário
    return [];
  }

  /// Busca transações por categoria
  static Future<List<Transaction>> getByCategory(String categoryId) async {
    // Na web, usa apenas Supabase - implementar conforme necessário
    return [];
  }

  /// Busca transações por tipo
  static Future<List<Transaction>> getByType(TransactionType type) async {
    // Na web, usa apenas Supabase - implementar conforme necessário
    return [];
  }

  /// Busca uma transação por ID
  static Future<Transaction?> getById(String id) async {
    // Na web, usa apenas Supabase - implementar conforme necessário
    return null;
  }

  /// Insere uma nova transação
  static Future<void> insert(Transaction transaction) async {
    // Na web, usa apenas Supabase - implementar conforme necessário
  }

  /// Atualiza uma transação existente
  static Future<void> update(Transaction transaction) async {
    // Na web, usa apenas Supabase - implementar conforme necessário
  }

  /// Exclui uma transação
  static Future<void> delete(String id) async {
    // Na web, usa apenas Supabase - implementar conforme necessário
  }

  /// Busca receitas do mês
  static Future<List<Map<String, dynamic>>> getReceitasMes(int ano, int mes) async {
    // Na web, usa apenas Supabase - implementar conforme necessário
    return [];
  }

  /// Busca investimentos do mês
  static Future<List<Map<String, dynamic>>> getInvestimentosMes(int ano, int mes) async {
    // Na web, usa apenas Supabase - implementar conforme necessário
    return [];
  }

  /// Busca transações com dados da categoria
  static Future<List<Map<String, dynamic>>> getTransactionsWithCategory() async {
    // Na web, usa apenas Supabase - implementar conforme necessário
    return [];
  }

  /// Busca resumo de transações por categoria em um período
  static Future<List<Map<String, dynamic>>> getCategorySummary(
    DateTime start, 
    DateTime end,
    TransactionType? type,
  ) async {
    // Na web, usa apenas Supabase - implementar conforme necessário
    return [];
  }
}
