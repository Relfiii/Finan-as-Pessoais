import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../provedor/transicaoProvedor.dart';
import '../provedor/categoriaProvedor.dart';
import 'dart:ui';
import 'dart:async';
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
  DateTime _currentDate = DateTime.now();

  // Timer para debounce na navegação
  Timer? _debounceTimer;

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
    
    // Limpar cache antes de recarregar dados (força atualização)
    transactionProvider.clearCache();
    gastoProvider.clearCache();
    
    await Future.wait([
      transactionProvider.loadTransactions(),
      categoryProvider.loadCategories(),
      gastoProvider.loadGastos(),
    ]);
    
    // Chama _loadResumo() após carregar os dados
    await _loadResumo();
  }

  // Método para calcular o saldo atual (receitas do mês atual)
  Future<double> _calcularSaldoAtual() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return 0.0;
      
      final inicioMes = DateTime(_currentDate.year, _currentDate.month, 1);
      final fimMes = DateTime(_currentDate.year, _currentDate.month + 1, 1).subtract(const Duration(days: 1));
      
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
    saldoAtual = await _calcularSaldoAtual(); // Receitas do mês selecionado
    
    gastoMes = gastoProvider.totalGastoMes(referencia: _currentDate);
    
    investimento = await transactionProvider.getInvestimentoPorMes(_currentDate);

    receitasPorMes.clear();
    gastosPorMes.clear();
    investimentosPorMes.clear();
    meses.clear();

    if (_periodoSelecionado == PeriodoFiltro.mes) {
      // Últimos 12 meses
      meses.addAll(getUltimos12Meses(_currentDate));
      for (final mes in meses) {
        receitasPorMes.add(await transactionProvider.getReceitaPorMes(mes));
        gastosPorMes.add(gastoProvider.totalGastoMes(referencia: mes));
        investimentosPorMes.add(await transactionProvider.getInvestimentoPorMes(mes));
      }
    } else if (_periodoSelecionado == PeriodoFiltro.ano) {
      // Buscar todos os anos distintos que possuem valores em receitas, gastos ou investimentos
      try {
        // Buscar anos distintos em cada tabela
        final anosReceitas = await transactionProvider.getAnosComReceita();
        final anosGastos = await gastoProvider.getAnosComGasto();
        final anosInvestimentos = await transactionProvider.getAnosComInvestimento();

        // Unificar e ordenar os anos
        final Set<int> anos = {...anosReceitas, ...anosGastos, ...anosInvestimentos};
        final List<int> anosOrdenados = anos.toList()..sort();

        for (final ano in anosOrdenados) {
          final referenciaAno = DateTime(ano, 1, 1);
          meses.add(referenciaAno);

          double totalReceitaAno = await transactionProvider.getReceitaPorAno(ano);
          double totalGastoAno = await gastoProvider.totalGastoAno(ano: ano);
          double totalInvestimentoAno = await transactionProvider.getInvestimentoPorAno(ano);

          receitasPorMes.add(totalReceitaAno);
          gastosPorMes.add(totalGastoAno);
          investimentosPorMes.add(totalInvestimentoAno);
        }

        // Se não houver nenhum ano, mostrar pelo menos o ano atual
        if (anosOrdenados.isEmpty) {
          final anoAtual = DateTime.now().year;
          final referenciaAno = DateTime(anoAtual, 1, 1);
          meses.add(referenciaAno);
          receitasPorMes.add(await transactionProvider.getReceitaPorAno(anoAtual));
          gastosPorMes.add(await gastoProvider.totalGastoAno(ano: anoAtual));
          investimentosPorMes.add(await transactionProvider.getInvestimentoPorAno(anoAtual));
        }
      } catch (e) {
        // Em caso de erro, mostrar pelo menos o ano atual
        final anoAtual = _currentDate.year;
        final referenciaAno = DateTime(anoAtual, 1, 1);
        meses.add(referenciaAno);
        receitasPorMes.add(await transactionProvider.getReceitaPorAno(anoAtual));
        gastosPorMes.add(await gastoProvider.totalGastoAno(ano: anoAtual));
        investimentosPorMes.add(await transactionProvider.getInvestimentoPorAno(anoAtual));
      }
    } else if (_periodoSelecionado == PeriodoFiltro.dia) {
      // 30 dias anteriores + dia atual + 1 dia posterior baseado na data selecionada
      
      // Gerar sequência de 32 dias baseado na data selecionada
      for (int i = -30; i <= 1; i++) {
        final dataAtual = DateTime(_currentDate.year, _currentDate.month, _currentDate.day + i);
        meses.add(dataAtual);
        
        // Buscar dados para cada dia
        double receitaDia = await transactionProvider.getReceitaPorDia(dataAtual);
        double gastoDia = gastoProvider.totalGastoDia(referencia: dataAtual);
        double investimentoDia = await transactionProvider.getInvestimentoPorDia(dataAtual);
        
        receitasPorMes.add(receitaDia);
        gastosPorMes.add(gastoDia);
        investimentosPorMes.add(investimentoDia);
      }
    }

    setState(() {});
  }

  // Método para navegar para o próximo período com debounce
  void _nextPeriod() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        if (_periodoSelecionado == PeriodoFiltro.mes) {
          _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
        } else if (_periodoSelecionado == PeriodoFiltro.ano) {
          _currentDate = DateTime(_currentDate.year + 1, _currentDate.month);
        } else if (_periodoSelecionado == PeriodoFiltro.dia) {
          _currentDate = _currentDate.add(const Duration(days: 1));
        }
      });
      _loadResumo();
    });
  }

  // Método para navegar para o período anterior com debounce
  void _previousPeriod() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        if (_periodoSelecionado == PeriodoFiltro.mes) {
          _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
        } else if (_periodoSelecionado == PeriodoFiltro.ano) {
          _currentDate = DateTime(_currentDate.year - 1, _currentDate.month);
        } else if (_periodoSelecionado == PeriodoFiltro.dia) {
          _currentDate = _currentDate.subtract(const Duration(days: 1));
        }
      });
      _loadResumo();
    });
  }

  // Método para formatar a data conforme o filtro selecionado
    String _formatCurrentDate() {
      if (_periodoSelecionado == PeriodoFiltro.mes) {
        // Mostra o mês por extenso e os dois últimos dígitos do ano
        final ano2d = _currentDate.year.toString().substring(2);
        return '${_capitalizeMonth(DateFormat('MMMM', 'pt_BR').format(_currentDate))} $ano2d';
      } else if (_periodoSelecionado == PeriodoFiltro.ano) {
        // Mostra só os dois últimos dígitos do ano
        return _currentDate.year.toString();
      } else if (_periodoSelecionado == PeriodoFiltro.dia) {
        return DateFormat('dd/MM/yyyy').format(_currentDate);
      }
      return '';
    }

  // Método para capitalizar o mês
  String _capitalizeMonth(String month) {
    if (month.isEmpty) return month;
    return month[0].toUpperCase() + month.substring(1);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
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
          // Fundo com cor sólida da paleta
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF121212), // Fundo da paleta
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
                          icon: const Icon(Icons.menu, color: Color(0xFFB388FF)), // Cor dos acentos
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
                                  color: Color(0xFFB388FF), // Cor dos acentos
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  letterSpacing: 1.1,
                                ),
                              )
                            : SizedBox(width: 120),
                      ),
                      const SizedBox(width: 8),
                      // CaixaTextoWidget como botão
                      // Expanded(
                      //   child: CaixaTextoWidget(
                      //     asButton: true,
                      //     onExpand: () {
                      //       caixaTextoOverlay.show(context);
                      //     },
                      //   ),
                      // ),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 250),
                        child: !caixaTextoOverlay.isExpanded(context)
                            ? IconButton(
                                key: ValueKey('notif'),
                                icon: const Icon(Icons.notifications_none, color: Color(0xFFB388FF)), // Cor dos acentos
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
                                            backgroundColor: const Color(0xFF1E1E1E), // Cor de fundo mais clara
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12)),
                                            title: const Row(
                                              children: [
                                                Icon(Icons.notifications, color: Color(0xFFB388FF)), // Cor dos acentos
                                                SizedBox(width: 8),
                                                Text(
                                                  'Notificações',
                                                  style: TextStyle(
                                                      color: Color(0xFFE0E0E0), // Cor do texto
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            content: const Text(
                                              'Nenhuma notificação no momento.',
                                              style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 14), // Cor do texto
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Fechar',
                                                    style: TextStyle(color: Color(0xFFE0E0E0))), // Cor do texto
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
                const Divider(color: Color(0xFF303030), thickness: 1, indent: 24, endIndent: 24), // Cor mais clara para o divisor
                // Conteúdo centralizado para web
                Expanded(
                  child: Center(
                    child: Container(
                      width: kIsWeb ? 1000 : double.infinity,
                      constraints: kIsWeb 
                        ? const BoxConstraints(maxWidth: 1000)
                        : null,
                      child: Column(
                        children: [
                          // Botões de filtro de período com navegação
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Botões de filtro do lado esquerdo
                                Row(
                                  children: [
                                    ChoiceChip(
                            label: Text('Mês', style: TextStyle(color: _periodoSelecionado == PeriodoFiltro.mes ? Color(0xFF121212) : Color(0xFFE0E0E0))), // Texto preto quando selecionado, texto da paleta quando não
                            selected: _periodoSelecionado == PeriodoFiltro.mes,
                            selectedColor: Color(0xFF448AFF), // Botão primário
                            backgroundColor: Colors.transparent,
                            showCheckmark: false,
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
                            label: Text('Ano', style: TextStyle(color: _periodoSelecionado == PeriodoFiltro.ano ? Color(0xFF121212) : Color(0xFFE0E0E0))), // Texto preto quando selecionado, texto da paleta quando não
                            selected: _periodoSelecionado == PeriodoFiltro.ano,
                            selectedColor: Color(0xFF448AFF), // Botão primário
                            backgroundColor: Colors.transparent,
                            showCheckmark: false,
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
                            label: Text('Dia', style: TextStyle(color: _periodoSelecionado == PeriodoFiltro.dia ? Color(0xFF121212) : Color(0xFFE0E0E0))), // Texto preto quando selecionado, texto da paleta quando não
                            selected: _periodoSelecionado == PeriodoFiltro.dia,
                            selectedColor: Color(0xFF448AFF), // Botão primário
                            backgroundColor: Colors.transparent,
                            showCheckmark: false,
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
                      // Navegação de período do lado direito
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left, color: Color(0xFFE0E0E0), size: 18), // Cor do texto
                            onPressed: _previousPeriod,
                            tooltip: 'Período anterior',
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                          const SizedBox(width: 4),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.3, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              );
                            },
                            child: Text(
                              _formatCurrentDate(),
                              key: ValueKey(_currentDate.toString()),
                              style: const TextStyle(
                                color: Color(0xFFB388FF), // Cor dos acentos
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, color: Color(0xFFE0E0E0), size: 18), // Cor do texto
                            onPressed: _nextPeriod,
                            tooltip: 'Próximo período',
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ],
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
                                                  color: Color(0xFF1E1E1E), // Cor de fundo mais clara que o fundo principal
                                                  borderRadius: BorderRadius.circular(16),
                                                  border: Border.all(color: Color(0xFF00E676), width: 1), // Borda verde para entrada
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.3),
                                                      offset: Offset(2, 2),
                                                      blurRadius: 4,
                                                    ),
                                                  ],
                                                ),
                                                constraints: const BoxConstraints(
                                                  minHeight: 100,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      localizations.saldoAtual,
                                                      style: const TextStyle(
                                                        color: Color(0xFFE0E0E0), // Cor do texto
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                      softWrap: true,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Consumer<TransactionProvider>(
                                                            builder: (context, transactionProvider, _) {
                                                              final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
                                                              return Text(
                                                                formatter.format(saldoAtual),
                                                                style: const TextStyle(
                                                                  color: Color(0xFF00E676), // Cor de entrada
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 16,
                                                                ),
                                                                overflow: TextOverflow.ellipsis,
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Icon(
                                                          Icons.account_balance_wallet,
                                                          color: Color(0xFF00E676), // Cor de entrada
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
                                                // Força a atualização dos dados quando retorna da tela de gastos
                                                await _loadData();
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.all(3),
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF1E1E1E), // Cor de fundo mais clara que o fundo principal
                                                  borderRadius: BorderRadius.circular(16),
                                                  border: Border.all(color: Color(0xFFEF5350), width: 1), // Borda vermelha para saída
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.3),
                                                      offset: Offset(2, 2),
                                                      blurRadius: 4,
                                                    ),
                                                  ],
                                                ),
                                                constraints: const BoxConstraints(
                                                  minHeight: 100,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      localizations.gastoNoMes,
                                                      style: const TextStyle(
                                                        color: Color(0xFFE0E0E0), // Cor do texto
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                      softWrap: true,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Consumer<GastoProvider>(
                                                            builder: (context, gastoProvider, _) {
                                                              // Usa o método fresh se houve mudanças recentes, senão usa o método normal com cache
                                                              final totalGasto = gastoProvider.totalGastoMesFresh(referencia: _currentDate);
                                                              final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
                                                              
                                                              // Atualiza o valor local também para consistência
                                                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                                                if (mounted && gastoMes != totalGasto) {
                                                                  setState(() {
                                                                    gastoMes = totalGasto;
                                                                  });
                                                                }
                                                              });
                                                              
                                                              return Text(
                                                                formatter.format(totalGasto),
                                                                style: const TextStyle(
                                                                  color: Color(0xFFEF5350), // Cor de saída
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 16,
                                                                ),
                                                                overflow: TextOverflow.ellipsis,
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Icon(
                                                          Icons.trending_down,
                                                          color: Color(0xFFEF5350), // Cor de saída
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
                                          color: Color(0xFF1E1E1E), // Cor de fundo mais clara que o fundo principal
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Color(0xFF448AFF), width: 1), // Borda azul para investimentos
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              offset: Offset(2, 2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        constraints: const BoxConstraints(
                                          minHeight: 100,
                                        ),
                                        width: double.infinity,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              localizations.investimentos,
                                              style: const TextStyle(
                                                  color: Color(0xFFE0E0E0), fontSize: 16), // Cor do texto
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    toCurrencyString(
                                                      investimento.toString(),
                                                      leadingSymbol: 'R\$',
                                                      useSymbolPadding: true,
                                                      thousandSeparator: ThousandSeparator.Period,
                                                    ),
                                                    style: const TextStyle(
                                                      color: Color(0xFF448AFF), // Cor do botão primário
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Icon(
                                                  Icons.trending_up,
                                                  color: Color(0xFF448AFF), // Cor do botão primário
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
                              // Gráfico de visão geral financeira (colunas)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                child: Container(
                                  height: 300,
                                  child: GraficoColunaPrincipal(
                                    enableAutoScroll: true, // Ativar apenas aqui
                                    isDailyView: _periodoSelecionado == PeriodoFiltro.dia, // Novo parâmetro
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
                  ),
                ),
              ],
            ),
          ),
          // Overlay da caixa de texto expandida
          // CaixaTextoOverlay(),
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
            icon: const Icon(Icons.menu, color: Color(0xFFB388FF)), // Cor dos acentos
            onPressed: () {
              abrirMenuLateral(context);
            },
            tooltip: 'Abrir menu',
          ),
        ),
        const SizedBox(width: 8),
        // Título
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: !caixaTextoOverlay.isExpanded(context)
              ? const Text(
                  "NossoDinDin",
                  key: ValueKey('title'),
                  style: TextStyle(
                    color: Color(0xFFB388FF), // Cor dos acentos
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                )
              : const SizedBox(width: 120),
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
        // const SizedBox(width: 8),
        const Spacer(),
        // Botão de notificação
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: !caixaTextoOverlay.isExpanded(context)
              ? IconButton(
                  key: const ValueKey('notif'),
                  icon: const Icon(Icons.notifications_none, color: Color(0xFFB388FF)), // Cor dos acentos
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
                              backgroundColor: const Color(0xFF1E1E1E), // Cor de fundo mais clara
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              title: const Row(
                                children: [
                                  Icon(Icons.notifications, color: Color(0xFFB388FF)), // Cor dos acentos
                                  SizedBox(width: 8),
                                  Text(
                                    'Notificações',
                                    style: TextStyle(                                      color: Color(0xFFE0E0E0), // Cor do texto
                                      fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              content: const Text(
                                'Nenhuma notificação no momento.',
                                style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 14), // Cor do texto
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Fechar',
                                      style: TextStyle(color: Color(0xFFE0E0E0))), // Cor do texto
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              : const SizedBox(width: 48),
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
    if (!expanded) return const SizedBox.shrink();
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

List<DateTime> getUltimos12Meses(DateTime referencia) {
  return List.generate(12, (i) { // Últimos 12 meses baseado na data de referência
    return DateTime(referencia.year, referencia.month - (11 - i), 1);
  });
}

enum PeriodoFiltro { mes, ano, dia }

