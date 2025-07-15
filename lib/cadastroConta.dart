import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'telaLogin.dart';

class CadastroContaScreen extends StatefulWidget {
  @override
  State<CadastroContaScreen> createState() => _CadastroContaScreenState();
}

class _CadastroContaScreenState extends State<CadastroContaScreen> {
   bool _obscureSenha = true;
   bool _obscureConfirme = true;
   final TextEditingController _senhaController = TextEditingController();
   final TextEditingController _confirmeController = TextEditingController();
   final TextEditingController _emailController = TextEditingController();
   final TextEditingController _nomeController = TextEditingController(); // Novo controlador para nome
   String? _senhaStatus;
   Color _senhaBorderColor = Colors.transparent;
   Color _confirmeBorderColor = Colors.transparent;
   String? _erroCamposVazios; // Adicionado para mensagem de erro
   Color _emailBorderColor = Colors.transparent; // Adicionado para borda do e-mail
   Color _nomeBorderColor = Colors.transparent; // Adicionado para borda do nome
   bool _mostrarErroSenhaVazia = false; // Flag para mostrar erro de senha vazia

    @override
  void initState() {
    super.initState();
    _confirmeController.addListener(_verificarSenhas);
    _senhaController.addListener(_verificarSenhas);
  }

  void _verificarSenhas() {
    final senha = _senhaController.text;
    final confirme = _confirmeController.text;
    setState(() {
      if (confirme.isEmpty) {
        _senhaStatus = null;
      } else if (senha == confirme) {
        _senhaStatus = "ok";
      } else {
        _senhaStatus = "erro";
      }
    });
  }

  @override
  void dispose() {
    _senhaController.dispose();
    _confirmeController.dispose();
    _emailController.dispose();
    _nomeController.dispose();
    super.dispose();
  }
  
