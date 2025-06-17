// models/game_session.dart
import 'package:uuid/uuid.dart';

class GameSession {
  final String id;
  final String gameName;
  final List<String> players;
  final Map<String, int> scores;
  final DateTime createdAt;
  final DateTime lastModified;
  final List<ScoreHistory> history;

  GameSession({
    String? id,
    required this.gameName,
    required this.players,
    Map<String, int>? scores,
    DateTime? createdAt,
    DateTime? lastModified,
    List<ScoreHistory>? history,
  })  : id = id ?? const Uuid().v4(),
        scores = scores ?? Map.fromIterable(players, value: (player) => 0),
        createdAt = createdAt ?? DateTime.now(),
        lastModified = lastModified ?? DateTime.now(),
        history = history ?? [];

  String getCurrentLeader() {
    if (scores.isEmpty) return 'No scores yet';

    final maxScore = scores.values.reduce((a, b) => a > b ? a : b);
    final leaders =
        scores.entries.where((entry) => entry.value == maxScore).toList();

    if (leaders.length == 1) {
      return '${leaders.first.key} (${leaders.first.value})';
    } else {
      final leaderNames = leaders.map((e) => e.key).join(', ');
      return 'Tie: $leaderNames ($maxScore)';
    }
  }

  List<MapEntry<String, int>> getSortedPlayers() {
    final entries = scores.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  void addScore(String playerName, int score, {String? reason}) {
    scores[playerName] = (scores[playerName] ?? 0) + score;
    history.add(ScoreHistory(
      playerName: playerName,
      scoreChange: score,
      newTotal: scores[playerName]!,
      timestamp: DateTime.now(),
      reason: reason,
    ));
  }

  void resetScores() {
    scores.updateAll((key, value) => 0);
    history.clear();
  }

  bool undoLastScore() {
    if (history.isEmpty) return false;

    final lastEntry = history.removeLast();
    scores[lastEntry.playerName] = lastEntry.newTotal - lastEntry.scoreChange;
    return true;
  }

  GameSession copyWith({
    String? gameName,
    List<String>? players,
    Map<String, int>? scores,
    DateTime? lastModified,
  }) {
    return GameSession(
      id: id,
      gameName: gameName ?? this.gameName,
      players: players ?? this.players,
      scores: scores ?? Map.from(this.scores),
      createdAt: createdAt,
      lastModified: lastModified ?? DateTime.now(),
      history: List.from(history),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameName': gameName,
      'players': players,
      'scores': scores,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'history': history.map((h) => h.toJson()).toList(),
    };
  }

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      id: json['id'],
      gameName: json['gameName'],
      players: List<String>.from(json['players']),
      scores: Map<String, int>.from(json['scores']),
      createdAt: DateTime.parse(json['createdAt']),
      lastModified: DateTime.parse(json['lastModified']),
      history: (json['history'] as List?)
              ?.map((h) => ScoreHistory.fromJson(h))
              .toList() ??
          [],
    );
  }
}

class ScoreHistory {
  final String playerName;
  final int scoreChange;
  final int newTotal;
  final DateTime timestamp;
  final String? reason;

  ScoreHistory({
    required this.playerName,
    required this.scoreChange,
    required this.newTotal,
    required this.timestamp,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'playerName': playerName,
      'scoreChange': scoreChange,
      'newTotal': newTotal,
      'timestamp': timestamp.toIso8601String(),
      'reason': reason,
    };
  }

  factory ScoreHistory.fromJson(Map<String, dynamic> json) {
    return ScoreHistory(
      playerName: json['playerName'],
      scoreChange: json['scoreChange'],
      newTotal: json['newTotal'],
      timestamp: DateTime.parse(json['timestamp']),
      reason: json['reason'],
    );
  }
}
