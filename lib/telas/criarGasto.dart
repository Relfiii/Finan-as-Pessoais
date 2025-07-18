import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../modelos/categoria.dart';
import '../../provedor/categoriaProvedor.dart';
import '../../provedor/gastoProvedor.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart';
import '../../modelos/gasto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class AddExpenseDialog extends StatefulWidget {
  final Category? categoriaSelecionada; // Adiciona o parâmetro opcional

  const AddExpenseDialog({
    super.key,
    this.categoriaSelecionada,
  });

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final TextEditingController _descController = TextEditingController();
  late final MoneyMaskedTextController _valueController;
  Category? _selectedCategoria;
  String _tipoGasto = 'Despesa única';
  DateTime _selectedDate = DateTime.now();
  bool _localeReady = false;

  final List<String> _tipos = ['Despesa única', 'Recorrente'];

  // Adiciona variáveis para mensagens de erro
  String? _descError;
  String? _valueError;
  String? _categoriaError;

  // Adicionar lista de intervalos de meses
  final List<int> _intervalosMeses = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  int? _intervaloSelecionado;

  // Adicionar variáveis para parcelamento
  final List<String> _opcoesParcelamento = ['2x', '3x', '4x', '5x', '6x', '7x', '8x', '9x', '10x', '11x', '12x', 'Personalizado'];
  String _tipoUnicaSelecionado = 'À vista'; // À vista ou Parcelado
  String _parcelamentoSelecionado = '2x';
  final TextEditingController _parcelasCustomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initLocale();
    _valueController = MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.', initialValue: 0.0);
    _selectedCategoria = widget.categoriaSelecionada; // Inicializa com a categoria selecionada
  }

  Future<void> _initLocale() async {
    await initializeDateFormatting('pt_BR', null);
    if (mounted) {
      setState(() {
        _localeReady = true;
      });
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _valueController.dispose();
    _parcelasCustomController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime tempPicked = _selectedDate;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Stack(
          children: [
            // Fundo fosco com blur
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
                        'Selecione a data',
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
                                setState(() {
                                  _selectedDate = tempPicked;
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

  String _formatDate(DateTime date) {
    return DateFormat("d 'de' MMMM 'de' y", 'pt_BR').format(date);
  }

  int _getNumeroParcelasAtual() {
    // Para tipos que não são "Despesa única", sempre retorna 1
    if (_tipoGasto != 'Despesa única') {
      return 1;
    }
    
    // Para "Despesa única", verifica se é "À vista" ou "Parcelado"
    if (_tipoUnicaSelecionado == 'À vista') {
      return 1;
    }
    
    // Para "Despesa única" + "Parcelado", verifica as opções de parcelamento
    if (_parcelamentoSelecionado == 'Outros' && _parcelasCustomController.text.isNotEmpty) {
      return int.tryParse(_parcelasCustomController.text) ?? 1;
    }
    
    if (_parcelamentoSelecionado != 'Outros') {
      return int.tryParse(_parcelamentoSelecionado.replaceAll('x', '')) ?? 1;
    }
    
    return 1;
  }

  Widget _buildResumoParcelamento() {
    final valor = double.tryParse(
      _valueController.text.replaceAll('.', '').replaceAll(',', '.')
    ) ?? 0.0;
    
    if (valor <= 0) return const SizedBox.shrink();
    
    final numeroParcelas = _getNumeroParcelasAtual();
    final valorParcela = valor / numeroParcelas;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF23272F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB983FF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.credit_card, color: const Color(0xFFB983FF), size: 20),
              const SizedBox(width: 8),
              Text(
                'Parcelamento:',
                style: const TextStyle(
                  color: Color(0xFFB983FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${numeroParcelas}x de R\$ ${valorParcela.toStringAsFixed(2).replaceAll('.', ',')}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'As parcelas serão distribuídas pelos próximos $numeroParcelas meses',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildResumoRecorrencia() {
    final valor = double.tryParse(
      _valueController.text.replaceAll('.', '').replaceAll(',', '.')
    ) ?? 0.0;
    
    if (valor <= 0 || _intervaloSelecionado == null) return const SizedBox.shrink();
    
    final valorTotal = valor * _intervaloSelecionado!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF23272F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB983FF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.repeat, color: const Color(0xFFB983FF), size: 20),
              const SizedBox(width: 8),
              Text(
                'Despesa Recorrente:',
                style: const TextStyle(
                  color: Color(0xFFB983FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')} por mês',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total em ${_intervaloSelecionado} meses: R\$ ${valorTotal.toStringAsFixed(2).replaceAll('.', ',')}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_localeReady) {
      return const Center(child: CircularProgressIndicator());
    }
    final categorias = context.watch<CategoryProvider>().categories;
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
                'Adicionar despesa',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.of(context).pop(),
                splashRadius: 20,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preencha os detalhes da sua despesa.',
                  //Use a IA para sugerir uma categoria!',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 20),
                // Descrição
                TextField(
                  controller: _descController,
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
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.auto_awesome, color: Color(0xFFB983FF)),
                      onPressed: () {
                        // Aqui pode chamar a IA para sugerir categoria
                      },
                    ),
                    errorText: _descError, // Exibe mensagem de erro
                  ),
                ),
                const SizedBox(height: 14),
                // Valor
                TextField(
                  controller: _valueController,
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
                    errorText: _valueError, // Exibe mensagem de erro
                  ),
                ),
                const SizedBox(height: 14),
                // Categoria
                DropdownButtonFormField<Category>(
                  value: _selectedCategoria,
                  items: categorias.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat.name, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (cat) => setState(() => _selectedCategoria = cat),
                  dropdownColor: const Color(0xFF23272F),
                  decoration: InputDecoration(
                    hintText: 'Categoria',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF23272F),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    errorText: _categoriaError, // Exibe mensagem de erro
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                ),
                const SizedBox(height: 14),
                // Tipo de gasto
                DropdownButtonFormField<String>(
                  value: _tipoGasto,
                  items: _tipos.map((tipo) {
                    return DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (tipo) => setState(() => _tipoGasto = tipo!),
                  dropdownColor: const Color(0xFF23272F),
                  decoration: InputDecoration(
                    hintText: 'Tipo de despesa',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF23272F),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                ),
                const SizedBox(height: 14),
                // Sub-opção para Despesa única (À vista ou Parcelado)
                if (_tipoGasto == 'Despesa única') ...[
                  DropdownButtonFormField<String>(
                    value: _tipoUnicaSelecionado,
                    items: ['À vista', 'Parcelado'].map((tipo) {
                      return DropdownMenuItem(
                        value: tipo,
                        child: Text(tipo, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (tipo) => setState(() => _tipoUnicaSelecionado = tipo!),
                    dropdownColor: const Color(0xFF23272F),
                    decoration: InputDecoration(
                      hintText: 'Forma de pagamento',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF23272F),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                  ),
                  const SizedBox(height: 14),
                ],
                // Opções de parcelamento (apenas quando Despesa única + Parcelado for selecionado)
                if (_tipoGasto == 'Despesa única' && _tipoUnicaSelecionado == 'Parcelado') ...[
                  DropdownButtonFormField<String>(
                    value: _parcelamentoSelecionado,
                    items: _opcoesParcelamento.map((opcao) {
                      return DropdownMenuItem(
                        value: opcao,
                        child: Text(opcao, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (opcao) => setState(() {
                      _parcelamentoSelecionado = opcao!;
                      if (opcao != 'Outros') {
                        _parcelasCustomController.clear();
                      }
                    }),
                    dropdownColor: const Color(0xFF23272F),
                    decoration: InputDecoration(
                      hintText: 'Número de parcelas',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF23272F),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                  ),
                  const SizedBox(height: 14),
                ],
                // Campo para número de parcelas customizado (apenas quando "Outros" for selecionado)
                if (_tipoGasto == 'Despesa única' && _tipoUnicaSelecionado == 'Parcelado' && _parcelamentoSelecionado == 'Outros') ...[
                  TextField(
                    controller: _parcelasCustomController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Número de parcelas (ex: 15)',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF23272F),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      suffixIcon: const Icon(Icons.credit_card, color: Colors.white54),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                // Card de resumo do parcelamento (apenas quando Despesa única + Parcelado for selecionado)
                if (_tipoGasto == 'Despesa única' && _tipoUnicaSelecionado == 'Parcelado') ...[
                  _buildResumoParcelamento(),
                  const SizedBox(height: 14),
                ],
                const SizedBox(height: 14),
                // Intervalo de meses (apenas para despesas recorrentes)
                if (_tipoGasto == 'Recorrente') ...[
                  DropdownButtonFormField<int>(
                    value: _intervaloSelecionado,
                    items: _intervalosMeses.map((meses) {
                      return DropdownMenuItem(
                        value: meses,
                        child: Text('$meses meses', style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (meses) => setState(() => _intervaloSelecionado = meses),
                    dropdownColor: const Color(0xFF23272F),
                    decoration: InputDecoration(
                      hintText: 'Intervalo de meses',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF23272F),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      errorText: _tipoGasto == 'Recorrente' && _intervaloSelecionado == null
                          ? 'Por favor, selecione o intervalo de meses.'
                          : null,
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                  ),
                  const SizedBox(height: 14),
                  // Card de resumo da recorrência
                  _buildResumoRecorrencia(),
                ],
                const SizedBox(height: 14),
                // Data
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextField(
                      controller: TextEditingController(text: _formatDate(_selectedDate)),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Data',
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
                const SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB983FF),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                onPressed: () async {
                  setState(() {
                    // Valida os campos e define mensagens de erro
                    _descError = _descController.text.isEmpty ? 'Por favor, preencha a descrição.' : null;
                    _valueError = _valueController.text == '0,00' ? 'Por favor, preencha o valor.' : null;
                    _categoriaError = _selectedCategoria == null ? 'Por favor, selecione uma categoria.' : null;

                    if (_tipoGasto == 'Recorrente') {
                      _categoriaError ??= _intervaloSelecionado == null ? 'Por favor, selecione o intervalo de meses.' : null;
                    }

                    // Validação do parcelamento personalizado
                    if (_parcelamentoSelecionado == 'Outros') {
                      final parcelas = int.tryParse(_parcelasCustomController.text);
                      if (parcelas == null || parcelas < 1 || parcelas > 999) {
                        _categoriaError ??= 'Por favor, digite um número válido de parcelas (1-999).';
                      }
                    }
                  });

                  // Se houver erros, não prossegue
                  if (_descError != null || _valueError != null || _categoriaError != null) {
                    return;
                  }

                  final valor = double.tryParse(
                    _valueController.text.replaceAll('.', '').replaceAll(',', '.')
                  ) ?? 0.0;

                  try {
                    // Verifica se a categoria selecionada existe no banco de dados
                    await Supabase.instance.client
                        .from('categorias')
                        .select()
                        .eq('id', _selectedCategoria!.id)
                        .single();

                    final gastoProvider = context.read<GastoProvider>();
                    
                    if (_tipoGasto == 'Recorrente' && _intervaloSelecionado != null) {
                      // Para despesas recorrentes, criar apenas um gasto na base
                      final userId = Supabase.instance.client.auth.currentUser?.id;
                      print('Iniciando criação de despesa recorrente para ${_intervaloSelecionado} meses');
                      print('Categoria selecionada: ${_selectedCategoria!.name} (ID: ${_selectedCategoria!.id})');

                      // Insere apenas um gasto recorrente
                      final result = await Supabase.instance.client
                          .from('gastos')
                          .insert({
                            'descricao': _descController.text,
                            'valor': valor,
                            'data': _selectedDate.toIso8601String(),
                            'data_compra': _selectedDate.toIso8601String(), // Data original da compra
                            'categoria_id': _selectedCategoria!.id,
                            'user_id': userId,
                            'recorrente': true,
                            'intervalo_meses': _intervaloSelecionado,
                            'parcela_atual': 1,
                            'total_parcelas': 1,
                          })
                          .select()
                          .single();

                      // Adiciona o gasto recorrente no provedor
                      gastoProvider.addGasto(
                        Gasto(
                          id: result['id'],
                          descricao: _descController.text,
                          valor: valor,
                          data: _selectedDate,
                          dataCompra: _selectedDate,
                          categoriaId: _selectedCategoria!.id,
                          parcelaAtual: 1,
                          totalParcelas: 1,
                          recorrente: true,
                          intervalo_meses: _intervaloSelecionado,
                        ),
                      );

                      // Recarrega as categorias para atualizar a UI
                      await context.read<CategoryProvider>().loadCategories();

                      // Recarrega os gastos do banco de dados para incluir o novo gasto recorrente
                      await gastoProvider.reloadGastos();

                      print('Categorias e gastos recarregados no provider');

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Despesa recorrente criada para ${_intervaloSelecionado} meses!'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 4),
                        ),
                      );

                      // Retorna informações sobre o gasto criado para permitir navegação
                      Navigator.of(context).pop({
                        'success': true,
                        'isRecorrente': true,
                        'categoriaId': _selectedCategoria!.id,
                        'categoriaNome': _selectedCategoria!.name,
                        'intervaloMeses': _intervaloSelecionado,
                      });
                    } else {
                      // Para despesas únicas ou parceladas
                      final numeroParcelas = _getNumeroParcelasAtual();
                      final valorParcela = valor / numeroParcelas;
                      
                      if (numeroParcelas == 1) {
                        // Despesa única (à vista)
                        final result = await Supabase.instance.client
                            .from('gastos')
                            .insert({
                              'descricao': _descController.text,
                              'valor': valor,
                              'data': _selectedDate.toIso8601String(),
                              'data_compra': _selectedDate.toIso8601String(), // Data original da compra
                              'categoria_id': _selectedCategoria!.id,
                              'user_id': Supabase.instance.client.auth.currentUser?.id,
                              'recorrente': false,
                              'intervalo_meses': null,
                              'parcela_atual': 1,
                              'total_parcelas': 1,
                            })
                            .select()
                            .single();

                        // Adiciona no provedor local
                        gastoProvider.addGasto(
                          Gasto(
                            id: result['id'],
                            descricao: _descController.text,
                            valor: valor,
                            data: _selectedDate,
                            dataCompra: _selectedDate, // Data original da compra
                            categoriaId: _selectedCategoria!.id,
                            parcelaAtual: 1,
                            totalParcelas: 1,
                            recorrente: false,
                            intervalo_meses: null,
                          ),
                        );
                        
                        // Força atualização dos totais
                        gastoProvider.forceUpdateTotals();
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Despesa criada com sucesso!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        // Despesa parcelada
                        final List<Map<String, dynamic>> gastosParcelados = [];
                        
                        for (int i = 1; i <= numeroParcelas; i++) {
                          final dataParcela = DateTime(
                            _selectedDate.year,
                            _selectedDate.month + (i - 1),
                            _selectedDate.day,
                          );
                          
                          gastosParcelados.add({
                            'descricao': _descController.text,
                            'valor': valorParcela,
                            'data': dataParcela.toIso8601String(),
                            'data_compra': _selectedDate.toIso8601String(), // Data original da compra
                            'categoria_id': _selectedCategoria!.id,
                            'user_id': Supabase.instance.client.auth.currentUser?.id,
                            'recorrente': false,
                            'intervalo_meses': null,
                            'parcela_atual': i,
                            'total_parcelas': numeroParcelas,
                          });
                        }
                        
                        // Insere todas as parcelas de uma vez
                        final gastosResults = await Supabase.instance.client
                            .from('gastos')
                            .insert(gastosParcelados)
                            .select();
                        
                        // Adiciona todos os gastos no provedor
                        for (final result in gastosResults) {
                          gastoProvider.addGasto(
                            Gasto(
                              id: result['id'],
                              descricao: _descController.text,
                              valor: result['valor'].toDouble(),
                              data: DateTime.parse(result['data']),
                              dataCompra: result['data_compra'] != null ? DateTime.parse(result['data_compra']) : null,
                              categoriaId: result['categoria_id'],
                              parcelaAtual: result['parcela_atual'] ?? 1,
                              totalParcelas: result['total_parcelas'] ?? 1,
                            ),
                          );
                        }
                        
                        // Força atualização dos totais
                        gastoProvider.forceUpdateTotals();
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Despesa parcelada em ${numeroParcelas}x criada com sucesso!'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    }

                    // Força uma última atualização antes de fechar o dialog
                    gastoProvider.forceUpdateTotals();
                    Navigator.of(context).pop(true);
                  } catch (e) {
                    print('Erro detalhado ao salvar gasto: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao salvar gasto: $e'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                },
                child: const Text('Adicionar despesa'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
