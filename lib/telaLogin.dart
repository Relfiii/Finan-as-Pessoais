import 'package:flutter/material.dart';
import 'telas/telaPrincipal.dart';
import 'cadastroConta.dart';
import 'alterarSenha.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TelaLogin extends StatefulWidget {
  static const routeName = '/login';
  @override
  _TelaLoginState createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  // Mensagem de erro fixa
  bool loginInvalido = false;

  // Novo estado para controlar a visibilidade da senha
  bool _senhaVisivel = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF181818),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/logo-NossoDinDin.png',
                width: 100, // ajuste o tamanho conforme necessário
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Color(0xFF222222),
                  borderRadius: BorderRadius.circular(16),
                ),
                width: 320,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Entrar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFF181818),
                        hintText: 'E-mail',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: senhaController,
                      obscureText: !_senhaVisivel,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFF181818),
                        hintText: 'Senha',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                        // Adiciona o ícone de olho
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
                      style: TextStyle(color: Colors.white),
                    ),
                    if (loginInvalido)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                        child: Text(
                          'E-mail ou senha inválidos.',
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF00E6D8),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () async {
                          setState(() {
                            loginInvalido = false;
                          });
                          try {
                            final response = await Supabase.instance.client.auth.signInWithPassword(
                              email: emailController.text,
                              password: senhaController.text,
                            );
                            if (response.user != null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => HomeScreen()),
                              );
                            } else {
                              setState(() {
                                loginInvalido = true;
                              });
                            }
                          } on AuthException catch (e) {
                            // Tradução das mensagens mais comuns do Supabase
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
                              // Mensagem padrão em português
                              mensagem = 'Erro: ' + mensagem;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(mensagem),
                                backgroundColor: Colors.red,
                              ),
                            );
                            setState(() {
                              loginInvalido = true;
                            });
                          } catch (e) {
                            setState(() {
                              loginInvalido = true;
                            });
                          }
                        },
                        child: Text('Entrar'),
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF181818),
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
                        child: Text(
                          'Cadastrar conta',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
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
                        child: Text(
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
    );
  }
}
