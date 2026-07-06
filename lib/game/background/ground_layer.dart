import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/game_config.dart';
import 'scene_layer.dart';

class GroundLayer extends SceneLayer {
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final horizonY = GameConfig.roadHorizonY(size.y);

    final roadLeft = GameConfig.roadLeftAtY(size.x, size.y, horizonY);

    final roadRight = GameConfig.roadRightAtY(size.x, size.y, horizonY);

    final bottomLeft = GameConfig.roadLeftAtY(size.x, size.y, size.y);

    final bottomRight = GameConfig.roadRightAtY(size.x, size.y, size.y);

    final left = Path()
      ..moveTo(0, size.y)
      ..lineTo(0, horizonY)
      ..lineTo(roadLeft, horizonY)
      ..lineTo(bottomLeft, size.y)
      ..close();

    final right = Path()
      ..moveTo(size.x, size.y)
      ..lineTo(size.x, horizonY)
      ..lineTo(roadRight, horizonY)
      ..lineTo(bottomRight, size.y)
      ..close();

    canvas.drawPath(left, Paint()..color = const Color(0xFF2E6A35));

    canvas.drawPath(right, Paint()..color = const Color(0xFFB96F38));
  }
}
