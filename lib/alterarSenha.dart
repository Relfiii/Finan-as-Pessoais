import 'package:flutter/material.dart';
import 'dart:ui';
import 'telaLogin.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Adicione esta linha

class AlterarSenhaPage extends StatelessWidget {
  const AlterarSenhaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

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
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFFB983FF)),
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => TelaLogin()),
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Recuperar Senha',
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
                            constraints: BoxConstraints(
                              maxWidth: 400,
                              minWidth: 280,
                            ),
                            width: MediaQuery.of(context).size.width > 400 ? 400 : MediaQuery.of(context).size.width * 0.9,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                    color: Colors.grey[400],
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                TextField(
                                  controller: emailController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'E-mail',
                                    hintStyle: TextStyle(color: Colors.grey[400]),
                                    filled: true,
                                    fillColor: const Color(0xFF181818),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00E6C3),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                                    child: const Text('Enviar Link de Redefinição'),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF181818),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(builder: (_) => TelaLogin()),
                                      );
                                    },
                                    child: const Text('Cancelar'),
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

