import 'dart:io';
import 'package:image/image.dart';

void main() async {
  print('Criando favicon...');
  
  // Carrega a imagem original
  final originalImage = await File('docs/logo-NossoDinDin.png').readAsBytes();
  final image = decodePng(originalImage);
  
  if (image == null) {
    print('Erro: Não foi possível carregar a imagem');
    return;
  }
  
  print('Imagem original: ${image.width}x${image.height}');
  
  // Criar favicon 32x32
  final favicon32 = copyResize(image, width: 32, height: 32, interpolation: Interpolation.cubic);
  await File('docs/favicon-32x32.png').writeAsBytes(encodePng(favicon32));
  print('Criado: favicon-32x32.png');
  
  // Criar favicon 16x16
  final favicon16 = copyResize(image, width: 16, height: 16, interpolation: Interpolation.cubic);
  await File('docs/favicon-16x16.png').writeAsBytes(encodePng(favicon16));
  print('Criado: favicon-16x16.png');
  
  // Criar apple-touch-icon 180x180
  final appleIcon = copyResize(image, width: 180, height: 180, interpolation: Interpolation.cubic);
  await File('docs/apple-touch-icon.png').writeAsBytes(encodePng(appleIcon));
  print('Criado: apple-touch-icon.png');
  
  // Criar favicon.ico (usando 32x32)
  await File('docs/favicon.ico').writeAsBytes(encodePng(favicon32));
  print('Criado: favicon.ico');
  
  print('Favicons criados com sucesso!');
}
