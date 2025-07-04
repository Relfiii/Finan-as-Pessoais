import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProvider extends ChangeNotifier {
  String _nomeUsuario = '';

  String get nomeUsuario => _nomeUsuario;

  void setNomeUsuario(String nome) {
    _nomeUsuario = nome;
    notifyListeners();
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // Outros provedores...
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Nome do Usuário: ${userProvider.nomeUsuario}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                userProvider.setNomeUsuario('Novo Nome');
              },
              child: Text('Alterar Nome'),
            ),
          ],
        ),
      ),
    );
  }
}