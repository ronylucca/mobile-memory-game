import 'package:flutter/material.dart';

class ThemeModel {
  final String id;
  final String name;
  final String folderPath;
  final Color primaryColor;
  final Color secondaryColor;
  final String backgroundImage;
  final String themeCardImage;
  final Map<String, String> themeSounds;

  ThemeModel({
    required this.id,
    required this.name,
    required this.folderPath,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundImage,
    required this.themeCardImage,
    this.themeSounds = const {},
  });

  static List<ThemeModel> getAllThemes() {
    return [
      ThemeModel(
        id: 'bob_esponja',
        name: 'Bob Esponja Calça Quadrada',
        folderPath: 'assets/images/bob_esponja',
        primaryColor: Colors.yellow,
        secondaryColor: Colors.blue,
        backgroundImage: 'assets/images/bob_esponja/background.jpg',
        themeCardImage: 'assets/images/bob_esponja/theme_card.jpg',
        themeSounds: {
          'access_theme': 'assets/images/bob_esponja/sounds/access_theme.mp3',
          'game_start': 'assets/images/bob_esponja/sounds/game_start.mp3',
          'card_flip': 'assets/images/bob_esponja/sounds/card_flip.mp3',
          'match_found': 'assets/images/bob_esponja/sounds/match_found.mp3',
          'no_match': 'assets/images/bob_esponja/sounds/no_match.mp3',
          'game_end': 'assets/images/bob_esponja/sounds/game_end.mp3',
        },
      ),
      ThemeModel(
        id: 'peppa_pig',
        name: 'Peppa Pig',
        folderPath: 'assets/images/peppa_pig',
        primaryColor: Colors.pink,
        secondaryColor: Colors.lightBlue,
        backgroundImage: 'assets/images/peppa_pig/background.jpg',
        themeCardImage: 'assets/images/peppa_pig/theme_card.jpg',
        themeSounds: {
          'access_theme': 'assets/images/peppa_pig/sounds/access_theme.mp3',
          'game_start': 'assets/images/peppa_pig/sounds/game_start.mp3',
          'card_flip': 'assets/images/peppa_pig/sounds/card_flip.mp3',
          'match_found': 'assets/images/peppa_pig/sounds/match_found.mp3',
          'no_match': 'assets/images/peppa_pig/sounds/no_match.mp3',
          'game_end': 'assets/images/peppa_pig/sounds/game_end.mp3',
        },
      ),
      ThemeModel(
        id: 'nemo',
        name: 'Nemo',
        folderPath: 'assets/images/nemo',
        primaryColor: Colors.orange,
        secondaryColor: Colors.blue,
        backgroundImage: 'assets/images/nemo/background.jpg',
        themeCardImage: 'assets/images/nemo/theme_card.jpg',
        themeSounds: {
          'access_theme': 'assets/images/nemo/sounds/access_theme.mp3',
          'game_start': 'assets/images/nemo/sounds/game_start.mp3',
          'card_flip': 'assets/images/nemo/sounds/card_flip.mp3',
          'match_found': 'assets/images/nemo/sounds/match_found.mp3',
          'no_match': 'assets/images/nemo/sounds/no_match.mp3',
          'game_end': 'assets/images/nemo/sounds/game_end.mp3',
        },
      ),
      ThemeModel(
        id: 'supergatinhos',
        name: 'SuperGatinhos da Disney',
        folderPath: 'assets/images/supergatinhos',
        primaryColor: Colors.purple,
        secondaryColor: Colors.pink,
        backgroundImage: 'assets/images/supergatinhos/background.jpg',
        themeCardImage: 'assets/images/supergatinhos/theme_card.jpg',
        themeSounds: {
          'access_theme': 'assets/images/supergatinhos/sounds/access_theme.mp3',
          'game_start': 'assets/images/supergatinhos/sounds/game_start.mp3',
          'card_flip': 'assets/images/supergatinhos/sounds/card_flip.mp3',
          'match_found': 'assets/images/supergatinhos/sounds/match_found.mp3',
          'no_match': 'assets/images/supergatinhos/sounds/no_match.mp3',
          'game_end': 'assets/images/supergatinhos/sounds/game_end.mp3',
        },
      ),
      ThemeModel(
        id: 'astro_bot',
        name: 'Astro Bot',
        folderPath: 'assets/images/astro_bot',
        primaryColor: Colors.blue,
        secondaryColor: Colors.white,
        backgroundImage: 'assets/images/astro_bot/background.jpg',
        themeCardImage: 'assets/images/astro_bot/theme_card.jpg',
        themeSounds: {
          'access_theme': 'assets/images/astro_bot/sounds/access_theme.mp3',
          'game_start': 'assets/images/astro_bot/sounds/game_start.mp3',
          'card_flip': 'assets/images/astro_bot/sounds/card_flip.mp3',
          'match_found': 'assets/images/astro_bot/sounds/match_found.mp3',
          'no_match': 'assets/images/astro_bot/sounds/no_match.mp3',
          'game_end': 'assets/images/astro_bot/sounds/game_end.mp3',
        },
      ),
      ThemeModel(
        id: 'little_big_planet',
        name: 'Little Big Planet',
        folderPath: 'assets/images/little_big_planet',
        primaryColor: Colors.brown,
        secondaryColor: Colors.green,
        backgroundImage: 'assets/images/little_big_planet/background.jpg',
        themeCardImage: 'assets/images/little_big_planet/theme_card.jpg',
        themeSounds: {
          'access_theme': 'assets/images/little_big_planet/sounds/access_theme.mp3',
          'game_start': 'assets/images/little_big_planet/sounds/game_start.mp3',
          'card_flip': 'assets/images/little_big_planet/sounds/card_flip.mp3',
          'match_found': 'assets/images/little_big_planet/sounds/match_found.mp3',
          'no_match': 'assets/images/little_big_planet/sounds/no_match.mp3',
          'game_end': 'assets/images/little_big_planet/sounds/game_end.mp3',
        },
      ),
    ];
  }
} 