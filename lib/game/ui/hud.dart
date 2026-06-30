import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../managers/game_manager.dart';

class Hud extends PositionComponent {
  late TextComponent scoreText;
  late TextComponent distanceText;
  late TextComponent healthText;
  late TextComponent gameOverText;

  // int score = 0;
  double travelDistance = 0;
  int health = 100;

  @override
  Future<void> onLoad() async {
    scoreText = TextComponent(
      text: "Score : 0",
      position: Vector2(20, 20),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(scoreText);
    distanceText = TextComponent(
      text: "Distance : 0.00 KM",
      position: Vector2(20, 60),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(distanceText);
    healthText = TextComponent(
      text: " ❤️ Health : 100",
      position: Vector2(20, 100),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(healthText);
    gameOverText = TextComponent(
      text: "",
      anchor: Anchor.center,
      position: Vector2(findGame()!.size.x / 2, findGame()!.size.y * 0.45),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 34,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(gameOverText);

    await super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // if (GameManager.instance.isGameOver) {
    //   return;
    // }
    if (!GameManager.instance.isGameOver) {
      GameManager.instance.score += (dt * 100).toInt();
      GameManager.instance.distance += dt * 0.08;
    }

    scoreText.text = "Score : ${GameManager.instance.score}";

    distanceText.text =
        "Distance : ${GameManager.instance.distance.toStringAsFixed(2)} KM";

    healthText.text = "❤️ Health : ${GameManager.instance.playerHealth}%";

    if (GameManager.instance.isGameOver) {
      gameOverText.text =
          "💥 GAME OVER\n\n"
          "Tap to Restart\n"
          "Press R on Keyboard";
    } else {
      gameOverText.text = "";
    }
  }
}
