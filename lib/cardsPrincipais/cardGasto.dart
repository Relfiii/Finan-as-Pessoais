import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../provedor/categoriaProvedor.dart';
import '../provedor/gastoProvedor.dart';
import '../telas/criarCategoria.dart';
import '../telas/criarGasto.dart';
import '../telas/detalhesCategoria.dart';
import '../caixaTexto/caixaTexto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../modelos/categoria.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'cardCategoGasto.dart';

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
              onSend: (comando, ctx) async {
                // Implementar ações de comando aqui
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CardGasto extends StatefulWidget {
  @override
  _CardGastoState createState() => _CardGastoState();
}

class _CardGastoState extends State<CardGasto> {
  DateTime _currentDate = DateTime.now();
  List<dynamic> _todasCategorias = [];

  @override
  void initState() {
    super.initState();
    _carregarTodasCategorias();
    // Não precisa mais carregar o total aqui, o Consumer fará isso automaticamente
  }

  Future<void> _carregarTodasCategorias() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        _todasCategorias = [];
      });
      return;
    }

    try {
      print('Carregando todas as categorias do usuário');
      
      // Busca TODAS as categorias do usuário, independente do mês
      final categoriasResponse = await supabase
          .from('categorias')
          .select()
          .eq('user_id', userId)
          .order('data', ascending: true);

      print('Categorias encontradas: ${categoriasResponse.length}');

      // Converte para objetos Category
      final categorias = categoriasResponse.map<Category>((cat) => Category(
        id: cat['id'],
        name: cat['nome'],
        description: '', // Campo description não existe na tabela, usar valor padrão
        color: const Color(0xFFB983FF),
        icon: Icons.category,
        createdAt: DateTime.parse(cat['data']),
        updatedAt: DateTime.now(),
      )).toList();

      setState(() {
        _todasCategorias = categorias;
      });
      
      print('Estado atualizado com ${_todasCategorias.length} categorias');
    } catch (e) {
      print('Erro ao carregar categorias: $e');
      setState(() {
        _todasCategorias = [];
      });
    }
    
    // O Consumer já atualiza automaticamente quando necessário
  }

  Future<void> _editarCategoria(Category categoria) async {
    final TextEditingController controller = TextEditingController(text: categoria.name);
    
    final resultado = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Center(
            child: AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E), // Cor de fundo mais clara
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text(
                'Editar Categoria',
                style: TextStyle(color: Color(0xFFE0E0E0), fontWeight: FontWeight.bold), // Cor do texto
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Edite o nome da categoria selecionada.',
                    style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 14), // Cor do texto
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    style: const TextStyle(color: Color(0xFFE0E0E0)), // Cor do texto
                    decoration: InputDecoration(
                      hintText: 'Nome da categoria',
                      hintStyle: const TextStyle(color: Color(0xFFE0E0E0)), // Cor do texto
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E), // Cor de fundo mais clara
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFFB983FF)), // Borda roxa
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFFB983FF)), // Borda roxa
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFFB983FF), width: 2), // Borda roxa mais grossa quando focado
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Color(0xFFE0E0E0)), // Cor do texto
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB983FF), // Roxa para categorias
                    foregroundColor: const Color(0xFF121212), // Texto preto
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () {
                    final novoNome = controller.text.trim();
                    if (novoNome.isNotEmpty) {
                      Navigator.of(context).pop(novoNome);
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (resultado != null && resultado != categoria.name) {
      try {
        final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
        await categoryProvider.updateCategoryName(categoria.id, resultado);
        
        // Recarregar as categorias locais
        await _carregarTodasCategorias();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Categoria atualizada com sucesso!'),
            backgroundColor: Color(0xFFB983FF),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar categoria: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deletarCategoria(Category categoria) async {
    final confirmacao = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E), // Cor de fundo mais clara
          title: const Text('Confirmar exclusão', style: TextStyle(color: Color(0xFFE0E0E0))), // Cor do texto
          content: Text(
            'Tem certeza que deseja excluir a categoria "${categoria.name}"?\n\nEsta ação não pode ser desfeita.',
            style: const TextStyle(color: Color(0xFFE0E0E0)), // Cor do texto
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Color(0xFFE0E0E0))), // Cor do texto
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFEF5350), // Cor de saída
                foregroundColor: Color(0xFF121212), // Texto preto
              ),
              child: const Text('Deletar'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    );

    if (confirmacao == true) {
      try {
        final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
        await categoryProvider.deleteCategory(categoria.id);
        
        // Recarregar as categorias locais
        await _carregarTodasCategorias();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Categoria "${categoria.name}" excluída com sucesso!'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir categoria: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatMonthYear(DateTime date) {
    return DateFormat("MMMM y", 'pt_BR').format(date);
  }

  void _nextMonth() async {
    // Feedback tátil
    if (Theme.of(context).platform == TargetPlatform.android || 
        Theme.of(context).platform == TargetPlatform.iOS) {
      HapticFeedback.lightImpact();
    }
    
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
    });
    
    // O Consumer já atualiza automaticamente
  }

  void _previousMonth() async {
    // Feedback tátil
    if (Theme.of(context).platform == TargetPlatform.android || 
        Theme.of(context).platform == TargetPlatform.iOS) {
      HapticFeedback.lightImpact();
    }
    
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
    });
    
    // O Consumer já atualiza automaticamente
  }

  // Mova este método para cá:
  String _formatCategoryName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length <= 1) return name;
    return '${parts.first}\n${parts.sublist(1).join(' ')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GastoProvider>(
      builder: (context, gastoProvider, child) {
        // Debug: mostrar quando a tela está sendo reconstruída
        print('🔄 CardGasto rebuild - Mês: ${_currentDate.month}/${_currentDate.year}');
        
        return RefreshIndicator(
          onRefresh: () async {
            print('Executando refresh da tela...');
            await Provider.of<CategoryProvider>(context, listen: false).loadCategories();
            await gastoProvider.loadGastos();
            await _carregarTodasCategorias();
            // O Consumer já atualiza automaticamente
            print('Refresh concluído');
          },
      child: Scaffold(
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
                          icon: const Icon(Icons.arrow_back, color: Color(0xFFB388FF)),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Gastos',
                          style: TextStyle(
                            color: Color(0xFFB388FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFF303030), thickness: 1, indent: 24, endIndent: 24),
                  
                  // Conteúdo principal
                  Expanded(
                    child: Container(
                      width: kIsWeb ? 1000 : double.infinity,
                      constraints: kIsWeb ? const BoxConstraints(maxWidth: 1000) : null,
                      margin: kIsWeb ? const EdgeInsets.symmetric(horizontal: 20) : EdgeInsets.zero,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            // Total de Gastos
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total de Gastos:',
                                    style: TextStyle(
                                      color: Color(0xFFE0E0E0),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(
                                      gastoProvider.totalGastoMesFresh(referencia: _currentDate)
                                    ),
                                    style: TextStyle(
                                      color: Color(0xFFEF5350),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Navegação de mês
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFFE0E0E0).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.chevron_left, color: Color(0xFFE0E0E0)),
                                      onPressed: _previousMonth,
                                    ),
                                  ),
                                  Text(
                                    _formatMonthYear(_currentDate),
                                    style: const TextStyle(
                                      color: Color(0xFFB388FF),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFFE0E0E0).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.chevron_right, color: Color(0xFFE0E0E0)),
                                      onPressed: _nextMonth,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Botões de ação
                            Padding(
                              padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
                              child: Row(
                                children: [
                                  // Botão de categoria
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
                                      label: const Text('Categoria'),
                                      onPressed: () async {
                                        await showDialog(
                                          context: context,
                                          builder: (context) => const AddCategoryDialog(),
                                        );
                                        await Provider.of<CategoryProvider>(context, listen: false).loadCategories();
                                        await _carregarTodasCategorias();
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Botão de despesa
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
                                        final result = await showDialog(
                                          context: context,
                                          builder: (context) => const AddExpenseDialog(),
                                        );
                                        
                                        // Verificar se foi criado um gasto recorrente
                                        if (result is Map && result['success'] == true && result['isRecorrente'] == true) {
                                          // Navegar para detalhesCategoria.dart
                                          if (mounted) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => DetalhesCategoriaScreen(
                                                  categoryId: result['categoriaId'],
                                                  categoryName: result['categoriaNome'],
                                                  initialDate: DateTime.now(),
                                                ),
                                              ),
                                            );
                                          }
                                        } else {
                                          // Para outros tipos de gasto, apenas atualizar a tela atual
                                          await Provider.of<CategoryProvider>(context, listen: false).loadCategories();
                                          await Provider.of<GastoProvider>(context, listen: false).loadGastos();
                                          await _carregarTodasCategorias();
                                          // O Consumer já atualiza automaticamente
                                          setState(() {});
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Grid de categorias
                            _todasCategorias.isEmpty
                                ? Container(
                                    height: 300,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.category_outlined,
                                            size: 64,
                                            color: Color(0xFFE0E0E0).withOpacity(0.3),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Nenhuma categoria criada.',
                                            style: TextStyle(
                                              color: Color(0xFFE0E0E0).withOpacity(0.7),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(16),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final gridConfig = gridConfigForItems(_todasCategorias.length, context);                                        
                                        
                                        return GridView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.zero,
                                          itemCount: _todasCategorias.length,
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: gridConfig.crossAxisCount,
                                            crossAxisSpacing: gridConfig.crossAxisSpacing,
                                            mainAxisSpacing: gridConfig.mainAxisSpacing,
                                            childAspectRatio: gridConfig.childAspectRatio,
                                          ),
                                          itemBuilder: (context, categoryIndex) {
                                            final cat = _todasCategorias[categoryIndex];
                                            final valor = gastoProvider.totalPorCategoriaMes(cat.id, _currentDate);

                                            // Use o método aqui:
                                            return CategoryCard(
                                              categoryName: _formatCategoryName(cat.name),
                                              valor: valor,
                                              onTap: () async {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => DetalhesCategoriaScreen(
                                                      categoryId: cat.id,
                                                      categoryName: cat.name,
                                                      initialDate: _currentDate,
                                                    ),
                                                  ),
                                                );
                                              },
                                              onEdit: () async {
                                                await _editarCategoria(cat);
                                              },
                                              onDelete: () async {
                                                await _deletarCategoria(cat);
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                            const SizedBox(height: 20),
                          ],
                        ),
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
      ),
      );
      },
    );
  }
}

