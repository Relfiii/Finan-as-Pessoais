import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provedor/gastoProvedor.dart';
import '../provedor/categoriaProvedor.dart';
import '../telas/criarGasto.dart';
import 'dart:ui';
import '../caixaTexto/caixaTexto.dart';
import 'package:intl/intl.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import '../extensao/stringExtensao.dart';

class DetalhesCategoriaScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const DetalhesCategoriaScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<DetalhesCategoriaScreen> createState() => _DetalhesCategoriaScreenState();
}

class _DetalhesCategoriaScreenState extends State<DetalhesCategoriaScreen> {
  String _sortBy = 'data';
  bool _ascending = false;
  DateTime _currentDate = DateTime.now();

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
    // Certifique-se de descartar os controladores ao descartar o estado
    descricaoController.dispose();
    valorController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _carregarGastosDoMes();
  }

  Future<void> _carregarGastosDoMes() async {
    final gastoProvider = context.read<GastoProvider>();
    final gastos = await gastoProvider.getGastosPorMes(widget.categoryId, _currentDate);
    setState(() {
      _gastosDoMes = gastos;
    });
  }

  String _formatMonthYear(DateTime date) {
    return DateFormat("MMMM y", 'pt_BR').format(date).capitalize();
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

  // Método para confirmar deleção do gasto
  Future<void> _confirmarDeletarGasto(BuildContext context, dynamic gasto, GastoProvider gastoProvider) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Center(
            child: AlertDialog(
              backgroundColor: const Color(0xFF181818),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Confirmar exclusão',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 20,
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tem certeza que deseja deletar este despesa?',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF23272F),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gasto.descricao.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'R\$ ${gasto.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${gasto.data.day.toString().padLeft(2, '0')}/${gasto.data.month.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white54),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () async {
                          try {
                            // Deleta o gasto da base de dados e da lista
                            await gastoProvider.deleteGasto(gasto.id);
                            Navigator.of(context).pop();
                            
                            // Recarrega os dados da base para atualizar a lista de gastos
                            await _carregarGastosDoMes();
                            
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Despesa deletada com sucesso!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            Navigator.of(context).pop();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erro ao deletar despesa: $e'),
                                  backgroundColor: Colors.red,
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Método para editar gasto
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
              backgroundColor: const Color(0xFF181818),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text(
                'Editar Despesa',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Altere as informações da despesa.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descricaoController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Descrição da Despesa',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF23272F),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: valorController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        prefixText: 'R\$ ',
                        prefixStyle: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
                        hintText: '0,00',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF23272F),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
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
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB983FF),
                    foregroundColor: Colors.black,
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
                        // Atualiza o gasto na base de dados
                        await gastoProvider.updateGasto(
                          gasto.id,
                          novaDescricao,
                          novoValor,
                        );
  
                        // Fecha o dialog
                        Navigator.of(context).pop();
                        
                        // Recarrega os dados da base para atualizar a lista de gastos
                        await _carregarGastosDoMes();
                        
                        // Mostra mensagem de sucesso
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Despesa atualizada com sucesso!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao atualizar despesa: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Preencha todos os campos corretamente.'),
                          backgroundColor: Colors.orange,
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
                // AppBar customizada
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFFB983FF)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.categoryName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF232323),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(_calcularTotalMesAtual()),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 214, 158, 158),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, thickness: 1, indent: 24, endIndent: 24),
                // Linha de botões: adicionar gasto e caixa de texto
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Botão de adicionar gasto
                      SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF23272F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            minimumSize: const Size(0, 44),
                          ),
                          icon: const Icon(Icons.add, color: Color(0xFFB983FF)),
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
                            
                            // Se uma despesa foi adicionada, recarrega a lista
                            if (result == true) {
                              await _carregarGastosDoMes();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // CaixaTextoWidget como botão
                      Expanded(
                        child: CaixaTextoWidget(
                          asButton: true,
                          onExpand: () {
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (context) {
                                return BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                  child: Center(
                                    child: FractionallySizedBox(
                                      widthFactor: 0.95,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: CaixaTextoWidget(
                                          asButton: false,
                                          autofocus: true,
                                          onCollapse: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
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
                        icon: const Icon(Icons.chevron_left, color: Colors.white70),
                        onPressed: _previousMonth,
                      ),
                      Text(
                        _formatMonthYear(_currentDate),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Colors.white70),
                        onPressed: _nextMonth,
                      ),
                    ],
                  ),
                ),
                // Cabeçalho da tabela
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF23272F),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_sortBy == 'descricao') {
                                _ascending = !_ascending;
                              } else {
                                _sortBy = 'descricao';
                                _ascending = true;
                              }
                            });
                          },
                          child: Row(
                            children: [
                              const Text(
                                'Descrição',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_sortBy == 'descricao')
                                Icon(
                                  _ascending ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_sortBy == 'data') {
                                _ascending = !_ascending;
                              } else {
                                _sortBy = 'data';
                                _ascending = false;
                              }
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Data',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_sortBy == 'data')
                                Icon(
                                  _ascending ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_sortBy == 'valor') {
                                _ascending = !_ascending;
                              } else {
                                _sortBy = 'valor';
                                _ascending = false;
                              }
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text(
                                'Valor',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_sortBy == 'valor')
                                Icon(
                                  _ascending ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 40), // Espaço para coluna "Ações"
                      const Text(
                        'Ações',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Lista de gastos com RefreshIndicator
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _carregarGastosDoMes,
                    child: _gastosDoMes.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhuma despesa encontrada.',
                              style: TextStyle(color: Colors.white54, fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            itemCount: _gastosDoMes.length,
                            itemBuilder: (context, index) {
                              final gasto = _gastosDoMes[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF23272F),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        gasto.descricao.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${gasto.data.day.toString().padLeft(2, '0')}/${gasto.data.month.toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          NumberFormat.currency(
                                            locale: 'pt_BR',
                                            symbol: 'R\$',
                                            decimalDigits: 2,
                                          ).format(gasto.valor),
                                          style: const TextStyle(
                                            color: Colors.greenAccent,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert, color: Colors.white70),
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
                              );
                            },
                          ),
                  ),
                ),
                // Rodapé
                Center(
                  child: Text(
                    'NossoDinDin v1.0',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.18),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}