import 'package:NossoDinDin/cardsPrincipais/cardInvestimento.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provedor/transicaoProvedor.dart';
import '../provedor/categoriaProvedor.dart';
import 'dart:ui';
import 'telaLateral.dart';
import '../caixaTexto/caixaTexto.dart';
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
    final gastoProvider = context.read<GastoProvider>();

    await Future.wait([
      transactionProvider.loadTransactions(),
      categoryProvider.loadCategories(),
      gastoProvider.loadGastos(),
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
    // O nome do usuário agora é obtido via Provider dentro de TelaLateral
    return Scaffold(
      drawer: TelaLateral(),
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
                    child: _TopBarWithCaixaTexto(),
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
                                                  MaterialPageRoute(builder: (context) => CardInvestimento()),
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

/// TopBar customizada com CaixaTextoWidget como botão central
class _TopBarWithCaixaTexto extends StatefulWidget {
  @override
  State<_TopBarWithCaixaTexto> createState() => _TopBarWithCaixaTextoState();
}

class _TopBarWithCaixaTextoState extends State<_TopBarWithCaixaTexto> {
  void abrirMenuLateral(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Color(0xFFB983FF)),
            onPressed: () {
              abrirMenuLateral(context);
            },
            tooltip: 'Abrir menu',
          ),
        ),
        const SizedBox(width: 8),
        // Título
        AnimatedSwitcher(
          duration: Duration(milliseconds: 250),
          child: !CaixaTextoOverlay.isExpanded(context)
              ? Text(
                  "NossoDinDin",
                  key: ValueKey('title'),
                  style: TextStyle(
                    color: Color(0xFFB983FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                )
              : SizedBox(width: 120),
        ),
        const SizedBox(width: 8),
        // CaixaTextoWidget como botão
        Expanded(
          child: CaixaTextoWidget(
            asButton: true,
            onExpand: () {
              CaixaTextoOverlay.show(context);
            },
          ),
        ),
        const SizedBox(width: 8),
        // Botão de notificação
        AnimatedSwitcher(
          duration: Duration(milliseconds: 250),
          child: !CaixaTextoOverlay.isExpanded(context)
              ? IconButton(
                  key: ValueKey('notif'),
                  icon: Icon(Icons.notifications_none, color: Color(0xFFB983FF)),
                  tooltip: 'Notificações',
                  onPressed: () {
                    showGeneralDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel: "Notificações",
                      barrierColor: Colors.black.withOpacity(0.3),
                      transitionDuration: const Duration(milliseconds: 200),
                      pageBuilder: (context, anim1, anim2) {
                        return BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Center(
                            child: AlertDialog(
                              backgroundColor: const Color(0xFF181818),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              title: Row(
                                children: const [
                                  Icon(Icons.notifications, color: Color(0xFFB983FF)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Notificações',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              content: const Text(
                                'Nenhuma notificação no momento.',
                                style: TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Fechar',
                                      style: TextStyle(color: Colors.white70)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              : SizedBox(width: 48),
        ),
      ],
    );
  }
}

/// Overlay global para caixa de texto expandida
class CaixaTextoOverlay extends StatefulWidget {
  static final GlobalKey<_CaixaTextoOverlayState> _key = GlobalKey();
  CaixaTextoOverlay({Key? key}) : super(key: _key);

  static void show(BuildContext context) {
    _key.currentState?.expand();
  }

  static bool isExpanded(BuildContext context) {
    return _key.currentState?.expanded ?? false;
  }

  @override
  State<CaixaTextoOverlay> createState() => _CaixaTextoOverlayState();
}

class _CaixaTextoOverlayState extends State<CaixaTextoOverlay> {
  bool expanded = false;
  void expand() => setState(() => expanded = true);
  void collapse() => setState(() => expanded = false);

  @override
  Widget build(BuildContext context) {
    if (!expanded) return SizedBox.shrink();
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.45),
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.95,
            child: CaixaTextoWidget(
              asButton: false,
              autofocus: true,
              onCollapse: () => setState(() => expanded = false),
            ),
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