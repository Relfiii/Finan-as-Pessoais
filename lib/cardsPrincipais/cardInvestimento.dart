import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../telas/criarInvestimento.dart'; // Importa o novo arquivo

class ControleInvestimentosPage extends StatefulWidget {
  const ControleInvestimentosPage({Key? key}) : super(key: key);

  @override
  State<ControleInvestimentosPage> createState() => _ControleInvestimentosPageState();
}

class _ControleInvestimentosPageState extends State<ControleInvestimentosPage> {
  final List<Map<String, dynamic>> investimentos = [];
  double _totalInvestimentos = 0.0;
  DateTime _currentDate = DateTime.now();
  PageController _pageController = PageController(initialPage: 1000, viewportFraction: 0.95);
  int _currentPageIndex = 1000;

  Future<void> _carregarInvestimentos() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final inicioMes = DateTime(_currentDate.year, _currentDate.month, 1);
    final fimMes = DateTime(_currentDate.year, _currentDate.month + 1, 1).subtract(const Duration(days: 1));
    final response = await Supabase.instance.client
        .from('investimentos')
        .select()
        .eq('user_id', userId)
        .gte('data', inicioMes.toIso8601String())
        .lte('data', fimMes.toIso8601String())
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
          'user_id': Supabase.instance.client.auth.currentUser!.id,
        });
      }
      _totalInvestimentos = investimentos.fold(0.0, (soma, r) => soma + (r['valor'] ?? 0.0));
    });
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
    await _carregarInvestimentos();
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> _carregarInvestimentosDoMesEspecifico(DateTime data) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final inicioMes = DateTime(data.year, data.month, 1);
    final fimMes = DateTime(data.year, data.month + 1, 1).subtract(const Duration(days: 1));
    final response = await Supabase.instance.client
        .from('investimentos')
        .select()
        .eq('user_id', userId)
        .gte('data', inicioMes.toIso8601String())
        .lte('data', fimMes.toIso8601String())
        .order('data', ascending: false);

    List<Map<String, dynamic>> investimentosDoMes = [];
    for (final item in response) {
      investimentosDoMes.add({
        'id': item['id'],
        'descricao': item['descricao'],
        'valor': double.tryParse(item['valor'].toString()) ?? 0.0,
        'data': DateTime.parse(item['data']),
        'tipo': item['tipo'] ?? 'Outro',
        'user_id': Supabase.instance.client.auth.currentUser!.id,
      });
    }
    return investimentosDoMes;
  }

  String _formatMonthYear(DateTime date) {
    // Exibe mês por extenso e ano, exemplo: "Abril 2024"
    return '${_capitalizeMonth(_mesExtenso(date.month))} ${date.year}';
  }

  String _mesExtenso(int mes) {
    const meses = [
      '', 'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
    ];
    return meses[mes];
  }

  String _capitalizeMonth(String month) {
    if (month.isEmpty) return month;
    return month[0].toUpperCase() + month.substring(1);
  }

  Future<void> _editarInvestimento(String investimentoId) async {
    // Encontra o investimento pelo ID
    final investimento = investimentos.firstWhere((i) => i['id'] == investimentoId);
    
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
                backgroundColor: const Color(0xFF1E1E1E), // Cor de fundo mais clara
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                title: const Text(
                  'Editar Investimento',
                  style: TextStyle(color: Color(0xFFE0E0E0), fontWeight: FontWeight.bold), // Cor do texto
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edite os dados do investimento selecionado.',
                      style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 14), // Cor do texto
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descricaoController,
                      style: const TextStyle(color: Color(0xFFE0E0E0)), // Cor do texto
                      decoration: InputDecoration(
                        hintText: 'Descrição',
                        hintStyle: const TextStyle(color: Color(0xFFE0E0E0)), // Cor do texto
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E), // Cor de fundo mais clara
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF448AFF)), // Borda azul
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF448AFF)), // Borda azul
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF448AFF), width: 2), // Borda azul mais grossa quando focado
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: valorController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Color(0xFFE0E0E0)), // Cor do texto
                      inputFormatters: [
                        MoneyInputFormatter(
                          leadingSymbol: 'R\$',
                          useSymbolPadding: true,
                          thousandSeparator: ThousandSeparator.Period,
                        ),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Valor investido',
                        hintStyle: const TextStyle(color: Color(0xFFE0E0E0)), // Cor do texto
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E), // Cor de fundo mais clara
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF448AFF)), // Borda azul
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF448AFF)), // Borda azul
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF448AFF), width: 2), // Borda azul mais grossa quando focado
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: tipoSelecionado,
                      dropdownColor: const Color(0xFF1E1E1E), // Cor de fundo mais clara
                      style: const TextStyle(color: Color(0xFFE0E0E0)), // Cor do texto
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E), // Cor de fundo mais clara
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF448AFF)), // Borda azul
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF448AFF)), // Borda azul
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF448AFF), width: 2), // Borda azul mais grossa quando focado
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
                        child: Text(tipo, style: TextStyle(color: Color(0xFFE0E0E0))), // Cor do texto
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
                          style: const TextStyle(color: Color(0xFFE0E0E0)), // Cor do texto
                          decoration: InputDecoration(
                            hintText: 'Descreva o tipo de investimento',
                            hintStyle: const TextStyle(color: Color(0xFFE0E0E0)), // Cor do texto
                            filled: true,
                            fillColor: const Color(0xFF1E1E1E), // Cor de fundo mais clara
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF448AFF)), // Borda azul
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF448AFF)), // Borda azul
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF448AFF), width: 2), // Borda azul mais grossa quando focado
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
                    child: const Text('Cancelar', style: TextStyle(color: Color(0xFFE0E0E0))), // Cor do texto
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF448AFF), // Azul para investimentos
                      foregroundColor: const Color(0xFF121212), // Texto preto
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

  Future<void> _deletarInvestimento(String investimentoId) async {
    // Encontra o investimento pelo ID
    final investimento = investimentos.firstWhere((i) => i['id'] == investimentoId);
    
    final confirm = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E), // Cor de fundo mais clara
          title: const Text('Confirmar exclusão', style: TextStyle(color: Color(0xFFE0E0E0))), // Cor do texto
          content: const Text(
            'Deseja realmente deletar este investimento?',
            style: TextStyle(color: Color(0xFFE0E0E0)), // Cor do texto
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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo com cor sólida da paleta
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF121212), // Fundo da paleta
            ),
          ),
          Positioned(
            top: -60,
            right: -60,
            child: Icon(Icons.pie_chart, size: 180, color: Color(0xFF448AFF).withOpacity(0.04)), // Azul para investimentos
          ),
          SafeArea(
            child: Column(
              children: [
                // AppBar customizada (largura total)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFFB388FF)), // Cor dos acentos
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Investimentos',
                        style: TextStyle(
                          color: Color(0xFFB388FF), // Cor dos acentos
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFF303030), thickness: 1, indent: 24, endIndent: 24), // Cor mais clara para o divisor
                // Conteúdo centralizado
                Expanded(
                  child: Center(
                    child: Container(
                      width: kIsWeb ? 1000 : double.infinity,
                      constraints: kIsWeb ? const BoxConstraints(maxWidth: 1000) : null,
                      child: RefreshIndicator(
                        onRefresh: _carregarInvestimentos,
                        child: Column(
                          children: [
                            // Navegação de mês/ano com efeito parallax
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFF1E1E1E), // Cor de fundo mais clara
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.chevron_left, color: Color(0xFFE0E0E0)), // Cor do texto
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
                                        color: Color(0xFFB388FF), // Cor dos acentos
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFF1E1E1E), // Cor de fundo mais clara
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.chevron_right, color: Color(0xFFE0E0E0)), // Cor do texto
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
                                      color: Color(0xFF448AFF).withOpacity(opacity), // Azul para investimentos
                                      borderRadius: BorderRadius.circular(size / 2),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 44,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1E1E1E), // Cor de fundo mais clara
                                        foregroundColor: Color(0xFFE0E0E0), // Cor do texto
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          side: BorderSide(color: Color(0xFF448AFF)), // Borda azul
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        minimumSize: const Size(0, 44),
                                      ),
                                      icon: const Icon(Icons.add_chart, color: Color(0xFF448AFF)), // Azul para investimentos
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
                                      color: const Color(0xFF1E1E1E), // Cor de fundo mais clara
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Color(0xFF448AFF)), // Borda azul
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.savings, color: Color(0xFF448AFF), size: 18), // Azul para investimentos
                                        const SizedBox(width: 6),
                                        Text(
                                          toCurrencyString(
                                            _totalInvestimentos.toString(),
                                            leadingSymbol: 'R\$',
                                            useSymbolPadding: true,
                                            thousandSeparator: ThousandSeparator.Period,
                                          ),
                                          style: const TextStyle(
                                            color: Color(0xFF448AFF), // Azul para investimentos
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
                            // Cards de investimentos do mês selecionado com PageView
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
                                              future: _carregarInvestimentosDoMesEspecifico(pageDate),
                                              builder: (context, snapshot) {
                                                List<Map<String, dynamic>> investimentosDoMes = snapshot.data ?? [];
                                                // Calcule o total do mês
                                                double totalMes = investimentosDoMes.fold(0.0, (soma, r) => soma + (r['valor'] ?? 0.0));
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                                  child: Column(
                                                    children: [
                                                      // Total do mês
                                                      Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(bottom: 8.0, top: 4),
                                                          child: Text(
                                                            'Total do mês: ' +
                                                                toCurrencyString(
                                                                  totalMes.toString(),
                                                                  leadingSymbol: 'R\$',
                                                                  useSymbolPadding: true,
                                                                  thousandSeparator: ThousandSeparator.Period,
                                                                ),
                                                            style: const TextStyle(
                                                              color: Color(0xFF448AFF), // Azul para investimentos
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: investimentosDoMes.isEmpty
                                                            ? Center(
                                                                child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Icon(
                                                                      Icons.trending_up_outlined,
                                                                      size: 64,
                                                                      color: Color(0xFFE0E0E0).withOpacity(0.3), // Texto em cinza claro
                                                                    ),
                                                                    const SizedBox(height: 16),
                                                                    Text(
                                                                      'Nenhum investimento cadastrado neste mês.',
                                                                      style: TextStyle(
                                                                        color: Color(0xFFE0E0E0).withOpacity(0.7), // Texto em cinza claro
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
                                                                itemCount: investimentosDoMes.length,
                                                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                                                itemBuilder: (context, investimentoIndex) {
                                                                  final investimento = investimentosDoMes[investimentoIndex];
                                                                  
                                                                  // Animação staggered para os cards
                                                                  return TweenAnimationBuilder<double>(
                                                                    duration: Duration(milliseconds: 200 + (investimentoIndex * 50)),
                                                                    tween: Tween(begin: 0.0, end: 1.0),
                                                                    curve: Curves.easeOutBack,
                                                                    builder: (context, animationValue, child) {
                                                                      final clampedAnimation = animationValue.clamp(0.0, 1.0);
                                                                      final translateY = 20 * (1 - clampedAnimation);
                                                                      return Transform.translate(
                                                                        offset: Offset(0, translateY),
                                                                        child: Opacity(
                                                                          opacity: clampedAnimation,
                                                                          child: InvestimentoCard(
                                                                            descricao: investimento['descricao'],
                                                                            valor: investimento['valor'],
                                                                            data: investimento['data'],
                                                                            tipo: investimento['tipo'],
                                                                            onEdit: () => _editarInvestimento(investimento['id']),
                                                                            onDelete: () => _deletarInvestimento(investimento['id']),
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
                          ],
                        ),
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
        return const Color(0xFF448AFF); // Azul para investimentos
      case 'Renda Variável':
        return const Color(0xFFB388FF); // Cor dos acentos
      case 'Cripto':
        return const Color(0xFFEF5350); // Cor de saída
      case 'Imóveis':
        return const Color(0xFF00E676); // Verde para receitas
      default:
        return const Color(0xFF448AFF); // Azul padrão para investimentos
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
        color: Color(0xFF1E1E1E), // Cor de fundo mais clara que o fundo principal
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _corTipo(tipo), width: 1), // Borda colorida conforme o tipo
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
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
                        backgroundColor: _corTipo(tipo).withOpacity(0.15), // Fundo do avatar mais sutil
                        child: Icon(_iconeTipo(tipo), color: _corTipo(tipo), size: 24),
                        radius: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          descricao,
                          style: const TextStyle(
                            color: Color(0xFFE0E0E0), // Cor do texto
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Color(0xFFE0E0E0), size: 20), // Cor do texto
                        color: const Color(0xFF1E1E1E), // Cor de fundo mais clara
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
                            child: Text('Editar', style: TextStyle(color: Color(0xFFE0E0E0))), // Cor do texto
                          ),
                          const PopupMenuItem(
                            value: 'deletar',
                            child: Text('Deletar', style: TextStyle(color: Color(0xFFEF5350))), // Cor de saída
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
                          color: _corTipo(tipo).withOpacity(0.15), // Fundo do badge mais sutil
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
                        color: Color(0xFFE0E0E0), // Cor do texto
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