import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<void> _processarComandoIA(BuildContext context, String comando, CategoryProvider categoryProvider) async {
    final comandoLower = comando.toLowerCase();
    // Adicionar categoria
    if (comandoLower.startsWith('criar categoria') || comandoLower.startsWith('nova categoria')) {
      // Extrai o nome da categoria
      final nome = comando.replaceFirst(RegExp(r'(?i)criar categoria|nova categoria|adicionar categoria'), '').trim();
      if (nome.isNotEmpty) {
        // Simula o mesmo fluxo do botão de criar categoria
        final userId = Supabase.instance.client.auth.currentUser!.id;
        final response = await Supabase.instance.client
          .from('categorias')
          .insert({'nome': nome, 'user_id': userId})
          .select()
          .single();

          final newCategory = Category(
            id: response['id'],
            name: nome,
            description: '',
            color: const Color(0xFFB983FF),
            icon: Icons.category,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await categoryProvider.addCategory(newCategory);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Categoria "$nome" criada!')),
        );
      }
    }
    // Deletar categoria
    else if (comandoLower.startsWith('deletar categoria') || comandoLower.startsWith('remover categoria')) {
      final nome = comandoLower
          .replaceFirst('deletar categoria', '')
          .replaceFirst('remover categoria', '')
          .trim();
      debugPrint('Comando para deletar categoria recebido: $nome');
      if (nome.isNotEmpty) {
        final categorias = categoryProvider.categories;
        Category? categoria;
        try {
          categoria = categorias.firstWhere(
            (cat) => cat.name.toLowerCase() == nome.toLowerCase(),
          );
          debugPrint('Categoria encontrada: ${categoria.name}');
        } catch (e) {
          categoria = null;
          debugPrint('Categoria não encontrada: $nome');
        }
        if (categoria != null) {
          await categoryProvider.deleteCategory(categoria.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Categoria "${categoria.name}" deletada!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Categoria "$nome" não encontrada!')),
          );
        }
      } else {
        debugPrint('Erro: Nome da categoria vazio no comando de deleção.');
      }
    }
  }

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
                final categoryProvider = Provider.of<CategoryProvider>(ctx, listen: false);
                await _processarComandoIA(ctx, comando, categoryProvider);
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
  // Popup de confirmação para deletar categoria
  Future<void> _confirmarDeletarCategoria(BuildContext context, dynamic categoria, CategoryProvider categoryProvider) async {
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
                    'Tem certeza que deseja deletar esta categoria?',
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
                          categoria.name.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
                          final gastoProvider = Provider.of<GastoProvider>(context, listen: false);
                          final gastosDaCategoria = await gastoProvider.getGastosPorMes(categoria.id, _currentDate);
                          if (gastosDaCategoria.isNotEmpty) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Não é possível deletar a categoria "${categoria.name}" pois ela possui gastos cadastrados.')),
                            );
                            return;
                          }
                          try {
                            await categoryProvider.deleteCategory(categoria.id);
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Categoria "${categoria.name}" deletada!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            // Recarrega categorias e gastos após deletar
                            await Provider.of<CategoryProvider>(context, listen: false).loadCategories();
                            await Provider.of<GastoProvider>(context, listen: false).loadGastos();
                            await _carregarTodasCategorias();
                          } catch (e) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erro ao deletar categoria: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
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

  Future<void> _editarCategoriaPopup(BuildContext context, CategoryProvider categoryProvider, dynamic categoria) async {
    final TextEditingController controller = TextEditingController(text: categoria.name);
    DateTime selectedDate = categoria.createdAt ?? DateTime.now();

    // Função para formatar a data
    String _formatDate(DateTime date) {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    // Função de calendário customizado
    Future<void> _pickEditDate(StateSetter setState) async {
      DateTime tempPicked = selectedDate;
      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          return Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              AnimatedPadding(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 320),
                    decoration: BoxDecoration(
                      color: const Color(0xFF181828).withOpacity(0.98),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.7),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const Text(
                          'Selecione a data da categoria',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 260,
                          child: Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Color(0xFFB983FF),
                                onPrimary: Colors.black,
                                surface: Color(0xFF23272F),
                                onSurface: Colors.white,
                              ),
                              dialogBackgroundColor: const Color(0xFF23272F),
                              textTheme: const TextTheme(
                                bodyMedium: TextStyle(color: Colors.white),
                              ),
                              datePickerTheme: const DatePickerThemeData(
                                backgroundColor: Color(0xFF23272F),
                                headerBackgroundColor: Color(0xFF181828),
                                dayStyle: TextStyle(color: Colors.white),
                                todayBackgroundColor: MaterialStatePropertyAll(Color(0xFFB983FF)),
                                todayForegroundColor: MaterialStatePropertyAll(Colors.black),
                                rangePickerBackgroundColor: Color(0xFF23272F),
                              ),
                            ),
                            child: CalendarDatePicker(
                              initialDate: tempPicked,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              currentDate: DateTime.now(),
                              onDateChanged: (picked) {
                                tempPicked = picked;
                              },
                              selectableDayPredicate: (date) => true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                  side: const BorderSide(color: Colors.white24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancelar'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB983FF),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  setState(() {
                                    selectedDate = tempPicked;
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Confirmar'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: const Color(0xFF181818),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text('Editar Categoria', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Nome da categoria',
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
                  GestureDetector(
                    onTap: () => _pickEditDate(setState),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: TextEditingController(text: _formatDate(selectedDate)),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Calendário',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: const Color(0xFF23273A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          suffixIcon: const Icon(Icons.calendar_today, color: Colors.white54),
                        ),
                        readOnly: true,
                      ),
                    ),
                  ),
                ],
              ),
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
                onPressed: () async {
                  try {
                    // Atualiza o nome se foi alterado
                    final novoNome = controller.text.trim();
                    if (novoNome.isNotEmpty && novoNome != categoria.name) {
                      await categoryProvider.updateCategoryName(categoria.id, novoNome);
                    }

                    // Atualiza a data no Supabase
                    if (selectedDate != categoria.createdAt) {
                      await Supabase.instance.client
                          .from('categorias')
                          .update({'data': selectedDate.toIso8601String()})
                          .eq('id', categoria.id);
                          
                      // Recarrega os dados para atualizar a UI
                      await _carregarTodasCategorias();
                      await Provider.of<CategoryProvider>(context, listen: false).loadCategories();
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Categoria atualizada com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao atualizar categoria: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        );
      },
    );
  }

  double _totalGastosMes = 0.0;
  DateTime _currentDate = DateTime.now();
  List<dynamic> _todasCategorias = [];
  PageController _pageController = PageController(initialPage: 1000, viewportFraction: 0.95); // Viewport fraction para mostrar um pouco das páginas adjacentes
  int _currentPageIndex = 1000;
  double _currentPageValue = 1000.0;

  @override
  void initState() {
    super.initState();
    _carregarTodasCategorias();
    _carregarTotalGastosMes();
    
    // Adiciona listener para animações suaves durante o scroll
    _pageController.addListener(() {
      if (mounted && _pageController.hasClients) {
        setState(() {
          _currentPageValue = _pageController.page ?? 1000.0;
        });
      }
    });
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
      print('User ID: $userId');
      
      // Busca TODAS as categorias do usuário, independente do mês
      final categoriasResponse = await supabase
          .from('categorias')
          .select()
          .eq('user_id', userId)
          .order('data', ascending: true);

      print('Categorias encontradas: ${categoriasResponse.length}');
      if (categoriasResponse.isNotEmpty) {
        for (var cat in categoriasResponse) {
          print('Categoria: ${cat['nome']} - Data: ${cat['data']} - ID: ${cat['id']}');
        }
      }

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
    
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400), // Aumentei a duração para mais suavidade
      curve: Curves.easeInOutCubic, // Curva mais sofisticada
    );
  }

  void _previousMonth() async {
    // Feedback tátil
    if (Theme.of(context).platform == TargetPlatform.android || 
        Theme.of(context).platform == TargetPlatform.iOS) {
      HapticFeedback.lightImpact();
    }
    
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400), // Aumentei a duração para mais suavidade
      curve: Curves.easeInOutCubic, // Curva mais sofisticada
    );
  }

  void _onPageChanged(int page) async {
    int difference = page - _currentPageIndex;
    _currentPageIndex = page;
    
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + difference);
    });
    
    print('Navegando via swipe para: ${_currentDate.month}/${_currentDate.year}');
    // Apenas recarrega o total de gastos, as categorias permanecem fixas
    await _carregarTotalGastosMes();
    setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E1E2C), Color(0xFF121212)],
                  ),
                ),
              ),
            ),
            SafeArea(
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
                                      'Gastos',
                                      style: TextStyle(
                                        color: Color(0xFFB983FF),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 40),
                              ],
                            ),
                          ),
                          const Divider(color: Colors.white24, thickness: 1, indent: 24, endIndent: 24),
                          // Exibição do valor total de gastos do mês selecionado
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total de Gastos:',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(_totalGastosMes),
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Navegação de mês/ano com efeito parallax
                          AnimatedBuilder(
                            animation: _pageController,
                            builder: (context, child) {
                              // Efeito de parallax no header - verificação de segurança
                              double parallaxOffset = 0.0;
                              if (_pageController.hasClients && _pageController.position.haveDimensions) {
                                parallaxOffset = (_currentPageValue - 1000) * 2;
                              }
                              
                              return Transform.translate(
                                offset: Offset(parallaxOffset, 0),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.chevron_left, color: Colors.white70),
                                          onPressed: _previousMonth,
                                        ),
                                      ),
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 300),
                                        transitionBuilder: (child, animation) {
                                          return SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(0, 0.3),
                                              end: Offset.zero,
                                            ).animate(animation),
                                            child: FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: Text(
                                          _formatMonthYear(_currentDate),
                                          key: ValueKey(_currentDate.toString()),
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.chevron_right, color: Colors.white70),
                                          onPressed: _nextMonth,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          // Indicador visual da navegação
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                // Mostra 5 pontos, com o do meio sendo o atual
                                double opacity = index == 2 ? 1.0 : 0.3;
                                double size = index == 2 ? 8.0 : 6.0;
                                
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: size,
                                  height: size,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFB983FF).withOpacity(opacity),
                                    borderRadius: BorderRadius.circular(size / 2),
                                  ),
                                );
                              }),
                            ),
                          ),
                          // TopBar com botões de categoria, gasto e caixa de texto
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 16, top: 8, bottom: 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(width: 10),
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
                                    icon: const Icon(Icons.category, color: Color(0xFFB983FF)),
                                    label: const Text('Categoria'),
                                    onPressed: () async {
                                      await showDialog(
                                        context: context,
                                        builder: (context) => const AddCategoryDialog(),
                                      );
                                      // Recarrega categorias e cards após criar
                                      await Provider.of<CategoryProvider>(context, listen: false).loadCategories();
                                      await _carregarTodasCategorias();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Botão de gasto
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
                                      // Recarrega categorias e gastos após criar despesa
                                      await Provider.of<CategoryProvider>(context, listen: false).loadCategories();
                                      await Provider.of<GastoProvider>(context, listen: false).loadGastos();
                                      // Força o recarregamento das categorias para capturar categorias recorrentes
                                      await _carregarTodasCategorias();
                                      await _carregarTotalGastosMes();
                                      // Atualiza o estado para garantir que a UI seja reconstruída
                                      setState(() {});
                                    },
                                  ),
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
                              ],
                            ),
                          ),
                          // Cards de categorias do mês selecionado com PageView
                          SizedBox(
                            height: constraints.maxHeight * 0.6, // Define altura específica para o PageView
                            child: PageView.builder(
                              controller: _pageController,
                              onPageChanged: _onPageChanged,
                              itemBuilder: (context, index) {
                                // Calcula o mês baseado no índice da página
                                int monthOffset = index - 1000;
                                DateTime pageDate = DateTime(DateTime.now().year, DateTime.now().month + monthOffset);
                                
                                // Calcula o fator de escala e opacidade baseado na posição da página
                                double value = 1.0;
                                if (_pageController.hasClients && _pageController.position.haveDimensions) {
                                  value = _pageController.page ?? 1000.0;
                                  value = (1 - (index - value).abs()).clamp(0.0, 1.0);
                                }
                                
                                return AnimatedBuilder(
                                  animation: _pageController,
                                  builder: (context, child) {
                                    // Efeito de parallax e escala - garantindo valores válidos
                                    double scale = (0.8 + (value * 0.2)).clamp(0.5, 1.0);
                                    double opacity = (0.5 + (value * 0.5)).clamp(0.0, 1.0);
                                    
                                    return Transform.scale(
                                      scale: scale,
                                      child: Opacity(
                                        opacity: opacity,
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                                            child: _todasCategorias.isEmpty
                                                ? Center(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(
                                                          Icons.category_outlined,
                                                          size: 64,
                                                          color: Colors.white.withOpacity(0.3),
                                                        ),
                                                        const SizedBox(height: 16),
                                                        Text(
                                                          'Nenhuma categoria criada.',
                                                          style: TextStyle(
                                                            color: Colors.white54, 
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : GridView.builder(
                                                    shrinkWrap: true,
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    padding: EdgeInsets.zero,
                                                    itemCount: _todasCategorias.length,
                                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 2,
                                                      crossAxisSpacing: 12,
                                                      mainAxisSpacing: 12,
                                                      childAspectRatio: 1.6,
                                                    ),
                                                    itemBuilder: (context, categoryIndex) {
                                                      final cat = _todasCategorias[categoryIndex];
                                                      final gastoProvider = Provider.of<GastoProvider>(context, listen: false);
                                                      final valor = gastoProvider.totalPorCategoriaMes(cat.id, pageDate);
                                                      
                                                      // Animação staggered para os cards
                                                      return TweenAnimationBuilder<double>(
                                                        duration: Duration(milliseconds: 200 + (categoryIndex * 50)),
                                                        tween: Tween(begin: 0.0, end: 1.0),
                                                        curve: Curves.easeOutBack,
                                                        builder: (context, animationValue, child) {
                                                          // Garante que os valores estejam dentro do range válido
                                                          final clampedAnimation = animationValue.clamp(0.0, 1.0);
                                                          final translateY = 20 * (1 - clampedAnimation);
                                                          
                                                          return Transform.translate(
                                                            offset: Offset(0, translateY),
                                                            child: Opacity(
                                                              opacity: clampedAnimation,
                                                              child: CategoryCard(
                                                                categoryName: cat.name,
                                                                valor: valor,
                                                                onTap: () async {
                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (context) => DetalhesCategoriaScreen(
                                                                        categoryId: cat.id,
                                                                        categoryName: cat.name,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                onEdit: () async {
                                                                  final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
                                                                  await _editarCategoriaPopup(context, categoryProvider, cat);
                                                                },
                                                                onDelete: () async {
                                                                  final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
                                                                  await _confirmarDeletarCategoria(context, cat, categoryProvider);
                                                                },
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
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
                          // Spacer para empurrar o rodapé para baixo
                          const SizedBox(height: 16),
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
                  );
                },
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

// Declare a instância de CaixaTextoOverlay no escopo correto
final CaixaTextoOverlay caixaTextoOverlay = CaixaTextoOverlay();