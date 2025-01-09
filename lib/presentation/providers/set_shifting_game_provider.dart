import 'package:flutter/foundation.dart';
import '../../domain/models/sortable_object.dart';
import '../../domain/rules/sorting_rule.dart';
import '../../domain/services/sorting_service.dart';
import '../../services/game_service.dart';
import '../../models/game_session.dart';
import '../../domain/rules/color_sorting_rule.dart';
import '../../domain/rules/shape_sorting_rule.dart';
import '../../domain/rules/size_sorting_rule.dart';

class SetShiftingGameProvider extends ChangeNotifier {
  late final SortingService _sortingService;
  GameSession? _currentSession;
  int _currentScore = 0;
  int _ruleChanges = 0;
  DateTime? _startTime;
  List<SortableObject> _currentObjects = [];
  late SortableObject _targetObject;

  SetShiftingGameProvider() {
    _sortingService = SortingService([
      ColorSortingRule(),
      ShapeSortingRule(),
      SizeSortingRule(),
    ]);
    _initializeGame();
  }

  void _initializeGame() {
    _generateNewRound();
    _currentScore = 0;
    _ruleChanges = 0;
    _startTime = DateTime.now();
    notifyListeners();
  }

  void _generateNewRound() {
    _targetObject = _generateRandomObject();
    _currentObjects = _generateObjects();
  }

  SortableObject _generateRandomObject() {
    return SortableObject(
      color: _getRandomValue(['red', 'blue', 'yellow']),
      shape: _getRandomValue(['circle', 'square', 'triangle']),
      size: _getRandomValue(['small', 'medium', 'large']),
    );
  }

  String _getRandomValue(List<String> values) {
    return values[DateTime.now().microsecondsSinceEpoch % values.length];
  }

  List<SortableObject> _generateObjects() {
    final objects = <SortableObject>[];
    
    // Add one matching object
    objects.add(_generateMatchingObject(_targetObject));
    
    // Add two non-matching objects
    while (objects.length < 3) {
      final obj = _generateRandomObject();
      if (!_sortingService.checkMatch(obj, _targetObject)) {
        objects.add(obj);
      }
    }
    
    objects.shuffle();
    return objects;
  }

  SortableObject _generateMatchingObject(SortableObject target) {
    final rule = _sortingService.currentRule;
    if (rule is ColorSortingRule) {
      return SortableObject(
        color: target.color,
        shape: _getRandomValue(['circle', 'square', 'triangle']),
        size: _getRandomValue(['small', 'medium', 'large']),
      );
    } else if (rule is ShapeSortingRule) {
      return SortableObject(
        color: _getRandomValue(['red', 'blue', 'yellow']),
        shape: target.shape,
        size: _getRandomValue(['small', 'medium', 'large']),
      );
    } else {
      return SortableObject(
        color: _getRandomValue(['red', 'blue', 'yellow']),
        shape: _getRandomValue(['circle', 'square', 'triangle']),
        size: target.size,
      );
    }
  }

  SortingRule get currentRule => _sortingService.currentRule;
  SortableObject get targetObject => _targetObject;
  List<SortableObject> get currentObjects => _currentObjects;
  int get currentScore => _currentScore;

  Future<bool> handleObjectSelection(SortableObject selectedObject) async {
    final isCorrect = _sortingService.checkMatch(selectedObject, _targetObject);
    _sortingService.handleSortingResult(isCorrect);

    if (isCorrect) {
      _currentScore++;
      
      // Change rule every 3 correct answers
      if (_currentScore % 3 == 0) {
        _sortingService.changeRule();
        _ruleChanges++;
      }

      _generateNewRound();

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
      _currentSession ??= await GameService.instance.startSession();

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
    _sortingService.resetGame();
    _initializeGame();
  }
} 