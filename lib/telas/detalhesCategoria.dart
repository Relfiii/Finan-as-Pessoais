import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../provedor/gastoProvedor.dart';
import '../provedor/categoriaProvedor.dart';
import '../telas/criarGasto.dart';
import '../modelos/gasto.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import '../extensao/stringExtensao.dart';

class DetalhesCategoriaScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final DateTime? initialDate;

  const DetalhesCategoriaScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
    this.initialDate,
  }) : super(key: key);

  @override
  State<DetalhesCategoriaScreen> createState() => _DetalhesCategoriaScreenState();
}

class _DetalhesCategoriaScreenState extends State<DetalhesCategoriaScreen> {
  String _sortBy = 'data';
  bool _ascending = false;
  late DateTime _currentDate;

  // Lista para armazenar os gastos do mês atual
  List<dynamic> _gastosDoMes = [];

  // Controladores movidos para membros da classe
  final TextEditingController descricaoController = TextEditingController();
  final MoneyMaskedTextController valorController = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
  );

  @override
  void dispose() {
    descricaoController.dispose();
    valorController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Inicializa _currentDate com a data fornecida ou a data atual
    _currentDate = widget.initialDate ?? DateTime.now();
    _carregarGastosDoMes();
  }

  Future<void> _carregarGastosDoMes() async {
    final gastoProvider = context.read<GastoProvider>();
    final gastos = await gastoProvider.getGastosPorMes(widget.categoryId, _currentDate);
    setState(() {
      _gastosDoMes = _sortGastos(gastos);
    });
  }

  List<dynamic> _sortGastos(List<dynamic> gastos) {
    List<dynamic> gastosSorted = List.from(gastos);
    
    gastosSorted.sort((a, b) {
      int comparison = 0;
      
      switch (_sortBy) {
        case 'descricao':
          comparison = a.descricao.toString().toLowerCase().compareTo(b.descricao.toString().toLowerCase());
          break;
        case 'data':
          comparison = a.data.compareTo(b.data);
          break;
        case 'valor':
          comparison = a.valor.compareTo(b.valor);
          break;
        case 'parcelas':
          // Ordenar por parcela atual
          try {
            int parcelaA = 1;
            int parcelaB = 1;
            
            // Tenta acessar parcela_atual de diferentes formas
            if (a.runtimeType.toString().contains('Map')) {
              parcelaA = (a as Map)['parcela_atual'] ?? 1;
            } else {
              try {
                parcelaA = a.parcela_atual ?? 1;
              } catch (e) {
                try {
                  parcelaA = a.parcelaAtual ?? 1;
                } catch (e) {
                  parcelaA = 1;
                }
              }
            }
            
            if (b.runtimeType.toString().contains('Map')) {
              parcelaB = (b as Map)['parcela_atual'] ?? 1;
            } else {
              try {
                parcelaB = b.parcela_atual ?? 1;
              } catch (e) {
                try {
                  parcelaB = b.parcelaAtual ?? 1;
                } catch (e) {
                  parcelaB = 1;
                }
              }
            }
            
            comparison = parcelaA.compareTo(parcelaB);
          } catch (e) {
            // Se der erro, ordena por descrição como fallback
            comparison = a.descricao.toString().toLowerCase().compareTo(b.descricao.toString().toLowerCase());
          }
          break;
      }
      
      return _ascending ? comparison : -comparison;
    });
    
    return gastosSorted;
  }

  String _formatMonthYear(DateTime date) {
    return DateFormat("MMMM y", 'pt_BR').format(date).capitalize();
  }

  String _formatParcelas(dynamic gasto) {
    // Verifica se o gasto tem informações de parcelas usando try/catch
    try {
      // Se é um objeto Gasto diretamente
      if (gasto is Gasto) {
        if (gasto.totalParcelas > 1) {
          return '${gasto.parcelaAtual}/${gasto.totalParcelas}';
        } else {
          return 'À vista';
        }
      }
      
      // Tenta acessar as propriedades de parcelas para outros tipos
      dynamic parcelaAtual;
      dynamic totalParcelas;
      
      if (gasto.runtimeType.toString().contains('Map')) {
        final gastoMap = gasto as Map;
        parcelaAtual = gastoMap['parcela_atual'];
        totalParcelas = gastoMap['total_parcelas'];
      } else {
        // Tenta acessar como propriedades do objeto
        try {
          parcelaAtual = gasto.parcelaAtual;
          totalParcelas = gasto.totalParcelas;
        } catch (e) {
          // Se não conseguir acessar, tenta como propriedades alternativas
          try {
            parcelaAtual = gasto.parcela_atual;
            totalParcelas = gasto.total_parcelas;
          } catch (e) {
            parcelaAtual = null;
            totalParcelas = null;
          }
        }
      }
          
      if (parcelaAtual != null && totalParcelas != null && totalParcelas > 1) {
        return '$parcelaAtual/$totalParcelas';
      } else {
        return 'À vista';
      }
    } catch (e) {
      // Se der erro ao tentar acessar as propriedades, retorna "À vista"
      return 'À vista';
    }
  }

  void _nextMonth() async {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
    });
    await _carregarGastosDoMes();
  }

  void _previousMonth() async {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
    });
    await _carregarGastosDoMes();
  }

  Future<void> _confirmarDeletarGasto(BuildContext context, dynamic gasto, GastoProvider gastoProvider) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Center(
            child: AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E), // Cor de fundo mais clara da paleta
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text(
                'Confirmar exclusão',
                style: TextStyle(color: Color(0xFFE0E0E0), fontWeight: FontWeight.bold), // Texto da paleta
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tem certeza que deseja deletar esta despesa?',
                    style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 14), // Texto da paleta
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E), // Cor de fundo mais clara da paleta
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFFEF5350)), // Borda vermelha para gastos
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gasto.descricao.toString(),
                          style: const TextStyle(
                            color: Color(0xFFE0E0E0), // Texto da paleta
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'R\$ ${gasto.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(
                            color: Color(0xFFEF5350), // Cor vermelha para gastos
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          () {
                            // Se tem data da compra (parcelamentos), usa ela; senão usa a data normal
                            final dataParaExibir = gasto.dataCompra ?? gasto.data;
                            return '${dataParaExibir.day.toString().padLeft(2, '0')}/${dataParaExibir.month.toString().padLeft(2, '0')}/${dataParaExibir.year}';
                          }(),
                          style: const TextStyle(
                            color: Color(0xFFE0E0E0), // Texto da paleta
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Color(0xFFE0E0E0)), // Texto da paleta
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFEF5350), // Cor vermelha para gastos
                    foregroundColor: Color(0xFF121212), // Texto preto sobre fundo colorido
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () async {
                    try {
                      await gastoProvider.deleteGasto(gasto.id);
                      Navigator.of(context).pop();
                      await _carregarGastosDoMes();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Despesa deletada com sucesso!'),
                            backgroundColor: Color(0xFF00E676), // Verde da paleta
                          ),
                        );
                      }
                    } catch (e) {
                      Navigator.of(context).pop();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao deletar despesa: $e'),
                            backgroundColor: Color(0xFFEF5350), // Vermelho da paleta
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Deletar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editarGasto(BuildContext context, dynamic gasto, GastoProvider gastoProvider) async {
    descricaoController.text = gasto.descricao;
    valorController.updateValue(gasto.valor);

    await showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Center(
            child: AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E), // Cor de fundo mais clara da paleta
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text(
                'Editar Despesa',
                style: TextStyle(color: Color(0xFFE0E0E0), fontWeight: FontWeight.bold), // Texto da paleta
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Altere as informações da despesa.',
                      style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 14), // Texto da paleta
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descricaoController,
                      style: const TextStyle(color: Color(0xFFE0E0E0)), // Texto da paleta
                      decoration: InputDecoration(
                        hintText: 'Descrição da Despesa',
                        hintStyle: const TextStyle(color: Color(0xFFE0E0E0)), // Texto da paleta
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E), // Cor de fundo mais clara da paleta
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFFEF5350)), // Borda vermelha para gastos
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFFEF5350)), // Borda vermelha para gastos
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFFEF5350), width: 2), // Borda vermelha focada
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: valorController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 18, fontWeight: FontWeight.bold), // Texto da paleta
                      decoration: InputDecoration(
                        prefixText: 'R\$ ',
                        prefixStyle: const TextStyle(color: Color(0xFFEF5350), fontWeight: FontWeight.bold), // Cor vermelha para gastos
                        hintText: '0,00',
                        hintStyle: const TextStyle(color: Color(0xFFE0E0E0)), // Texto da paleta
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E), // Cor de fundo mais clara da paleta
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFFEF5350)), // Borda vermelha para gastos
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFFEF5350)), // Borda vermelha para gastos
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFFEF5350), width: 2), // Borda vermelha focada
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar', style: TextStyle(color: Color(0xFFE0E0E0))), // Texto da paleta
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF5350), // Cor vermelha para gastos
                    foregroundColor: const Color(0xFF121212), // Texto preto sobre fundo colorido
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () async {
                    final novaDescricao = descricaoController.text.trim();
                    final novoValor = double.tryParse(
                      valorController.text.replaceAll('.', '').replaceAll(',', '.'),
                    );

                    if (novaDescricao.isNotEmpty && novoValor != null) {
                      try {
                        await gastoProvider.updateGasto(
                          gasto.id,
                          novaDescricao,
                          novoValor,
                        );

                        Navigator.of(context).pop();
                        await _carregarGastosDoMes();

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Despesa atualizada com sucesso!'),
                              backgroundColor: Color(0xFF00E676), // Verde da paleta
                            ),
                          );
                        }
                      } catch (e) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao atualizar despesa: ${e.toString()}'),
                            backgroundColor: Color(0xFFEF5350), // Vermelho da paleta
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Preencha todos os campos corretamente.'),
                          backgroundColor: Color(0xFF448AFF), // Cor do botão primário da paleta
                        ),
                      );
                    }
                  },
                  child: const Text('Salvar Alteração'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _calcularTotalMesAtual() {
    return _gastosDoMes.fold(0.0, (sum, gasto) => sum + gasto.valor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo gradiente com desfoque
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF121212), // Fundo da paleta
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // AppBar customizada
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFFB388FF)), // Cor dos acentos da paleta
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.categoryName,
                          style: const TextStyle(
                            color: Color(0xFFB388FF), // Cor dos acentos da paleta
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E), // Cor de fundo mais clara da paleta
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFFEF5350)), // Borda vermelha para gastos
                        ),
                        child: Text(
                          NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(_calcularTotalMesAtual()),
                          style: const TextStyle(
                            color: Color(0xFFEF5350), // Cor vermelha para gastos
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFF303030), thickness: 1, indent: 24, endIndent: 24), // Cor mais clara para o divisor
                Expanded(
                  child: Center(
                    child: Container(
                      width: kIsWeb ? 1000 : double.infinity,
                      constraints: kIsWeb ? const BoxConstraints(maxWidth: 1000) : null,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Column(
                                children: [
                                  // Linha de botões: adicionar gasto e caixa de texto
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 44,
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF1E1E1E), // Cor de fundo mais clara da paleta
                                              foregroundColor: Color(0xFFE0E0E0), // Texto da paleta
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                              minimumSize: const Size(0, 44),
                                              side: BorderSide(color: Color(0xFFEF5350)), // Borda vermelha para gastos
                                            ),
                                            icon: const Icon(Icons.add, color: Color(0xFFEF5350)), // Ícone vermelho para gastos
                                            label: const Text('Despesa'),
                                            onPressed: () async {
                                              final categoryProvider = context.read<CategoryProvider>();
                                              final selectedCategory = categoryProvider.getCategoryById(widget.categoryId);

                                              final result = await showDialog(
                                                context: context,
                                                builder: (context) => AddExpenseDialog(
                                                  categoriaSelecionada: selectedCategory,
                                                ),
                                              );

                                              if (result == true) {
                                                await _carregarGastosDoMes();
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Expanded(
                                        //   child: CaixaTextoWidget(
                                        //     asButton: true,
                                        //     onExpand: () {
                                        //       showDialog(
                                        //         context: context,
                                        //         barrierDismissible: true,
                                        //         builder: (context) {
                                        //           return BackdropFilter(
                                        //             filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                        //             child: Center(
                                        //               child: FractionallySizedBox(
                                        //                 widthFactor: 0.95,
                                        //                 child: Material(
                                        //                   color: Colors.transparent,
                                        //                   child: CaixaTextoWidget(
                                        //                     asButton: false,
                                        //                     autofocus: true,
                                        //                     onCollapse: () {
                                        //                       Navigator.of(context).pop();
                                        //                     },
                                        //                   ),
                                        //                 ),
                                        //               ),
                                        //             ),
                                        //           );
                                        //         },
                                        //       );
                                        //     },
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                  // Navegação de mês/ano
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.chevron_left, color: Color(0xFFE0E0E0)), // Texto da paleta
                                          onPressed: _previousMonth,
                                        ),
                                        Text(
                                          _formatMonthYear(_currentDate),
                                          style: const TextStyle(
                                            color: Color(0xFFB388FF), // Cor dos acentos da paleta
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.chevron_right, color: Color(0xFFE0E0E0)), // Texto da paleta
                                          onPressed: _nextMonth,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Lista de gastos
                                  RefreshIndicator(
                                    onRefresh: _carregarGastosDoMes,
                                    child: _gastosDoMes.isEmpty
                                        ? const Center(
                                            child: Text(
                                              'Nenhuma despesa encontrada.',
                                              style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 16), // Texto da paleta
                                            ),
                                          )
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            itemCount: _gastosDoMes.length,
                                            itemBuilder: (context, index) {
                                              final gasto = _gastosDoMes[index];
                                              return Container(
                                                margin: const EdgeInsets.only(bottom: 8),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF1E1E1E),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: const Color(0xFF303030), width: 1),
                                                ),
                                                child: ListTile(
                                                  title: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          gasto.descricao.toString(),
                                                          style: const TextStyle(
                                                            color: Color(0xFFE0E0E0),
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        NumberFormat.currency(
                                                          locale: 'pt_BR',
                                                          symbol: 'R\$',
                                                          decimalDigits: 2,
                                                        ).format(gasto.valor),
                                                        style: const TextStyle(
                                                          color: Color(0xFFEF5350),
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  subtitle: Padding(
                                                    padding: const EdgeInsets.only(top: 4),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFF303030),
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                          child: Text(
                                                            widget.categoryName,
                                                            style: const TextStyle(
                                                              color: Color(0xFFE0E0E0),
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          _formatParcelas(gasto),
                                                          style: const TextStyle(
                                                            color: Color(0xFFE0E0E0),
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  trailing: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          Text(
                                                            () {
                                                              final dataParaExibir = gasto.dataCompra ?? gasto.data;
                                                              return '${dataParaExibir.day.toString().padLeft(2, '0')} de ${DateFormat("MMM", 'pt_BR').format(dataParaExibir)}';
                                                            }(),
                                                            style: const TextStyle(
                                                              color: Color(0xFFE0E0E0),
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(width: 8),
                                                      PopupMenuButton<String>(
                                                        icon: const Icon(Icons.more_vert, color: Color(0xFFE0E0E0), size: 20),
                                                        onSelected: (value) async {
                                                          final gastoProvider = context.read<GastoProvider>();
                                                          if (value == 'editar') {
                                                            _editarGasto(context, gasto, gastoProvider);
                                                          } else if (value == 'deletar') {
                                                            _confirmarDeletarGasto(context, gasto, gastoProvider);
                                                          }
                                                        },
                                                        itemBuilder: (context) => [
                                                          const PopupMenuItem(
                                                            value: 'editar',
                                                            child: Text('Editar'),
                                                          ),
                                                          const PopupMenuItem(
                                                            value: 'deletar',
                                                            child: Text('Deletar'),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}