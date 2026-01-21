// services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_session.dart';

class StorageService {
  static late SharedPreferences _prefs;
  static const String _gamesKey = 'game_sessions';
  static const String _settingsKey = 'app_settings';

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<List<GameSession>> loadGameSessions() async {
    try {
      final gamesJson = _prefs.getString(_gamesKey);
      if (gamesJson == null) return [];

      final gamesList = jsonDecode(gamesJson) as List;
      return gamesList.map((json) => GameSession.fromJson(json)).toList();
    } catch (e) {
      print('Error loading games: $e');
      return [];
    }
  }

  static Future<bool> saveGameSessions(List<GameSession> games) async {
    try {
      final gamesJson = jsonEncode(games.map((g) => g.toJson()).toList());
      return await _prefs.setString(_gamesKey, gamesJson);
    } catch (e) {
      print('Error saving games: $e');
      return false;
    }
  }

  static Future<bool> deleteGameSession(String gameId) async {
    try {
      final games = await loadGameSessions();
      games.removeWhere((game) => game.id == gameId);
      return await saveGameSessions(games);
    } catch (e) {
      print('Error deleting game: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> loadSettings() async {
    try {
      final settingsJson = _prefs.getString(_settingsKey);
      if (settingsJson == null) {
        return {
          'darkMode': false,
          'soundEnabled': true,
          'hapticFeedback': true,
          'autoSave': true,
        };
      }
      return jsonDecode(settingsJson);
    } catch (e) {
      return {
        'darkMode': false,
        'soundEnabled': true,
        'hapticFeedback': true,
        'autoSave': true,
      };
    }
  }

  static Future<bool> saveSettings(Map<String, dynamic> settings) async {
    try {
      return await _prefs.setString(_settingsKey, jsonEncode(settings));
    } catch (e) {
      return false;
    }
  }

  static Future<bool> clearAllData() async {
    try {
      await _prefs.remove(_gamesKey);
      await _prefs.remove(_settingsKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> exportData() async {
    try {
      final games = await loadGameSessions();
      final settings = await loadSettings();

      final exportData = {
        'games': games.map((g) => g.toJson()).toList(),
        'settings': settings,
        'exportDate': DateTime.now().toIso8601String(),
        'version': '2.0',
      };

      // In a real app, you would use file_picker or share_plus
      // to save or share this JSON data
      print('Export data: ${jsonEncode(exportData)}');
      return true;
    } catch (e) {
      print('Error exporting data: $e');
      return false;
    }
  }

  static Future<bool> importData(String jsonData) async {
    try {
      final data = jsonDecode(jsonData);

      if (data['games'] != null) {
        final games = (data['games'] as List)
            .map((json) => GameSession.fromJson(json))
            .toList();
        await saveGameSessions(games);
      }

      if (data['settings'] != null) {
        await saveSettings(Map<String, dynamic>.from(data['settings']));
      }

      return true;
    } catch (e) {
      print('Error importing data: $e');
      return false;
    }
  }
}
