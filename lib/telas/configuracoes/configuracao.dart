import 'package:flutter/material.dart';
import 'dart:ui';
import 'editarPerfil.dart';
import 'alterarSenha.dart';
import 'idioma.dart';
import 'contasBancarias.dart';
import 'orcamento.dart';
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
                // Lista de configurações
                Expanded(
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
                      ),
                      _SettingsTile(
                        icon: Icons.pie_chart_outline,
                        title: 'Orçamentos',
                        subtitle: 'Defina limites de gastos',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OrcamentoPage()),
                          );
                        },
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
                      const SizedBox(height: 32),
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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
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
        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
        onTap: onTap,
      ),
    );
  }
}
