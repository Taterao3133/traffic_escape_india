import '../config/speed_config.dart';

class GameManager {
  // Singleton
  static final GameManager instance = GameManager._internal();

  GameManager._internal();

  int playerHealth = 100;

  int score = 0;
  int nearMisses = 0;
  double distance = 0;
  double highSpeedTimer = 0;
  bool highSpeedActive = false;

  bool isGameOver = false;

  void damagePlayer(int damage) {
    if (isGameOver) return;

    playerHealth -= damage;

    if (playerHealth < 0) {
      playerHealth = 0;
    }

    if (playerHealth == 0) {
      isGameOver = true;
    }
  }

  void restart() {
    playerHealth = 100;
    score = 0;
    distance = 0;
    isGameOver = false;
  }

  void addNearMiss() {
    nearMisses++;
    score += 100;
  }

  void update(double dt) {
    if (isGameOver) return;

    distance += SpeedConfig.playerSpeed * dt * 0.002;

    // Score follows distance
    score = distance.toInt();
    updateHighSpeed(dt);
  }

  void updateHighSpeed(double dt) {
    const double speedThreshold = 300;

    if (SpeedConfig.playerSpeed >= speedThreshold) {
      highSpeedTimer += dt;

      if (highSpeedTimer >= 2) {
        highSpeedActive = true;
        score += 25;
        highSpeedTimer = 0;
      }
    } else {
      highSpeedTimer = 0;
      highSpeedActive = false;
    }
  }

  double get difficulty {
    if (distance < 1) return 1.0;
    if (distance < 3) return 1.15;
    if (distance < 5) return 1.30;
    if (distance < 8) return 1.50;
    if (distance < 12) return 1.75;

    return 2.0;
  }
}