  bool _isCadastroAtivo() {
    return _nomeController.text.isNotEmpty && // Adicionado nome
        _emailController.text.isNotEmpty &&
        _senhaController.text.isNotEmpty &&
        _confirmeController.text.isNotEmpty &&
        _senhaController.text == _confirmeController.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // Header igual telaLogin.dart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Color(0xFF00E6D8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Criar Conta',
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
                        // Logo igual telaLogin.dart
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
                              // Campo Nome
                              TextField(
                                controller: _nomeController,
                                decoration: InputDecoration(
                                  labelText: 'Nome',
                                  labelStyle: TextStyle(color: Color(0xFF757575)),
                                  hintText: 'Digite seu nome',
                                  hintStyle: TextStyle(color: Color(0xFF555555)),
                                  filled: true,
                                  fillColor: Color(0xFF2C2C2C),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: _nomeBorderColor == Colors.transparent ? Color(0xFF424242) : _nomeBorderColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: _nomeBorderColor == Colors.transparent ? Color(0xFF00E6D8) : _nomeBorderColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: _nomeBorderColor == Colors.transparent ? Color(0xFF424242) : _nomeBorderColor),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 16),
                              // Campo Email
                              TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'E-mail',
                                  labelStyle: TextStyle(color: Color(0xFF757575)),
                                  hintText: 'Digite seu e-mail',
                                  hintStyle: TextStyle(color: Color(0xFF555555)),
                                  filled: true,
                                  fillColor: Color(0xFF2C2C2C),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: _emailBorderColor == Colors.transparent ? Color(0xFF424242) : _emailBorderColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: _emailBorderColor == Colors.transparent ? Color(0xFF00E6D8) : _emailBorderColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: _emailBorderColor == Colors.transparent ? Color(0xFF424242) : _emailBorderColor),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 16),
                              // Campo Senha
                              TextField(
                                controller: _senhaController,
                                obscureText: _obscureSenha,
                                decoration: InputDecoration(
                                  labelText: 'Senha',
                                  labelStyle: TextStyle(color: Color(0xFF757575)),
                                  hintText: 'Digite sua senha',
                                  hintStyle: TextStyle(color: Color(0xFF555555)),
                                  filled: true,
                                  fillColor: Color(0xFF2C2C2C),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: _senhaBorderColor == Colors.transparent ? Color(0xFF424242) : _senhaBorderColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: _senhaBorderColor == Colors.transparent ? Color(0xFF00E6D8) : _senhaBorderColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: _senhaBorderColor == Colors.transparent ? Color(0xFF424242) : _senhaBorderColor),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  suffixIcon: _senhaController.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(
                                            _obscureSenha ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                            color: Color(0xFF757575),
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscureSenha = !_obscureSenha;
                                            });
                                          },
                                        )
                                      : null,
                                ),
                                style: const TextStyle(color: Colors.white),
                                onChanged: (_) {
                                  setState(() {});
                                },
                              ),
                              const SizedBox(height: 16),
                              // Campo Confirme Senha
                              TextField(
                                controller: _confirmeController,
                                obscureText: _obscureConfirme,
                                decoration: InputDecoration(
                                  labelText: 'Confirme a senha',
                                  labelStyle: TextStyle(color: Color(0xFF757575)),
                                  hintText: 'Digite novamente sua senha',
                                  hintStyle: TextStyle(color: Color(0xFF555555)),
                                  filled: true,
                                  fillColor: Color(0xFF2C2C2C),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: _confirmeBorderColor == Colors.transparent ? Color(0xFF424242) : _confirmeBorderColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: _confirmeBorderColor == Colors.transparent ? Color(0xFF00E6D8) : _confirmeBorderColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: _confirmeBorderColor == Colors.transparent ? Color(0xFF424242) : _confirmeBorderColor),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  suffixIcon: _confirmeController.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(
                                            _obscureConfirme ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                            color: Color(0xFF757575),
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscureConfirme = !_obscureConfirme;
                                            });
                                          },
                                        )
                                      : null,
                                ),
                                style: const TextStyle(color: Colors.white),
                                onChanged: (_) {
                                  setState(() {});
                                },
                              ),
                              // Mensagem de senha igual
                              if (_senhaStatus != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _senhaStatus == "ok" ? Icons.check_circle : Icons.error_outline,
                                        color: _senhaStatus == "ok" ? Colors.green : Colors.red,
                                        size: 16,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        _senhaStatus == "ok"
                                            ? "Senhas coincidem"
                                            : _senhaStatus == "erro"
                                                ? "As senhas não coincidem"
                                                : "",
                                        style: TextStyle(
                                          color: _senhaStatus == "ok" ? Colors.green : Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              // Mensagem de erro campos vazios
                              if (_erroCamposVazios != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.red,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.error_outline, color: Colors.red, size: 16),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _erroCamposVazios!,
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (_mostrarErroSenhaVazia)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.red,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.error_outline, color: Colors.red, size: 16),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Preencha todos os campos de senha.',
                                            style: TextStyle(
                                              color: Colors.red,
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
                              // Botão Cadastrar
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF00E6D8),
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: _isCadastroAtivo()
                                      ? () async {
                                            // Verifica se todos os campos estão vazios
                                            if (_nomeController.text.isEmpty &&
                                                _emailController.text.isEmpty &&
                                                _senhaController.text.isEmpty &&
                                                _confirmeController.text.isEmpty) {
                                              setState(() {
                                                _nomeBorderColor = Colors.red;
                                                _emailBorderColor = Colors.red;
                                                _senhaBorderColor = Colors.red;
                                                _confirmeBorderColor = Colors.red;
                                                _erroCamposVazios = 'Preencha todos os campos.'; // Define mensagem de erro
                                                _mostrarErroSenhaVazia = false;
                                              });
                                              return;
                                            } else {
                                              setState(() {
                                                _erroCamposVazios = null; // Limpa mensagem se não for o caso
                                              });
                                            }

                                            setState(() {
                                              _nomeBorderColor = _nomeController.text.isEmpty ? Colors.red : Colors.transparent;
                                              _emailBorderColor = _emailController.text.isEmpty ? Colors.red : Colors.transparent;
                                              _senhaBorderColor = _senhaController.text.isEmpty ? Colors.red : Colors.transparent;
                                              _confirmeBorderColor = _confirmeController.text.isEmpty ? Colors.red : Colors.transparent;
                                            });

                                            if (_senhaController.text.isEmpty || _confirmeController.text.isEmpty) {
                                              setState(() {
                                                _mostrarErroSenhaVazia = true;
                                                _erroCamposVazios = null; // Remove mensagem de comprimento
                                              });
                                              return;
                                            } else if (_senhaController.text.length < 6) {
                                              setState(() {
                                                _mostrarErroSenhaVazia = false; // Remove erro de campos vazios
                                                _erroCamposVazios = 'A senha deve ter pelo menos 6 caracteres.';
                                              });
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('A senha deve ter pelo menos 6 caracteres.'),
                                                ),
                                              );
                                              return;
                                            } else {
                                              setState(() {
                                                _mostrarErroSenhaVazia = false;
                                                _erroCamposVazios = null;
                                              });
                                            }
                                            try {
                                              final response = await Supabase.instance.client.auth.signUp(
                                                email: _emailController.text,
                                                password: _senhaController.text,
                                                data: {'nome': _nomeController.text},
                                              );

                                              // Verifica se o usuário já confirmou o e-mail
                                              final user = response.user;
                                              if (user != null && user.emailConfirmedAt == null) {
                                                // E-mail não confirmado
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    backgroundColor: Color(0xFF222222),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                    content: Row(
                                                      children: [
                                                        Icon(Icons.info, color: Colors.orange, size: 32),
                                                        SizedBox(width: 12),
                                                        Expanded(
                                                          child: Text(
                                                            'Confirme seu e-mail para continuar.',
                                                            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                                Future.delayed(Duration(seconds: 2), () {
                                                  Navigator.of(context).pop(); // Fecha o dialog
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => TelaLogin(),
                                                    ),
                                                  );
                                                });
                                              } else {
                                                // Cadastro realizado com sucesso (caso raro, e-mail já confirmado)
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    backgroundColor: Color(0xFF222222),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                    content: Row(
                                                      children: [
                                                        Icon(Icons.check_circle, color: Colors.green, size: 32),
                                                        SizedBox(width: 12),
                                                        Expanded(
                                                          child: Text(
                                                            'Conta criada com sucesso!',
                                                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                                Future.delayed(Duration(seconds: 2), () {
                                                  Navigator.of(context).pop();
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => TelaLogin(),
                                                    ),
                                                  );
                                                });
                                              }
                                            } catch (e) {
                                              // Trate erros de cadastro aqui
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Erro ao cadastrar: ${e.toString()}'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        : null,
                                  child: Text(
                                    'Cadastrar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Botão para tela de login
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
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TelaLogin(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Já tem uma conta?',
                                    style: TextStyle(
                                      fontSize: 16,
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
            ),
            // Rodapé igual telaLogin.dart
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
    );
  }
}
