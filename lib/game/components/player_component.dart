import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
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
    lanePositions = GameConfig.laneCenters(game.size.x);

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

  bool moveLeft() {
    if (GameManager.instance.isGameOver || currentLane <= 0) {
      return false;
    }

    currentLane--;
    moveToLane();
    return true;
  }

  bool moveRight() {
    if (GameManager.instance.isGameOver ||
        currentLane >= GameConfig.laneCount - 1) {
      return false;
    }

    currentLane++;
    moveToLane();
    return true;
  }

  void resetPlayer() {
    currentLane = 1;
    lanePositions = GameConfig.laneCenters(game.size.x);

    position = Vector2(
      lanePositions[currentLane],
      game.size.y - GameConfig.playerBottomPadding - size.y / 2,
    );

    removeWhere((component) => component is MoveEffect);
  }

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
        moveLeft();
      }

      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        moveRight();
      }

      return true;
    }

    return false;
  }
}
