import 'package:flutter/material.dart';
import 'dart:ui';
import 'telas/telaPrincipal.dart';
import 'cadastroConta.dart';
import 'alterarSenha.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'provedor/transicaoProvedor.dart';
import 'provedor/categoriaProvedor.dart';
import 'provedor/gastoProvedor.dart';

class TelaLogin extends StatefulWidget {
  static const routeName = '/login';
  @override
  _TelaLoginState createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  bool loginInvalido = false;
  bool _senhaVisivel = false;
  String? mensagemErro;

  @override
  Widget build(BuildContext context) {
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      const SizedBox(width: 40),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Entrar',
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
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/logo-NossoDinDin.png',
                            width: 100,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            width: 320,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xFF181818),
                                    hintText: 'E-mail',
                                    hintStyle: TextStyle(color: Colors.grey[400]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: senhaController,
                                  obscureText: !_senhaVisivel,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xFF181818),
                                    hintText: 'Senha',
                                    hintStyle: TextStyle(color: Colors.grey[400]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide.none,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _senhaVisivel ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.grey[400],
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _senhaVisivel = !_senhaVisivel;
                                        });
                                      },
                                    ),
                                  ),
                                  style: const TextStyle(color: Colors.white),
                                ),
                                if (mensagemErro != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                                    child: Text(
                                      mensagemErro!,
                                      style: const TextStyle(color: Colors.red, fontSize: 14),
                                    ),
                                  ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00E6D8),
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        loginInvalido = false;
                                        mensagemErro = null;
                                      });
                                      final supabase = Supabase.instance.client;
                                      final email = emailController.text.trim();

                                      if (email.isEmpty || senhaController.text.isEmpty) {
                                        setState(() {
                                          mensagemErro = 'Por favor, preencha todos os campos.';
                                          loginInvalido = true;
                                        });
                                        return;
                                      }

                                      try {
                                        final response = await supabase.auth.signInWithPassword(
                                          email: email,
                                          password: senhaController.text,
                                        );
                                        if (response.user != null) {
                                          // Adiciona ou atualiza o usuário na tabela 'usuarios'
                                          final user = response.user;
                                          if (user != null) {
                                            String? nome;
                                            try {
                                              final userData = user.userMetadata;
                                              if (userData != null && userData['nome'] != null) {
                                                nome = userData['nome'] as String?;
                                              }
                                            } catch (_) {}
                                            await supabase.from('usuarios').upsert({
                                              'id': user.id,
                                              'email': user.email,
                                              if (nome != null) 'nome': nome,
                                            });
                                          }
                                          await context.read<TransactionProvider>().loadTransactions();
                                          await context.read<CategoryProvider>().loadCategories();
                                          await context.read<GastoProvider>().loadGastos();

                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (context) => HomeScreen()),
                                          );
                                        } else {
                                          setState(() {
                                            mensagemErro = 'E-mail ou senha inválidos.';
                                            loginInvalido = true;
                                          });
                                        }
                                      } on AuthException catch (e) {
                                        String mensagem = e.message;
                                        if (mensagem.contains('Invalid login credentials')) {
                                          mensagem = 'E-mail ou senha inválidos.';
                                        } else if (mensagem.contains('Email not confirmed')) {
                                          mensagem = 'Confirme seu e-mail antes de entrar.';
                                        } else if (mensagem.contains('User already registered')) {
                                          mensagem = 'Usuário já cadastrado.';
                                        } else if (mensagem.contains('Password should be at least')) {
                                          mensagem = 'A senha deve ter pelo menos 6 caracteres.';
                                        } else if (mensagem.contains('User not found')) {
                                          mensagem = 'Usuário não encontrado.';
                                        } else if (mensagem.contains('Network error')) {
                                          mensagem = 'Erro de conexão. Verifique sua internet.';
                                        } else {
                                          mensagem = 'Erro: ' + mensagem;
                                        }
                                        setState(() {
                                          mensagemErro = mensagem;
                                          loginInvalido = true;
                                        });
                                      } catch (e) {
                                        setState(() {
                                          mensagemErro = 'Erro ao tentar login.';
                                          loginInvalido = true;
                                        });
                                      }
                                    },
                                    child: const Text('Entrar'),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF181818),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    onPressed: () {
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CadastroContaScreen(),
                                          ),
                                        );
                                      });
                                    },
                                    child: const Text(
                                      'Cadastrar conta',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AlterarSenhaPage(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Esqueceu a senha?',
                                      style: TextStyle(
                                        color: Color(0xFFB983FF),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
        ],
      ),
    );
  }
}
