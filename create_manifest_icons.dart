import 'dart:io';
import 'package:image/image.dart';

void main() async {
  print('Criando ícones para manifest...');
  
  // Carrega a imagem original
  final originalImage = await File('docs/logo-NossoDinDin.png').readAsBytes();
  final image = decodePng(originalImage);
  
  if (image == null) {
    print('Erro: Não foi possível carregar a imagem');
    return;
  }
  
  // Criar ícone 192x192
  final icon192 = copyResize(image, width: 192, height: 192, interpolation: Interpolation.cubic);
  await File('docs/icons/Icon-192-logo.png').writeAsBytes(encodePng(icon192));
  print('Criado: icons/Icon-192-logo.png');
  
  // Criar ícone 512x512
  final icon512 = copyResize(image, width: 512, height: 512, interpolation: Interpolation.cubic);
  await File('docs/icons/Icon-512-logo.png').writeAsBytes(encodePng(icon512));
  print('Criado: icons/Icon-512-logo.png');
  
  print('Ícones do manifest criados com sucesso!');
}
