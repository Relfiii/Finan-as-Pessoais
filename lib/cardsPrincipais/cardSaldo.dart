import 'package:flutter/material.dart';
import 'dart:ui';
import '../telas/criarReceita.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class ControleReceitasPage extends StatefulWidget {
  const ControleReceitasPage({Key? key}) : super(key: key);

  @override
  State<ControleReceitasPage> createState() => _ControleReceitasPageState();
}

class _ControleReceitasPageState extends State<ControleReceitasPage> {
  final List<Map<String, dynamic>> receitas = [];
  double _totalReceitas = 0.0;

  Future<void> _editarReceita(int index) async {
    final receita = receitas[index];
    final descricaoController = TextEditingController(text: receita['descricao']);
    final valorController = TextEditingController(
      text: toCurrencyString(
        receita['valor'].toString(),
        leadingSymbol: 'R\$',
        useSymbolPadding: true,
        thousandSeparator: ThousandSeparator.Period,
      ),
    );
    bool _loading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Center(
              child: AlertDialog(
                backgroundColor: const Color(0xFF181818),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                title: const Text(
                  'Editar Receita',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edite os dados da receita selecionada.',
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
                        fillColor: const Color(0xFF23272F),
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
                        hintText: 'Valor',
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
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB983FF),
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
                            final novoValor = double.tryParse(valorTexto) ?? receita['valor'];
                            final novaDescricao = descricaoController.text;

                            // Atualiza no Supabase
                            await Supabase.instance.client
                                .from('entradas')
                                .update({
                                  'descricao': novaDescricao,
                                  'valor': novoValor,
                                })
                                .match({'id': receita['id']});

                            // Atualiza localmente
                            setState(() {
                              receitas[index]['descricao'] = novaDescricao;
                              receitas[index]['valor'] = novoValor;
                            });

                            setState(() => _loading = false);

                            // Opcional: recarrega tudo do banco para garantir sincronismo
                            await _carregarReceitas();

                            Navigator.of(context).pop(true);
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

    Future<void> _deletarReceita(int index) async {
    final receita = receitas[index];
        final confirm = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4), // escurece o fundo
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: const Color(0xFF23272F),
          title: const Text('Confirmar exclusão', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Deseja realmente deletar esta receita?',
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
      // Remove do Supabase
      await Supabase.instance.client
          .from('entradas')
          .delete()
          .match({'id': receita['id']});
  
      setState(() {
        receitas.removeAt(index);
      });
    }
  }

  Future<void> _carregarReceitas() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final response = await Supabase.instance.client
        .from('entradas')
        .select()
        .eq('user_id', userId)
        .order('data', ascending: false);

    setState(() {
      receitas.clear();
      for (final item in response) {
        receitas.add({
          'id': item['id'],
          'descricao': item['descricao'],
          'valor': double.tryParse(item['valor'].toString()) ?? 0.0,
          'data': DateTime.parse(item['data']),
        });
      }
    });

    // Atualiza o total das receitas
    final total = await ReceitaUtils.buscarTotalReceitas();
    setState(() {
      _totalReceitas = total;
    });
  }

  @override
  void initState() {
    super.initState();
    _carregarReceitas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo gradiente com blur
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
            child: RefreshIndicator(
              onRefresh: _carregarReceitas, // <-- Adicione esta linha
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
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Receitas do Mês',
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
                  // Botão de adicionar receita + total receitas
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 16, top: 8, bottom: 0),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 44,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF23272F),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              minimumSize: const Size(0, 44),
                            ),
                            icon: const Icon(Icons.add, color: Color(0xFFB983FF)),
                            label: const Text('Receita'),
                            onPressed: () async {
                              final result = await showDialog(
                                context: context,
                                builder: (context) => const AddReceitaDialog(),
                              );
                              if (result == true) {
                                await _carregarReceitas(); // Função para buscar receitas do Supabase
                              }
                            },
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF23272F),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                toCurrencyString(
                                  _totalReceitas.toString(),
                                  leadingSymbol: 'R\$',
                                  useSymbolPadding: true,
                                  thousandSeparator: ThousandSeparator.Period,
                                ),
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 158, 214, 158),
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
                  // Lista de cards um embaixo do outro
                  Expanded(
                    child: receitas.isEmpty
                        ? Center(
                            child: Text(
                              'Nenhuma receita cadastrada.',
                              style: TextStyle(color: Colors.white54, fontSize: 16),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: receitas.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final receita = receitas[index];
                              return ReceitaCard(
                                descricao: receita['descricao'],
                                valor: receita['valor'],
                                data: receita['data'],
                                onEdit: () => _editarReceita(index),
                                onDelete: () => _deletarReceita(index),
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

class ReceitaCard extends StatelessWidget {
  final String descricao;
  final double valor;
  final DateTime data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ReceitaCard({
    required this.descricao,
    required this.valor,
    required this.data,
    required this.onEdit,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String valorFormatado = toCurrencyString(
      valor.toString(),
      leadingSymbol: 'R\$',
      useSymbolPadding: true,
      thousandSeparator: ThousandSeparator.Period,
    );
    return Container(
      height: 130, // Defina a altura desejada aqui
      decoration: BoxDecoration(
        color: const Color(0xFF232323),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                        color: const Color(0xFF23272F),
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
                      const Icon(Icons.attach_money, color: Color(0xFFB983FF), size: 18),
                      const SizedBox(width: 6),
                      Text(
                        valorFormatado,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 158, 214, 158),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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

class ReceitaUtils {
  static Future<double> buscarTotalReceitas() async {
    final now = DateTime.now();
    final response = await Supabase.instance.client
        .from('entradas')
        .select('valor, data');
    double total = 0.0;
    for (final item in response) {
      final data = DateTime.tryParse(item['data'].toString());
      if (data != null && data.month == now.month && data.year == now.year) {
        total += double.tryParse(item['valor'].toString()) ?? 0.0;
      }
    }
    return total;
  }
}