import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../config/game_config.dart';
import '../managers/game_manager.dart';

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
    if (GameManager.instance.isGameOver) {
      return;
    }

    lineOffset += 300 * dt;

    if (lineOffset > 80) {
      lineOffset = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final grassPaint = Paint()..color = const Color(0xFF235A2F);
    canvas.drawRect(size.toRect(), grassPaint);

    final roadLeft = GameConfig.roadLeft(size.x);
    final roadWidth = GameConfig.roadWidth(size.x);
    final laneWidth = GameConfig.laneWidth(size.x);
    final roadRect = Rect.fromLTWH(roadLeft, 0, roadWidth, size.y);

    final roadPaint = Paint()..color = Colors.grey.shade800;

    canvas.drawRect(roadRect, roadPaint);

    final shoulderPaint = Paint()
      ..color = Colors.yellow.shade700
      ..strokeWidth = 4;

    canvas.drawLine(
      Offset(roadLeft, 0),
      Offset(roadLeft, size.y),
      shoulderPaint,
    );
    canvas.drawLine(
      Offset(roadLeft + roadWidth, 0),
      Offset(roadLeft + roadWidth, size.y),
      shoulderPaint,
    );

    final lanePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6;

    final lane1 = roadLeft + laneWidth;
    final lane2 = roadLeft + laneWidth * 2;

    for (double y = -80 + lineOffset; y < size.y; y += 80) {
      canvas.drawLine(Offset(lane1, y), Offset(lane1, y + 40), lanePaint);

      canvas.drawLine(Offset(lane2, y), Offset(lane2, y + 40), lanePaint);
    }
  }
}
