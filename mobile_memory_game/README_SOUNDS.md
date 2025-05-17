# Sons Personalizados por Tema

Este documento explica como adicionar e gerenciar sons personalizados para cada tema do jogo da memória.

## Estrutura de Pastas

Cada tema tem sua própria pasta de sons dentro da pasta de imagens do tema:

```
assets/
  ├── audio/                   # Sons globais do jogo
  │    ├── game_start.mp3      # Som quando o jogo começa
  │    └── (outros sons globais)
  │
  └── images/
       ├── bob_esponja/
       │    ├── card_1.png
       │    ├── ...
       │    ├── background.jpg
       │    └── sounds/        # Sons específicos do tema Bob Esponja
       │         ├── card_flip.mp3
       │         ├── match_found.mp3
       │         ├── no_match.mp3
       │         └── game_end.mp3
       │
       ├── peppa_pig/
       │    └── sounds/        # Sons específicos do tema Peppa Pig
       │
       └── (outros temas...)
```

## Sons Necessários por Tema

Para cada tema, você precisa criar ou adicionar os seguintes arquivos de som:

1. `card_flip.mp3` - Som quando uma carta é virada
2. `match_found.mp3` - Som quando um par é encontrado
3. `no_match.mp3` - Som quando as cartas não formam um par
4. `game_end.mp3` - Som quando o jogo termina

## Sons Globais

Estes sons são compartilhados por todos os temas e estão na pasta `assets/audio/`:

1. `game_start.mp3` - Som quando o jogo começa
2. (Outros sons globais conforme necessário)

## Fallback para Sons

Se um som específico do tema não for encontrado, o jogo usará automaticamente o som padrão global correspondente como fallback.

## Formato dos Arquivos

- Use arquivos MP3 com boa qualidade de áudio, mas tamanho otimizado
- Recomendação: arquivos com duração entre 1-3 segundos
- Nível de volume consistente entre diferentes sons

## Como Adicionar Novos Sons

1. Crie os arquivos de som no formato MP3
2. Coloque-os na pasta `sounds` do tema correspondente
3. O sistema de áudio detectará automaticamente esses sons
4. Se um tema novo for criado, lembre-se de criar também a pasta `sounds` e adicionar os sons correspondentes

## Depuração de Sons

Se um som não estiver funcionando:

1. Verifique se o arquivo está no local correto
2. Verifique se o nome do arquivo está correto (incluindo maiúsculas/minúsculas)
3. Verifique se o arquivo MP3 está em um formato válido
4. Verifique se a pasta do tema está incluída no `pubspec.yaml` 