import 'package:decimal/decimal.dart';
import '../models/transaction.dart';

/// Utilitários para cálculos financeiros
class CalculationUtils {
  /// Calcula o total de transações
  static Decimal calculateTotal(List<Transaction> transactions) {
    return transactions.fold(
      Decimal.zero,
      (total, transaction) => total + transaction.amount,
    );
  }

  /// Calcula o total de receitas
  static Decimal calculateIncome(List<Transaction> transactions) {
    final incomes = transactions.where((t) => t.type == TransactionType.income);
    return calculateTotal(incomes.toList());
  }

  /// Calcula o total de despesas
  static Decimal calculateExpenses(List<Transaction> transactions) {
    final expenses = transactions.where((t) => t.type == TransactionType.expense);
    return calculateTotal(expenses.toList());
  }

  /// Calcula o saldo (receitas - despesas)
  static Decimal calculateBalance(List<Transaction> transactions) {
    final income = calculateIncome(transactions);
    final expenses = calculateExpenses(transactions);
    return income - expenses;
  }

  /// Calcula o total por categoria
  static Map<String, Decimal> calculateTotalByCategory(
    List<Transaction> transactions,
  ) {
    final Map<String, Decimal> totals = {};

    for (final transaction in transactions) {
      final categoryId = transaction.categoryId;
      totals[categoryId] = (totals[categoryId] ?? Decimal.zero) + transaction.amount;
    }

    return totals;
  }

  /// Calcula porcentagem de uso do orçamento
  static double calculateBudgetUsagePercentage(
    Decimal spent,
    Decimal budget,
  ) {
    if (budget == Decimal.zero) return 0.0;
    final percentage = (spent / budget).toDouble() * 100;
    return percentage;
  }

  /// Calcula média de gastos por dia
  static Decimal calculateDailyAverage(
    List<Transaction> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    if (transactions.isEmpty) return Decimal.zero;

    final total = calculateExpenses(transactions);
    final days = endDate.difference(startDate).inDays + 1;
    
    return Decimal.parse((total.toDouble() / days).toString());
  }

  /// Calcula crescimento percentual entre dois períodos
  static double calculateGrowthPercentage(Decimal previous, Decimal current) {
    if (previous == Decimal.zero) {
      return current > Decimal.zero ? 100.0 : 0.0;
    }
    
    final growth = ((current - previous) / previous).toDouble() * 100;
    return growth;
  }

  /// Filtra transações por período
  static List<Transaction> filterByDateRange(
    List<Transaction> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    return transactions.where((transaction) {
      return transaction.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             transaction.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Agrupa transações por data
  static Map<DateTime, List<Transaction>> groupByDate(
    List<Transaction> transactions,
  ) {
    final Map<DateTime, List<Transaction>> grouped = {};

    for (final transaction in transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      grouped[date] ??= [];
      grouped[date]!.add(transaction);
    }

    return grouped;
  }

  /// Agrupa transações por mês
  static Map<DateTime, List<Transaction>> groupByMonth(
    List<Transaction> transactions,
  ) {
    final Map<DateTime, List<Transaction>> grouped = {};

    for (final transaction in transactions) {
      final monthKey = DateTime(transaction.date.year, transaction.date.month);

      grouped[monthKey] ??= [];
      grouped[monthKey]!.add(transaction);
    }

    return grouped;
  }
}