class GridConfig {
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  GridConfig({
    required this.crossAxisCount,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
    required this.childAspectRatio,
  });
}

GridConfig gridConfigForItems(int itemCount, BuildContext context) {
  // Obtém a largura da tela
  final screenWidth = MediaQuery.of(context).size.width;
  // Define se é tablet (largura maior que 600)
  final isTablet = screenWidth > 600;
  // Define se é desktop (largura maior que 1200)
  final isDesktop = screenWidth > 1200;

  // Valores padrão para celular
  int crossAxisCount = 2;         // Quantidade de colunas no grid
  double childAspectRatio = 1.2;  // Proporção largura/altura dos cards
  double spacing = 16;            // Espaçamento entre os cards

  // Se for desktop, ajusta os valores
  if (isDesktop) {
    crossAxisCount = itemCount > 8 ? 5 : 4; // Mais colunas se houver muitos itens
    childAspectRatio = 2.0;                 // Cards mais "esticados"
    spacing = 10;                           // Menos espaço entre os cards
  // Se for tablet, ajusta os valores
  } else if (isTablet) {
    crossAxisCount = itemCount > 6 ? 4 : 3; // Mais colunas se houver muitos itens
    childAspectRatio = 1.15;                // Proporção um pouco menor
    spacing = 18;                           // Espaçamento um pouco maior
  // Se for celular, ajusta os valores
  } else {
    crossAxisCount = itemCount > 4 ? 2 : 1; // Só uma coluna se poucos itens
    childAspectRatio = 1.4;                 // Cards mais altos
    spacing = 16;                           // Espaçamento padrão
  }

  // Retorna a configuração do grid com os valores definidos
  return GridConfig(
    crossAxisCount: crossAxisCount,
    crossAxisSpacing: spacing,
    mainAxisSpacing: spacing,
    childAspectRatio: childAspectRatio,
  );
}
