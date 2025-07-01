import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:decimal/decimal.dart';
import '../provedor/transicaoProvedor.dart';
import '../provedor/categoriaProvedor.dart';
import '../modelos/categoria.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/trsacoesRecente.dart';
import '../utils/formatarUtils.dart';
import '../utils/calculoUtils.dart';
import '../telaLogin.dart';
import 'dart:ui';
import 'criarCategoria.dart';
import 'criarGasto.dart';
import 'telaLateral.dart';

/// Tela principal do aplicativo
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      body: SafeArea(
        child: RefreshIndicator(
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
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        transactionProvider.error!,
                        style: theme.textTheme.bodyLarge,
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
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top bar - Apenas o título e botão menu
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 16, top: 16, bottom: 0),
                      child: Row(
                        children: [
                          Builder(
                            builder: (context) => IconButton(
                              icon: Icon(Icons.menu, color: Color(0xFFB983FF)),
                              onPressed: () {
                                abrirMenuLateral(context); // Chama o menu lateral com desfoque
                              },
                              tooltip: 'Abrir menu',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "NossoDinDin",
                            style: TextStyle(
                              color: Color(0xFFB983FF),
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          // Spacer para empurrar o botão de sair para o fim da linha
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.logout, color: Colors.white),
                            onPressed: () {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TelaLogin(),
                                  ),
                                );
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    // Caixa de texto e botões
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Caixa de texto
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF23272F),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Digite para criar categorias ou adicionar gastos ...",
                                hintStyle: TextStyle(color: Colors.white54),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.help_outline, color: Colors.white54, size: 20),
                                  tooltip: 'Como usar IA e comandos',
                                  onPressed: () {
                                    showGeneralDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      barrierLabel: "Ajuda IA",
                                      barrierColor: Colors.black.withOpacity(0.3),
                                      transitionDuration: const Duration(milliseconds: 200),
                                      pageBuilder: (context, anim1, anim2) {
                                        return BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                          child: Center(
                                            child: AlertDialog(
                                              backgroundColor: const Color(0xFF23272F),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              content: SingleChildScrollView(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: const [
                                                        Text(
                                                          "🧠 IA Inteligente:",
                                                          style: TextStyle(
                                                            color: Color(0xFFFF6EC7),
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      '• "Comprei carne 25.90" → 🛒 Mercado\n'
                                                      '• "Comprei pizza 35" → 🍽️ Restaurante\n'
                                                      '• "Comprei refrigerante 5.50" → ❓ Opções\n'
                                                      '• "Gastei 50 no mercado"\n'
                                                      '• "Uber custou 18"',
                                                      style: TextStyle(color: Colors.white, fontSize: 14),
                                                    ),
                                                    Divider(color: Colors.white24, height: 24),
                                                    Row(
                                                      children: const [
                                                        Text(
                                                          "🟦 Criar Categorias:",
                                                          style: TextStyle(
                                                            color: Color(0xFF00E0C6),
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 6),
                                                    Text(
                                                      '• "Criar categoria Pets"\n'
                                                      '• "Nova categoria Academia"',
                                                      style: TextStyle(color: Colors.white, fontSize: 14),
                                                    ),
                                                    SizedBox(height: 12),
                                                    Row(
                                                      children: const [
                                                        Text(
                                                          "🟥 Deletar Categoria:",
                                                          style: TextStyle(
                                                            color: Color(0xFFFFB300),
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 6),
                                                    Text(
                                                      '• "Deletar categoria Pets"\n'
                                                      '• "Remover categoria Academia"',
                                                      style: TextStyle(color: Colors.white, fontSize: 14),
                                                    ),
                                                    SizedBox(height: 12),
                                                    Row(
                                                      children: const [
                                                        Icon(Icons.info_outline, color: Color(0xFFFF6EC7), size: 18),
                                                        SizedBox(width: 4),
                                                        Expanded(
                                                          child: Text(
                                                            "A IA diferencia ingredientes de comida pronta!",
                                                            style: TextStyle(
                                                              color: Color(0xFFFF6EC7),
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 8),
                                                    Row(
                                                      children: const [
                                                        Icon(Icons.warning_amber_rounded, color: Color(0xFFFFB300), size: 18),
                                                        SizedBox(width: 4),
                                                        Expanded(
                                                          child: Text(
                                                            "Quando ambíguo, você escolhe a categoria!",
                                                            style: TextStyle(
                                                              color: Color(0xFFFFB300),
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: const Text('Fechar', style: TextStyle(color: Color(0xFFB983FF))),
                                                  onPressed: () => Navigator.of(context).pop(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Mês/Ano
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                      child: Text(
                        "Junho 2025",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                    ),
                    // Cards de resumo
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      child: Column(
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Saldo atual
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.all(3),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF23272F),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    constraints: const BoxConstraints(
                                      minHeight: 80,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 0),
                                        Text(
                                          "Saldo atual",
                                          style: TextStyle(color: Colors.white70, fontSize: 16),
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                        ),
                                        const SizedBox(height: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "R\$ 100.000.000,00",
                                              style: TextStyle(
                                                color: const Color.fromARGB(255, 24, 119, 5),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Gasto total no mês
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.all(3),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF23272F),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    constraints: const BoxConstraints(
                                      minHeight: 80,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 0),
                                        Text(
                                          "Gasto no mês",
                                          style: TextStyle(color: Colors.white70, fontSize: 16),
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                        ),
                                        const SizedBox(height: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "R\$ 100.000.000,00",
                                              style: TextStyle(
                                                color: const Color.fromARGB(255, 151, 53, 53),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Card de Investimentos abaixo
                          Container(
                            margin: const EdgeInsets.all(3),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(0xFF23272F),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            constraints: const BoxConstraints(
                              minHeight: 80,
                            ),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 0),
                                Text(
                                  "Investimentos",
                                  style: TextStyle(color: Colors.white70, fontSize: 16),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                                const SizedBox(height: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "R\$ 1.000.000.000,00",
                                      style: TextStyle(
                                        color: const Color.fromARGB(255, 15, 157, 240),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Lista de categorias em cards
                    Consumer<CategoryProvider>(
                      builder: (context, categoryProvider, child) {
                        final categories = categoryProvider.categories;
                        if (categories.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              'Nenhuma categoria cadastrada.',
                              style: TextStyle(color: Colors.white54, fontSize: 16),
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Responsivo: 4 colunas em telas largas, 2 em telas pequenas
                              int crossAxisCount = constraints.maxWidth > 900
                                  ? 4
                                  : constraints.maxWidth > 600
                                      ? 3
                                      : 2;
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.6,
                                ),
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  final cat = categories[index];
                                  // TODO: Buscar valor real da categoria e total do mês
                                  final valor = 'R\$ 0,00';
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF232323),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(18),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              cat.name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          valor,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}