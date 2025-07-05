import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io' show Platform;

class SegurancaPage extends StatelessWidget {
  const SegurancaPage({Key? key}) : super(key: key);

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
                        'Segurança',
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
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      const _SectionTitle('Autenticação'),
                      _SegurancaTile(
                        icon: Icons.fingerprint,
                        title: 'Biometria',
                        subtitle: 'Usar digital para acessar o app',
                        enabled: true,
                        onTap: () {
                          // Ação para ativar/desativar biometria
                        },
                      ),
                      // Botão de reconhecimento facial apenas para iOS
                      _SegurancaTile(
                        icon: Icons.face,
                        title: 'Reconhecimento Facial',
                        subtitle: 'Usar Face ID para acessar o app',
                        enabled: false,
                        onTap: () {
                          // Ação para ativar/desativar Face ID
                        },
                      ),
                      _SegurancaTile(
                        icon: Icons.lock,
                        title: 'Senha do App',
                        subtitle: 'Defina uma senha para abrir o app',
                        enabled: false,
                        onTap: () {
                          // Ação para definir senha do app
                        },
                      ),
                      const SizedBox(height: 18),
                      const _SectionTitle('Privacidade'),
                      _SegurancaTile(
                        icon: Icons.visibility_off,
                        title: 'Ocultar Saldo',
                        subtitle: 'Esconde o saldo na tela inicial',
                        enabled: false,
                        onTap: () {
                          // Ação para ocultar/exibir saldo
                        },
                      ),
                      _SegurancaTile(
                        icon: Icons.phonelink_lock,
                        title: 'Logout automático',
                        subtitle: 'Desconectar após inatividade',
                        enabled: true,
                        onTap: () {
                          // Ação para configurar logout automático
                        },
                      ),
                    ],
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

class _SegurancaTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;

  const _SegurancaTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.03),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFB983FF)),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        trailing: Switch(
          value: enabled,
          onChanged: (_) => onTap(),
          activeColor: const Color(0xFFB983FF),
        ),
        onTap: onTap,
      ),
    );
  }
}
