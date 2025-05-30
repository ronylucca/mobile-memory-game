# Sistema de Powerups - Mobile Memory Game

## Visão Geral

Sistema unificado de powerups que combina interface visual profissional com lógica robusta de jogo. Os powerups permitem que os jogadores gastem pontos para obter vantagens temporárias durante o jogo.

## Arquitetura

### Estrutura Unificada
- **`lib/widgets/power_up_effects.dart`** - Definições, UI e efeitos visuais
- **`lib/utils/powerup_service.dart`** - Lógica de negócio e integração
- **`lib/widgets/powerup_panel.dart`** - Interface completa para jogadores (legacy)
- **`lib/widgets/floating_powerups_display.dart`** - Sistema flutuante otimizado ⭐ **NOVO**
- **`lib/widgets/game_enhancement_demo.dart`** - Tela de demonstração interativa
- **`lib/models/player_model.dart`** - Estado dos powerups por jogador

### Classes Principais

```dart
// Tipos de powerup disponíveis
enum PowerUpType {
  hint, freeze, doublePoints, xray, shuffle, lightning, swapTurn, upsideDown, allYourMud
}

// Definição de um powerup
class PowerUp {
  final PowerUpType type;
  final String name;
  final String description;
  final String icon;
  final int cost;
  final Duration duration;
  final bool isPermanent;
}

// Powerup ativo com estado
class ActivePowerUp {
  final PowerUpType type;
  final DateTime activatedAt;
  final Duration duration;
  final bool isPermanent;
  final Map<String, dynamic> customState;
}
```

## Tela de Demo Interativa

### Funcionalidades

A tela de demo (`GameEnhancementDemo`) oferece uma experiência completa para testar o sistema:

#### 🎮 **Controles da Demo**
- **Troca de Jogador**: Alterna entre Jogador 1 e Jogador 2
- **Adicionar Pontos**: Permite dar pontos aos jogadores para testar powerups
- **Resetar Demo**: Reinicia toda a demonstração

#### ⚡ **Painéis de Powerups**
- **Dois painéis**: Um para cada jogador simulado
- **Indicação visual**: Jogador atual destacado em azul/verde
- **Estado em tempo real**: Mostra powerups ativos e pontos disponíveis

#### 📚 **Informações dos Powerups**
- **Lista completa**: Todos os powerups com descrições
- **Custos em pontos**: Valores balanceados para cada powerup
- **Dicas de uso**: Explicações sobre comportamento

#### 🎯 **Demonstrações Visuais**
- **Efeito Raio-X**: Mostra overlay roxo transparente
- **Efeito Congelar**: Animação de cristais de gelo
- **Efeito Raio**: Animação de raios amarelos
- **Pontos Duplos**: Efeito de estrelas douradas
- **Simular Expiração**: Testa remoção de powerups ativos

### Como Usar a Demo

1. **Acesse a demo** através do menu principal do jogo
2. **Adicione pontos** usando o botão "Dar Pontos"
3. **Teste powerups** clicando nos botões coloridos
4. **Observe efeitos visuais** com os botões de demonstração
5. **Troque jogadores** para testar o sistema multiplayer
6. **Reset quando necessário** para começar nova demonstração

### Validações na Demo

A demo inclui todas as validações do sistema real:

- ✅ **Pontos insuficientes**: Mostra aviso quando jogador não pode comprar
- ✅ **Powerup já ativo**: Previne ativação duplicada
- ✅ **Expiração automática**: Powerups temporários se removem sozinhos
- ✅ **Estado consistente**: Atualização em tempo real do estado dos jogadores

## Powerups Disponíveis (9 Total)

### 💡 **Hint (3 pontos)**
- **Duração**: 3 segundos
- **Efeito**: Destaca 3 cartas (1 par + 1 extra) por 3 segundos
- **Uso**: Memorizar posições de cartas específicas

### ❄️ **Freeze (5 pontos)**
- **Duração**: 30 segundos
- **Efeito**: Pausa o timer por 30 segundos
- **Uso**: Ganhar tempo extra em modo cronometrado

### ⭐ **Double Points (2 pontos)**
- **Duração**: Permanente até usar
- **Efeito**: Próximos 3 pares valem pontos em dobro
- **Uso**: Maximizar pontuação

### 👁️ **X-Ray (5 pontos)**
- **Duração**: 3 segundos
- **Efeito**: Mostra todas as cartas por 3 segundos
- **Uso**: Planejamento estratégico avançado

