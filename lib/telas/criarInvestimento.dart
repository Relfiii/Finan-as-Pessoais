import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

Future<bool?> showCriarInvestimentoDialog(BuildContext context) async {
  final descricaoController = TextEditingController();
  final valorController = TextEditingController();
  String tipoSelecionado = 'Renda Fixa';
  bool _loading = false;
  final tipoOutroController = TextEditingController();

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
                          final data = DateTime.now().toIso8601String();
                          final tipo = tipoSelecionado == 'Outro' ? tipoOutroController.text : tipoSelecionado;

                          await Supabase.instance.client
                              .from('investimentos')
                              .insert({
                                'descricao': descricao,
                                'valor': valor,
                                'data': data,
                                'tipo': tipo,
                                'tipo_outro': tipoSelecionado == 'Outro' ? tipoOutroController.text : null,
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
