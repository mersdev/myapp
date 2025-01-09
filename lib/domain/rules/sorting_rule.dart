import '../models/sortable_object.dart';

abstract class SortingRule {
  bool isMatch(SortableObject object1, SortableObject object2);
  String get ruleName;
}

class ColorSortingRule implements SortingRule {
  @override
  bool isMatch(SortableObject object1, SortableObject object2) {
    return object1.color == object2.color;
  }

  @override
  String get ruleName => 'Color';
}

class ShapeSortingRule implements SortingRule {
  @override
  bool isMatch(SortableObject object1, SortableObject object2) {
    return object1.shape == object2.shape;
  }

  @override
  String get ruleName => 'Shape';
}

class SizeSortingRule implements SortingRule {
  @override
  bool isMatch(SortableObject object1, SortableObject object2) {
    return object1.size == object2.size;
  }

  @override
  String get ruleName => 'Size';
} 