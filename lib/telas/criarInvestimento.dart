import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

Future<bool?> showCriarInvestimentoDialog(BuildContext context) async {
  final descricaoController = TextEditingController();
  final valorController = MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.', initialValue: 0.0);
  String tipoSelecionado = 'Renda Fixa';
  bool _loading = false;
  final tipoOutroController = TextEditingController();
  DateTime _selectedInvestDate = DateTime.now();

  // Função para abrir o seletor de data (igual ao criarGasto.dart)
  Future<void> _pickInvestDate(StateSetter setState) async {
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
            // Modal do calendário
            AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 320), // reduzido de 400 para 320
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20), // padding menor
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
                      SizedBox(
                        width: 260, // largura máxima do calendário
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
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  return showDialog<bool>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Center(
            child: AlertDialog(
              backgroundColor: const Color(0xFF181828),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: const [
                  Text('Novo Investimento', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixText: 'R\$ ',
                      prefixStyle: const TextStyle(color: Colors.white),
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
                  // Botão de data do investimento
                  GestureDetector(
                    onTap: () => _pickInvestDate(setState),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: TextEditingController(text: _formatInvestDate(_selectedInvestDate)),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Data do investimento',
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
                  onPressed: () => Navigator.of(context).pop(false),
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
                          final valor = double.tryParse(valorTexto) ?? 0.0;
                          final descricao = descricaoController.text;
                          final data = _selectedInvestDate.toIso8601String(); // Usa a data selecionada
                          final tipo = tipoSelecionado == 'Outro' ? tipoOutroController.text : tipoSelecionado;

                          await Supabase.instance.client
                              .from('investimentos')
                              .insert({
                                'descricao': descricao,
                                'valor': valor,
                                'data': data,
                                'tipo': tipo,
                                'tipo_outro': tipoSelecionado == 'Outro' ? tipoOutroController.text : null,
                                'user_id': Supabase.instance.client.auth.currentUser!.id,
                              });

                          setState(() => _loading = false);
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
