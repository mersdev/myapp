import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../domain/models/sortable_object.dart';
import '../../domain/rules/sorting_rule.dart';
import '../../domain/services/sorting_service.dart';
import '../../services/game_service.dart';
import '../../models/game_session.dart';

class SetShiftingGameProvider extends ChangeNotifier {
  final _sortingService = SortingService();
  GameSession? _currentSession;
  late SortingRule _currentRule;
  late SortableObject _targetObject;
  late List<SortableObject> _currentObjects;
  int _currentScore = 0;
  int _ruleChanges = 0;
  DateTime? _startTime;

  SetShiftingGameProvider() {
    _initializeGame();
  }

  void _initializeGame() {
    _currentRule = _sortingService.getRandomRule();
    _targetObject = _sortingService.generateRandomObject();
    _currentObjects = _sortingService.generateMatchingObjects(
      _targetObject,
      _currentRule,
      count: 3,
    );
    _currentScore = 0;
    _ruleChanges = 0;
    _startTime = DateTime.now();
    notifyListeners();
  }

  SortingRule get currentRule => _currentRule;
  SortableObject get targetObject => _targetObject;
  List<SortableObject> get currentObjects => _currentObjects;
  int get currentScore => _currentScore;

  Future<bool> handleObjectSelection(SortableObject selectedObject) async {
    final isCorrect = _sortingService.checkMatch(
      selectedObject,
      _targetObject,
      _currentRule,
    );

    if (isCorrect) {
      _currentScore++;
      
      // Change rule every 3 correct answers
      if (_currentScore % 3 == 0) {
        _currentRule = _sortingService.getRandomRule();
        _ruleChanges++;
      }

      // Generate new objects for the next round
      _targetObject = _sortingService.generateRandomObject();
      _currentObjects = _sortingService.generateMatchingObjects(
        _targetObject,
        _currentRule,
        count: 3,
      );

      // If we've reached 10 questions, save the game session
      if (_currentScore >= 10) {
        await _saveGameSession();
        resetGame();
      }
    }

    notifyListeners();
    return isCorrect;
  }

  Future<void> _saveGameSession() async {
    if (_startTime == null) return;

    final endTime = DateTime.now();
    final durationSeconds = endTime.difference(_startTime!).inSeconds;

    try {
      if (_currentSession == null) {
        _currentSession = await GameService.instance.startSession();
      }

      await GameService.instance.updateSession(
        _currentSession!.id,
        scores: {
          'color': _currentScore ~/ 3,
          'shape': _currentScore ~/ 3,
          'size': _currentScore ~/ 3,
        },
        ruleChanges: _ruleChanges,
        durationSeconds: durationSeconds,
      );
    } catch (e) {
      debugPrint('Error saving game session: $e');
    }
  }

  void resetGame() {
    _initializeGame();
  }
} 