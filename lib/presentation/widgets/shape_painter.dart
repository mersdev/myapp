import 'package:flutter/material.dart';
import '../../domain/models/sortable_object.dart';

class ShapePainter extends CustomPainter {
  final String shape;
  final String color;
  final String size;

  ShapePainter({
    required this.shape,
    required this.color,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _getColor()
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = _getSize(size);

    switch (shape) {
      case SortableObjectShape.circle:
        _drawCircle(canvas, center, radius, paint);
        break;
      case SortableObjectShape.square:
        _drawSquare(canvas, center, radius, paint);
        break;
      case SortableObjectShape.triangle:
        _drawTriangle(canvas, center, radius, paint);
        break;
    }
  }

  void _drawCircle(Canvas canvas, Offset center, double radius, Paint paint) {
    canvas.drawCircle(center, radius, paint);
  }

  void _drawSquare(Canvas canvas, Offset center, double radius, Paint paint) {
    final rect = Rect.fromCenter(
      center: center,
      width: radius * 2,
      height: radius * 2,
    );
    canvas.drawRect(rect, paint);
  }

  void _drawTriangle(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    final height = radius * 2;
    final width = radius * 2;

    path.moveTo(center.dx, center.dy - height / 2); // Top vertex
    path.lineTo(center.dx - width / 2, center.dy + height / 2); // Bottom left
    path.lineTo(center.dx + width / 2, center.dy + height / 2); // Bottom right
    path.close();

    canvas.drawPath(path, paint);
  }

  Color _getColor() {
    switch (color) {
      case SortableObjectColor.red:
        return Colors.red;
      case SortableObjectColor.blue:
        return Colors.blue;
      case SortableObjectColor.yellow:
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  double _getSize(Size canvasSize) {
    final minDimension = canvasSize.width < canvasSize.height
        ? canvasSize.width
        : canvasSize.height;

    switch (size) {
      case SortableObjectSize.small:
        return minDimension * 0.2;
      case SortableObjectSize.medium:
        return minDimension * 0.3;
      case SortableObjectSize.large:
        return minDimension * 0.4;
      default:
        return minDimension * 0.3;
    }
  }

  @override
  bool shouldRepaint(ShapePainter oldDelegate) {
    return oldDelegate.shape != shape ||
        oldDelegate.color != color ||
        oldDelegate.size != size;
  }
} 