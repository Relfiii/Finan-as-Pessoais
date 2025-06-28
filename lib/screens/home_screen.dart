import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:decimal/decimal.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/recent_transactions.dart';
import '../utils/format_utils.dart';
import '../utils/calculation_utils.dart';

/// Tela principal do aplicativo
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final transactionProvider = context.read<TransactionProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    
    await Future.wait([
      transactionProvider.loadTransactions(),
      categoryProvider.loadCategories(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financeiro'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Consumer<TransactionProvider>(
          builder: (context, transactionProvider, child) {
            if (transactionProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (transactionProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      transactionProvider.error!,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }

            final transactions = transactionProvider.transactions;
            final balance = CalculationUtils.calculateBalance(transactions);
            final income = CalculationUtils.calculateIncome(transactions);
            final expenses = CalculationUtils.calculateExpenses(transactions);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cards de resumo
                  Row(
                    children: [
                      Expanded(
                        child: DashboardCard(
                          title: 'Saldo',
                          value: FormatUtils.formatCurrency(balance),
                          icon: Icons.account_balance_wallet,
                          color: balance >= Decimal.zero 
                              ? Colors.green 
                              : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DashboardCard(
                          title: 'Receitas',
                          value: FormatUtils.formatCurrency(income),
                          icon: Icons.trending_up,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DashboardCard(
                          title: 'Despesas',
                          value: FormatUtils.formatCurrency(expenses),
                          icon: Icons.trending_down,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DashboardCard(
                          title: 'Transações',
                          value: transactions.length.toString(),
                          icon: Icons.receipt_long,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Transações recentes
                  Text(
                    'Transações Recentes',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  const RecentTransactions(),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implementar tela de nova transação
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
