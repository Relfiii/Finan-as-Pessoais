import 'package:flutter/material.dart';

class CardGasto extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalhes do Gasto')),
      body: Center(child: Text('Aqui vão os detalhes do gasto')),
    );
  }
}