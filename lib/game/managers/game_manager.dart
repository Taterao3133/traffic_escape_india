// class GameManager {
//   int playerHealth = 100;

//   int score = 0;

//   bool isGameOver = false;

//   void damagePlayer(int damage) {
//     if (isGameOver) return;

//     playerHealth -= damage;

//     if (playerHealth < 0) {
//       playerHealth = 0;
//     }

//     if (playerHealth == 0) {
//       isGameOver = true;
//     }
//   }

//   void addScore(int value) {
//     score += value;
//   }

//   void restart() {
//     playerHealth = 100;
//     score = 0;
//     isGameOver = false;
//   }
// }

class GameManager {
  // Singleton
  static final GameManager instance = GameManager._internal();

  GameManager._internal();

  int playerHealth = 100;

  int score = 0;

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
    isGameOver = false;
  }
}
