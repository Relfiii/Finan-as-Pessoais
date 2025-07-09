import 'package:flutter/material.dart';

class GerenciarMembrosPage extends StatelessWidget {
  const GerenciarMembrosPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text(
          'Gerenciar Membros',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB983FF)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E1E2C), Color(0xFF121212)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 5, // Exemplo: 5 membros
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.white.withOpacity(0.03),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFB983FF),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          'Membro ${index + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: const Text(
                          'Parentesco: Exemplo',
                          style: TextStyle(color: Colors.white70),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            // Lógica para remover membro
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB983FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Adicionar Membro',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    // Lógica para adicionar membro
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
