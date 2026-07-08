import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/game_config.dart';
import '../managers/game_manager.dart';
import '../road/road_provider.dart';

class PlayerComponent extends SpriteComponent
    with
        HasGameReference<FlameGame>,
        KeyboardHandler,
        CollisionCallbacks,
        RoadProvider {
  static const String playerSpritePath = 'cars/sportscar.png';
  static const double _spriteAspectRatio = 228 / 219;

  int currentLane = 1;

  // Color playerColor = Colors.orange;

  @override
  Future<void> onLoad() async {
    priority = 30;
    anchor = Anchor.center;
    final playerY = game.size.y - GameConfig.playerBottomPadding;
    final carWidth =
        (GameConfig.laneWidthAtY(
                  game.size.x,
                  game.size.y,
                  game.size.y - GameConfig.playerBottomPadding,
                ) *
                0.90)
            .clamp(70.0, 150.0);
    size = Vector2(carWidth, carWidth * _spriteAspectRatio);
    sprite = await Sprite.load(playerSpritePath);

    position = Vector2(road.laneCenter(currentLane, playerY), playerY);

    add(
      RectangleHitbox(
        size: Vector2(size.x * 0.55, size.y * 0.75),
        position: Vector2(size.x * 0.225, size.y * 0.125),
      ),
    );
    await super.onLoad();
  }

  void moveToLane() {
    removeWhere((component) => component is MoveEffect);

    add(
      MoveToEffect(
        Vector2(road.laneCenter(currentLane, position.y), position.y),
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
    final playerY = game.size.y - GameConfig.playerBottomPadding;

    position = Vector2(road.laneCenter(currentLane, playerY), playerY);

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
