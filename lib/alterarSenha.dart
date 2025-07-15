import 'package:flutter/material.dart';
import 'telaLogin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlterarSenhaPage extends StatelessWidget {
  const AlterarSenhaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

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
                      color: Color(0xFF9C27B0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Recuperar Senha',
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
                        // Container de formulário
                        Container(
                          constraints: BoxConstraints(maxWidth: 400),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título e instrução
                              const Text(
                                'Esqueceu a Senha?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Não se preocupe, acontece. Insira seu e-mail para enviarmos um link de redefinição de senha.',
                                style: TextStyle(
                                  color: Color(0xFFB0B0B0),
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 24),
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
                                    borderSide: BorderSide(color: Color(0xFF9C27B0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Color(0xFF424242)),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 32),
                              // Botão Enviar Link
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF9C27B0),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () async {
                                    final email = emailController.text.trim();
                                    if (email.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Informe seu e-mail.')),
                                      );
                                      return;
                                    }
                                    try {
                                      await Supabase.instance.client.auth.resetPasswordForEmail(email);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Enviamos um link de redefinição para seu e-mail!')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Erro ao enviar link: $e')),
                                      );
                                    }
                                  },
                                  child: Text(
                                    'Enviar Link de Redefinição',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Botão Cancelar
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
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(builder: (_) => TelaLogin()),
                                    );
                                  },
                                  child: Text(
                                    'Cancelar',
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

