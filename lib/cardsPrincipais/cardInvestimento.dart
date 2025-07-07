import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import '../telas/criarInvestimento.dart'; // Importa o novo arquivo

class ControleInvestimentosPage extends StatefulWidget {
  const ControleInvestimentosPage({Key? key}) : super(key: key);

  @override
  State<ControleInvestimentosPage> createState() => _ControleInvestimentosPageState();
}

class _ControleInvestimentosPageState extends State<ControleInvestimentosPage> {
  final List<Map<String, dynamic>> investimentos = [];
  double _totalInvestimentos = 0.0;

  Future<void> _carregarInvestimentos() async {
    final response = await Supabase.instance.client
        .from('investimentos')
        .select()
        .order('data', ascending: false);

    setState(() {
      investimentos.clear();
      for (final item in response) {
        investimentos.add({
          'id': item['id'],
          'descricao': item['descricao'],
          'valor': double.tryParse(item['valor'].toString()) ?? 0.0,
          'data': DateTime.parse(item['data']),
          'tipo': item['tipo'] ?? 'Outro',
        });
      }
    });

    final total = await InvestimentoUtils.buscarTotalInvestimentos();
    setState(() {
      _totalInvestimentos = total;
    });
  }

  Future<void> _editarInvestimento(int index) async {
    final investimento = investimentos[index];
    final descricaoController = TextEditingController(text: investimento['descricao']);
    final valorController = TextEditingController(
      text: toCurrencyString(
        investimento['valor'].toString(),
        leadingSymbol: 'R\$',
        useSymbolPadding: true,
        thousandSeparator: ThousandSeparator.Period,
      ),
    );
    String tipoSelecionado = investimento['tipo'] ?? 'Outro';
    bool _loading = false;
    final tipoOutroController = TextEditingController(text: tipoSelecionado == 'Outro' ? investimento['tipo'] : '');

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Center(
              child: AlertDialog(
                backgroundColor: const Color(0xFF181828),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                title: const Text(
                  'Editar Investimento',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edite os dados do investimento selecionado.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descricaoController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Descrição',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF23273A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: valorController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      inputFormatters: [
                        MoneyInputFormatter(
                          leadingSymbol: 'R\$',
                          useSymbolPadding: true,
                          thousandSeparator: ThousandSeparator.Period,
                        ),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Valor investido',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF23273A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: tipoSelecionado,
                      dropdownColor: const Color(0xFF23273A),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF23273A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: [
                        'Renda Fixa',
                        'CDB',
                        'LCI',
                        'LCA',
                        'Tesouro Direto',
                        'Debêntures',
                        'Renda Variável',
                        'Ações',
                        'Fundos Imobiliários',
                        'ETFs',
                        'Cripto',
                        'Imóveis',
                        'Outro'
                      ].map((tipo) => DropdownMenuItem(
                        value: tipo,
                        child: Text(tipo),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          tipoSelecionado = value ?? 'Outro';
                        });
                      },
                    ),
                    if (tipoSelecionado == 'Outro')
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: TextField(
                          controller: tipoOutroController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Descreva o tipo de investimento',
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: const Color(0xFF23273A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7DE2FC),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: _loading
                        ? null
                        : () async {
                            setState(() => _loading = true);
                            String valorTexto = valorController.text.trim();
                            valorTexto = valorTexto
                                .replaceAll('R\$', '')
                                .replaceAll('.', '')
                                .replaceAll(',', '.')
                                .replaceAll(' ', '');
                            final novoValor = double.tryParse(valorTexto) ?? investimento['valor'];
                            final novaDescricao = descricaoController.text;
                            final tipo = tipoSelecionado == 'Outro' ? tipoOutroController.text : tipoSelecionado;

                            await Supabase.instance.client
                                .from('investimentos')
                                .update({
                                  'descricao': novaDescricao,
                                  'valor': novoValor,
                                  'tipo': tipo,
                                })
                                .match({'id': investimento['id']});

                            setState(() => _loading = false);
                            await _carregarInvestimentos();
                            Navigator.of(context).pop();
                          },
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Text('Salvar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deletarInvestimento(int index) async {
    final investimento = investimentos[index];
    final confirm = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: const Color(0xFF23273A),
          title: const Text('Confirmar exclusão', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Deseja realmente deletar este investimento?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Deletar'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      await Supabase.instance.client
          .from('investimentos')
          .delete()
          .match({'id': investimento['id']});

      await _carregarInvestimentos();
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarInvestimentos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo gradiente com blur e overlay de gráfico
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF23273A),
                    Color(0xFF181828),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -60,
            right: -60,
            child: Icon(Icons.pie_chart, size: 180, color: Colors.white.withOpacity(0.04)),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _carregarInvestimentos,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF7DE2FC)),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Investimentos',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white24, thickness: 1, indent: 24, endIndent: 24),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 16, top: 8, bottom: 0),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 44,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF23273A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              minimumSize: const Size(0, 44),
                            ),
                            icon: const Icon(Icons.add_chart, color: Color(0xFF7DE2FC)),
                            label: const Text('Investir'),
                            onPressed: () async {
                              // Chama o popup externo e recarrega ao salvar
                              final result = await showCriarInvestimentoDialog(context);
                              if (result == true) {
                                await _carregarInvestimentos();
                              }
                            },
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF23273A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.savings, color: Color(0xFF7DE2FC), size: 18),
                              const SizedBox(width: 6),
                              Text(
                                toCurrencyString(
                                  _totalInvestimentos.toString(),
                                  leadingSymbol: 'R\$',
                                  useSymbolPadding: true,
                                  thousandSeparator: ThousandSeparator.Period,
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF7DE2FC),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: investimentos.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.trending_down, color: Colors.white24, size: 54),
                                const SizedBox(height: 12),
                                Text(
                                  'Nenhum investimento cadastrado.',
                                  style: TextStyle(color: Colors.white54, fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: investimentos.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final investimento = investimentos[index];
                              return InvestimentoCard(
                                descricao: investimento['descricao'],
                                valor: investimento['valor'],
                                data: investimento['data'],
                                tipo: investimento['tipo'],
                                onEdit: () => _editarInvestimento(index),
                                onDelete: () => _deletarInvestimento(index),
                              );
                            },
                          ),
                  ),
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
          ),
        ],
      ),
    );
  }
}

