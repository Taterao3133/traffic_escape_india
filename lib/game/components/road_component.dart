import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class RoadComponent extends PositionComponent {

  double lineOffset = 0;

  @override
  Future<void> onLoad() async {
    size = findGame()!.size;
    position = Vector2.zero();

    await super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    lineOffset += 300 * dt;

    if (lineOffset > 80) {
      lineOffset = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final roadPaint = Paint()
      ..color = Colors.grey.shade800;

    canvas.drawRect(size.toRect(), roadPaint);

    final lanePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6;

    final lane1 = size.x / 3;
    final lane2 = (size.x / 3) * 2;

    for (double y = -80 + lineOffset; y < size.y; y += 80) {

      canvas.drawLine(
        Offset(lane1, y),
        Offset(lane1, y + 40),
        lanePaint,
      );

      canvas.drawLine(
        Offset(lane2, y),
        Offset(lane2, y + 40),
        lanePaint,
      );
    }
  }
}