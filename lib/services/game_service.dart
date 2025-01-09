import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/game_session.dart';
import 'auth_service.dart';

class GameService {
  GameService._();
  static final instance = GameService._();

  static const String _baseUrl = 'http://localhost:8080/api';

  Future<GameSession> startSession() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/sessions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': AuthService.instance.currentUserId,
      }),
    );

    if (response.statusCode == 201) {
      return GameSession.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to start game session');
    }
  }

  Future<void> updateSession(String sessionId, {
    required Map<String, int> scores,
    required int ruleChanges,
    required int durationSeconds,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/sessions/$sessionId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'score': {
          'color': scores['color'] ?? 0,
          'shape': scores['shape'] ?? 0,
          'size': scores['size'] ?? 0,
          'total': scores.values.fold(0, (sum, score) => sum + score),
        },
        'rule_changes': ruleChanges,
        'duration_seconds': durationSeconds,
        'completed_at': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update game session');
    }
  }

  Future<List<GameSession>> getUserSessions() async {
    final userId = AuthService.instance.currentUserId;
    final response = await http.get(
      Uri.parse('$_baseUrl/users/$userId/sessions'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => GameSession.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch user sessions');
    }
  }

  Future<Map<String, dynamic>> getUserStats() async {
    final userId = AuthService.instance.currentUserId;
    final response = await http.get(
      Uri.parse('$_baseUrl/users/$userId/stats'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch user stats');
    }
  }

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/leaderboard'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch leaderboard');
    }
  }
} 