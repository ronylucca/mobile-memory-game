# Rodar o jogo localmente na Web

Projeto Flutter com suporte web já habilitado (pasta `web/`).
Flutter SDK: `/Users/ronylucca/development/flutter/bin/flutter`

## Passos

```bash
cd mobile_memory_game
flutter pub get
flutter run -d chrome            # abre no Chrome com hot reload (r / R)
```

Sem Chrome / em outro navegador:

```bash
flutter run -d web-server --web-port 8080
# abra http://localhost:8080
```

## Build de produção servido localmente

```bash
flutter build web
cd build/web && python3 -m http.server 8000
# abra http://localhost:8000
```

## Dicas / problemas comuns
- `flutter devices` lista os alvos disponíveis (deve aparecer `chrome`).
- Web não habilitada? `flutter config --enable-web`.
- Assets novos (ex.: `assets/images/<tema>/`) precisam estar declarados em `pubspec.yaml` em `flutter: assets:`; depois rode de novo (hot restart não basta para assets novos).
- Áudio (`audioplayers`) no navegador só toca após uma interação do usuário (política de autoplay).
- `shared_preferences` na web usa o localStorage do navegador.
- Problemas estranhos de cache: `flutter clean && flutter pub get`.
