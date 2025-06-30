import 'package:flutter/material.dart';
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
   String? _senhaStatus;
   Color _senhaBorderColor = Colors.transparent;
   Color _confirmeBorderColor = Colors.transparent;

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
    super.dispose();
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
                      controller: _emailController,
                      obscureText: false,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFF181818),
                        hintText: 'E-mail',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.transparent, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.transparent, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.transparent, width: 2),
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
                    ),
                    if (_senhaStatus != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                        child: Text(
                          _senhaStatus == "ok"
                              ? "Senhas coincidem"
                              : "Senhas não coincidem",
                          style: TextStyle(
                            color: _senhaStatus == "ok"
                                ? Colors.green
                                : Colors.red,
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
                        onPressed: () {
                          setState(() {
                            _senhaBorderColor = _senhaController.text.isEmpty ? Colors.red : Colors.transparent;
                            _confirmeBorderColor = _confirmeController.text.isEmpty ? Colors.red : Colors.transparent;
                          });

                          if (_senhaController.text.isEmpty || _confirmeController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Preencha todos os campos de senha.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
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
                          // Cadastro realizado com sucesso
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
                                      'Cadastro realizado com sucesso!',
                                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
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
                        },
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