### 🔀 **Shuffle (4 pontos)**
- **Duração**: Instantâneo
- **Efeito**: Reposiciona cartas não emparelhadas
- **Uso**: Confundir adversário

### ⚡ **Lightning (8 pontos)**
- **Duração**: Instantâneo
- **Efeito**: 50% chance de acertar par automaticamente
- **Uso**: Progresso garantido

### 🔄 **Swap Turn (4 pontos)**
- **Duração**: Permanente até usar
- **Efeito**: Joga novamente mesmo errando
- **Uso**: Segunda chance em jogada arriscada

### 🙃 **Upside Down (7 pontos)** ⭐ ADVERSARIAL
- **Duração**: Até a próxima jogada do adversário
- **Efeito**: Adversário vê cartas invertidas na próxima jogada
- **Uso**: Powerup adversarial que dificulta a visão do oponente
- **Impacto na IA**: Reduz taxa de sucesso em 25%

### 🌊 **All Your Mud (8 pontos)** ⭐ ADVERSARIAL
- **Duração**: Até a próxima jogada do adversário
- **Efeito**: Remove seus debuffs e embarralha visão do adversário
- **Uso**: Powerup defensivo/ofensivo que limpa debuffs e embaralha visão do oponente
- **Impacto na IA**: Reduz taxa de sucesso em 25%

## Integração com GameProvider

### Métodos Principais

```dart
// No GameProvider
void activatePowerup(PowerUpType powerupType);
void updatePowerups();
bool shouldHighlightCard(int cardIndex);
GameModel useSwapTurn(GameModel game);
```

### Uso na Game Screen

```dart
// Adicionado aos painéis de jogo
PowerupPanel(
  player: game.players[0],
  isCurrentPlayer: game.currentPlayerIndex == 0,
  onPowerupPressed: (type) => gameProvider.activatePowerup(type),
)
```

## Estrutura de Custos

Os custos foram balanceados baseados no impacto no jogo:

- **2-3 pontos**: Powerups básicos (Double Points, Hint)
- **4-5 pontos**: Powerups moderados (Lightning, Freeze, Swap Turn, Shuffle, X-Ray)
- **7-8 pontos**: Powerups adversariais (Upside Down, All Your Mud)

## Sistema de Expiração

### Powerups Temporários
- **Hint, Freeze, X-Ray**: Expiram automaticamente por tempo
- **Timer interno**: Controla duração e remove quando necessário
- **Atualização contínua**: Timer de 1 segundo no GameProvider

### Powerups Permanentes
- **Double Points, Swap Turn**: Persistem até serem consumidos
- **Uso único**: Removidos quando efeito é aplicado
- **Estado persistente**: Mantidos entre turnos

### Powerups Adversariais
- **Upside Down, All Your Mud**: Removidos quando o jogador afetado completa uma jogada
- **Não empilham**: Apenas um debuff por jogador por vez
- **Auto-limpeza**: Removidos automaticamente após o turno do jogador afetado

## Considerações de Performance

### Otimizações Implementadas
- **Estado imutável**: Usa `copyWith` para atualizações eficientes
- **Verificações rápidas**: Métodos `canAfford` e `hasPowerup` otimizados
- **Timer separado**: Timer independente para powerups funciona em qualquer modo de jogo
- **Limpeza automática**: Remove powerups expirados automaticamente

## ⚔️ Sistema de Powerups Adversariais

### Novos Recursos (v2.0)

#### 🎯 **Powerups de Debuff**
- **Upside Down**: Rotaciona cartas do adversário 180°
- **All Your Mud**: Aplica efeito visual de "água/lama" nas cartas
- **Contramedidas**: Powerups adversariais removem debuffs próprios

#### 🤖 **Estratégia da IA**
- **Uso inteligente**: IA prioriza powerups adversariais quando está atrás no score
- **Impacto nos debuffs**: Taxa de sucesso da IA reduzida em 25% por debuff ativo
- **Frequência adaptativa**: Mais powerups quando perdendo (até 40% de chance)

#### 🎨 **Feedback Visual**
- **Indicadores no scoreboard**: Ícones de debuff aparecem ao lado do nome do jogador
- **Efeitos nas cartas**: Rotação e filtros visuais aplicados em tempo real
- **Cores diferenciadas**: Vermelho para Upside Down, marrom para Mud

