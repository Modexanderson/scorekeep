// services/demo_data.dart
// Demo data seeder for App Store screenshots.
// Populates the app with the same game sessions shown in the promotional screenshots.
//
// Usage: Set the constant `kSeedDemoData` to true in main.dart, run the app,
// then set it back to false before building for release.

import '../models/game_session.dart';
import 'storage_service.dart';

class DemoData {
  /// Seeds demo game sessions matching the App Store screenshots.
  /// Clears existing data first to ensure a clean state.
  static Future<void> seed() async {
    final now = DateTime.now();

    // Game 1: Poker Tournament (Screenshot 1 - home page)
    // 5 players, Tie: James & Jamie, Last played just now
    final pokerTournament = GameSession(
      id: 'demo-poker-tournament',
      gameName: 'Poker Tournament',
      players: ['James', 'Jamie', 'Mike', 'Lisa', 'Tom'],
      scores: {
        'James': 320,
        'Jamie': 320,
        'Mike': 280,
        'Lisa': 250,
        'Tom': 190,
      },
      createdAt: now.subtract(const Duration(hours: 2)),
      lastModified: now,
      history: [
        ScoreHistory(
          playerName: 'James',
          scoreChange: 50,
          newTotal: 320,
          timestamp: now.subtract(const Duration(minutes: 1)),
          reason: 'Won the round',
        ),
        ScoreHistory(
          playerName: 'Jamie',
          scoreChange: 40,
          newTotal: 320,
          timestamp: now.subtract(const Duration(minutes: 2)),
          reason: 'Full house',
        ),
        ScoreHistory(
          playerName: 'Mike',
          scoreChange: 30,
          newTotal: 280,
          timestamp: now.subtract(const Duration(minutes: 3)),
        ),
        ScoreHistory(
          playerName: 'Lisa',
          scoreChange: 25,
          newTotal: 250,
          timestamp: now.subtract(const Duration(minutes: 5)),
        ),
        ScoreHistory(
          playerName: 'Tom',
          scoreChange: 20,
          newTotal: 190,
          timestamp: now.subtract(const Duration(minutes: 6)),
        ),
      ],
    );

    // Game 2: Cards Against Humanity (Screenshot 1, Screenshot 5)
    // 6 players, Tie: Sophie, Ryan, Zoe,...
    final cardsAgainstHumanity = GameSession(
      id: 'demo-cards-against',
      gameName: 'Cards Against Humanity',
      players: ['Sophie', 'Ryan', 'Zoe', 'Noah', 'Lily', 'Ethan'],
      scores: {
        'Sophie': 12,
        'Ryan': 12,
        'Zoe': 12,
        'Noah': 10,
        'Lily': 8,
        'Ethan': 7,
      },
      createdAt: now.subtract(const Duration(hours: 3)),
      lastModified: now.subtract(const Duration(minutes: 1)),
      history: [
        ScoreHistory(
          playerName: 'Sophie',
          scoreChange: 1,
          newTotal: 12,
          timestamp: now.subtract(const Duration(minutes: 2)),
          reason: 'Won the round',
        ),
        ScoreHistory(
          playerName: 'Ryan',
          scoreChange: 1,
          newTotal: 12,
          timestamp: now.subtract(const Duration(minutes: 3)),
        ),
        ScoreHistory(
          playerName: 'Zoe',
          scoreChange: 1,
          newTotal: 12,
          timestamp: now.subtract(const Duration(minutes: 4)),
        ),
        ScoreHistory(
          playerName: 'Noah',
          scoreChange: 1,
          newTotal: 10,
          timestamp: now.subtract(const Duration(minutes: 5)),
        ),
      ],
    );

    // Game 3: Scrabble Championship (Screenshot 1, Screenshot 3)
    // 3 players: Alex, Maya, David - 13 score changes
    // Alex leading with 342, Maya 318, David 287
    final scrabbleChampionship = GameSession(
      id: 'demo-scrabble',
      gameName: 'Scrabble Championship',
      players: ['Alex', 'Maya', 'David'],
      scores: {
        'Alex': 342,
        'Maya': 318,
        'David': 287,
      },
      createdAt: now.subtract(const Duration(hours: 4)),
      lastModified: now.subtract(const Duration(minutes: 7)),
      history: [
        // Most recent first (as shown in screenshot 3)
        ScoreHistory(
          playerName: 'Alex',
          scoreChange: 47,
          newTotal: 342,
          timestamp: now.subtract(const Duration(minutes: 7)),
          reason: 'QUIXOTIC with triple word',
        ),
        ScoreHistory(
          playerName: 'Maya',
          scoreChange: 28,
          newTotal: 318,
          timestamp: now.subtract(const Duration(minutes: 8)),
          reason: 'ZEPHYR',
        ),
        ScoreHistory(
          playerName: 'David',
          scoreChange: 31,
          newTotal: 287,
          timestamp: now.subtract(const Duration(minutes: 9)),
          reason: 'OXYGEN on double letter',
        ),
        ScoreHistory(
          playerName: 'Alex',
          scoreChange: 15,
          newTotal: 295,
          timestamp: now.subtract(const Duration(minutes: 10)),
          reason: 'JAZZ',
        ),
        ScoreHistory(
          playerName: 'Maya',
          scoreChange: 22,
          newTotal: 290,
          timestamp: now.subtract(const Duration(minutes: 12)),
          reason: 'WALTZ',
        ),
        ScoreHistory(
          playerName: 'David',
          scoreChange: 18,
          newTotal: 256,
          timestamp: now.subtract(const Duration(minutes: 14)),
          reason: 'PIXEL',
        ),
        ScoreHistory(
          playerName: 'Alex',
          scoreChange: 35,
          newTotal: 280,
          timestamp: now.subtract(const Duration(minutes: 16)),
          reason: 'FREEZE on triple letter',
        ),
        ScoreHistory(
          playerName: 'Maya',
          scoreChange: 14,
          newTotal: 268,
          timestamp: now.subtract(const Duration(minutes: 18)),
          reason: 'BLOOM',
        ),
        ScoreHistory(
          playerName: 'David',
          scoreChange: 26,
          newTotal: 238,
          timestamp: now.subtract(const Duration(minutes: 20)),
          reason: 'QUIRKY',
        ),
        ScoreHistory(
          playerName: 'Alex',
          scoreChange: 20,
          newTotal: 245,
          timestamp: now.subtract(const Duration(minutes: 22)),
          reason: 'VIVID',
        ),
        ScoreHistory(
          playerName: 'Maya',
          scoreChange: 30,
          newTotal: 254,
          timestamp: now.subtract(const Duration(minutes: 24)),
          reason: 'SPHINX',
        ),
        ScoreHistory(
          playerName: 'David',
          scoreChange: 12,
          newTotal: 212,
          timestamp: now.subtract(const Duration(minutes: 26)),
          reason: 'FLAME',
        ),
        ScoreHistory(
          playerName: 'Alex',
          scoreChange: 25,
          newTotal: 225,
          timestamp: now.subtract(const Duration(minutes: 28)),
          reason: 'JUMBLE',
        ),
      ],
    );

    // Game 4: Monopoly Night (Screenshot 1, Screenshot 2)
    // 4 players: Emma 485, Jake 478, Sarah 461, + 1 more
    final monopolyNight = GameSession(
      id: 'demo-monopoly',
      gameName: 'Monopoly Night',
      players: ['Emma', 'Jake', 'Sarah', 'Ben'],
      scores: {
        'Emma': 485,
        'Jake': 478,
        'Sarah': 461,
        'Ben': 390,
      },
      createdAt: now.subtract(const Duration(hours: 5)),
      lastModified: now.subtract(const Duration(minutes: 14)),
      history: [
        ScoreHistory(
          playerName: 'Emma',
          scoreChange: 50,
          newTotal: 485,
          timestamp: now.subtract(const Duration(minutes: 14)),
          reason: 'Rent collected',
        ),
        ScoreHistory(
          playerName: 'Jake',
          scoreChange: 35,
          newTotal: 478,
          timestamp: now.subtract(const Duration(minutes: 16)),
          reason: 'Property sale',
        ),
        ScoreHistory(
          playerName: 'Sarah',
          scoreChange: 40,
          newTotal: 461,
          timestamp: now.subtract(const Duration(minutes: 18)),
          reason: 'Passed Go',
        ),
        ScoreHistory(
          playerName: 'Ben',
          scoreChange: 25,
          newTotal: 390,
          timestamp: now.subtract(const Duration(minutes: 20)),
        ),
      ],
    );

    // Game 5: Family Game Night (Screenshot 4 - game setup)
    // 4 players: Mom, Dad, Sister, Brother - fresh game with 0 scores
    final familyGameNight = GameSession(
      id: 'demo-family',
      gameName: 'Family Game Night',
      players: ['Mom', 'Dad', 'Sister', 'Brother'],
      scores: {
        'Mom': 0,
        'Dad': 0,
        'Sister': 0,
        'Brother': 0,
      },
      createdAt: now.subtract(const Duration(minutes: 30)),
      lastModified: now.subtract(const Duration(minutes: 30)),
      history: [],
    );

    final demoGames = [
      pokerTournament,
      cardsAgainstHumanity,
      scrabbleChampionship,
      monopolyNight,
      familyGameNight,
    ];

    await StorageService.saveGameSessions(demoGames);
    print('Demo data seeded: ${demoGames.length} game sessions');
  }
}
