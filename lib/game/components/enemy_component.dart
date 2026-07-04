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
import 'package:flame/effects.dart';

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
  late double currentSpeed;
  late double targetSpeed;

  static const double safeDistance = 220;
  static const double brakeSpeed = 80;
  bool hasCollided = false;
  bool isChangingLane = false;

  static const double laneChangeDuration = 0.35;
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

  _VehicleSpec _randomVehicle() {
    final roll = random.nextInt(100);

    if (roll < 25) {
      return _vehicleSpecs[1]; // Sedan
    } else if (roll < 40) {
      return _vehicleSpecs[3]; // Sedan 2
    } else if (roll < 55) {
      return _vehicleSpecs[7]; // Hatchback
    } else if (roll < 65) {
      return _vehicleSpecs[5]; // White SUV
    } else if (roll < 75) {
      return _vehicleSpecs[6]; // Black SUV
    } else if (roll < 83) {
      return _vehicleSpecs[0]; // Taxi
    } else if (roll < 88) {
      return _vehicleSpecs[8]; // Pickup
    } else if (roll < 93) {
      return _vehicleSpecs[4]; // Jeep
    } else if (roll < 96) {
      return _vehicleSpecs[9]; // City Bus
    } else if (roll < 98) {
      return _vehicleSpecs[10]; // Coach Bus
    } else if (roll < 99) {
      return _vehicleSpecs[2]; // Police
    } else {
      // Very Rare Vehicles
      const rareVehicles = [
        11, // Box Truck
        12, // Cargo Truck
        13, // Cargo Truck 2
        14, // Fuel Tanker
        15, // Dump Truck
        16, // Auto Rickshaw
      ];

      return _vehicleSpecs[rareVehicles[random.nextInt(rareVehicles.length)]];
    }
  }

  @override
  Future<void> onLoad() async {
    debugPrint("Enemy Loaded");

    // final spec = _vehicleSpecs[random.nextInt(_vehicleSpecs.length)];
    final spec = _randomVehicle();
    _aspectRatio = spec.aspectRatio;
    speed = spec.speed;
    currentSpeed = speed;
    targetSpeed = speed;

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
    _updateTrafficAI(dt);
    final roadSpeed = SpeedConfig.playerSpeed;

    final relativeSpeed = roadSpeed - currentSpeed;

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

  void _tryLaneChange() {
    if (isChangingLane) return;

    final enemies = parent!.children.whereType<EnemyComponent>().toList();

    // Check left first, then right
    for (final newLane in [currentLane - 1, currentLane + 1]) {
      if (newLane < 0 || newLane > 2) continue;

      bool laneFree = true;

      for (final other in enemies) {
        if (other == this) continue;

        if (other.currentLane != newLane) continue;

        // Need enough space both ahead and behind
        if ((other.position.y - position.y).abs() < 250) {
          laneFree = false;
          break;
        }
      }

      if (laneFree) {
        isChangingLane = true;

        currentLane = newLane;

        final gameSize = findGame()!.size;

        final targetX = GameConfig.laneCenterAtY(
          gameSize.x,
          gameSize.y,
          currentLane,
          position.y,
        );

        add(
          MoveToEffect(
            Vector2(targetX, position.y),
            EffectController(duration: laneChangeDuration),
            onComplete: () {
              isChangingLane = false;
            },
          ),
        );

        return;
      }
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

  // int _closestLane(double x) {
  //   final gameSize = findGame()!.size;
  //   var closestLane = 0;
  //   var closestDistance = double.infinity;

  //   for (int lane = 0; lane < GameConfig.laneCount; lane++) {
  //     final distance =
  //         (GameConfig.laneCenterAtY(
  //                   gameSize.x,
  //                   gameSize.y,
  //                   lane,
  //                   position.y.clamp(0.0, gameSize.y),
  //                 ) -
  //                 x)
  //             .abs();

  //     if (distance < closestDistance) {
  //       closestDistance = distance;
  //       closestLane = lane;
  //     }
  //   }

  //   return closestLane;
  // }

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

  void _updateTrafficAI(double dt) {
    targetSpeed = speed;

    final enemies = parent!.children.whereType<EnemyComponent>();

    for (final other in enemies) {
      if (other == this) continue;

      if (other.currentLane != currentLane) continue;

      // Car ahead
      if (other.position.y > position.y) {
        final distance = other.position.y - position.y;

        if (distance < safeDistance) {
          _tryLaneChange();

          targetSpeed = min(targetSpeed, other.currentSpeed - brakeSpeed);
        }
      }
    }

    currentSpeed += (targetSpeed - currentSpeed) * 4 * dt;
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
