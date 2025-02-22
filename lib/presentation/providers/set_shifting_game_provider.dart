import 'package:flutter/material.dart';
import '../../domain/models/sortable_object.dart';
import '../../domain/rules/sorting_rule.dart';
import '../../domain/services/sorting_service.dart';
import '../../services/game_service.dart';
import '../../models/game_session.dart';

class SetShiftingGameProvider extends ChangeNotifier {
  static const int maxQuestions = 5;
  late final SortingService _sortingService;
  GameSession? _currentSession;  
  int _currentScore = 0;  
  int _correctAnswers = 0;  
  int _ruleChanges = 0;  
  DateTime? _startTime;  
  List<SortableObject> _currentObjects = [];  
  late SortableObject _targetObject;  
  int _questionNumber = 0;
  bool _isGameOver = false;

  // Add getters
  int get questionNumber => _questionNumber;
  bool get isLastQuestion => _questionNumber == maxQuestions - 1;
  
  SetShiftingGameProvider() {
    _sortingService = SortingService([
      ColorSortingRule(),
      ShapeSortingRule(),
      SizeSortingRule(),
    ]);    
    resetGame(); 
  }

  void _generateNewRound() {
    _targetObject = _generateRandomObject();
    _currentObjects = _generateObjects();
  }

  SortableObject _generateRandomObject() {
    final color = _getRandomValue(['red', 'blue', 'yellow']);
    final shape = _getRandomValue(['circle', 'square', 'triangle']);
    final size = _getRandomValue(['small', 'medium', 'large']);
    return SortableObject(
      color: color,
      shape: shape,
      size: size,
      imageAsset: 'assets/images/placeholder.png', // Placeholder image asset
    );
  }

  SortableObject _generateNonMatchingObject(SortableObject target) {
    final rule = _sortingService.currentRule;
    
    if (rule is ColorSortingRule) {
      var color = _getRandomValue(['red', 'blue', 'yellow']);
      while (color == target.color) {
        color = _getRandomValue(['red', 'blue', 'yellow']);
      }
      return SortableObject(
        color: color,
        shape: _getRandomValue(['circle', 'square', 'triangle']),
        size: _getRandomValue(['small', 'medium', 'large']),
        imageAsset: 'assets/images/placeholder.png',
      );
    } else if (rule is ShapeSortingRule) {
      var shape = _getRandomValue(['circle', 'square', 'triangle']);
      while (shape == target.shape) {
        shape = _getRandomValue(['circle', 'square', 'triangle']);
      }
      return SortableObject(
        color: _getRandomValue(['red', 'blue', 'yellow']),
        shape: shape,
        size: _getRandomValue(['small', 'medium', 'large']),
        imageAsset: 'assets/images/placeholder.png',
      );
    } else if (rule is SizeSortingRule) {
      var size = _getRandomValue(['small', 'medium', 'large']);
      while(size == target.size){
        size = _getRandomValue(['small', 'medium', 'large']);
      }
      return SortableObject(
        color: _getRandomValue(['red', 'blue', 'yellow']),
        shape: _getRandomValue(['circle', 'square', 'triangle']),
        size: size,
        imageAsset: 'assets/images/placeholder.png',
      );
    }
    // Fallback to generating a random object if rule type is unknown
    return _generateRandomObject();
  }

  SortableObject _generateMatchingObject(SortableObject target) {
    final rule = _sortingService.currentRule;

    if (rule is ColorSortingRule) {
      return SortableObject(
        color: target.color,
        shape: _getRandomValue(['circle', 'square', 'triangle']),
        size: _getRandomValue(['small', 'medium', 'large']),
        imageAsset: 'assets/images/placeholder.png',
      );
    } else if (rule is ShapeSortingRule) {
      return SortableObject(
        color: _getRandomValue(['red', 'blue', 'yellow']),
        shape: target.shape,
        size: _getRandomValue(['small', 'medium', 'large']),
        imageAsset: 'assets/images/placeholder.png',
      );
    } else if (rule is SizeSortingRule) {
      return SortableObject(
        color: _getRandomValue(['red', 'blue', 'yellow']),
        shape: _getRandomValue(['circle', 'square', 'triangle']),
        size: target.size,
        imageAsset: 'assets/images/placeholder.png',
      );
    } else {
      // Default case, should not happen ideally
      return SortableObject(
        color: target.color,
        shape: target.shape,
        size: target.size,
        imageAsset: 'assets/images/placeholder.png',
      );
    }
  }

