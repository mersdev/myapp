import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../domain/models/sortable_object.dart';
import '../../domain/rules/sorting_rule.dart';
import '../../domain/services/sorting_service.dart';

class SetShiftingGameProvider extends ChangeNotifier {
  late final SortingService _sortingService;
  late List<SortableObject> currentObjects;
  late SortableObject targetObject;
  bool isAnimating = false;
  final Random _random = Random();

  SetShiftingGameProvider() {
    _sortingService = SortingService([
      ColorSortingRule(),
      ShapeSortingRule(),
      SizeSortingRule(),
    ]);
    initializeGame();
  }

  SortingRule get currentRule => _sortingService.currentRule;
  int get currentScore => _sortingService.currentScore;

  void initializeGame() {
    currentObjects = _generateSortableObjects();
    targetObject = _generateTargetObject();
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
    
    // Generate two random objects
    for (var i = 0; i < 2; i++) {
      objects.add(
        SortableObject(
          color: _getRandomColor(),
          shape: _getRandomShape(),
          size: _getRandomSize(),
          imageAsset: '', // Not used anymore
        ),
      );
    }

    // Generate a third object that matches one of the previous objects
    // based on the current rule
    final baseObject = objects[0];
    final matchingObject = SortableObject(
      color: currentRule is ColorSortingRule
          ? baseObject.color
          : _getRandomColor(),
      shape: currentRule is ShapeSortingRule
          ? baseObject.shape
          : _getRandomShape(),
      size: currentRule is SizeSortingRule
          ? baseObject.size
          : _getRandomSize(),
      imageAsset: '', // Not used anymore
    );

    objects.add(matchingObject);
    objects.shuffle(_random);
    return objects;
  }

  SortableObject _generateTargetObject() {
    // Pick a random object from current objects and create a matching target
    // based on the current rule
    final baseObject = currentObjects[_random.nextInt(currentObjects.length)];
    
    return SortableObject(
      color: currentRule is ColorSortingRule
          ? baseObject.color
          : _getRandomColor(),
      shape: currentRule is ShapeSortingRule
          ? baseObject.shape
          : _getRandomShape(),
      size: currentRule is SizeSortingRule
          ? baseObject.size
          : _getRandomSize(),
      imageAsset: '', // Not used anymore
    );
  }

  Future<bool> handleObjectSelection(SortableObject selectedObject) async {
    if (isAnimating) return false;

    final bool isCorrect = _sortingService.checkMatch(selectedObject, targetObject);
    _sortingService.handleSortingResult(isCorrect);

    isAnimating = true;
    notifyListeners();

    if (isCorrect) {
      await Future.delayed(const Duration(milliseconds: 500));
      currentObjects = _generateSortableObjects();
      targetObject = _generateTargetObject();
    }

    isAnimating = false;
    notifyListeners();

    return isCorrect;
  }

  void resetGame() {
    _sortingService.resetGame();
    initializeGame();
  }
} 