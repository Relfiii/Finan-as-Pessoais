import 'package:flutter/material.dart';
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
  void initState() {
    super.initState();
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Color(0xFF00C853),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Entrar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 28,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF1E1E1E),
                          ),
                          child: Image.asset(
                            'assets/logo-NossoDinDin.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 60),
                        
                        // Campos de input
                        Container(
                          constraints: BoxConstraints(maxWidth: 400),
                          child: Column(
                            children: [
                              // Campo Email
                              TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: 'E-mail',
                                  labelStyle: TextStyle(color: Color(0xFF757575)),
                                  hintText: 'Digite seu e-mail',
                                  hintStyle: TextStyle(color: Color(0xFF555555)),
                                  filled: true,
                                  fillColor: Color(0xFF2C2C2C),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Color(0xFF424242)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Color(0xFF00E676)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Color(0xFF424242)),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 16),
                              
                              // Campo Senha
                              TextField(
                                controller: senhaController,
                                obscureText: !_senhaVisivel,
                                decoration: InputDecoration(
                                  labelText: 'Senha',
                                  labelStyle: TextStyle(color: Color(0xFF757575)),
                                  hintText: 'Digite sua senha',
                                  hintStyle: TextStyle(color: Color(0xFF555555)),
                                  filled: true,
                                  fillColor: Color(0xFF2C2C2C),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Color(0xFF424242)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Color(0xFF00E676)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Color(0xFF424242)),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _senhaVisivel ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                      color: Color(0xFF757575),
                                      size: 20,
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
                              
                              // Mensagem de erro
                              if (mensagemErro != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: mensagemErro!.contains('Fazendo login') || 
                                             mensagemErro!.contains('Login realizado') ||
                                             mensagemErro!.contains('Carregando') 
                                          ? Color(0xFF00C853).withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: mensagemErro!.contains('Fazendo login') || 
                                               mensagemErro!.contains('Login realizado') ||
                                               mensagemErro!.contains('Carregando')
                                            ? Color(0xFF00C853)
                                            : Colors.red,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          mensagemErro!.contains('Fazendo login') || 
                                          mensagemErro!.contains('Login realizado') ||
                                          mensagemErro!.contains('Carregando')
                                              ? Icons.info_outline
                                              : Icons.error_outline,
                                          color: mensagemErro!.contains('Fazendo login') || 
                                                 mensagemErro!.contains('Login realizado') ||
                                                 mensagemErro!.contains('Carregando')
                                              ? Color(0xFF00C853)
                                              : Colors.red,
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            mensagemErro!,
                                            style: TextStyle(
                                              color: mensagemErro!.contains('Fazendo login') || 
                                                     mensagemErro!.contains('Login realizado') ||
                                                     mensagemErro!.contains('Carregando')
                                                  ? Color(0xFF00C853)
                                                  : Colors.red,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 32),
                              
                              // Botão Entrar
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF00E676),
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
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
                                      setState(() {
                                        mensagemErro = 'Fazendo login...';
                                      });
                                      
                                      final response = await supabase.auth.signInWithPassword(
                                        email: email,
                                        password: senhaController.text,
                                      );
                                      
                                      if (response.user != null) {
                                        setState(() {
                                          mensagemErro = 'Login realizado! Carregando dados...';
                                        });
                                        
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
                                        
                                        // Carrega dados com timeout
                                        try {
                                          setState(() {
                                            mensagemErro = 'Carregando transações...';
                                          });
                                          await context.read<TransactionProvider>().loadTransactions().timeout(Duration(seconds: 10));
                                          
                                          setState(() {
                                            mensagemErro = 'Carregando categorias...';
                                          });
                                          await context.read<CategoryProvider>().loadCategories().timeout(Duration(seconds: 10));
                                          
                                          setState(() {
                                            mensagemErro = 'Carregando gastos...';
                                          });
                                          await context.read<GastoProvider>().loadGastos().timeout(Duration(seconds: 10));

                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (context) => HomeScreen()),
                                          );
                                        } catch (timeoutError) {
                                          print('Erro de timeout ao carregar dados: $timeoutError');
                                          // Mesmo com erro no carregamento, permite entrar no app
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (context) => HomeScreen()),
                                          );
                                        }
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
                                  child: Text(
                                    'Entrar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Botão Cadastrar
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
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
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Link Esqueci a senha
                              GestureDetector(
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
                                    color: Color(0xFF9C27B0),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
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
            ),
          ],
        ),
      ),
    );
  }
}