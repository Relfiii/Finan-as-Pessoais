import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlterarSenhaPage extends StatefulWidget {
  const AlterarSenhaPage({Key? key}) : super(key: key);

  @override
  State<AlterarSenhaPage> createState() => _AlterarSenhaPageState();
}

class _AlterarSenhaPageState extends State<AlterarSenhaPage> {
  final _formKey = GlobalKey<FormState>();
  final _senhaAtualController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _loading = false;
  bool _senhaVisivelAtual = false;
  bool _senhaVisivelNova = false;
  bool _senhaVisivelConfirma = false;
  String? _erroSenhaDiferente;
  String? _erroSenhaAtual;
  String? _erroSenhaNovaIgualAtual;
  bool get _senhasIguais =>
      _novaSenhaController.text == _confirmarSenhaController.text &&
      _novaSenhaController.text.isNotEmpty &&
      _confirmarSenhaController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _novaSenhaController.addListener(_onSenhaChanged);
    _confirmarSenhaController.addListener(_onSenhaChanged);
  }

  void _onSenhaChanged() {
    setState(() {
      // Verifica se nova senha é igual à atual
      if (_novaSenhaController.text.isNotEmpty &&
          _senhaAtualController.text.isNotEmpty &&
          _novaSenhaController.text == _senhaAtualController.text) {
        _erroSenhaNovaIgualAtual = 'A senha precisa ser diferente da atual';
      } else {
        _erroSenhaNovaIgualAtual = null;
      }

      if (_confirmarSenhaController.text.isEmpty ||
          _novaSenhaController.text.isEmpty) {
        _erroSenhaDiferente = null;
      } else if (_novaSenhaController.text != _confirmarSenhaController.text) {
        _erroSenhaDiferente = 'As senhas não coincidem';
      } else {
        _erroSenhaDiferente = null;
      }
    });
  }

  @override
  void dispose() {
    _novaSenhaController.removeListener(_onSenhaChanged);
    _confirmarSenhaController.removeListener(_onSenhaChanged);
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _alterarSenha() async {
    setState(() {
      _erroSenhaDiferente = null;
      _erroSenhaAtual = null;
      _erroSenhaNovaIgualAtual = null;
    });
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado.');

      // Tenta autenticar com a senha atual
      await supabase.auth.signInWithPassword(
        email: user.email ?? '',
        password: _senhaAtualController.text,
      );


      // Atualiza a senha no auth
      await supabase.auth.updateUser(
        UserAttributes(password: _novaSenhaController.text),
      );

      // Garante que o usuário está na tabela usuarios (sem senha)
      await supabase.from('usuarios').upsert({
        'id': user.id,
        'nome': user.userMetadata?['nome'],
        'email': user.email,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha alterada com sucesso!')),
        );
        Navigator.of(context).pop();
      }
    } on AuthException catch (e) {
      String mensagem = e.message;
      if (mensagem.contains('Credenciais de login inválidas') ||
          mensagem.toLowerCase().contains('senha') ||
          mensagem.toLowerCase().contains('password') ||
          mensagem.toLowerCase().contains('invalid login credentials')) {
        setState(() {
          _erroSenhaAtual = 'Senha incorreta';
        });
      } else if (mensagem.contains('A senha deve ter pelo menos')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('A nova senha deve ter pelo menos 6 caracteres.'), backgroundColor: Colors.red),
        );
      } else {
        // Traduza a mensagem padrão para português, se possível
        String mensagemPt = mensagem;
        if (mensagem.toLowerCase().contains('invalid login credentials')) {
          mensagemPt = 'E-mail ou senha inválidos.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagemPt), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao alterar senha: $e'), backgroundColor: Colors.red),
      );
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        'Alterar Senha',
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
                const Divider(color: Colors.white24, thickness: 1, indent: 24, endIndent: 24),
                // Formulário de alteração de senha no mesmo estilo do editarPerfil
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      children: [
                        const Text(
                          'Senha Atual',
                          style: TextStyle(color: Color(0xFFB983FF), fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Card(
                          color: Colors.white.withOpacity(0.03),
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextFormField(
                              controller: _senhaAtualController,
                              obscureText: !_senhaVisivelAtual,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Digite sua senha atual',
                                hintStyle: const TextStyle(color: Colors.white38),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _senhaVisivelAtual ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.grey[400],
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _senhaVisivelAtual = !_senhaVisivelAtual;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Informe sua senha atual';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        if (_erroSenhaAtual != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 2, bottom: 8),
                            child: Text(
                              _erroSenhaAtual!,
                              style: const TextStyle(color: Colors.red, fontSize: 13),
                            ),
                          ),
                        const SizedBox(height: 18),
                        const Text(
                          'Nova Senha',
                          style: TextStyle(color: Color(0xFFB983FF), fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Card(
                          color: Colors.white.withOpacity(0.03),
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextFormField(
                              controller: _novaSenhaController,
                              obscureText: !_senhaVisivelNova,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Digite a nova senha',
                                hintStyle: const TextStyle(color: Colors.white38),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _senhaVisivelNova ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.grey[400],
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _senhaVisivelNova = !_senhaVisivelNova;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Informe a nova senha';
                                }
                                if (value.length < 6) {
                                  return 'A senha deve ter pelo menos 6 caracteres';
                                }
                                if (_senhaAtualController.text.isNotEmpty &&
                                    value == _senhaAtualController.text) {
                                  return null; // Mensagem controlada pelo listener
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        if (_erroSenhaNovaIgualAtual != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 2, bottom: 8),
                            child: Text(
                              _erroSenhaNovaIgualAtual!,
                              style: const TextStyle(color: Colors.red, fontSize: 13),
                            ),
                          ),
                        const SizedBox(height: 18),
                        const Text(
                          'Confirmar nova senha',
                          style: TextStyle(color: Color(0xFFB983FF), fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Card(
                          color: Colors.white.withOpacity(0.03),
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextFormField(
                              controller: _confirmarSenhaController,
                              obscureText: !_senhaVisivelConfirma,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Confirme a nova senha',
                                hintStyle: const TextStyle(color: Colors.white38),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _senhaVisivelConfirma ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.grey[400],
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _senhaVisivelConfirma = !_senhaVisivelConfirma;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Confirme a nova senha';
                                }
                                if (value != _novaSenhaController.text) {
                                  return null; // Mensagem controlada pelo listener
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        if (_erroSenhaDiferente != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 2, bottom: 8),
                            child: Text(
                              _erroSenhaDiferente!,
                              style: const TextStyle(color: Colors.red, fontSize: 13),
                            ),
                          ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB983FF),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: (_loading || !_senhasIguais) ? null : _alterarSenha,
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Salvar nova senha', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
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
