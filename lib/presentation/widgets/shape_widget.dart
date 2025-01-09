import 'package:flutter/material.dart';
import '../../domain/models/sortable_object.dart';
import 'shape_painter.dart';

class ShapeWidget extends StatelessWidget {
  final SortableObject object;
  final double size;

  const ShapeWidget({
    super.key,
    required this.object,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: ShapePainter(
          shape: object.shape,
          color: object.color,
          size: object.size,
        ),
      ),
    );
  }
} 