class InvestimentoCard extends StatelessWidget {
  final String descricao;
  final double valor;
  final DateTime data;
  final String tipo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const InvestimentoCard({
    required this.descricao,
    required this.valor,
    required this.data,
    required this.tipo,
    required this.onEdit,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  Color _corTipo(String tipo) {
    switch (tipo) {
      case 'Renda Fixa':
        return const Color(0xFF7DE2FC);
      case 'Renda Variável':
        return const Color(0xFFB983FF);
      case 'Cripto':
        return const Color(0xFFFFA8A8);
      case 'Imóveis':
        return const Color(0xFFB8FFB8);
      default:
        return Colors.white24;
    }
  }

  IconData _iconeTipo(String tipo) {
    switch (tipo) {
      case 'Renda Fixa':
        return Icons.savings;
      case 'Renda Variável':
        return Icons.show_chart;
      case 'Cripto':
        return Icons.currency_bitcoin;
      case 'Imóveis':
        return Icons.home_work;
      default:
        return Icons.pie_chart;
    }
  }

  @override
  Widget build(BuildContext context) {
    String valorFormatado = toCurrencyString(
      valor.toString(),
      leadingSymbol: 'R\$',
      useSymbolPadding: true,
      thousandSeparator: ThousandSeparator.Period,
    );

    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _corTipo(tipo).withOpacity(0.13),
            Colors.black.withOpacity(0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _corTipo(tipo).withOpacity(0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _corTipo(tipo).withOpacity(0.09),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _corTipo(tipo).withOpacity(0.18),
                        child: Icon(_iconeTipo(tipo), color: _corTipo(tipo), size: 24),
                        radius: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          descricao,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white54, size: 20),
                        color: const Color(0xFF23273A),
                        padding: EdgeInsets.zero,
                        onSelected: (value) {
                          if (value == 'editar') {
                            onEdit();
                          } else if (value == 'deletar') {
                            onDelete();
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'editar',
                            child: Text('Editar', style: TextStyle(color: Colors.white)),
                          ),
                          const PopupMenuItem(
                            value: 'deletar',
                            child: Text('Deletar', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(_iconeTipo(tipo), color: _corTipo(tipo), size: 18),
                      const SizedBox(width: 6),
                      Text(
                        valorFormatado,
                        style: TextStyle(
                          color: _corTipo(tipo),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _corTipo(tipo).withOpacity(0.13),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tipo,
                          style: TextStyle(
                            color: _corTipo(tipo),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '${data.day.toString().padLeft(2, '0')}/'
                      '${data.month.toString().padLeft(2, '0')}/'
                      '${data.year}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InvestimentoUtils {
  static Future<double> buscarTotalInvestimentos() async {
    final response = await Supabase.instance.client
        .from('investimentos')
        .select('valor');
    double total = 0.0;
    for (final item in response) {
      total += double.tryParse(item['valor'].toString()) ?? 0.0;
    }
    return total;
  }
}