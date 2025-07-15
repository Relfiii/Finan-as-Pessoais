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
  double _totalGastosMes = 0.0;
  DateTime _currentDate = DateTime.now();
  List<dynamic> _todasCategorias = [];

  @override
  void initState() {
    super.initState();
    _carregarTodasCategorias();
    _carregarTotalGastosMes();
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
    
    await _carregarTotalGastosMes();
  }

  Future<void> _carregarTotalGastosMes() async {
    final gastoProvider = Provider.of<GastoProvider>(context, listen: false);
    final gastosMes = await gastoProvider.getGastosPorMes(null, _currentDate);
    double total = 0.0;
    for (final gasto in gastosMes) {
      final data = gasto.data;
      if (data.month == _currentDate.month && data.year == _currentDate.year) {
        total += gasto.valor;
      }
    }
    setState(() {
      _totalGastosMes = total;
    });
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
    
    await _carregarTotalGastosMes();
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
    
    await _carregarTotalGastosMes();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        print('Executando refresh da tela...');
        await Provider.of<CategoryProvider>(context, listen: false).loadCategories();
        await Provider.of<GastoProvider>(context, listen: false).loadGastos();
        await _carregarTodasCategorias();
        await _carregarTotalGastosMes();
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
                                    NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(_totalGastosMes),
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
                                        await showDialog(
                                          context: context,
                                          builder: (context) => const AddExpenseDialog(),
                                        );
                                        await Provider.of<CategoryProvider>(context, listen: false).loadCategories();
                                        await Provider.of<GastoProvider>(context, listen: false).loadGastos();
                                        await _carregarTodasCategorias();
                                        await _carregarTotalGastosMes();
                                        setState(() {});
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
                                            final gastoProvider = Provider.of<GastoProvider>(context, listen: false);
                                            final valor = gastoProvider.totalPorCategoriaMes(cat.id, _currentDate);
                                            
                                            return CategoryCard(
                                              categoryName: cat.name,
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
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Editar categoria: ${cat.name}'),
                                                    backgroundColor: Color(0xFFB983FF),
                                                  ),
                                                );
                                              },
                                              onDelete: () async {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Deletar categoria: ${cat.name}'),
                                                    backgroundColor: Color(0xFFEF5350),
                                                  ),
                                                );
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
  final screenWidth = MediaQuery.of(context).size.width; // Largura da tela atual
  final isTablet = screenWidth > 600;                    // Considera tablet se largura > 600px
  final isDesktop = screenWidth > 1200;                  // Considera desktop se largura > 1200px
  
  int crossAxisCount = 2;        // Número de colunas padrão para mobile
  double childAspectRatio = 1.2; // Proporção largura/altura padrão para mobile
  double spacing = 16;           // Espaçamento padrão para mobile
  
  if (isDesktop) {
    // Se for desktop: mais colunas, cards menores
    crossAxisCount = itemCount > 8 ? 5 : 4; // 5 colunas se muitos itens, senão 4
    childAspectRatio = 2.0;                 // Cards mais "quadrados"
    spacing = 10;                           // Espaçamento maior
  } else if (isTablet) {
    // Se for tablet: quantidade média de colunas
    crossAxisCount = itemCount > 6 ? 4 : 3; // 4 colunas se muitos itens, senão 3
    childAspectRatio = 1.15;                // Cards levemente mais altos
    spacing = 18;                           // Espaçamento intermediário
  } else {
    // Se for mobile: menos colunas, cards maiores
    crossAxisCount = itemCount > 4 ? 3 : 2; // 3 colunas se muitos itens, senão 2
    childAspectRatio = 1.5;                // Cards mais "altos"
    spacing = 16;                           // Espaçamento menor
  }
  
  return GridConfig(
    crossAxisCount: crossAxisCount,         // Quantidade de colunas no grid
    crossAxisSpacing: spacing,              // Espaçamento horizontal entre os cards
    mainAxisSpacing: spacing,               // Espaçamento vertical entre os cards
    childAspectRatio: childAspectRatio,     // Proporção largura/altura dos cards
  );
}