#### ⚖️ **Balanceamento**
- **Custos elevados**: 7-8 pontos para powerups adversariais
- **Duração limitada**: Apenas até a próxima jogada do adversário
- **Não stackable**: Apenas 1 debuff por jogador por vez
- **Auto-limpeza**: Debuffs removidos automaticamente na troca de turno

### Integração com Sistema Existente

Os novos powerups adversariais se integram perfeitamente com:
- ✅ Sistema de powerups flutuantes
- ✅ Animações e efeitos visuais
- ✅ Lógica de IA existente
- ✅ Sistema de pontuação
- ✅ Demo de funcionalidades

### Próximos Passos

1. **Testes de balanceamento**: Ajustar custos baseado no feedback
2. **Novos efeitos visuais**: Adicionar mais animações para debuffs
3. **Powerups defensivos**: Criar contramedidas específicas
4. **Sistema de combo**: Powerups que se potencializam mutuamente

## Sistema Flutuante de Powerups ⭐

### Visão Geral da Inovação

O novo sistema flutuante **revoluciona a experiência de jogo**, eliminando os painéis fixos que ocupavam 25% da tela e permitindo que as cartas sejam **30% maiores** com uma interface muito mais limpa.

### Características Principais

#### 🎯 **Interface Compacta**
- **Botões flutuantes** de 80x80px nas laterais da tela
- **Expansão sob demanda** com um toque
- **Zero espaço fixo** - cartas ocupam toda a área útil
- **Animações suaves** com feedback visual

#### ⚡ **Funcionalidades Avançadas**
- **Indicador visual** do jogador atual (pulso animado)
- **Badge de contagem** de powerups ativos
- **Pontuação instantânea** no botão compacto
- **Estado em tempo real** com timer de expiração

#### 🎨 **Design Responsivo**
- **Posicionamento inteligente**: Esquerda (Player 1) / Direita (Player 2)
- **Expansão exclusiva**: Apenas um painel expandido por vez
- **Cores temáticas**: Azul/Roxo (ativo) vs Cinza (inativo)
- **Feedback tátil**: Animações de toque e transições suaves

### Comparação: Antes vs Depois

| Aspecto | Sistema Antigo | Sistema Flutuante |
|---------|---------------|-------------------|
| **Espaço ocupado** | 25% da tela | 0% (flutuante) |
| **Tamanho das cartas** | Reduzido | +30% maior |
| **Acesso aos powerups** | Sempre visível | Expansão sob demanda |
| **Interface** | Poluída | Limpa e focada |
| **Performance** | Muitos widgets | Otimizado |

### Implementação Técnica

#### **FloatingPowerupsDisplay**
```dart
FloatingPowerupsDisplay(
  player: player,
  isCurrentPlayer: true,
  onPowerupPressed: (type) => gameProvider.activatePowerup(type),
  isExpanded: false,
  alignment: Alignment.centerRight,
  onToggleExpanded: () => toggleExpansion(),
)
```

#### **FloatingPowerupsManager**
```dart
// Posiciona automaticamente os dois jogadores
FloatingPowerupsManager(
  player1: game.players[0],
  player2: game.players[1], 
  currentPlayerIndex: game.currentPlayerIndex,
  onPowerupPressed: (type) => gameProvider.activatePowerup(type),
)
```

### Estados do Sistema

#### **Estado Compacto (Padrão)**
- **Ícone de raio** centralizado
- **Badge numérico** com powerups ativos
- **Pontuação atual** na parte inferior
- **Animação de pulso** para jogador ativo

#### **Estado Expandido (On-Demand)**
- **Header** com nome e pontuação do jogador
- **Seção "Ativos"** com powerups em execução e timer
- **Seção "Disponíveis"** com powerups que podem ser comprados
- **Botão de fechar** para voltar ao estado compacto

### Integração na Game Screen

```dart
// Substituição simples na game_screen.dart
Stack(
  children: [
    // Jogo principal
    GameBoard(...),
    
    // Sistema flutuante (substitui os painéis fixos)
    FloatingPowerupsManager(
      player1: game.players[0],
      player2: game.players[1],
      currentPlayerIndex: game.currentPlayerIndex,
      onPowerupPressed: (type) => gameProvider.activatePowerup(type),
    ),
  ],
)
```

---

**Sistema desenvolvido com foco em experiência do usuário, performance e escalabilidade para o Mobile Memory Game.** 