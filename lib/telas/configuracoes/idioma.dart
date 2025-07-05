import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../provedor/idioma_provedor.dart';
import '../../l10n/app_localizations.dart';

class IdiomaPage extends StatefulWidget {
  const IdiomaPage({Key? key}) : super(key: key);

  @override
  State<IdiomaPage> createState() => _IdiomaPageState();
}

class _IdiomaPageState extends State<IdiomaPage> {
  late String _idiomaSelecionado;

  final List<Map<String, String>> _idiomas = [
    {'codigo': 'pt', 'nomeKey': 'portugues'},
    {'codigo': 'en', 'nomeKey': 'ingles'},
    {'codigo': 'es', 'nomeKey': 'espanhol'},
  ];

  @override
  void initState() {
    super.initState();
    final idiomaProvedor = Provider.of<IdiomaProvedor>(context, listen: false);
    _idiomaSelecionado = idiomaProvedor.locale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    final idiomaProvedor = Provider.of<IdiomaProvedor>(context);
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        children: [
          // ...existing code...
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
                      Text(
                        localizations.idioma,
                        style: const TextStyle(
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
                      _SectionTitle(localizations.selecioneIdioma),
                      ..._idiomas.map((idioma) => _SettingsTile(
                        icon: Icons.language_outlined,
                        title: _getIdiomaName(localizations, idioma['nomeKey']!),
                        subtitle: idioma['codigo']!,
                        selected: _idiomaSelecionado == idioma['codigo'],
                        onTap: () {
                          setState(() {
                            _idiomaSelecionado = idioma['codigo']!;
                          });
                          idiomaProvedor.setLocale(Locale(idioma['codigo']!));
                        },
                      )).toList(),
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

  String _getIdiomaName(AppLocalizations localizations, String key) {
    switch (key) {
      case 'portugues':
        return localizations.portugues;
      case 'ingles':
        return localizations.ingles;
      case 'espanhol':
        return localizations.espanhol;
      default:
        return key;
    }
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
  final bool selected;
  final VoidCallback onTap;
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selected = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: selected
          ? const Color(0xFFB983FF).withOpacity(0.18)
          : Colors.white.withOpacity(0.03),
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
        trailing: selected
            ? const Icon(Icons.check_circle, color: Color(0xFFB983FF))
            : const Icon(Icons.chevron_right, color: Colors.white38),
        onTap: onTap,
      ),
    );
  }
}
