import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provedor/transicaoProvedor.dart';
import '../provedor/categoriaProvedor.dart';
import 'dart:ui';
import '../widgets/topBarComCaixaTexto.dart';
import '../cardsPrincipais/cardSaldo.dart';
import '../cardsPrincipais/cardGasto.dart';
import '../provedor/gastoProvedor.dart';
import 'package:intl/intl.dart';

/// Tela principal do aplicativo
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double saldoAtual = 0.0;
  double gastoMes = 0.0;
  double investimento = 0.0;

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
    _loadResumo();
  }

  Future<void> _loadResumo() async {
    final transactionProvider = context.read<TransactionProvider>();
    saldoAtual = await transactionProvider.getSaldoAtual();
    gastoMes = await transactionProvider.getGastoMesAtual();
    investimento = await transactionProvider.getInvestimento();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // TOPO FIXO
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8, right: 16, top: 16, bottom: 0),
                    child: TopBarComCaixaTexto(),
                  ),
                  // CONTEÚDO ROLÁVEL
                  Expanded(
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

                        return SingleChildScrollView(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Mês/Ano
                              Padding(
                                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                                child: Text(
                                  DateFormat("MMMM yyyy", "pt_BR").format(DateTime.now()).capitalize(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              // Cards de resumo
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                child: Column(
                                  children: [
                                    IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          // Saldo atual
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => CardSaldo()),
                                                );
                                              },
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
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(height: 0),
                                                    Text(
                                                      "Saldo atual",
                                                      style: TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 16),
                                                      softWrap: true,
                                                      overflow: TextOverflow.visible,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          "R\$ ${saldoAtual.toStringAsFixed(2).replaceAll('.', ',')}",
                                                          style: TextStyle(
                                                            color: const Color.fromARGB(
                                                                255, 24, 119, 5),
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Gasto total no mês
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => CardGasto()),
                                                );
                                              },
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
                                                      style: TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 16),
                                                      softWrap: true,
                                                      overflow: TextOverflow.visible,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Consumer<GastoProvider>(
                                                          builder: (context, gastoProvider, _) {
                                                            final totalGasto = gastoProvider.totalGastoMes();
                                                            return Text(
                                                              "R\$ ${totalGasto.toStringAsFixed(2).replaceAll('.', ',')}",
                                                              style: TextStyle(
                                                                color: const Color.fromARGB(255, 151, 53, 53),
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 16,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Card de Investimentos abaixo
                                    GestureDetector(
                                      onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => CardGasto()),
                                                );
                                              },
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
                                        width: double.infinity,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 0),
                                            Text(
                                              "Investimentos",
                                              style: TextStyle(
                                                  color: Colors.white70, fontSize: 16),
                                              softWrap: true,
                                              overflow: TextOverflow.visible,
                                            ),
                                            const SizedBox(height: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "R\$ ${investimento.toStringAsFixed(2).replaceAll('.', ',')}",
                                                  style: TextStyle(
                                                    color: const Color.fromARGB(
                                                        255, 15, 157, 240),
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
                              const SizedBox(height: 24),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              // Overlay da caixa de texto expandida
              CaixaTextoOverlay(),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}