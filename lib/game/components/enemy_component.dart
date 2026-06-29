import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flame/collisions.dart';
//import 'package:flutter/foundation.dart';
import '../managers/game_manager.dart';
import 'player_component.dart';

class EnemyComponent extends PositionComponent with CollisionCallbacks {
  int randomLane = Random().nextInt(3);
  final random = Random(); //old random lane generation
  static int lastLane = -1;
  late List<double> lanePositions;
  double speed = 400;
  bool hasCollided = false;
  @override
  Future<void> onLoad() async {
    debugPrint("Enemy Loaded");
    size = Vector2(110, 180);

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

    position.y += speed * dt;

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

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = Colors.green;

    canvas.drawRect(size.toRect(), paint);
  }

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
