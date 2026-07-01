import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flame/collisions.dart';
//import 'package:flutter/foundation.dart';
//import 'package:flame/flame.dart';
import '../config/game_config.dart';
import '../managers/game_manager.dart';
import 'player_component.dart';

class _VehicleSpec {
  const _VehicleSpec({
    required this.spritePath,
    required this.aspectRatio,
    required this.speed,
  });

  final String spritePath;
  final double aspectRatio;
  final double speed;
}

class EnemyComponent extends SpriteComponent with CollisionCallbacks {
  EnemyComponent() {
    anchor = Anchor.center;
  }
  final random = Random(); //old random lane generation
  static int lastLane = -1;
  double speed = 400;
  bool hasCollided = false;
  int currentLane = 0;
  late double _aspectRatio;

  static const List<_VehicleSpec> _vehicleSpecs = [
    _VehicleSpec(
      spritePath: 'cars/game assests_05.png',
      aspectRatio: 256 / 219,
      speed: 380,
    ),
    _VehicleSpec(
      spritePath: 'cars/game assests_07.png',
      aspectRatio: 256 / 219,
      speed: 390,
    ),
    _VehicleSpec(
      spritePath: 'cars/game assests_08.png',
      aspectRatio: 256 / 222,
      speed: 400,
    ),
    _VehicleSpec(
      spritePath: 'cars/game assests_10.png',
      aspectRatio: 228 / 219,
      speed: 420,
    ),
    _VehicleSpec(
      spritePath: 'cars/game assests_11.png',
      aspectRatio: 228 / 219,
      speed: 410,
    ),
    _VehicleSpec(
      spritePath: 'cars/game assests_12.png',
      aspectRatio: 228 / 219,
      speed: 405,
    ),
    _VehicleSpec(
      spritePath: 'cars/game assests_13.png',
      aspectRatio: 228 / 219,
      speed: 415,
    ),
    _VehicleSpec(
      spritePath: 'cars/game assests_14.png',
      aspectRatio: 228 / 219,
      speed: 430,
    ),
    _VehicleSpec(
      spritePath: 'cars/game assests_16.png',
      aspectRatio: 256 / 219,
      speed: 360,
    ),
    _VehicleSpec(
      spritePath: 'cars/game assests_17.png',
      aspectRatio: 256 / 219,
      speed: 370,
    ),
    _VehicleSpec(
      spritePath: 'cars/game assests_18.png',
      aspectRatio: 256 / 187,
      speed: 350,
    ),
    _VehicleSpec(
      spritePath: 'cars/game assests_19.png',
      aspectRatio: 256 / 219,
      speed: 390,
    ),
    _VehicleSpec(
      spritePath: 'cars/game assests_21.png',
      aspectRatio: 256 / 219,
      speed: 375,
    ),
    _VehicleSpec(
      spritePath: 'cars/game assests_22.png',
      aspectRatio: 256 / 219,
      speed: 385,
    ),
    _VehicleSpec(
      spritePath: 'cars/game assests_24.png',
      aspectRatio: 256 / 222,
      speed: 395,
    ),
  ];

  @override
  Future<void> onLoad() async {
    debugPrint("Enemy Loaded");
    final spec = _vehicleSpecs[random.nextInt(_vehicleSpecs.length)];
    _aspectRatio = spec.aspectRatio;

    sprite = await Sprite.load(spec.spritePath);
    _resizeForDepth();
    speed = spec.speed;

    if (position == Vector2.zero()) {
      currentLane = random.nextInt(GameConfig.laneCount);
      position = Vector2(
        _laneCenter(),
        -size.y - random.nextInt(800).toDouble(),
      );
    } else {
      currentLane = _closestLane(position.x);
      position.x = _laneCenter();
    }

    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (GameManager.instance.isGameOver) {
      return;
    }

    // position.y += speed * dt;
    double difficultyMultiplier = 1 + (GameManager.instance.score / 1000);

    if (difficultyMultiplier > 2.5) {
      difficultyMultiplier = 2.5;
    }

    position.y += speed * difficultyMultiplier * dt;
    _resizeForDepth();
    position.x = _laneCenter();

    if (position.y > findGame()!.size.y) {
      //    removeFromParent();
      position.y = -200;

      // position.x = lanePositions[random.nextInt(3)];
      int lane;

      do {
        lane = random.nextInt(3);
      } while (lane == lastLane);

      currentLane = lane;
      lastLane = lane;
      _resizeForDepth();

      position.x = _laneCenter();
      hasCollided = false;
    }
  }

  double _laneCenter() {
    final gameSize = findGame()!.size;

    return GameConfig.laneCenterAtY(
      gameSize.x,
      gameSize.y,
      currentLane,
      position.y.clamp(0.0, gameSize.y),
    );
  }

  int _closestLane(double x) {
    final gameSize = findGame()!.size;
    var closestLane = 0;
    var closestDistance = double.infinity;

    for (int lane = 0; lane < GameConfig.laneCount; lane++) {
      final distance =
          (GameConfig.laneCenterAtY(
                    gameSize.x,
                    gameSize.y,
                    lane,
                    position.y.clamp(0.0, gameSize.y),
                  ) -
                  x)
              .abs();

      if (distance < closestDistance) {
        closestDistance = distance;
        closestLane = lane;
      }
    }

    return closestLane;
  }

  void _resizeForDepth() {
    final gameSize = findGame()!.size;
    final depthY = position.y.clamp(0.0, gameSize.y);
    final carWidth =
        (GameConfig.laneWidthAtY(gameSize.x, gameSize.y, depthY) * 0.72).clamp(
          52.0,
          150.0,
        );

    size = Vector2(carWidth, carWidth * _aspectRatio);
  }

  // @override
  // void render(Canvas canvas) {
  //   super.render(canvas);

  //   final paint = Paint()..color = Colors.green;

  //   canvas.drawRect(size.toRect(), paint);
  // }

  // @override
  // void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
  //   super.onCollision(intersectionPoints, other);

  //   if (hasCollided) return;

  //   hasCollided = true;

  //   GameManager.instance.damagePlayer(25);

  //   debugPrint("💥 Collision! Health: ${GameManager.instance.playerHealth}");
  // }
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (hasCollided) return;

    if (other is PlayerComponent) {
      hasCollided = true;

      GameManager.instance.damagePlayer(25);

      other.takeDamage();

      debugPrint("💥 Collision! Health: ${GameManager.instance.playerHealth}");
    }
  }
}
