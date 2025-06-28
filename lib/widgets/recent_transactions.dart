import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../models/transaction.dart';
import '../utils/format_utils.dart';

/// Widget para exibir transações recentes
class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, CategoryProvider>(
      builder: (context, transactionProvider, categoryProvider, child) {
        final transactions = transactionProvider.transactions.take(5).toList();
        
        if (transactions.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma transação encontrada',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione sua primeira transação tocando no botão +',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Column(
            children: [
              ...transactions.map((transaction) {
                final category = categoryProvider.getCategoryById(transaction.categoryId);
                return TransactionListItem(
                  transaction: transaction,
                  categoryName: category?.name ?? 'Categoria',
                  categoryColor: category?.color ?? Colors.grey,
                  categoryIcon: category?.icon ?? Icons.category,
                );
              }),
              if (transactionProvider.transactions.length > 5)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navegar para lista completa de transações
                    },
                    child: Text('Ver todas (${transactionProvider.transactions.length})'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Widget para item individual de transação na lista
class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final String categoryName;
  final Color categoryColor;
  final IconData categoryIcon;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    final amountColor = isExpense ? Colors.red : Colors.green;
    final amountPrefix = isExpense ? '-' : '+';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: categoryColor.withValues(alpha: 0.1),
        child: Icon(
          categoryIcon,
          color: categoryColor,
        ),
      ),
      title: Text(
        transaction.description,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '$categoryName • ${FormatUtils.formatDate(transaction.date)}',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: Text(
        '$amountPrefix${FormatUtils.formatCurrency(transaction.amount)}',
        style: TextStyle(
          color: amountColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      onTap: () {
        // TODO: Navegar para detalhes da transação
      },
    );
  }
}
