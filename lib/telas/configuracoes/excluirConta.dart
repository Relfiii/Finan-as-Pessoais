import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../telaLogin.dart';
import '../../../provedor/transicaoProvedor.dart';

class ExcluirContaPage extends StatefulWidget {
  const ExcluirContaPage({Key? key}) : super(key: key);

  @override
  State<ExcluirContaPage> createState() => _ExcluirContaPageState();
}

class _ExcluirContaPageState extends State<ExcluirContaPage> {
  final TextEditingController _controller = TextEditingController();
  bool _confirmado = false;
  String _nome = '';
  String _email = '';
  bool _carregandoDados = true;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    final userId = user?.id;
    if (userId == null) {
      setState(() => _carregandoDados = false);
      return;
    }
    final data = await supabase.from('usuarios').select('nome, email').eq('id', userId).single();
    setState(() {
      _nome = data['nome'] ?? '';
      _email = data['email'] ?? '';
      _carregandoDados = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_carregandoDados) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
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
                      const Text(
                        'Excluir Conta',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                // Header com avatar, nome e e-mail
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: const Color(0xFF7B2FF2),
                        child: const Icon(Icons.account_circle, size: 54, color: Colors.white),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nome,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            Text(
                              _email,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, thickness: 1, indent: 24, endIndent: 24),
                // Conteúdo centralizado para web
                Expanded(
                  child: Center(
                    child: Container(
                      width: kIsWeb ? 1000 : double.infinity,
                      constraints: kIsWeb 
                        ? const BoxConstraints(maxWidth: 1000)
                        : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle('Atenção'),
                            const Text(
                              'Esta ação é irreversível. Todos os seus dados serão apagados e não poderão ser recuperados.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Digite "EXCLUIR" para confirmar:',
                              style: TextStyle(
                                color: Color(0xFFB983FF),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _controller,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white10,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: 'EXCLUIR',
                                hintStyle: const TextStyle(color: Colors.white38),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _confirmado = value.trim() == 'EXCLUIR';
                                });
                              },
                            ),
                            const Spacer(),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.delete_forever),
                                label: const Text(
                                  'Excluir minha conta',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                onPressed: _confirmado
                                    ? () async {
                                        final supabase = Supabase.instance.client;
                                        try {
                                          await supabase.rpc('delete_current_user');
                                          await supabase.auth.signOut();

                                          if (mounted) {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (context) => const ContaExcluidaDialog(),
                                            );
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Erro ao excluir conta: $e')),
                                          );
                                        }
                                      }
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 16),
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

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8, left: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFB983FF),
          fontSize: 15,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class ContaExcluidaDialog extends StatelessWidget {
  const ContaExcluidaDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Center(
        child: AlertDialog(
          backgroundColor: const Color(0xFF181818),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            'Conta excluída',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Sua conta foi excluída (logout realizado). Para exclusão total, contate o suporte.',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB983FF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => TelaLogin()),
                  (route) => false,
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}
