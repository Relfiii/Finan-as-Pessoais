import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui';
import 'editarPerfil.dart';
import 'alterarSenha.dart';
import 'idioma.dart';
import 'contasBancarias.dart';
import 'seguranca.dart';
import 'excluirConta.dart';

class ConfiguracaoPage extends StatelessWidget {
  const ConfiguracaoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove backgroundColor para usar o gradiente
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
                // AppBar customizada (toda a largura)
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
                        'Configurações',
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
                // Conteúdo centralizado para web
                Expanded(
                  child: Center(
                    child: Container(
                      width: kIsWeb ? 1000 : double.infinity,
                      constraints: kIsWeb 
                        ? const BoxConstraints(maxWidth: 1000)
                        : null,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        children: [
                      _SectionTitle('Conta'),
                      _SettingsTile(
                        icon: Icons.person_outline,
                        title: 'Editar Perfil',
                        subtitle: 'Nome, e-mail, foto',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditarPerfilPage()),
                          );
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.lock_outline,
                        title: 'Alterar Senha',
                        subtitle: 'Atualize sua senha',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AlterarSenhaPage()),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      _SectionTitle('Preferências'),
                      _SettingsTile(
                        icon: Icons.language_outlined,
                        title: 'Idioma',
                        subtitle: 'Português (Brasil)',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const IdiomaPage()),
                          );
                        },
                        disabled: true,
                      ),
                      const SizedBox(height: 18),
                      _SectionTitle('Financeiro'),
                      _SettingsTile(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Contas Bancárias',
                        subtitle: 'Gerencie suas contas',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ContasBancariasPage()),
                          );
                        },
                        disabled: true,
                      ),
                      const SizedBox(height: 18),
                      _SectionTitle('Privacidade'),
                      _SettingsTile(
                        icon: Icons.security_outlined,
                        title: 'Segurança',
                        subtitle: 'Autenticação e acesso',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SegurancaPage()),
                          );
                        },
                        disabled: true,
                      ),
                      _SettingsTile(
                        icon: Icons.delete_outline,
                        title: 'Excluir Conta',
                        subtitle: 'Remova sua conta do app',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ExcluirContaPage()),
                          );
                        },
                      ),
                    ],
                      ),
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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool disabled;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.disabled = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color iconColor = disabled ? Colors.grey : const Color(0xFFB983FF);
    final Color titleColor = disabled ? Colors.grey : Colors.white;
    final Color subtitleColor = disabled ? Colors.grey : Colors.white70;

    return Card(
      color: Colors.white.withOpacity(0.03),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: subtitleColor,
            fontSize: 13,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: disabled ? Colors.grey : Colors.white38),
        onTap: disabled ? null : onTap,
      ),
    );
  }
}
