import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HighContrastQrCode extends StatelessWidget {
  final String data;
  final double size;

  const HighContrastQrCode({
    super.key,
    required this.data,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 2),
      ),
      child: CustomPaint(
        painter: _QrPainter(data: data),
        size: Size(size - 24, size - 24),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  final String data;
  _QrPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final double cellSize = size.width / 21;

    // Draw finder patterns (top-left, top-right, bottom-left)
    _drawFinderPattern(canvas, paint, 0, 0, cellSize);
    _drawFinderPattern(canvas, paint, (21 - 7) * cellSize, 0, cellSize);
    _drawFinderPattern(canvas, paint, 0, (21 - 7) * cellSize, cellSize);

    // Draw procedural high-contrast modules based on data hash
    final hash = data.hashCode.abs();
    for (int r = 0; r < 21; r++) {
      for (int c = 0; c < 21; c++) {
        // Skip finder areas
        if ((r < 8 && c < 8) ||
            (r < 8 && c > 12) ||
            (r > 12 && c < 8)) {
          continue;
        }

        // Timing patterns
        if (r == 6 || c == 6) {
          if ((r + c) % 2 == 0) {
            canvas.drawRect(
              Rect.fromLTWH(c * cellSize, r * cellSize, cellSize - 0.5, cellSize - 0.5),
              paint,
            );
          }
          continue;
        }

        final bit = ((hash ^ (r * 31 + c * 17)) % 7) < 4;
        if (bit) {
          canvas.drawRect(
            Rect.fromLTWH(c * cellSize, r * cellSize, cellSize - 0.5, cellSize - 0.5),
            paint,
          );
        }
      }
    }
  }

  void _drawFinderPattern(
    Canvas canvas,
    Paint paint,
    double x,
    double y,
    double cellSize,
  ) {
    // Outer 7x7
    canvas.drawRect(
      Rect.fromLTWH(x, y, 7 * cellSize, 7 * cellSize),
      paint,
    );
    // Inner 5x5 cutout
    final whitePaint = Paint()..color = AppColors.surfaceContainerLowest;
    canvas.drawRect(
      Rect.fromLTWH(x + cellSize, y + cellSize, 5 * cellSize, 5 * cellSize),
      whitePaint,
    );
    // Center 3x3 solid
    canvas.drawRect(
      Rect.fromLTWH(x + 2 * cellSize, y + 2 * cellSize, 3 * cellSize, 3 * cellSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) => oldDelegate.data != data;
}
