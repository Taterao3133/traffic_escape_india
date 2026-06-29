import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flame/collisions.dart';
//import 'package:flutter/foundation.dart';
//import 'package:flame/flame.dart';
import '../managers/game_manager.dart';
import 'player_component.dart';

class EnemyComponent extends SpriteComponent with CollisionCallbacks {
  EnemyComponent() {
    anchor = Anchor.center;
  }
  int randomLane = Random().nextInt(3);
  final random = Random(); //old random lane generation
  static int lastLane = -1;
  late List<double> lanePositions;
  double speed = 400;
  bool hasCollided = false;
  static final List<String> vehicleSprites = [
    'cars/sedan.png',
    'cars/taxi.png',
    'cars/police_suv.png',
    'cars/city_bus.png',
    'cars/auto_rickshaw.png',
  ];
  @override
  Future<void> onLoad() async {
    debugPrint("Enemy Loaded");
    final randomSprite = vehicleSprites[random.nextInt(vehicleSprites.length)];

    sprite = await Sprite.load(randomSprite);
    switch (randomSprite) {
      case 'cars/sedan.png':
        size = Vector2(170, 260);
        speed = 400;
        break;

      case 'cars/taxi.png':
        size = Vector2(170, 260);
        speed = 400;
        break;

      case 'cars/police_suv.png':
        size = Vector2(185, 280);
        speed = 500;
        break;

      case 'cars/city_bus.png':
        size = Vector2(240, 420);
        speed = 200;
        break;

      case 'cars/auto_rickshaw.png':
        size = Vector2(145, 220);
        speed = 350;
        break;
    }

    lanePositions = [150, 335, 520];

    if (position == Vector2.zero()) {
      position = Vector2(
        lanePositions[randomLane],
        -150 - random.nextInt(800).toDouble(),
      );
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

    if (position.y > findGame()!.size.y) {
      //    removeFromParent();
      position.y = -200;

      // position.x = lanePositions[random.nextInt(3)];
      int lane;

      do {
        lane = random.nextInt(3);
      } while (lane == lastLane);

      lastLane = lane;

      position.x = lanePositions[lane];
      hasCollided = false;
    }
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
