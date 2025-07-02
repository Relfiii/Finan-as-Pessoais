import 'package:flutter/material.dart';
import '../widgets/topBarComCaixaTexto.dart';

class ConfiguracaoPage extends StatelessWidget {
  const ConfiguracaoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // TopBar com caixa de texto
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 16, top: 16, bottom: 8),
                  child: TopBarComCaixaTexto(
                    titulo: "Configurações",
                    mostrarMenuLateral: false,
                    mostrarNotificacao: false,
                  ),
                ),
                // Conteúdo
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    children: [
          _SectionTitle('Conta'),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Editar Perfil',
            subtitle: 'Nome, e-mail, foto',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: 'Alterar Senha',
            subtitle: 'Atualize sua senha',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _SectionTitle('Preferências'),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Tema',
            subtitle: 'Claro / Escuro',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notificações',
            subtitle: 'Gerencie alertas e lembretes',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.language_outlined,
            title: 'Idioma',
            subtitle: 'Português (Brasil)',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _SectionTitle('Financeiro'),
          _SettingsTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Contas Bancárias',
            subtitle: 'Gerencie suas contas',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.category_outlined,
            title: 'Categorias de Gastos',
            subtitle: 'Personalize categorias',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.pie_chart_outline,
            title: 'Orçamentos',
            subtitle: 'Defina limites de gastos',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _SectionTitle('Privacidade'),
          _SettingsTile(
            icon: Icons.security_outlined,
            title: 'Segurança',
            subtitle: 'Autenticação e acesso',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.delete_outline,
            title: 'Excluir Conta',
            subtitle: 'Remova sua conta do app',
            onTap: () {},
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
            // Overlay da caixa de texto
            CaixaTextoOverlay(),
          ],
        ),
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
      padding: const EdgeInsets.only(bottom: 8, top: 8),
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
      margin: const EdgeInsets.symmetric(vertical: 6),
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
