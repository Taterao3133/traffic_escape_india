// import 'dart:ui' as ui;

// import 'package:flame/cache.dart';
import 'package:flame/components.dart';
// import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
// import '../config/game_config.dart';
import '../managers/game_manager.dart';
// import '../road/road_geometry.dart';
// import '../traffic_game.dart';
import '../road/road_provider.dart';

class RoadComponent extends PositionComponent with RoadProvider {
  // static final Images _terrainImages = Images(prefix: 'assets/');

  double lineOffset = 0;
  // late RoadGeometry road;
  // RoadGeometry get road => (findGame() as TrafficGame).road;

  @override
  Future<void> onLoad() async {
    priority = 0;

    size = findGame()!.size;
    position = Vector2.zero();

    // road = RoadGeometry(screenWidth: size.x, screenHeight: size.y);

    await super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (GameManager.instance.isGameOver) {
      return;
    }

    lineOffset += 240 * dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _drawRoad(canvas);
  }

  // void _drawScenery(Canvas canvas) {
  //   final horizonY = road.horizonY;
  //   final backgroundPaint = Paint()
  //     ..shader = const LinearGradient(
  //       begin: Alignment.topCenter,
  //       end: Alignment.bottomCenter,
  //       colors: [Color(0xFF88C7ED), Color(0xFF2E6A35)],
  //     ).createShader(size.toRect());
  //   canvas.drawRect(size.toRect(), backgroundPaint);

  //   final centerX = size.x / 2;
  //   final topLeft = road.roadLeft(horizonY);
  //   final topRight = road.roadRight(horizonY);

  //   final bottomLeft = road.roadLeft(size.y);
  //   final bottomRight = road.roadRight(size.y);
  //   final leftGround = Path()
  //     ..moveTo(0, size.y)
  //     ..lineTo(0, horizonY)
  //     ..lineTo(topLeft, horizonY)
  //     ..lineTo(bottomLeft, size.y)
  //     ..close();
  //   canvas.drawPath(leftGround, Paint()..color = const Color(0xFF2E6A35));

  //   final rightGround = Path()
  //     ..moveTo(size.x, size.y)
  //     ..lineTo(size.x, horizonY)
  //     ..lineTo(topRight, horizonY)
  //     ..lineTo(bottomRight, size.y)
  //     ..close();
  //   canvas.drawPath(rightGround, Paint()..color = const Color(0xFFB96F38));

  //   _drawDistantTerrain(canvas, horizonY, centerX);

  //   final riverPaint = Paint()
  //     ..color = const Color(0xFF1F8FB5).withValues(alpha: 0.78)
  //     ..style = PaintingStyle.stroke
  //     ..strokeCap = StrokeCap.round
  //     ..strokeWidth = size.x * 0.055;
  //   final river = Path()
  //     ..moveTo(size.x * 0.10, horizonY + 8)
  //     ..quadraticBezierTo(size.x * 0.03, size.y * 0.42, size.x * 0.15, size.y);
  //   canvas.drawPath(river, riverPaint);
  // }

  // void _drawDistantTerrain(Canvas canvas, double horizonY, double centerX) {
  //   final leftTrees = Paint()..color = const Color(0xFF1E5A2C);
  //   final rightRocks = Paint()..color = const Color(0xFF9C5B32);

  //   for (double x = 10; x < centerX - 42; x += 34) {
  //     final treePath = Path()
  //       ..moveTo(x, horizonY + 36)
  //       ..lineTo(x + 14, horizonY + 4)
  //       ..lineTo(x + 30, horizonY + 36)
  //       ..close();
  //     canvas.drawPath(treePath, leftTrees);
  //   }

  //   for (double x = centerX + 50; x < size.x; x += 42) {
  //     final rockPath = Path()
  //       ..moveTo(x, horizonY + 38)
  //       ..lineTo(x + 18, horizonY + 8)
  //       ..lineTo(x + 40, horizonY + 38)
  //       ..close();
  //     canvas.drawPath(rockPath, rightRocks);
  //   }
  // }

  // void _drawSkyImage(Canvas canvas, ui.Image image, Rect destination) {
  //   final imageRatio = image.width / image.height;
  //   final destinationRatio = destination.width / destination.height;
  //   late final Rect source;

