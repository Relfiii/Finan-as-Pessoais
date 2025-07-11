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
import '../l10n/app_localizations.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import '../cardsPrincipais/cardInvestimento.dart';
import '../graficos/graficoColunaPrincipal.dart';
import '../graficos/graficoRoscaPrincipal.dart';

/// Tela principal do aplicativo
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _firstBuild = true;
  double saldoAtual = 0.0;
  double gastoMes = 0.0;
  double investimento = 0.0;
  PeriodoFiltro _periodoSelecionado = PeriodoFiltro.mes;

  // Adicione estas linhas:
  List<double> receitasPorMes = [];
  List<double> gastosPorMes = [];
  List<double> investimentosPorMes = [];
  List<DateTime> meses = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_firstBuild) {
      _firstBuild = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadData();
      });
    }
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

  // Atualize para receber o período
  Future<void> _loadResumo() async {
    final gastoProvider = context.read<GastoProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    final meses = getUltimos6Meses();

    receitasPorMes.clear();
    gastosPorMes.clear();
    investimentosPorMes.clear();

    for (final mes in meses) {
      receitasPorMes.add(await transactionProvider.getReceitaPorMes(mes));
      gastosPorMes.add(gastoProvider.totalGastoMes(referencia: mes));
      investimentosPorMes.add(await transactionProvider.getInvestimentoPorMes(mes));
    }

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: TelaLateral(),
      body: Stack(
        children: [
          // Fundo gradiente com desfoque (igual à tela de configurações)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E1E2C), Color(0xFF121212)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // AppBar customizada (igual à tela de configurações)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu, color: Color(0xFFB983FF)),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                          tooltip: 'Abrir menu',
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 250),
                        child: !caixaTextoOverlay.isExpanded(context)
                            ? const Text(
                                "NossoDinDin",
                                key: ValueKey('title'),
                                style: TextStyle(
                                  color: Color(0xFFB983FF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  letterSpacing: 1.1,
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
                            caixaTextoOverlay.show(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 250),
                        child: !caixaTextoOverlay.isExpanded(context)
                            ? IconButton(
                                key: ValueKey('notif'),
                                icon: const Icon(Icons.notifications_none, color: Color(0xFFB983FF)),
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
                  ),
                ),
                const Divider(color: Colors.white24, thickness: 1, indent: 24, endIndent: 24),
                // Filtro de período no topo
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                  child: Row(
                    children: [
                      ToggleButtons(
                        borderRadius: BorderRadius.circular(8),
                        fillColor: Color(0xFFB983FF).withOpacity(0.15),
                        selectedColor: Color(0xFFB983FF),
                        color: Colors.white70,
                        isSelected: [
                          _periodoSelecionado == PeriodoFiltro.mes,
                          _periodoSelecionado == PeriodoFiltro.ano,
                          _periodoSelecionado == PeriodoFiltro.dia,
                        ],
                        onPressed: (i) {
                          setState(() {
                            _periodoSelecionado = PeriodoFiltro.values[i];
                          });
                          _loadResumo(); // Atualiza tudo ao trocar o filtro
                        },
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('Por meses'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('Por anos'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('Por dias'),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Mostra o período selecionado
                      Text(
                        _periodoSelecionado == PeriodoFiltro.mes
                            ? DateFormat("MMMM yyyy", localizations.localeName).format(DateTime.now()).capitalize()
                            : _periodoSelecionado == PeriodoFiltro.ano
                                ? DateFormat("yyyy").format(DateTime.now())
                                : DateFormat("dd/MM/yyyy").format(DateTime.now()),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                // Conteúdo rolável (mantém o conteúdo original)
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData, // Chama a função de atualizar
                    child: Consumer<TransactionProvider>(
                      builder: (context, transactionProvider, child) {
                        if (transactionProvider.isLoading) {
                          return Center(child: CircularProgressIndicator());
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
                                  child: Text(localizations.tentarNovamente),
                                ),
                              ],
                            ),
                          );
                        }

                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(), // Permite o pull-to-refresh mesmo sem scroll
                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                            child: GestureDetector(
                                              onTap: () async {
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => ControleReceitasPage()),
                                                  );
                                                  await _loadResumo(); // Atualiza o saldo ao voltar
                                                },
                                              child: Container(
                                                margin: const EdgeInsets.all(3),
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [Color(0xFF2A2D3E), Color(0xFF1C1F2A)],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  borderRadius: BorderRadius.circular(16),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.5),
                                                      offset: Offset(4, 4),
                                                      blurRadius: 8,
                                                    ),
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.2),
                                                      offset: Offset(-4, -4),
                                                      blurRadius: 8,
                                                    ),
                                                  ],
                                                ),
                                                constraints: const BoxConstraints(
                                                  minHeight: 100,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(height: 0),
                                                    Text(
                                                      localizations.saldoAtual,
                                                      style: const TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                      softWrap: true,
                                                      overflow: TextOverflow.visible,
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          toCurrencyString(
                                                            saldoAtual.toString(),
                                                            leadingSymbol: 'R\$',
                                                            useSymbolPadding: true,
                                                            thousandSeparator: ThousandSeparator.Period,
                                                          ),
                                                          style: TextStyle(
                                                            color: const Color.fromARGB(
                                                                255, 24, 119, 5),
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons.account_balance_wallet,
                                                          color: const Color.fromARGB(255, 24, 119, 5),
                                                          size: 28,
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
                                              onTap: () async {
                                                await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => CardGasto()),
                                                );
                                                await _loadResumo();
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.all(3),
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [Color(0xFF3A1C1C), Color(0xFF2A1A1A)],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  borderRadius: BorderRadius.circular(16),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.5),
                                                      offset: Offset(4, 4),
                                                      blurRadius: 8,
                                                    ),
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.2),
                                                      offset: Offset(-4, -4),
                                                      blurRadius: 8,
                                                    ),
                                                  ],
                                                ),
                                                constraints: const BoxConstraints(
                                                  minHeight: 100,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(height: 0),
                                                    Text(
                                                      localizations.gastoNoMes,
                                                      style: const TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                      softWrap: true,
                                                      overflow: TextOverflow.visible,
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Consumer<GastoProvider>(
                                                          builder: (context, gastoProvider, _) {
                                                            final totalGasto = gastoProvider.totalGastoMes();
                                                            final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
                                                            return Text(
                                                              formatter.format(totalGasto),
                                                              style: TextStyle(
                                                                color: const Color.fromARGB(255, 151, 53, 53),
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 16,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                        Icon(
                                                          Icons.trending_down,
                                                          color: const Color.fromARGB(255, 151, 53, 53),
                                                          size: 28,
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
                                      onTap: () async {
                                                await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => ControleInvestimentosPage()),
                                                );
                                                await _loadResumo(); // Atualiza o valor ao voltar
                                              },
                                      child: Container(
                                        margin: const EdgeInsets.all(3),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Color(0xFF1C2A3A), Color(0xFF1A2A2F)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.5),
                                              offset: Offset(4, 4),
                                              blurRadius: 8,
                                            ),
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              offset: Offset(-4, -4),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                        constraints: const BoxConstraints(
                                          minHeight: 100,
                                        ),
                                        width: double.infinity,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 0),
                                            Text(
                                              localizations.investimentos,
                                              style: const TextStyle(
                                                  color: Colors.white70, fontSize: 16),
                                              softWrap: true,
                                              overflow: TextOverflow.visible,
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                FutureBuilder<double>(
                                                  future: InvestimentoUtils.buscarTotalInvestimentos(),
                                                  builder: (context, snapshot) {
                                                    final valor = snapshot.data ?? 0.0;
                                                    return Text(
                                                      toCurrencyString(
                                                        valor.toString(),
                                                        leadingSymbol: 'R\$',
                                                        useSymbolPadding: true,
                                                        thousandSeparator: ThousandSeparator.Period,
                                                      ),
                                                      style: TextStyle(
                                                        color: const Color.fromARGB(255, 15, 157, 240),
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 20,
                                                      ),
                                                    );
                                                  },
                                                ),
                                                Icon(
                                                  Icons.trending_up,
                                                  color: const Color.fromARGB(255, 15, 157, 240),
                                                  size: 28,
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
                              // Gráfico de visão geral financeira (colunas)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                child: Container(
                                  height: 300,
                                  child: GraficoColunaPrincipal(
                                    saldoAtual: saldoAtual,
                                    totalGastoMes: gastoMes,
                                    investimento: investimento,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Gráfico de rosca logo abaixo
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                              //   child: Container(
                              //     height: 220,
                              //     child: GraficoRoscaPrincipal(
                              //       saldoAtual: saldoAtual,
                              //       totalGastoMes: gastoMes,
                              //       investimento: investimento,
                              //     ),
                              //   ),
                              // ),
                              // const SizedBox(height: 24),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Overlay da caixa de texto expandida
          CaixaTextoOverlay(),
        ],
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
          child: !caixaTextoOverlay.isExpanded(context)
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
              caixaTextoOverlay.show(context);
            },
          ),
        ),
        const SizedBox(width: 8),
        // Botão de notificação
        AnimatedSwitcher(
          duration: Duration(milliseconds: 250),
          child: !caixaTextoOverlay.isExpanded(context)
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
  final GlobalKey<_CaixaTextoOverlayState> _key = GlobalKey();

  CaixaTextoOverlay({Key? key}) : super(key: key);

  void show(BuildContext context) {
    _key.currentState?.expand();
  }

  bool isExpanded(BuildContext context) {
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

final CaixaTextoOverlay caixaTextoOverlay = CaixaTextoOverlay();

extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

List<DateTime> getUltimos6Meses() {
  final agora = DateTime.now();
  return List.generate(6, (i) {
    return DateTime(agora.year, agora.month - (5 - i), 1);
  });
}

enum PeriodoFiltro { mes, ano, dia }

