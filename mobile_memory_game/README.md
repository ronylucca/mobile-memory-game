# Jogo da Memória Mobile

Um jogo da memória para dispositivos móveis desenvolvido com Flutter, focado em oferecer uma experiência divertida para dois jogadores no mesmo dispositivo.

## Recursos

- **Multiplayer Local**: Jogo para 2 jogadores no mesmo dispositivo
- **Interface Atraente**: Design moderno e animações suaves
- **Tabuleiro de Jogo**: 20 cartas (10 pares) com visuais temáticos
- **Sistema de Turnos**: Alternância automática com indicador visual do jogador atual
- **Pontuação**: Sistema de contagem de pontos baseado em pares encontrados
- **Seleção de Temas**: 6 temas diferentes para escolher:
  - Bob Esponja Calça Quadrada
  - Peppa Pig
  - Nemo
  - SuperGatinhos da Disney
  - Astro Bot
  - Little Big Planet
- **Efeitos Sonoros**: Sons para todas as ações do jogo (virar carta, encontrar par, etc.)
- **Animações**: Animação 3D ao virar cartas e efeitos de confete na vitória
- **Armazenamento Local**: Salva as pontuações máximas no dispositivo

## Tecnologias Utilizadas

- **Framework**: Flutter & Dart
- **Gerenciamento de Estado**: Provider
- **Animações**: flip_card para efeito 3D de virar cartas e confetti para celebrações
- **Armazenamento**: shared_preferences para salvar pontuações
- **Áudio**: audioplayers para efeitos sonoros

## Estrutura do Projeto

```
mobile_memory_game/
├── assets/
│   ├── audio/             # Sons do jogo
│   └── images/            # Imagens para os temas e cartas
├── lib/
│   ├── models/            # Modelos de dados (Card, Player, Theme, Game)
│   ├── providers/         # Gerenciadores de estado (GameProvider)
│   ├── screens/           # Telas do jogo
│   ├── utils/             # Funções utilitárias
│   ├── widgets/           # Componentes reutilizáveis
│   └── main.dart          # Ponto de entrada do aplicativo
└── pubspec.yaml           # Dependências do projeto
```

## Como Executar

1. Certifique-se de ter o Flutter instalado em seu ambiente
2. Clone o repositório
3. Execute `flutter pub get` para instalar as dependências
4. Execute `flutter run` para iniciar o aplicativo

## Próximos Passos

- Adicionar modo de um jogador contra o computador
- Implementar níveis de dificuldade com diferentes quantidades de cartas
- Adicionar mais temas e personalização
- Implementar um sistema de conquistas

## Licença

Este projeto está licenciado sob a licença MIT.
