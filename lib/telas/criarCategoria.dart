import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../modelos/categoria.dart';
import '../../provedor/categoriaProvedor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final TextEditingController _categoryNameController = TextEditingController();

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Center(
        child: AlertDialog(
          backgroundColor: const Color(0xFF181818),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            'Adicionar Categoria',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crie uma categoria para organizar seus gastos.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _categoryNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Nome da Categoria',
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
              onPressed: () async {
                final name = _categoryNameController.text.trim();
                if (name.isNotEmpty) {
                  final supabase = Supabase.instance.client;
                  // Insere na base e obtém o id gerado
                  final response = await supabase
                      .from('categorias')
                      .insert({'nome': name})
                      .select()
                      .single();
              
                  // Cria o objeto local com o id do banco
                  final newCategory = Category(
                    id: response['id'], // Usa o id do Supabase
                    name: name,
                    description: '',
                    color: const Color(0xFFB983FF),
                    icon: Icons.category,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
              
                  // Adiciona na lista local do provider
                  final categoryProvider = context.read<CategoryProvider>();
                  await categoryProvider.addCategory(newCategory);
              
                  _categoryNameController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Criar Categoria'),
            ),
          ],
        ),
      ),
    );
  }
}
