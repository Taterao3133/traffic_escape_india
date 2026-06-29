import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/game_config.dart';
import '../managers/game_manager.dart';

class PlayerComponent extends SpriteComponent
    with HasGameReference<FlameGame>, KeyboardHandler, CollisionCallbacks {
  int currentLane = 1;

  // Color playerColor = Colors.orange;

  late List<double> lanePositions;

  @override
  Future<void> onLoad() async {
    size = Vector2(220, 320);
    sprite = await Sprite.load('cars/player_car.png');
    lanePositions = [150, 335, 520];

    position = Vector2(
      0,
      game.size.y - GameConfig.playerBottomPadding - size.y / 2,
    );

    moveToLane();

    // add(RectangleHitbox());
    add(RectangleHitbox(size: Vector2(80, 150), position: Vector2(70, 90)));
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

  void resetPlayer() {
    currentLane = 1;

    position = Vector2(
      lanePositions[currentLane],
      game.size.y - GameConfig.playerBottomPadding,
    );

    removeWhere((component) => component is MoveEffect);
  }

  // void flashDamage() {
  //   playerColor = Colors.red;

  //   Future.delayed(const Duration(milliseconds: 200), () {
  //     playerColor = Colors.orange;
  //   });
  // }

  // void takeDamage() {
  //   flashDamage();
  // }
  void flashDamage() {
    opacity = 0.3;

    Future.delayed(const Duration(milliseconds: 150), () {
      opacity = 1.0;
    });
  }

  void takeDamage() {
    flashDamage();
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Stop movement when Game Over
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyR) {
      GameManager.instance.restart();

      resetPlayer();

      debugPrint("Game Restarted");

      return true;
    }
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

  // @override
  // void render(Canvas canvas) {
  //   super.render(canvas);

  //   final paint = Paint()..color = playerColor;

  //   canvas.drawRect(size.toRect(), paint);
  // }
}
