import 'dart:ui' as ui;

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import '../config/game_config.dart';
import '../managers/game_manager.dart';

class RoadComponent extends PositionComponent {
  static final Images _terrainImages = Images(prefix: 'assets/');

  double lineOffset = 0;
  // late final ui.Image _clearSky;
  late final ui.Image _mountainSky;
  late final ui.Image _leftShoulderTile;
  late final ui.Image _rightShoulderTile;

  @override
  Future<void> onLoad() async {
    size = findGame()!.size;
    position = Vector2.zero();
    // _clearSky = await _terrainImages.load('terrain/sky_04.png');
    _mountainSky = await _terrainImages.load('terrain/sky_07.png');
    _leftShoulderTile = await Flame.images.load('road/road assists_02.png');
    _rightShoulderTile = await Flame.images.load('road/road assists_04.png');

    await super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (GameManager.instance.isGameOver) {
      return;
    }

    lineOffset += 360 * dt;

    if (lineOffset > _leftShoulderTile.height) {
      lineOffset %= _leftShoulderTile.height;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _drawScenery(canvas);
    // _drawRoadsideTiles(canvas);
    _drawRoad(canvas);
  }

  void _drawScenery(Canvas canvas) {
    final horizonY = GameConfig.roadHorizonY(size.y);
    final backgroundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF88C7ED), Color(0xFF2E6A35)],
      ).createShader(size.toRect());
    canvas.drawRect(size.toRect(), backgroundPaint);

    // _drawSkyImage(
    //   canvas,
    //   _clearSky,
    //   Rect.fromLTWH(0, 0, size.x, size.y * 0.16),
    // );
    _drawSkyImage(
      canvas,
      _mountainSky,
      Rect.fromLTWH(0, size.y * 0.00, size.x, size.y * 0.18),
    );

    final centerX = size.x / 2;
    final topLeft = GameConfig.roadLeftAtY(size.x, size.y, horizonY);
    final topRight = GameConfig.roadRightAtY(size.x, size.y, horizonY);
    final bottomLeft = GameConfig.roadLeftAtY(size.x, size.y, size.y);
    final bottomRight = GameConfig.roadRightAtY(size.x, size.y, size.y);

    final leftGround = Path()
      ..moveTo(0, size.y)
      ..lineTo(0, horizonY)
      ..lineTo(topLeft, horizonY)
      ..lineTo(bottomLeft, size.y)
      ..close();
    canvas.drawPath(leftGround, Paint()..color = const Color(0xFF2E6A35));

    final rightGround = Path()
      ..moveTo(size.x, size.y)
      ..lineTo(size.x, horizonY)
      ..lineTo(topRight, horizonY)
      ..lineTo(bottomRight, size.y)
      ..close();
    canvas.drawPath(rightGround, Paint()..color = const Color(0xFFB96F38));

    _drawDistantTerrain(canvas, horizonY, centerX);

    final riverPaint = Paint()
      ..color = const Color(0xFF1F8FB5).withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.x * 0.055;
    final river = Path()
      ..moveTo(size.x * 0.10, horizonY + 8)
      ..quadraticBezierTo(size.x * 0.03, size.y * 0.42, size.x * 0.15, size.y);
    canvas.drawPath(river, riverPaint);
  }

  void _drawDistantTerrain(Canvas canvas, double horizonY, double centerX) {
    final leftTrees = Paint()..color = const Color(0xFF1E5A2C);
    final rightRocks = Paint()..color = const Color(0xFF9C5B32);

    for (double x = 10; x < centerX - 42; x += 34) {
      final treePath = Path()
        ..moveTo(x, horizonY + 36)
        ..lineTo(x + 14, horizonY + 4)
        ..lineTo(x + 30, horizonY + 36)
        ..close();
      canvas.drawPath(treePath, leftTrees);
    }

    for (double x = centerX + 50; x < size.x; x += 42) {
      final rockPath = Path()
        ..moveTo(x, horizonY + 38)
        ..lineTo(x + 18, horizonY + 8)
        ..lineTo(x + 40, horizonY + 38)
        ..close();
      canvas.drawPath(rockPath, rightRocks);
    }
  }

  void _drawSkyImage(Canvas canvas, ui.Image image, Rect destination) {
    final imageRatio = image.width / image.height;
    final destinationRatio = destination.width / destination.height;
    late final Rect source;

    if (imageRatio > destinationRatio) {
      final sourceWidth = image.height * destinationRatio;
      source = Rect.fromLTWH(
        (image.width - sourceWidth) / 2,
        0,
        sourceWidth,
        image.height.toDouble(),
      );
    } else {
      final sourceHeight = image.width / destinationRatio;
      source = Rect.fromLTWH(
        0,
        (image.height - sourceHeight) / 2,
        image.width.toDouble(),
        sourceHeight,
      );
    }

    canvas.drawImageRect(image, source, destination, Paint());
  }

  void _drawRoadsideTiles(Canvas canvas) {
    final horizonY = GameConfig.roadHorizonY(size.y);
    final tileHeight = size.y * 0.14;
    const tileOverlap = 4.0;
    final leftTileWidth =
        tileHeight * _leftShoulderTile.width / _leftShoulderTile.height;
    final rightTileWidth =
        tileHeight * _rightShoulderTile.width / _rightShoulderTile.height;
    final srcLeft = Rect.fromLTWH(
      0,
      0,
      _leftShoulderTile.width.toDouble(),
      _leftShoulderTile.height.toDouble(),
    );
    final srcRight = Rect.fromLTWH(
      0,
      0,
      _rightShoulderTile.width.toDouble(),
      _rightShoulderTile.height.toDouble(),
    );

    for (
      double y = -tileHeight + lineOffset;
      y < size.y;
      y += tileHeight - tileOverlap
    ) {
      if (y + tileHeight < horizonY + 16) {
        continue;
      }

      final leftRoadEdge = GameConfig.roadLeftAtY(
        size.x,
        size.y,
        y + tileHeight,
      );
      final rightRoadEdge = GameConfig.roadRightAtY(
        size.x,
        size.y,
        y + tileHeight,
      );

      canvas.drawImageRect(
        _leftShoulderTile,
        srcLeft,
        Rect.fromLTWH(
          leftRoadEdge - leftTileWidth + 4,
          y,
          leftTileWidth,
          tileHeight,
        ),
        Paint(),
      );

      canvas.drawImageRect(
        _rightShoulderTile,
        srcRight,
        Rect.fromLTWH(rightRoadEdge - 4, y, rightTileWidth, tileHeight),
        Paint(),
      );
    }
  }

  void _drawRoad(Canvas canvas) {
    final horizonY = GameConfig.roadHorizonY(size.y);
    final bottomWidth = GameConfig.roadWidthAtY(size.x, size.y, size.y);
    final topWidth = GameConfig.roadWidthAtY(size.x, size.y, horizonY);
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
  }

  void _drawAsphaltTexture(Canvas canvas, Path roadPath, double horizonY) {
    canvas.save();
    canvas.clipPath(roadPath);

    final texturePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.055)
      ..strokeWidth = 1;
    for (double y = horizonY + 10 + lineOffset % 28; y < size.y; y += 28) {
      final left = GameConfig.roadLeftAtY(size.x, size.y, y);
      final right = GameConfig.roadRightAtY(size.x, size.y, y);

      canvas.drawLine(
        Offset(left + 8, y),
        Offset(right - 8, y + 4),
        texturePaint,
      );
    }

    canvas.restore();
  }

  void _drawLaneLines(Canvas canvas) {
    // final edgePaint = Paint()
    //   ..color = const ui.Color.fromARGB(255, 24, 24, 21)
    //   ..strokeWidth = 4
    //   ..strokeCap = StrokeCap.round;
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
    double lineX(double y) {
      final roadLeft = GameConfig.roadLeftAtY(size.x, size.y, y);
      final laneWidth = GameConfig.laneWidthAtY(size.x, size.y, y);

      return roadLeft + laneWidth * laneBoundary;
    }

    if (solid) {
      final horizonY = GameConfig.roadHorizonY(size.y);
      final path = Path()..moveTo(lineX(horizonY), horizonY);

      for (double y = horizonY + 20; y <= size.y; y += 20) {
        path.lineTo(lineX(y), y);
      }

      canvas.drawPath(path, paint);
      return;
    }

    const segment = 46.0;
    const gap = 52.0;
    final horizonY = GameConfig.roadHorizonY(size.y);
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
