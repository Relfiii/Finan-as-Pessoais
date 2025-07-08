import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class EditarPerfilPage extends StatefulWidget {
  const EditarPerfilPage({Key? key}) : super(key: key);

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _apelidoController = TextEditingController();
  bool _loading = false;
  bool _editando = false;
  bool _carregandoDados = true;
  XFile? _imagemPerfil;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    final userId = user?.id;      // ID do usuário
    if (userId == null) {
      setState(() => _carregandoDados = false);
      return;
    }
    final data = await supabase.from('usuarios').select('nome, email, apelido').eq('id', userId).single();
    setState(() {
      _nomeController.text = data['nome'] ?? '';
      _emailController.text = data['email'] ?? '';
      _apelidoController.text = data['apelido'] ?? '';
      _carregandoDados = false;
    });
  }

  Future<void> _salvarPerfil() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    final userId = user?.id ?? '';
    final novoEmail = _emailController.text.trim();
    final emailAntigo = user?.email;

    // Atualiza o e-mail no Auth se mudou
    if (novoEmail.isNotEmpty && novoEmail != emailAntigo) {
      final response = await supabase.auth.updateUser(UserAttributes(email: novoEmail));
      if (response.user == null) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao atualizar e-mail de login no Supabase Auth.')),
        );
        return;
      }
    }

    // Atualiza a tabela usuarios
    await supabase.from('usuarios').update({
      'nome': _nomeController.text,
      'apelido': _apelidoController.text,
      // Se a imagem foi selecionada, você pode implementar o upload aqui
      'email': novoEmail,
    }).eq('id', userId);
    await _carregarDadosUsuario();
    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
    }
  }

  Future<void> _selecionarImagem() async {
    // Solicita permissão
    var status = await Permission.photos.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissão de acesso às fotos negada.')),
      );
      return;
    }

    final picker = ImagePicker();
    final imagem = await picker.pickImage(source: ImageSource.gallery);
    if (imagem != null) {
      setState(() {
        _imagemPerfil = imagem;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregandoDados) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
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
                        'Editar Perfil',
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
                // Header com avatar, nome e e-mail
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: const Color(0xFF7B2FF2),
                            backgroundImage: _imagemPerfil != null
                                ? FileImage(File(_imagemPerfil!.path))
                                : null,
                            child: _imagemPerfil == null
                                ? const Icon(Icons.account_circle, size: 54, color: Colors.white)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _selecionarImagem,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB983FF),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(Icons.edit, size: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nomeController.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            Text(
                              _emailController.text,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, thickness: 1, indent: 24, endIndent: 24),
                // Formulário de edição
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      children: [
                        const Text(
                          'Como quer ser chamado?',
                          style: TextStyle(color: Color(0xFFB983FF), fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Card(
                          color: Colors.white.withOpacity(0.03),
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextFormField(
                              controller: _apelidoController,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Apelido',
                                hintStyle: TextStyle(color: Colors.white38),
                              ),
                              enabled: _editando,
                              readOnly: !_editando,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Nome',
                          style: TextStyle(color: Color(0xFFB983FF), fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Card(
                          color: Colors.white.withOpacity(0.03),
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextFormField(
                              controller: _nomeController,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Nome',
                                hintStyle: TextStyle(color: Colors.white38),
                              ),
                              enabled: _editando,
                              readOnly: !_editando,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'E-mail',
                          style: TextStyle(color: Color(0xFFB983FF), fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Card(
                          color: Colors.white.withOpacity(0.03),
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'E-mail',
                                hintStyle: TextStyle(color: Colors.white38),
                              ),
                              enabled: _editando,
                              readOnly: !_editando,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB983FF),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: _loading
                                ? null
                                : () async {
                                    if (_editando) {
                                      await _salvarPerfil(); // Aguarda salvar no banco
                                      setState(() {
                                        _editando = false;
                                      });
                                    } else {
                                      setState(() {
                                        _editando = true;
                                      });
                                    }
                                  },
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(_editando ? 'Salvar Alterações' : 'Editar', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
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
