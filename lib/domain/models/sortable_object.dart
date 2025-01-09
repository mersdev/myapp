class SortableObjectColor {
  static const red = 'red';
  static const blue = 'blue';
  static const yellow = 'yellow';
}

class SortableObjectShape {
  static const circle = 'circle';
  static const square = 'square';
  static const triangle = 'triangle';
}

class SortableObjectSize {
  static const small = 'small';
  static const medium = 'medium';
  static const large = 'large';
}

class SortableObject {
  final String color;
  final String shape;
  final String size;
  final String imageAsset;

  const SortableObject({
    required this.color,
    required this.shape,
    required this.size,
    required this.imageAsset,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SortableObject &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          shape == other.shape &&
          size == other.size;

  @override
  int get hashCode => color.hashCode ^ shape.hashCode ^ size.hashCode;
} 