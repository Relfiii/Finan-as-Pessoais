import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class AddReceitaDialog extends StatefulWidget {
  final TextEditingController? descricaoController;
  final TextEditingController? valorController;
  final bool isEditing;

  const AddReceitaDialog({
    super.key,
    this.descricaoController,
    this.valorController,
    this.isEditing = false,
  });

  @override
  State<AddReceitaDialog> createState() => _AddReceitaDialogState();
}

class _AddReceitaDialogState extends State<AddReceitaDialog> {
  late final TextEditingController _descricaoController;
  late final MoneyMaskedTextController _valorController;
  bool _loading = false;
  DateTime _selectedInvestDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _descricaoController = widget.descricaoController ?? TextEditingController();
    _valorController = widget.valorController != null
        ? widget.valorController as MoneyMaskedTextController
        : MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.', initialValue: 0.0);
    _selectedInvestDate = DateTime.now();
  }

  @override
  void dispose() {
    if (widget.descricaoController == null) _descricaoController.dispose();
    if (widget.valorController == null) {
      _valorController.updateValue(0.0); // Garante que o valor seja válido antes de limpar
      _valorController.dispose();
    }
    super.dispose();
  }

  // Função para abrir o seletor de data (igual ao criarGasto.dart)
  Future<void> _pickInvestDate() async {
    DateTime tempPicked = _selectedInvestDate;
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
                                setState(() {
                                  _selectedInvestDate = tempPicked;
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

  String _formatInvestDate(DateTime date) {
    // Formato igual ao criarGasto.dart
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Future<void> _adicionarReceita() async {
    final descricao = _descricaoController.text.trim();
    String valorTexto = _valorController.text.trim();

    // Remove símbolo de moeda e espaços extras
    valorTexto = valorTexto.replaceAll('R\$', '').replaceAll(' ', '');
    valorTexto = valorTexto.replaceAll('.', '').replaceAll(',', '.');
    double valor = 0.0;
    try {
      valor = double.parse(valorTexto);
    } catch (_) {
      valor = 0.0;
    }

    final data = _selectedInvestDate; // Usa a data selecionada do investimento

    if (descricao.isEmpty || valor <= 0) return;

    setState(() => _loading = true);

    if (widget.isEditing) {
      setState(() => _loading = false);
      if (mounted) Navigator.of(context).pop(true);
      return;
    }

    final response = await Supabase.instance.client
        .from('entradas')
        .insert({
          'descricao': descricao,
          'valor': valor,
          'data': data.toIso8601String().substring(0, 10),
          'user_id': Supabase.instance.client.auth.currentUser!.id,
        })
        .select('id')
        .single();

    setState(() => _loading = false);

    if (response['id'] == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar receita!')),
        );
      }
      return;
    }

    _descricaoController.clear();
    _valorController.clear();
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Center(
        child: AlertDialog(
          backgroundColor: const Color(0xFF181818),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            widget.isEditing ? 'Editar Receita' : 'Nova Receita',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEditing
                    ? 'Edite os dados da receita selecionada.'
                    : 'Adicione uma receita ao seu controle financeiro.',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descricaoController,
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
                controller: _valorController,
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
              const SizedBox(height: 12),
              // Botão de data do investimento
              GestureDetector(
                onTap: _pickInvestDate,
                child: AbsorbPointer(
                  child: TextField(
                    controller: TextEditingController(text: _formatInvestDate(_selectedInvestDate)),
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
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
              onPressed: _loading ? null : _adicionarReceita,
              child: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : Text(widget.isEditing ? 'Salvar' : 'Adicionar'),
            ),
          ],
        ),
      ),
    );
  }
}