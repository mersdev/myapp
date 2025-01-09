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
    final correctObject = SortableObject(
      color: _getRandomColor(),
      shape: _getRandomShape(),
      size: _getRandomSize(),
      imageAsset: '',
    );
    objects.add(correctObject);
    
    // Generate two incorrect objects that don't match based on current rule
    for (var i = 0; i < 2; i++) {
      SortableObject incorrectObject;
      do {
        incorrectObject = SortableObject(
          color: currentRule is ColorSortingRule
              ? _getRandomColorExcept(correctObject.color)
              : _getRandomColor(),
          shape: currentRule is ShapeSortingRule
              ? _getRandomShapeExcept(correctObject.shape)
              : _getRandomShape(),
          size: currentRule is SizeSortingRule
              ? _getRandomSizeExcept(correctObject.size)
              : _getRandomSize(),
          imageAsset: '',
        );
      } while (currentRule.isMatch(incorrectObject, correctObject));
      objects.add(incorrectObject);
    }

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

  SortableObject _generateTargetObject() {
    // Use the first object as base to ensure we have a matching pair
    final baseObject = currentObjects[0];
    
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
      imageAsset: '',
    );
  }

  Future<bool> handleObjectSelection(SortableObject selectedObject) async {
    if (isAnimating) return false;

    final bool isCorrect = _sortingService.checkMatch(selectedObject, targetObject);
    _sortingService.handleSortingResult(isCorrect);

    isAnimating = true;
    notifyListeners();

    if (isCorrect) {
      // Generate new objects immediately but don't notify yet
      final newObjects = _generateSortableObjects();
      final newTarget = _generateTargetObject();
      
      // Wait for 2 seconds (matching the feedback animation duration)
      await Future.delayed(const Duration(seconds: 2));
      
      // Update the objects and notify
      currentObjects = newObjects;
      targetObject = newTarget;
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