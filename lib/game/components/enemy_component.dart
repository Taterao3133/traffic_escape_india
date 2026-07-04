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
      spritePath: 'cars/Taxi.png',
      aspectRatio: 256 / 219,
      speed: SpeedConfig.taxi,
    ),
    _VehicleSpec(
      spritePath: 'cars/sedan.png',
      aspectRatio: 256 / 219,

      speed: SpeedConfig.sedan,
    ),
    _VehicleSpec(
      spritePath: 'cars/police.png',
      aspectRatio: 256 / 222,

      speed: SpeedConfig.police,
    ),
    // _VehicleSpec(
    //   spritePath: 'cars/game assests_10.png',
    //   aspectRatio: 228 / 219,

    //   speed: SpeedConfig.sportsPlayer,
    // ),
    _VehicleSpec(
      spritePath: 'cars/sedanwhite.png',
      aspectRatio: 228 / 219,

      speed: SpeedConfig.sedan,
    ),
    _VehicleSpec(
      spritePath: 'cars/jeep.png',
      aspectRatio: 228 / 219,

      speed: SpeedConfig.jeep,
    ),
    _VehicleSpec(
      spritePath: 'cars/whitesuv.png',
      aspectRatio: 228 / 219,

      speed: SpeedConfig.jeep,
    ),
    _VehicleSpec(
      spritePath: 'cars/blacksuv.png',
      aspectRatio: 228 / 219,

      speed: SpeedConfig.jeep,
    ),
    _VehicleSpec(
      spritePath: 'cars/hatchback.png',
      aspectRatio: 228 / 219,

      speed: SpeedConfig.hatchback,
    ),
    _VehicleSpec(
      spritePath: 'cars/pickup.png',
      aspectRatio: 228 / 219,

      speed: SpeedConfig.pickup,
    ),
    _VehicleSpec(
      spritePath: 'cars/citybus.png',
      aspectRatio: 256 / 219,

      speed: SpeedConfig.cityBus,
    ),
    _VehicleSpec(
      spritePath: 'cars/coachbus.png',
      aspectRatio: 256 / 219,

      speed: SpeedConfig.coachBus,
    ),
    _VehicleSpec(
      spritePath: 'cars/boxtruck.png',
      aspectRatio: 256 / 187,

      speed: SpeedConfig.boxTruck,
    ),
    _VehicleSpec(
      spritePath: 'cars/cargotruck.png',
      aspectRatio: 256 / 219,

      speed: SpeedConfig.cargoTruck,
    ),
    _VehicleSpec(
      spritePath: 'cars/cargotruck2.png',
      aspectRatio: 256 / 219,

      speed: SpeedConfig.cargoTruck,
    ),
    _VehicleSpec(
      spritePath: 'cars/fueltanker.png',
      aspectRatio: 256 / 219,

      speed: SpeedConfig.fuelTanker,
    ),
    _VehicleSpec(
      spritePath: 'cars/dumper.png',
      aspectRatio: 256 / 222,

      speed: SpeedConfig.dumpTruck,
    ),
    _VehicleSpec(
      spritePath: 'cars/autorikshaw.png',
      aspectRatio: 256 / 222,

      speed: SpeedConfig.dumpTruck,
    ),
  ];

  @override
  @override
  Future<void> onLoad() async {
    debugPrint("Enemy Loaded");

    final spec = _vehicleSpecs[random.nextInt(_vehicleSpecs.length)];

    _aspectRatio = spec.aspectRatio;
    speed = spec.speed;

    sprite = await Sprite.load(spec.spritePath);

    final gameSize = findGame()!.size;

    // TrafficManager already sets currentLane and position.y
    position.x = GameConfig.laneCenterAtY(
      gameSize.x,
      gameSize.y,
      currentLane,
      position.y,
    );

    _resizeForDepth();

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
    const double difficultyMultiplier = 1.0;

    final roadSpeed = SpeedConfig.playerSpeed;
    final relativeSpeed = roadSpeed - speed;

    position.y +=
        relativeSpeed *
        difficultyMultiplier *
        dt; // here we can decide the vehcle which direction shoult move
    _resizeForDepth();
    position.x = _laneCenter();
    // if (position.y > findGame()!.size.y + size.y) {
    //   removeFromParent();
    // }

    // if (position.y > findGame()!.size.y + size.y) {
    //   removeFromParent();
    // }
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