  //   if (imageRatio > destinationRatio) {
  //     final sourceWidth = image.height * destinationRatio;
  //     source = Rect.fromLTWH(
  //       (image.width - sourceWidth) / 2,
  //       0,
  //       sourceWidth,
  //       image.height.toDouble(),
  //     );
  //   } else {
  //     final sourceHeight = image.width / destinationRatio;
  //     source = Rect.fromLTWH(
  //       0,
  //       (image.height - sourceHeight) / 2,
  //       image.width.toDouble(),
  //       sourceHeight,
  //     );
  //   }

  //   canvas.drawImageRect(image, source, destination, Paint());
  // }

  void _drawRoad(Canvas canvas) {
    // final horizonY = GameConfig.roadHorizonY(size.y);
    final horizonY = road.horizonY;
    // Landscape highway proportions
    final bottomWidth = road.roadWidth(size.y);
    final topWidth = road.roadWidth(horizonY);
    final centerX = size.x / 2;
    final roadPath = Path()
      ..moveTo(centerX - topWidth / 2, horizonY)
      ..lineTo(centerX + topWidth / 2, horizonY)
      ..lineTo(centerX + bottomWidth / 2, size.y)
      ..lineTo(centerX - bottomWidth / 2, size.y)
      ..close();

    canvas.drawPath(
      roadPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3B3B3B), Color(0xFF222222)],
        ).createShader(Rect.fromLTWH(0, horizonY, size.x, size.y - horizonY)),
    );

    _drawAsphaltTexture(canvas, roadPath, horizonY);

    _drawLaneLines(canvas);

    canvas.drawPath(
      roadPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.10),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.20),
          ],
        ).createShader(Rect.fromLTWH(0, horizonY, size.x, size.y - horizonY)),
    );

    final fadePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.75),
          Colors.white.withValues(alpha: 0.30),
          Colors.transparent,
        ],
        stops: const [0.0, 0.20, 1.0],
      ).createShader(Rect.fromLTWH(0, horizonY, size.x, size.y * 0.20));

    canvas.save();
    canvas.clipPath(roadPath);

    canvas.drawRect(
      Rect.fromLTWH(0, horizonY, size.x, size.y * 0.20),
      fadePaint,
    );

    canvas.restore();
  }

  void _drawAsphaltTexture(Canvas canvas, Path roadPath, double horizonY) {
    canvas.save();
    canvas.clipPath(roadPath);

    final texturePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.055)
      ..strokeWidth = 1;
    for (double y = horizonY + 10 + lineOffset % 28; y < size.y; y += 28) {
      final left = road.roadLeft(y);
      final right = road.roadRight(y);

      canvas.drawLine(
        Offset(left + 8, y),
        Offset(right - 8, y + 4),
        texturePaint,
      );
    }

    canvas.restore();
  }

  void _drawLaneLines(Canvas canvas) {
    final lanePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.88)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // _drawProjectedLine(canvas, 0, edgePaint, solid: true);
    _drawProjectedLine(canvas, 1, lanePaint);
    _drawProjectedLine(canvas, 2, lanePaint);
    // _drawProjectedLine(canvas, 3, edgePaint, solid: true);
  }

  void _drawProjectedLine(
    Canvas canvas,
    int laneBoundary,
    Paint paint, {
    bool solid = false,
  }) {
    // final horizonY = GameConfig.roadHorizonY(size.y);
    final horizonY = road.horizonY;
    double lineX(double y) {
      return road.roadLeft(y) + road.laneWidth(y) * laneBoundary;
    }

    if (solid) {
      // final horizonY = GameConfig.roadHorizonY(size.y);
      final horizonY = road.horizonY;
      final path = Path()..moveTo(lineX(horizonY), horizonY);

      for (double y = horizonY + 20; y <= size.y; y += 20) {
        path.lineTo(lineX(y), y);
      }

      canvas.drawPath(path, paint);
      return;
    }

    const segment = 46.0;
    const gap = 52.0;
    for (
      double y = horizonY - segment + lineOffset % (segment + gap);
      y < size.y;
      y += segment + gap
    ) {
      final y1 = y.clamp(horizonY, size.y);
      final y2 = (y + segment).clamp(0.0, size.y);

      if (y2 <= horizonY || y1 >= size.y) {
        continue;
      }

      canvas.drawLine(Offset(lineX(y1), y1), Offset(lineX(y2), y2), paint);
    }
  }
}
