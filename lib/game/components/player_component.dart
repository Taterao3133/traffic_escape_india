import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
//import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/game_config.dart';
import '../managers/game_manager.dart';

class PlayerComponent extends PositionComponent
    with HasGameReference<FlameGame>, KeyboardHandler, CollisionCallbacks {
  int currentLane = 1;

  Color playerColor = Colors.orange;

  late List<double> lanePositions;

  @override
  Future<void> onLoad() async {
    size = Vector2(GameConfig.playerSize.width, GameConfig.playerSize.height);

    lanePositions = [150, 335, 520];

    position = Vector2(0, game.size.y - GameConfig.playerBottomPadding);

    moveToLane();

    add(RectangleHitbox());

    await super.onLoad();
  }

  void moveToLane() {
    add(
      MoveToEffect(
        Vector2(lanePositions[currentLane], position.y),
        EffectController(duration: GameConfig.laneChangeDuration),
      ),
    );
  }

  void flashDamage() {
    playerColor = Colors.red;

    Future.delayed(const Duration(milliseconds: 200), () {
      playerColor = Colors.orange;
    });
  }

  void takeDamage() {
    flashDamage();
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Stop movement when Game Over
    if (GameManager.instance.isGameOver) {
      return false;
    }

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (currentLane > 0) {
          currentLane--;
          moveToLane();
        }
      }

      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (currentLane < 2) {
          currentLane++;
          moveToLane();
        }
      }

      return true;
    }

    return false;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Future player logic goes here.
    // Example:
    // Speed Boost
    // Nitro
    // Magnet
    // Shield
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = playerColor;

    canvas.drawRect(size.toRect(), paint);
  }
}
