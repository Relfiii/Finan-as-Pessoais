import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../telas/criarReceita.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:intl/intl.dart';

class ControleReceitasPage extends StatefulWidget {
  const ControleReceitasPage({Key? key}) : super(key: key);

  @override
  State<ControleReceitasPage> createState() => _ControleReceitasPageState();
}

class _ControleReceitasPageState extends State<ControleReceitasPage> {
  final List<Map<String, dynamic>> receitas = [];
  double _totalReceitas = 0.0;
  DateTime _currentDate = DateTime.now();
  PageController _pageController = PageController(initialPage: 1000, viewportFraction: 0.95);
  int _currentPageIndex = 1000;

  Future<void> _editarReceita(String receitaId) async {
    // Encontra a receita pelo ID
    final receita = receitas.firstWhere((r) => r['id'] == receitaId);
    final index = receitas.indexWhere((r) => r['id'] == receitaId);
    
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
                content: SizedBox(
                  width: double.maxFinite,
                  child: Column(
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
                      const SizedBox(height: 12),
                    // Botão de data do investimento (igual aos outros modais)
                    GestureDetector(
                      onTap: () async {
                        DateTime tempPicked = receita['data'];
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
                                            'Selecione a data do investimento',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Opacity(
                                            opacity: 0.8,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF23272F),
                                                borderRadius: BorderRadius.circular(18),
                                                border: Border.all(
                                                  color: const Color(0xFFB983FF).withOpacity(0.5),
                                                  width: 2,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.15),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                              child: SizedBox(
                                                width: 240,
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
                                                      backgroundColor: Colors.transparent,
                                                      headerBackgroundColor: Color(0xFF181828),
                                                      dayStyle: TextStyle(color: Colors.white),
                                                      todayBackgroundColor: MaterialStatePropertyAll(Color(0xFFB983FF)),
                                                      todayForegroundColor: MaterialStatePropertyAll(Colors.black),
                                                      rangePickerBackgroundColor: Colors.transparent,
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
                                                    // Atualiza a data no objeto local
                                                    receitas[index]['data'] = tempPicked;
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
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          controller: TextEditingController(
                            text: '${receita['data'].day.toString().padLeft(2, '0')}/'
                                  '${receita['data'].month.toString().padLeft(2, '0')}/'
                                  '${receita['data'].year}',
                          ),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Data do investimento',
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: const Color(0xFF23272F),
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

  Future<void> _deletarReceita(String receitaId) async {
    // Encontra a receita pelo ID
    final receita = receitas.firstWhere((r) => r['id'] == receitaId);
    final index = receitas.indexWhere((r) => r['id'] == receitaId);
    
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
    final inicioMes = DateTime(_currentDate.year, _currentDate.month, 1);
    final fimMes = DateTime(_currentDate.year, _currentDate.month + 1, 1).subtract(const Duration(days: 1));
    final response = await Supabase.instance.client
        .from('entradas')
        .select()
        .eq('user_id', userId)
        .gte('data', inicioMes.toIso8601String())
        .lte('data', fimMes.toIso8601String())
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
      _totalReceitas = receitas.fold(0.0, (soma, r) => soma + (r['valor'] ?? 0.0));
    });
  }

  String _formatMonthYear(DateTime date) {
    return '${_capitalizeMonth(DateFormat('MMMM', 'pt_BR').format(date))} ${date.year}';
  }

  String _capitalizeMonth(String month) {
    if (month.isEmpty) return month;
    return month[0].toUpperCase() + month.substring(1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextMonth() async {
    // Feedback tátil
    if (Theme.of(context).platform == TargetPlatform.android || 
        Theme.of(context).platform == TargetPlatform.iOS) {
      HapticFeedback.lightImpact();
    }
    
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _previousMonth() async {
    // Feedback tátil
    if (Theme.of(context).platform == TargetPlatform.android || 
        Theme.of(context).platform == TargetPlatform.iOS) {
      HapticFeedback.lightImpact();
    }
    
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onPageChanged(int page) async {
    int difference = page - _currentPageIndex;
    _currentPageIndex = page;
    
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + difference);
    });
    
    print('Navegando via swipe para: ${_currentDate.month}/${_currentDate.year}');
    await _carregarReceitas();
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> _carregarReceitasDoMesEspecifico(DateTime data) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final inicioMes = DateTime(data.year, data.month, 1);
    final fimMes = DateTime(data.year, data.month + 1, 1).subtract(const Duration(days: 1));
    final response = await Supabase.instance.client
        .from('entradas')
        .select()
        .eq('user_id', userId)
        .gte('data', inicioMes.toIso8601String())
        .lte('data', fimMes.toIso8601String())
        .order('data', ascending: false);

    List<Map<String, dynamic>> receitasDoMes = [];
    for (final item in response) {
      receitasDoMes.add({
        'id': item['id'],
        'descricao': item['descricao'],
        'valor': double.tryParse(item['valor'].toString()) ?? 0.0,
        'data': DateTime.parse(item['data']),
      });
    }
    return receitasDoMes;
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
              onRefresh: _carregarReceitas,
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
                  // Navegação de mês/ano com efeito parallax
                  Padding(
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
                  // Cards de receitas do mês selecionado com PageView
                  Expanded(
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
                                  child: FutureBuilder<List<Map<String, dynamic>>>(
                                    future: _carregarReceitasDoMesEspecifico(pageDate),
                                    builder: (context, snapshot) {
                                      List<Map<String, dynamic>> receitasDoMes = snapshot.data ?? [];
                                      
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: receitasDoMes.isEmpty
                                            ? Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.attach_money_outlined,
                                                      size: 64,
                                                      color: Colors.white.withOpacity(0.3),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Text(
                                                      'Nenhuma receita cadastrada neste mês.',
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
                                            : ListView.separated(
                                                padding: EdgeInsets.zero,
                                                itemCount: receitasDoMes.length,
                                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                                itemBuilder: (context, receitaIndex) {
                                                  final receita = receitasDoMes[receitaIndex];
                                                  
                                                  // Animação staggered para os cards
                                                  return TweenAnimationBuilder<double>(
                                                    duration: Duration(milliseconds: 200 + (receitaIndex * 50)),
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
                                                          child: ReceitaCard(
                                                            descricao: receita['descricao'],
                                                            valor: receita['valor'],
                                                            data: receita['data'],
                                                            onEdit: () => _editarReceita(receita['id']),
                                                            onDelete: () => _deletarReceita(receita['id']),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
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

    return GestureDetector(
      onTap: () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 140, // Altura ajustada
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A2A2A), Color(0xFF1E1E1E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
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
              splashColor: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
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
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.white54, size: 20),
                          color: const Color(0xFF2A2A2A),
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
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, color: Color(0xFFB983FF), size: 20),
                        const SizedBox(width: 6),
                        Text(
                          valorFormatado,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 158, 214, 158),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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