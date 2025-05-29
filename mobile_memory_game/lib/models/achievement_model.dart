enum AchievementType {
  combo,
  speed,
  accuracy,
  games,
  themes,
  special
}

enum AchievementRarity {
  common,
  rare,
  epic,
  legendary
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementType type;
  final AchievementRarity rarity;
  final int targetValue;
  final int rewardXP;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int currentProgress;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.rarity,
    required this.targetValue,
    required this.rewardXP,
    this.isUnlocked = false,
    this.unlockedAt,
    this.currentProgress = 0,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    AchievementType? type,
    AchievementRarity? rarity,
    int? targetValue,
    int? rewardXP,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? currentProgress,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      targetValue: targetValue ?? this.targetValue,
      rewardXP: rewardXP ?? this.rewardXP,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }

  double get progressPercentage => currentProgress / targetValue;
  bool get isCompleted => currentProgress >= targetValue;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'type': type.name,
      'rarity': rarity.name,
      'targetValue': targetValue,
      'rewardXP': rewardXP,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'currentProgress': currentProgress,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      type: AchievementType.values.firstWhere((e) => e.name == json['type']),
      rarity: AchievementRarity.values.firstWhere((e) => e.name == json['rarity']),
      targetValue: json['targetValue'],
      rewardXP: json['rewardXP'],
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
      currentProgress: json['currentProgress'] ?? 0,
    );
  }
}

class AchievementManager {
  static List<Achievement> get defaultAchievements => [
    // Conquistas de Combo
    Achievement(
      id: 'combo_starter',
      title: 'Primeiros Passos',
      description: 'Faça seu primeiro combo de 2x',
      icon: '🔥',
      type: AchievementType.combo,
      rarity: AchievementRarity.common,
      targetValue: 1,
      rewardXP: 50,
    ),
    Achievement(
      id: 'combo_master',
      title: 'Mestre dos Combos',
      description: 'Alcance um combo de 10x',
      icon: '⚡',
      type: AchievementType.combo,
      rarity: AchievementRarity.epic,
      targetValue: 10,
      rewardXP: 300,
    ),
    
    // Conquistas de Velocidade
    Achievement(
      id: 'speed_demon',
      title: 'Demônio da Velocidade',
      description: 'Complete um jogo em menos de 60 segundos',
      icon: '💨',
      type: AchievementType.speed,
      rarity: AchievementRarity.rare,
      targetValue: 60,
      rewardXP: 200,
    ),
    
    // Conquistas de Precisão
    Achievement(
      id: 'perfectionist',
      title: 'Perfeccionista',
      description: 'Complete um jogo com 100% de precisão',
      icon: '🎯',
      type: AchievementType.accuracy,
      rarity: AchievementRarity.epic,
      targetValue: 100,
      rewardXP: 250,
    ),
    
    // Conquistas de Jogos
    Achievement(
      id: 'dedicated_player',
      title: 'Jogador Dedicado',
      description: 'Complete 100 jogos',
      icon: '🏆',
      type: AchievementType.games,
      rarity: AchievementRarity.rare,
      targetValue: 100,
      rewardXP: 500,
    ),
    
    // Conquistas de Temas
    Achievement(
      id: 'theme_collector',
      title: 'Colecionador de Temas',
      description: 'Desbloqueie todos os temas disponíveis',
      icon: '🎨',
      type: AchievementType.themes,
      rarity: AchievementRarity.legendary,
      targetValue: 10, // Assumindo 10 temas
      rewardXP: 1000,
    ),
    
    // Conquistas Especiais
    Achievement(
      id: 'first_win',
      title: 'Primeira Vitória',
      description: 'Vença sua primeira partida',
      icon: '🥇',
      type: AchievementType.special,
      rarity: AchievementRarity.common,
      targetValue: 1,
      rewardXP: 100,
    ),
    Achievement(
      id: 'comeback_king',
      title: 'Rei da Virada',
      description: 'Vença depois de estar perdendo por 5+ pontos',
      icon: '👑',
      type: AchievementType.special,
      rarity: AchievementRarity.legendary,
      targetValue: 1,
      rewardXP: 750,
    ),
  ];
} 