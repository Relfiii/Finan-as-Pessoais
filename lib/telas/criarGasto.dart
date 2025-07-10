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
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime tempPicked = _selectedDate;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF23272F),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 16,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                CalendarDatePicker(
                  initialDate: tempPicked,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  currentDate: DateTime.now(),
                  onDateChanged: (picked) {
                    tempPicked = picked;
                  },
                  selectableDayPredicate: (date) => true,
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
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat("d 'de' MMMM 'de' y", 'pt_BR').format(date);
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

                    // Salva no Supabase
                    final result = await Supabase.instance.client
                        .from('gastos')
                        .insert({
                          'descricao': _descController.text,
                          'valor': valor,
                          'data': _selectedDate.toIso8601String(),
                          'categoria_id': _selectedCategoria!.id,
                          'user_id': Supabase.instance.client.auth.currentUser?.id,
                          'recorrente': _tipoGasto == 'Recorrente',
                          'intervalo_meses': _tipoGasto == 'Recorrente' ? _intervaloSelecionado : null,
                        })
                        .select()
                        .single();

                    // Adiciona no provedor local (ajuste conforme seu modelo Gasto)
                    final gastoProvider = context.read<GastoProvider>();
                    gastoProvider.addGasto(
                      Gasto(
                        id: result['id'],
                        descricao: _descController.text,
                        valor: valor,
                        data: _selectedDate,
                        categoriaId: _selectedCategoria!.id,
                      ),
                    );

                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao salvar gasto: $e')),
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
