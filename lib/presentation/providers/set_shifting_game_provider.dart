import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../domain/models/sortable_object.dart';
import '../../domain/rules/sorting_rule.dart';
import '../../domain/services/sorting_service.dart';
import '../../services/game_service.dart';
import '../../models/game_session.dart';

class SetShiftingGameProvider extends ChangeNotifier {
  late final SortingService _sortingService;
  late List<SortableObject> currentObjects;
  late SortableObject targetObject;
  bool isAnimating = false;
  final Random _random = Random();
  
  // Game session tracking
  GameSession? _currentSession;
  DateTime? _startTime;
  int _questionCount = 0;
  final Map<String, int> _scores = {
    'color': 0,
    'shape': 0,
    'size': 0,
  };

  static const int maxQuestions = 10;

  SetShiftingGameProvider() {
    _sortingService = SortingService([
      ColorSortingRule(),
      ShapeSortingRule(),
      SizeSortingRule(),
    ]);
    _initializeGame();
  }

  SortingRule get currentRule => _sortingService.currentRule;
  int get currentScore => _scores.values.fold(0, (sum, score) => sum + score);
  int get questionCount => _questionCount;
  bool get isGameComplete => _questionCount >= maxQuestions;
  Duration get elapsedTime => _startTime != null ? DateTime.now().difference(_startTime!) : Duration.zero;

  Future<void> _initializeGame() async {
    try {
      _currentSession = await GameService.instance.startSession();
      _startTime = DateTime.now();
      _questionCount = 0;
      _scores.updateAll((key, value) => 0);
      initializeGame();
    } catch (e) {
      debugPrint('Failed to start game session: $e');
      // Initialize game anyway to allow offline play
      initializeGame();
    }
  }

  void initializeGame() {
    final objects = _generateSortableObjects();
    
    final matchingObjects = objects.where((obj) => currentRule.isMatch(obj, targetObject));
    assert(matchingObjects.length == 1, 'Invalid game state: ${matchingObjects.length} matching objects');
    
    currentObjects = objects;
    notifyListeners();
  }

  String _getRandomColor() {
    final colors = [
      SortableObjectColor.red,
      SortableObjectColor.blue,
      SortableObjectColor.yellow,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  String _getRandomShape() {
    final shapes = [
      SortableObjectShape.circle,
      SortableObjectShape.square,
      SortableObjectShape.triangle,
    ];
    return shapes[_random.nextInt(shapes.length)];
  }

  String _getRandomSize() {
    final sizes = [
      SortableObjectSize.small,
      SortableObjectSize.medium,
      SortableObjectSize.large,
    ];
    return sizes[_random.nextInt(sizes.length)];
  }

  List<SortableObject> _generateSortableObjects() {
    final objects = <SortableObject>[];
    
    // Generate the correct object first
    final correctObject = SortableObject(
      color: _getRandomColor(),
      shape: _getRandomShape(),
      size: _getRandomSize(),
      imageAsset: '',
    );

    // Generate the target object that matches the correct object based on current rule
    targetObject = SortableObject(
      color: currentRule is ColorSortingRule
          ? correctObject.color
          : _getRandomColor(),
      shape: currentRule is ShapeSortingRule
          ? correctObject.shape
          : _getRandomShape(),
      size: currentRule is SizeSortingRule
          ? correctObject.size
          : _getRandomSize(),
      imageAsset: '',
    );

    // Verify that the correct object actually matches the target
    assert(currentRule.isMatch(correctObject, targetObject), 
      'Generated correct object does not match target based on current rule');
    
    objects.add(correctObject);
    
    // Generate two incorrect objects that don't match the target
    while (objects.length < 3) {
      final incorrectObject = SortableObject(
        color: currentRule is ColorSortingRule
            ? _getRandomColorExcept(targetObject.color)
            : _getRandomColor(),
        shape: currentRule is ShapeSortingRule
            ? _getRandomShapeExcept(targetObject.shape)
            : _getRandomShape(),
        size: currentRule is SizeSortingRule
            ? _getRandomSizeExcept(targetObject.size)
            : _getRandomSize(),
        imageAsset: '',
      );

      // Double check that this object is actually incorrect
      if (!currentRule.isMatch(incorrectObject, targetObject)) {
        objects.add(incorrectObject);
      }
    }

    // Verify we have exactly 3 objects
    assert(objects.length == 3, 'Generated incorrect number of objects');
    
    // Verify exactly one object matches the target
    final matchingObjects = objects.where((obj) => currentRule.isMatch(obj, targetObject));
    assert(matchingObjects.length == 1, 'Found ${matchingObjects.length} matching objects instead of 1');

    objects.shuffle(_random);
    return objects;
  }

  String _getRandomColorExcept(String excludeColor) {
    final colors = [
      SortableObjectColor.red,
      SortableObjectColor.blue,
      SortableObjectColor.yellow,
    ]..removeWhere((color) => color == excludeColor);
    return colors[_random.nextInt(colors.length)];
  }

  String _getRandomShapeExcept(String excludeShape) {
    final shapes = [
      SortableObjectShape.circle,
      SortableObjectShape.square,
      SortableObjectShape.triangle,
    ]..removeWhere((shape) => shape == excludeShape);
    return shapes[_random.nextInt(shapes.length)];
  }

  String _getRandomSizeExcept(String excludeSize) {
    final sizes = [
      SortableObjectSize.small,
      SortableObjectSize.medium,
      SortableObjectSize.large,
    ]..removeWhere((size) => size == excludeSize);
    return sizes[_random.nextInt(sizes.length)];
  }

  Future<bool> handleObjectSelection(SortableObject selectedObject) async {
    if (isAnimating || isGameComplete) return false;

    final bool isCorrect = _sortingService.checkMatch(selectedObject, targetObject);
    _sortingService.handleSortingResult(isCorrect);

    if (isCorrect) {
      // Update score for current rule type
      final ruleType = currentRule is ColorSortingRule
          ? 'color'
          : currentRule is ShapeSortingRule
              ? 'shape'
              : 'size';
      _scores[ruleType] = (_scores[ruleType] ?? 0) + 1;
    }

    _questionCount++;
    isAnimating = true;
    notifyListeners();

    if (isCorrect) {
      final newObjects = _generateSortableObjects();
      await Future.delayed(const Duration(seconds: 2));
      currentObjects = newObjects;
    }

    isAnimating = false;
    notifyListeners();

    // Check if game is complete
    if (isGameComplete) {
      await _completeGame();
    }

    return isCorrect;
  }

  Future<void> _completeGame() async {
    if (_currentSession == null) return;

    try {
      await GameService.instance.updateSession(
        _currentSession!.id,
        scores: _scores,
        ruleChanges: _sortingService.currentScore ~/ 10, // Convert total score to rule changes
        durationSeconds: elapsedTime.inSeconds,
      );
    } catch (e) {
      debugPrint('Failed to update game session: $e');
    }
  }

  Future<void> resetGame() async {
    _sortingService.resetGame();
    await _initializeGame();
  }
} 