@echo off
echo "=== FAZENDO BUILD PARA WEB ==="

echo "1. Limpando build anterior..."
flutter clean

echo "2. Baixando dependências..."
flutter pub get

echo "3. Gerando build web otimizado..."
flutter build web --web-renderer canvaskit --release --dart-define=FLUTTER_WEB_USE_SKIA=true

echo "4. Copiando para pasta docs (GitHub Pages)..."
if exist "docs" rmdir /s /q docs
xcopy build\web docs /e /i /h

echo "5. Corrigindo base href para GitHub Pages..."
powershell -Command "(Get-Content docs\index.html) -replace '<base href=\".*?\">', '<base href=\"/Finan-as-Pessoais/\">' | Set-Content docs\index.html"

echo "=== BUILD CONCLUÍDO ==="
echo "Os arquivos estão prontos na pasta 'docs' para GitHub Pages"
echo "E na pasta 'build/web' para outros serviços de hospedagem"
pause
