import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flame/collisions.dart';
//import 'package:flutter/foundation.dart';
//import 'package:flame/flame.dart';
import '../config/game_config.dart';
import '../managers/game_manager.dart';
import 'player_component.dart';
import '../config/speed_config.dart';

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
  double speed = 300;
  bool hasCollided = false;
  int currentLane = 0;
  late double _aspectRatio;

  static const List<_VehicleSpec> _vehicleSpecs = [
    _VehicleSpec(
      spritePath: 'cars/game assests_05.png',
      aspectRatio: 256 / 219,
      speed: SpeedConfig.taxi,
    ),
    _VehicleSpec(
      spritePath: 'cars/game assests_07.png',
      aspectRatio: 256 / 219,

      speed: SpeedConfig.sedan,
    ),
    _VehicleSpec(
      spritePath: 'cars/game assests_08.png',
      aspectRatio: 256 / 222,

      speed: SpeedConfig.police,
    ),
    // _VehicleSpec(
    //   spritePath: 'cars/game assests_10.png',
    //   aspectRatio: 228 / 219,

    //   speed: SpeedConfig.sportsPlayer,
    // ),
    _VehicleSpec(
      spritePath: 'cars/game assests_11.png',
      aspectRatio: 228 / 219,

      speed: SpeedConfig.sedan,
    ),
    _VehicleSpec(
      spritePath: 'cars/game assests_12.png',
      aspectRatio: 228 / 219,

      speed: SpeedConfig.jeep,
    ),
    _VehicleSpec(
      spritePath: 'cars/game assests_13.png',
      aspectRatio: 228 / 219,

      speed: SpeedConfig.hatchback,
    ),
    _VehicleSpec(
      spritePath: 'cars/game assests_14.png',
      aspectRatio: 228 / 219,

      speed: SpeedConfig.pickup,
    ),
    _VehicleSpec(
      spritePath: 'cars/game assests_16.png',
      aspectRatio: 256 / 219,

      speed: SpeedConfig.cityBus,
    ),
    _VehicleSpec(
      spritePath: 'cars/game assests_17.png',
      aspectRatio: 256 / 219,

      speed: SpeedConfig.coachBus,
    ),
    _VehicleSpec(
      spritePath: 'cars/game assests_18.png',
      aspectRatio: 256 / 187,

      speed: SpeedConfig.boxTruck,
    ),
    _VehicleSpec(
      spritePath: 'cars/game assests_19.png',
      aspectRatio: 256 / 219,

      speed: SpeedConfig.cargoTruck,
    ),
    _VehicleSpec(
      spritePath: 'cars/game assests_21.png',
      aspectRatio: 256 / 219,

      speed: SpeedConfig.cargoTruck,
    ),
    _VehicleSpec(
      spritePath: 'cars/game assests_22.png',
      aspectRatio: 256 / 219,

      speed: SpeedConfig.fuelTanker,
    ),
    _VehicleSpec(
      spritePath: 'cars/game assests_24.png',
      aspectRatio: 256 / 222,

      speed: SpeedConfig.dumpTruck,
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

      final gameSize = findGame()!.size;
      final horizon = GameConfig.roadHorizonY(gameSize.y);

      position = Vector2(
        GameConfig.laneCenterAtY(
          gameSize.x,
          gameSize.y,
          currentLane,
          horizon + 20,
        ),
        horizon + random.nextDouble() * 10,
        // gameSize.y + random.nextDouble() * 50,

        // position.y = gameSize.y + random.nextDouble() * 500;
      );

      _resizeForDepth();
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
    double difficultyMultiplier = 1 + (GameManager.instance.score / 5000);

    if (difficultyMultiplier > 1.5) {
      difficultyMultiplier = 1.5;
    }

    final roadSpeed = SpeedConfig.playerSpeed;
    final relativeSpeed = roadSpeed - speed;

    position.y +=
        relativeSpeed *
        difficultyMultiplier *
        dt; // here we can decide the vehcle which direction shoult move
    _resizeForDepth();
    position.x = _laneCenter();

    if (position.y > findGame()!.size.y + size.y) {
      removeFromParent();
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