  String _getRandomValue(List<String> values) {
    return values[DateTime.now().microsecondsSinceEpoch % values.length];
  }

  List<SortableObject> _generateObjects() {
    // Generate one matching object
    final matchingObject = _generateMatchingObject(_targetObject);

    // Generate two non-matching objects
    final nonMatchingObject1 = _generateNonMatchingObject(_targetObject);
    final nonMatchingObject2 = _generateNonMatchingObject(_targetObject);

    // Combine the objects into a list
    final objects = [matchingObject, nonMatchingObject1, nonMatchingObject2];

    objects.shuffle();
    return objects;
  }

  Future<bool> handleObjectSelection(SortableObject selectedObject) async {
    if (_isGameOver) return false;
    
    final isCorrect = _sortingService.checkMatch(_targetObject, selectedObject);
    _sortingService.handleSortingResult(isCorrect);
    
    if (isCorrect) {
      _correctAnswers++;
      _currentScore += 10;
    }
    
    _questionNumber++;
    
    // Only set game over when we've completed all questions
    if (_questionNumber >= maxQuestions) {
      _isGameOver = true;
      await _saveGameSession();
    }
    
    notifyListeners();
    return isCorrect;
  }

  void nextQuestion() {
    if (_isGameOver) return;
    _generateNewRound();
    notifyListeners();
  }

  Future<void> _saveGameSession() async {
    if (_currentSession == null) return;
    
    try {
      await GameService.instance.updateSession(
        _currentSession!.id,
        scores: {
          'color': _correctAnswers,
          'shape': _correctAnswers,
          'size': _correctAnswers,
        },
        ruleChanges: _ruleChanges,
        durationSeconds: DateTime.now().difference(_startTime!).inSeconds,
      );
    } catch (e) {
      debugPrint('Error saving game session: $e');
    }
  }

  SortingRule get currentRule => _sortingService.currentRule;
  SortableObject get targetObject => _targetObject;
  List<SortableObject> get currentObjects => _currentObjects;
int get currentScore => _currentScore;
bool get isGameOver => _isGameOver;
int get correctAnswers => _correctAnswers;
int get totalQuestions => _questionNumber;
int get remainingQuestions => maxQuestions - _questionNumber;

Duration get gameDuration {
  if (_startTime == null) {
    return Duration.zero;
  }
  return DateTime.now().difference(_startTime!);
}

  void _changeRule() {
    _sortingService.changeRule();
    _ruleChanges++;
    _correctAnswers = 0; // Reset correct answers counter
  }

  void resetGame() {
    _isGameOver = false;
    _currentScore = 0;
    _ruleChanges = 0;
    _correctAnswers = 0;
    _questionNumber = 0;
    _sortingService.resetGame();
    _generateNewRound();
    _startTime = DateTime.now();
    notifyListeners();
  }

  void showGameOverDialog(BuildContext context) {
    if (!isGameOver) return; 

    // Access game stats using provider's getters
    final correctAns = correctAnswers;
    final totalQues = totalQuestions;
    final duration = gameDuration.inSeconds;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over!'), 
        content: Text('You answered $correctAns out of $totalQues questions correctly in $duration seconds.'), 
        actions: [
          TextButton(onPressed: () { Navigator.of(context).pop(); resetGame(); }, child: const Text('Play Again'))
        ],
      ),
    );
  }
  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}

class GameStats {
  final int correctAnswers;
  final int totalQuestions;
  final Duration gameDuration;

  GameStats({required this.correctAnswers, required this.totalQuestions, required this.gameDuration});
}