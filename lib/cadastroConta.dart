import 'package:flutter/material.dart';
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
      backgroundColor: Color(0xFF181818),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),
              Text(
                'Criar conta',
                style: TextStyle(
                  color: Color(0xFFB983FF),
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
              Container(
                padding: EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Color(0xFF222222),
                  borderRadius: BorderRadius.circular(16),
                ),
                width: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Criar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24),
                    TextField(
                      controller: _nomeController,
                      obscureText: false,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFF181818),
                        hintText: 'Nome',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: _nomeBorderColor, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: _nomeBorderColor, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: _nomeBorderColor, width: 2),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      obscureText: false,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFF181818),
                        hintText: 'E-mail',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: _emailBorderColor, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: _emailBorderColor, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: _emailBorderColor, width: 2),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    TextField(
                        controller: _senhaController,
                        obscureText: _obscureSenha,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFF181818),
                          hintText: 'Senha',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: _senhaBorderColor, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: _senhaBorderColor, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: _senhaBorderColor, width: 2),
                          ),
                          suffixIcon: _senhaController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    _obscureSenha ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey[400],
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureSenha = !_obscureSenha;
                                    });
                                  },
                                )
                              : null,
                        ),
                        style: TextStyle(color: Colors.white),
                        onChanged: (_) {
                          setState(() {});
                        },
                      ),
                    SizedBox(height: 16),
                      TextField(
                      controller: _confirmeController,
                      obscureText: _obscureConfirme,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFF181818),
                        hintText: 'Confirme senha',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: _confirmeBorderColor, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: _confirmeBorderColor, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: _confirmeBorderColor, width: 2),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      onChanged: (_) {
                        setState(() {}); // Atualiza a tela para mostrar mensagem de erro
                      },
                    ),
                    if (_senhaStatus != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                        child: Text(
                          _senhaStatus == "ok"
                              ? "Senhas coincidem"
                              : _senhaStatus == "erro"
                                  ? "As senhas não coincidem"
                                  : "",
                          style: TextStyle(
                            color: _senhaStatus == "ok"
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (_erroCamposVazios != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                        child: Text(
                          _erroCamposVazios!,
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (_mostrarErroSenhaVazia)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                        child: Text(
                          'Preencha todos os campos de senha.',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
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
                                  });
                                  return;
                                } else {
                                  setState(() {
                                    _mostrarErroSenhaVazia = false;
                                  });
                                }
                                if (_senhaController.text != _confirmeController.text) {
                                  setState(() {
                                    _confirmeBorderColor = Colors.red;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('As senhas não coincidem.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
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
                        child: Text('Cadastrar'),
                      ),
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () {
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
