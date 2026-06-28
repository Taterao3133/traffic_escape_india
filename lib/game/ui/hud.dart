import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Hud extends PositionComponent {
  late TextComponent scoreText;
  late TextComponent distanceText;
  late TextComponent healthText;

  int score = 0;
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

    await super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    score += (dt * 100).toInt();

    scoreText.text = "Score : $score";
    travelDistance += dt * 0.08;

    distanceText.text = "Distance : ${travelDistance.toStringAsFixed(2)} KM";
    healthText.text = "Health : $health";
  }
}
