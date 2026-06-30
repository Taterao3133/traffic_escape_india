import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/game_config.dart';
import '../managers/game_manager.dart';

enum EnvironmentObjectType {
  tree,
  palmTree,
  house,
  streetLight,
  trafficSign,
  barrier,
}

enum RoadSide { left, right }

/// Reusable roadside prop that scrolls with the road and recycles offscreen.
class EnvironmentComponent extends PositionComponent {
  EnvironmentComponent({Random? random, RoadSide? side, double? initialY})
    : this._(random ?? Random(), side, initialY);

  EnvironmentComponent._(Random random, RoadSide? side, this.initialY)
    : _random = random,
      _side = side ?? (random.nextBool() ? RoadSide.left : RoadSide.right),
      super();

  static const double _baseScrollSpeed = 320;
  static const double _roadPadding = 8;
  static const double _screenPadding = 8;

  final Random _random;
  final double? initialY;

  late EnvironmentObjectType _type;
  RoadSide _side;

  @override
  Future<void> onLoad() async {
    anchor = Anchor.topLeft;
    _chooseObject();
    position.y = initialY ?? -_random.nextDouble() * findGame()!.size.y;
    _placeOutsideRoad();

    await super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (GameManager.instance.isGameOver) {
      return;
    }

    position.y += _baseScrollSpeed * dt;

    if (position.y > findGame()!.size.y + size.y) {
      _recycle();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    switch (_type) {
      case EnvironmentObjectType.tree:
        _drawTree(canvas, const Color(0xFF2E7D32));
        break;
      case EnvironmentObjectType.palmTree:
        _drawPalmTree(canvas);
        break;
      case EnvironmentObjectType.house:
        _drawHouse(canvas);
        break;
      case EnvironmentObjectType.streetLight:
        _drawStreetLight(canvas);
        break;
      case EnvironmentObjectType.trafficSign:
        _drawTrafficSign(canvas);
        break;
      case EnvironmentObjectType.barrier:
        _drawBarrier(canvas);
        break;
    }
  }

  void _recycle() {
    _side = _random.nextBool() ? RoadSide.left : RoadSide.right;
    _chooseObject();
    position.y = -size.y - _random.nextDouble() * 260;
    _placeOutsideRoad();
  }

  void _chooseObject() {
    final roll = _random.nextInt(100);

    if (roll < 34) {
      _type = EnvironmentObjectType.tree;
      size = Vector2(34, 72);
    } else if (roll < 52) {
      _type = EnvironmentObjectType.palmTree;
      size = Vector2(32, 92);
    } else if (roll < 68) {
      _type = EnvironmentObjectType.house;
      size = Vector2(42, 48);
    } else if (roll < 82) {
      _type = EnvironmentObjectType.streetLight;
      size = Vector2(16, 76);
    } else if (roll < 92) {
      _type = EnvironmentObjectType.trafficSign;
      size = Vector2(28, 46);
    } else {
      _type = EnvironmentObjectType.barrier;
      size = Vector2(38, 22);
    }
  }

  void _placeOutsideRoad() {
    final gameSize = findGame()!.size;
    final roadLeft = GameConfig.roadLeft(gameSize.x);
    final roadRight = GameConfig.roadRight(gameSize.x);

    if (_side == RoadSide.left) {
      final maxX = roadLeft - size.x - _roadPadding;
      position.x = _randomRange(_screenPadding, max(_screenPadding, maxX));
      return;
    }

    final minX = roadRight + _roadPadding;
    final maxX = gameSize.x - size.x - _screenPadding;
    position.x = _randomRange(min(minX, maxX), max(minX, maxX));
  }

  double _randomRange(double minValue, double maxValue) {
    if (maxValue <= minValue) {
      return minValue;
    }

    return minValue + _random.nextDouble() * (maxValue - minValue);
  }

  void _drawTree(Canvas canvas, Color leafColor) {
    final trunkPaint = Paint()..color = const Color(0xFF795548);
    final leafPaint = Paint()..color = leafColor;

    canvas.drawRect(
      Rect.fromLTWH(size.x * 0.42, size.y * 0.48, size.x * 0.16, size.y * 0.46),
      trunkPaint,
    );
    canvas.drawCircle(
      Offset(size.x * 0.5, size.y * 0.32),
      size.x * 0.38,
      leafPaint,
    );
    canvas.drawCircle(
      Offset(size.x * 0.32, size.y * 0.45),
      size.x * 0.26,
      leafPaint,
    );
    canvas.drawCircle(
      Offset(size.x * 0.68, size.y * 0.45),
      size.x * 0.26,
      leafPaint,
    );
  }

  void _drawPalmTree(Canvas canvas) {
    final trunkPaint = Paint()..color = const Color(0xFF8D6E63);
    final leafPaint = Paint()..color = const Color(0xFF43A047);

    canvas.drawRect(
      Rect.fromLTWH(size.x * 0.43, size.y * 0.26, size.x * 0.14, size.y * 0.68),
      trunkPaint,
    );

    for (final angle in const [-1.2, -0.55, 0.0, 0.55, 1.2]) {
      final end = Offset(
        size.x * 0.5 + cos(angle) * size.x * 0.48,
        size.y * 0.2 + sin(angle) * size.y * 0.18,
      );
      canvas.drawLine(
        Offset(size.x * 0.5, size.y * 0.22),
        end,
        leafPaint..strokeWidth = 7,
      );
    }
  }

  void _drawHouse(Canvas canvas) {
    final wallPaint = Paint()..color = const Color(0xFFD7CCC8);
    final roofPaint = Paint()..color = const Color(0xFFB71C1C);
    final doorPaint = Paint()..color = const Color(0xFF4E342E);

    canvas.drawRect(
      Rect.fromLTWH(2, size.y * 0.38, size.x - 4, size.y * 0.52),
      wallPaint,
    );

    final roof = Path()
      ..moveTo(size.x * 0.5, 0)
      ..lineTo(size.x, size.y * 0.42)
      ..lineTo(0, size.y * 0.42)
      ..close();
    canvas.drawPath(roof, roofPaint);
    canvas.drawRect(
      Rect.fromLTWH(size.x * 0.42, size.y * 0.62, size.x * 0.18, size.y * 0.28),
      doorPaint,
    );
  }

  void _drawStreetLight(Canvas canvas) {
    final polePaint = Paint()
      ..color = const Color(0xFF455A64)
      ..strokeWidth = 4;
    final lightPaint = Paint()..color = const Color(0xFFFFD54F);

    canvas.drawLine(
      Offset(size.x * 0.5, size.y),
      Offset(size.x * 0.5, size.y * 0.18),
      polePaint,
    );
    canvas.drawLine(
      Offset(size.x * 0.5, size.y * 0.18),
      Offset(size.x, size.y * 0.18),
      polePaint,
    );
    canvas.drawCircle(
      Offset(size.x * 0.88, size.y * 0.22),
      size.x * 0.24,
      lightPaint,
    );
  }

  void _drawTrafficSign(Canvas canvas) {
    final polePaint = Paint()
      ..color = const Color(0xFF546E7A)
      ..strokeWidth = 3;
    final signPaint = Paint()..color = const Color(0xFFFFC107);

    canvas.drawLine(
      Offset(size.x * 0.5, size.y),
      Offset(size.x * 0.5, size.y * 0.35),
      polePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 0, size.x - 4, size.y * 0.42),
        const Radius.circular(4),
      ),
      signPaint,
    );
  }

  void _drawBarrier(Canvas canvas) {
    final basePaint = Paint()..color = const Color(0xFFFFF3E0);
    final stripePaint = Paint()
      ..color = const Color(0xFFE65100)
      ..strokeWidth = 5;

    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(3)),
      basePaint,
    );
    canvas.drawLine(
      Offset(size.x * 0.2, size.y),
      Offset(size.x * 0.45, 0),
      stripePaint,
    );
    canvas.drawLine(
      Offset(size.x * 0.62, size.y),
      Offset(size.x * 0.86, 0),
      stripePaint,
    );
  }
}
