import 'dart:math';
import '../models/sortable_object.dart';
import '../rules/sorting_rule.dart';

class SortingService {
  late SortingRule _currentRule;
  final List<SortingRule> _availableRules;
  final Random _random = Random();
  int _currentScore = 0;
  int _consecutiveCorrect = 0;
  static const int _consecutiveCorrectToChangeRule = 3;

  SortingService(this._availableRules) {
    _currentRule = _availableRules[0];
  }

  SortingRule get currentRule => _currentRule;
  int get currentScore => _currentScore;

  bool checkMatch(SortableObject object1, SortableObject object2) {
    return _currentRule.isMatch(object1, object2);
  }

  void handleSortingResult(bool isCorrect) {
    if (isCorrect) {
      _currentScore += 10;
      _consecutiveCorrect++;
      if (_consecutiveCorrect >= _consecutiveCorrectToChangeRule) {
        changeRule();
        _consecutiveCorrect = 0;
      }
    } else {
      _currentScore = max(0, _currentScore - 5);
      _consecutiveCorrect = 0;
    }
  }

  void changeRule() {
    final currentIndex = _availableRules.indexOf(_currentRule);
    final nextIndex = (currentIndex + 1) % _availableRules.length;
    _currentRule = _availableRules[nextIndex];
  }

  void resetGame() {
    _currentScore = 0;
    _consecutiveCorrect = 0;
    _currentRule = _availableRules[0];
  }
} 