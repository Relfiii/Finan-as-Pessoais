import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provedor/transicaoProvedor.dart';
import '../provedor/categoriaProvedor.dart';
import 'dart:ui';
import 'telaLateral.dart';
import '../caixaTexto/caixaTexto.dart';
import '../cardsPrincipais/cardSaldo.dart';
import '../cardsPrincipais/cardGasto.dart';
import '../cardsPrincipais/cardInvestimento.dart';
import '../provedor/gastoProvedor.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import '../graficos/graficoColunaPrincipal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  // Método para calcular o saldo atual (receitas do mês atual)
  Future<double> _calcularSaldoAtual() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return 0.0;
      
      final agora = DateTime.now();
      final inicioMes = DateTime(agora.year, agora.month, 1);
      final fimMes = DateTime(agora.year, agora.month + 1, 1).subtract(const Duration(days: 1));
      
      final response = await Supabase.instance.client
          .from('entradas')
          .select('valor')
          .eq('user_id', userId)
          .gte('data', inicioMes.toIso8601String())
          .lte('data', fimMes.toIso8601String());
      
      double total = 0.0;
      for (final item in response) {
        total += double.tryParse(item['valor'].toString()) ?? 0.0;
      }
      return total;
    } catch (e) {
      print('Erro ao calcular saldo atual: $e');
      return 0.0;
    }
  }

  // Atualize para buscar dados conforme o filtro selecionado
  Future<void> _loadResumo() async {
    final gastoProvider = context.read<GastoProvider>();
    final transactionProvider = context.read<TransactionProvider>();

    // Calcula o saldo do mês atual, gasto do mês e investimento
    saldoAtual = await _calcularSaldoAtual(); // Receitas do mês atual
    
    gastoMes = gastoProvider.totalGastoMes();
    
    investimento = await transactionProvider.getInvestimentoPorMes(DateTime.now());

    receitasPorMes.clear();
    gastosPorMes.clear();
    investimentosPorMes.clear();
    meses.clear();

    if (_periodoSelecionado == PeriodoFiltro.mes) {
      // Últimos 12 meses
      meses.addAll(getUltimos12Meses());
      for (final mes in meses) {
        receitasPorMes.add(await transactionProvider.getReceitaPorMes(mes));
        gastosPorMes.add(gastoProvider.totalGastoMes(referencia: mes));
        investimentosPorMes.add(await transactionProvider.getInvestimentoPorMes(mes));
      }
    } else if (_periodoSelecionado == PeriodoFiltro.ano) {
      // Agrupar por ano: buscar todos os anos em que o usuário tem dados
      try {
        print('🔍 Iniciando busca de anos com dados...');
        
        int anoMaisAntigo = await transactionProvider.getAnoMaisAntigo() ?? DateTime.now().year;
        int anoMaisRecente = await transactionProvider.getAnoMaisRecente() ?? DateTime.now().year;
        
        print('📅 Ano mais antigo encontrado: $anoMaisAntigo');
        print('📅 Ano mais recente encontrado: $anoMaisRecente');
        
        // Garantir que o range está correto
        if (anoMaisAntigo > anoMaisRecente) {
          anoMaisAntigo = anoMaisRecente;
        }
        
        print('✅ Carregando dados de anos de $anoMaisAntigo até $anoMaisRecente');
        
        for (int ano = anoMaisAntigo; ano <= anoMaisRecente; ano++) {
          final referenciaAno = DateTime(ano, 1, 1);
          meses.add(referenciaAno); // Aqui, cada item representa um ano
          
          print('📊 Processando ano $ano...');
          
          // Buscar totais do ano inteiro
          double totalReceitaAno = await transactionProvider.getReceitaPorAno(ano);
          double totalGastoAno = await gastoProvider.totalGastoAno(ano: ano);
          double totalInvestimentoAno = await transactionProvider.getInvestimentoPorAno(ano);
          
          receitasPorMes.add(totalReceitaAno);
          gastosPorMes.add(totalGastoAno);
          investimentosPorMes.add(totalInvestimentoAno);
          
          print('💰 Ano $ano: Receitas=R\$${totalReceitaAno.toStringAsFixed(2)}, Gastos=R\$${totalGastoAno.toStringAsFixed(2)}, Investimentos=R\$${totalInvestimentoAno.toStringAsFixed(2)}');
        }
        
        print('🎯 Total de anos carregados: ${meses.length}');
      } catch (e) {
        print('❌ Erro ao carregar dados por ano: $e');
        // Em caso de erro, mostrar pelo menos o ano atual
        final anoAtual = DateTime.now().year;
        final referenciaAno = DateTime(anoAtual, 1, 1);
        meses.add(referenciaAno);
        
        double totalReceitaAno = await transactionProvider.getReceitaPorAno(anoAtual);
        double totalGastoAno = await gastoProvider.totalGastoAno(ano: anoAtual);
        double totalInvestimentoAno = await transactionProvider.getInvestimentoPorAno(anoAtual);
        
        receitasPorMes.add(totalReceitaAno);
        gastosPorMes.add(totalGastoAno);
        investimentosPorMes.add(totalInvestimentoAno);
      }
    } else if (_periodoSelecionado == PeriodoFiltro.dia) {
      // Últimos 7 dias
      final agora = DateTime.now();
      for (int i = 6; i >= 0; i--) {
        final dia = DateTime(agora.year, agora.month, agora.day - i);
        meses.add(dia);
        receitasPorMes.add(await transactionProvider.getReceitaPorDia(dia));
        gastosPorMes.add(gastoProvider.totalGastoDia(referencia: dia));
        investimentosPorMes.add(await transactionProvider.getInvestimentoPorDia(dia));
      }
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
                // Botões de filtro de período
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: Text('Mês', style: TextStyle(color: _periodoSelecionado == PeriodoFiltro.mes ? Colors.white : Colors.white70)),
                        selected: _periodoSelecionado == PeriodoFiltro.mes,
                        selectedColor: Color(0xFFB983FF),
                        backgroundColor: Colors.transparent,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _periodoSelecionado = PeriodoFiltro.mes;
                            });
                            _loadResumo();
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text('Ano', style: TextStyle(color: _periodoSelecionado == PeriodoFiltro.ano ? Colors.white : Colors.white70)),
                        selected: _periodoSelecionado == PeriodoFiltro.ano,
                        selectedColor: Color(0xFFB983FF),
                        backgroundColor: Colors.transparent,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _periodoSelecionado = PeriodoFiltro.ano;
                            });
                            _loadResumo();
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text('Dia', style: TextStyle(color: _periodoSelecionado == PeriodoFiltro.dia ? Colors.white : Colors.white70)),
                        selected: _periodoSelecionado == PeriodoFiltro.dia,
                        selectedColor: Color(0xFFB983FF),
                        backgroundColor: Colors.transparent,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _periodoSelecionado = PeriodoFiltro.dia;
                            });
                            _loadResumo();
                          }
                        },
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
                                                        Consumer<TransactionProvider>(
                                                          builder: (context, transactionProvider, _) {
                                                            final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
                                                            return Text(
                                                              formatter.format(saldoAtual),
                                                              style: TextStyle(
                                                                color: const Color.fromARGB(255, 24, 119, 5),
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 16,
                                                              ),
                                                            );
                                                          },
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
                                    enableAutoScroll: true, // Ativar apenas aqui
                                    labels: meses.map((dt) {
                                      if (_periodoSelecionado == PeriodoFiltro.ano) {
                                        return dt.year.toString();
                                      } else if (_periodoSelecionado == PeriodoFiltro.mes) {
                                        return '${dt.year}/${DateFormat('MMM', 'pt_BR').format(dt).toLowerCase()}';
                                      } else {
                                        // Dia
                                        return DateFormat('dd/MM').format(dt);
                                      }
                                    }).toList(),
                                    receitas: receitasPorMes,
                                    despesas: gastosPorMes,
                                    investimentos: investimentosPorMes,
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

List<DateTime> getUltimos12Meses() {
  final agora = DateTime.now();
  return List.generate(12, (i) { // Aumentei para 12 meses para ter mais contexto histórico
    return DateTime(agora.year, agora.month - (11 - i), 1);
  });
}

enum PeriodoFiltro { mes, ano, dia }

