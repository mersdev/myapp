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
    // Generate objects and target
    final objects = _generateSortableObjects();
    
    // Verify we have exactly one correct answer before setting
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
    if (isAnimating) return false;

    final bool isCorrect = _sortingService.checkMatch(selectedObject, targetObject);
    _sortingService.handleSortingResult(isCorrect);

    isAnimating = true;
    notifyListeners();

    if (isCorrect) {
      // Generate new objects immediately but don't notify yet
      final newObjects = _generateSortableObjects();
      
      // Wait for 2 seconds (matching the feedback animation duration)
      await Future.delayed(const Duration(seconds: 2));
      
      // Update the objects and notify
      currentObjects = newObjects;
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