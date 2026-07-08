import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flame/collisions.dart';
//import 'package:flutter/foundation.dart';
//import 'package:flame/flame.dart';
// import '../config/game_config.dart';
import '../managers/game_manager.dart';
import 'player_component.dart';
import '../config/speed_config.dart';
import 'package:flame/effects.dart';
import '../road/road_provider.dart';
import '../traffic_game.dart';

enum VehicleType {
  taxi,
  sedan,
  police,
  jeep,
  suv,
  hatchback,
  pickup,
  cityBus,
  coachBus,
  boxTruck,
  cargoTruck,
  fuelTanker,
  dumpTruck,
  autorickshaw,
}

class _VehicleSpec {
  const _VehicleSpec({
    required this.spritePath,
    required this.aspectRatio,
    required this.speed,
    required this.type,
  });

  final String spritePath;
  final double aspectRatio;
  final double speed;
  final VehicleType type;
}

class EnemyComponent extends SpriteComponent
    with HasGameReference<TrafficGame>, CollisionCallbacks, RoadProvider {
  late VehicleType vehicleType;
  bool reachedRoad = false;

  bool nearMissAwarded = false;
  EnemyComponent() {
    anchor = Anchor.center;
  }
  final random = Random(); //old random lane generation
  static int lastLane = -1;
  double speed = 300;
  late double currentSpeed;
  late double targetSpeed;

  static const double safeDistance = 220;
  static const double brakeSpeed = 20;
  bool hasCollided = false;
  bool isChangingLane = false;
  double laneChangeCooldown = 0;
  double laneDecisionTimer = 0;
  static const double laneChangeDelay = 1.5;

  static const double laneChangeDuration = 0.35;
  int currentLane = 0;
  int? previousLane;
  bool isOvertaking = false;
  late double _aspectRatio;

  static const List<_VehicleSpec> _vehicleSpecs = [
    _VehicleSpec(
      spritePath: 'cars/Taxi.png',
      aspectRatio: 256 / 219,
      speed: SpeedConfig.taxi,
      type: VehicleType.taxi,
    ),
    _VehicleSpec(
      spritePath: 'cars/sedan.png',
      aspectRatio: 256 / 219,

      speed: SpeedConfig.sedan,
      type: VehicleType.sedan,
    ),
    _VehicleSpec(
      spritePath: 'cars/police.png',
      aspectRatio: 256 / 222,

      speed: SpeedConfig.police,
      type: VehicleType.police,
    ),

    _VehicleSpec(
      spritePath: 'cars/sedanwhite.png',
      aspectRatio: 228 / 219,

      speed: SpeedConfig.sedan,
      type: VehicleType.sedan,
    ),
    _VehicleSpec(
      spritePath: 'cars/jeep.png',
      aspectRatio: 228 / 219,

      speed: SpeedConfig.jeep,
      type: VehicleType.jeep,
    ),
    _VehicleSpec(
      spritePath: 'cars/whitesuv.png',
      aspectRatio: 228 / 219,

      speed: SpeedConfig.jeep,
      type: VehicleType.suv,
    ),
    _VehicleSpec(
      spritePath: 'cars/blacksuv.png',
      aspectRatio: 228 / 219,

      speed: SpeedConfig.jeep,
      type: VehicleType.suv,
    ),
    _VehicleSpec(
      spritePath: 'cars/hatchback.png',
      aspectRatio: 228 / 219,

      speed: SpeedConfig.hatchback,
      type: VehicleType.hatchback,
    ),
    _VehicleSpec(
      spritePath: 'cars/pickup.png',
      aspectRatio: 228 / 219,

      speed: SpeedConfig.pickup,
      type: VehicleType.pickup,
    ),
    _VehicleSpec(
      spritePath: 'cars/citybus.png',
      aspectRatio: 256 / 219,

      speed: SpeedConfig.cityBus,
      type: VehicleType.cityBus,
    ),
    _VehicleSpec(
      spritePath: 'cars/coachbus.png',
      aspectRatio: 256 / 219,

      speed: SpeedConfig.coachBus,
      type: VehicleType.coachBus,
    ),
    _VehicleSpec(
      spritePath: 'cars/boxtruck.png',
      aspectRatio: 256 / 187,

      speed: SpeedConfig.boxTruck,
      type: VehicleType.boxTruck,
    ),
    _VehicleSpec(
      spritePath: 'cars/cargotruck.png',
      aspectRatio: 256 / 219,

      speed: SpeedConfig.cargoTruck,
      type: VehicleType.cargoTruck,
    ),
    _VehicleSpec(
      spritePath: 'cars/cargotruck2.png',
      aspectRatio: 256 / 219,

      speed: SpeedConfig.cargoTruck,
      type: VehicleType.cargoTruck,
    ),
    _VehicleSpec(
      spritePath: 'cars/fueltanker.png',
      aspectRatio: 256 / 219,

      speed: SpeedConfig.fuelTanker,
      type: VehicleType.fuelTanker,
    ),
    _VehicleSpec(
      spritePath: 'cars/dumper.png',
      aspectRatio: 256 / 222,

      speed: SpeedConfig.dumpTruck,
      type: VehicleType.dumpTruck,
    ),
    _VehicleSpec(
      spritePath: 'cars/autorikshaw.png',
      aspectRatio: 256 / 222,

      speed: SpeedConfig.autorikshaw,
      type: VehicleType.autorickshaw,
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

  double get laneChangeChance {
    switch (vehicleType) {
      case VehicleType.taxi:
        return 0.90;

      case VehicleType.sedan:
        return 0.60;

      case VehicleType.hatchback:
        return 0.70;

      case VehicleType.suv:
        return 0.75;

      case VehicleType.jeep:
        return 0.50;

      case VehicleType.pickup:
        return 0.35;

      case VehicleType.cityBus:
      case VehicleType.coachBus:
        return 0.10;

      case VehicleType.boxTruck:
      case VehicleType.cargoTruck:
      case VehicleType.fuelTanker:
      case VehicleType.dumpTruck:
        return 0.02;

      case VehicleType.police:
        return 1.00;

      case VehicleType.autorickshaw:
        return 0.80;
    }
  }

  bool get canChangeLane {
    return random.nextDouble() <= laneChangeChance;
  }

  @override
  Future<void> onLoad() async {
    priority = 20;
    debugPrint("Enemy Loaded");

    // final spec = _vehicleSpecs[random.nextInt(_vehicleSpecs.length)];
    final spec = _randomVehicle();
    vehicleType = spec.type;
    _aspectRatio = spec.aspectRatio;
    speed = spec.speed;
    currentSpeed = speed;
    targetSpeed = speed;

    sprite = await Sprite.load(spec.spritePath);
    opacity = 0.20;

    // final gameSize = findGame()!.size;

    // TrafficManager already sets currentLane and position.y
    position.x = road.laneCenter(currentLane, position.y);

    _resizeForDepth();

    await super.onLoad();

    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    laneDecisionTimer += dt;
    if (laneChangeCooldown > 0) {
      laneChangeCooldown -= dt;
    }
    if (GameManager.instance.isGameOver) {
      return;
    }

    // position.y += speed * dt;
    const double difficultyMultiplier = 1.0;
    _updateTrafficAI(dt);
    _tryReturnToLane();
    final roadSpeed = SpeedConfig.playerSpeed;

    final relativeSpeed = roadSpeed - currentSpeed;

    ///dwdew

    position.y +=
        relativeSpeed *
        difficultyMultiplier *
        dt; // here we can decide the vehcle which direction shoult move
    _resizeForDepth();
    // final horizonY = GameConfig.roadHorizonY(findGame()!.size.y);
    final horizonY = road.horizonY;

    if (!reachedRoad && position.y >= horizonY) {
      reachedRoad = true;

      add(OpacityEffect.to(1.0, EffectController(duration: 0.35)));
    }
    position.x = _laneCenter();
    final player = parent?.children.whereType<PlayerComponent>().firstOrNull;

    if (player != null && !nearMissAwarded) {
      final dx = (player.position.x - position.x).abs();
      final dy = (player.position.y - position.y).abs();

      if (!nearMissAwarded && dx < 60 && dy < 40) {
        nearMissAwarded = true;

        GameManager.instance.addNearMiss();

        // debugPrint("🔥 Near Miss | Score: ${GameManager.instance.score}");
      }
    }
  }

  void _tryLaneChange() {
    if (isChangingLane || laneChangeCooldown > 0) return;
    if (!canChangeLane) return;

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
        laneChangeCooldown = laneChangeDelay;

        previousLane = currentLane;
        currentLane = newLane;
        isOvertaking = true;

        // final gameSize = findGame()!.size;
        // final targetX
        //          = GameConfig.laneCenterAtY(
        //           gameSize.x,
        //           gameSize.y,
        //           currentLane,
        //           position.y,
        //         );
        final targetX = road.laneCenter(currentLane, position.y);

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

  void _tryReturnToLane() {
    if (!isOvertaking) return;

    if (previousLane == null) return;

    if (isChangingLane) return;

    final enemies = parent!.children.whereType<EnemyComponent>();

    for (final other in enemies) {
      if (other == this) continue;

      if (other.currentLane != previousLane) continue;

      if ((other.position.y - position.y).abs() < 250) {
        return;
      }
    }

    currentLane = previousLane!;
    previousLane = null;
    isOvertaking = false;

    // final gameSize = findGame()!.size;

    add(
      MoveToEffect(
        Vector2(road.laneCenter(currentLane, position.y), position.y),
        EffectController(duration: laneChangeDuration),
      ),
    );
  }

  double _laneCenter() {
    return road.laneCenter(currentLane, position.y.clamp(0.0, game.size.y));
  }

  void _resizeForDepth() {
    final gameSize = findGame()!.size;
    final depthY = position.y.clamp(0.0, gameSize.y);
    final carWidth = (road.laneWidth(depthY) * 0.80).clamp(
      12.0,
      150.0,
    ); // Adjust the multiplier to control how much of the lane width the car occupies

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
          // Too close? Match the front car speed.
          if (distance < 80) {
            targetSpeed = other.currentSpeed;
            continue;
          }

          if (laneDecisionTimer >= 0.5) {
            laneDecisionTimer = 0;
            _tryLaneChange();
          }

          targetSpeed = max(
            speed * 0.85,
            min(targetSpeed, other.currentSpeed - brakeSpeed),
          );
        }
      }
    }

    const double acceleration = 40;
    const double braking = 0;

    if (currentSpeed < targetSpeed) {
      currentSpeed = min(currentSpeed + acceleration * dt, targetSpeed);
    } else if (currentSpeed > targetSpeed) {
      currentSpeed = max(currentSpeed - braking * dt, targetSpeed);
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (hasCollided) return;

    if (other is PlayerComponent) {
      hasCollided = true;

      GameManager.instance.damagePlayer(25);

      other.takeDamage();

      // debugPrint("💥 Collision! Health: ${GameManager.instance.playerHealth}");
    }
  }
}
