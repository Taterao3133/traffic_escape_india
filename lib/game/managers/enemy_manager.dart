import 'dart:math';

import 'package:flame/components.dart';

import '../components/enemy_component.dart';

class EnemyManager extends Component {
  final Random random = Random();

  final List<double> lanePositions = [150, 335, 520];

  final List<double> laneCooldown = [0, 0, 0];

  double spawnTimer = 0;

  double spawnInterval = 1.5;
  double laneCooldownTime = 1.5;

  @override
  void update(double dt) {
    super.update(dt);
    for (int i = 0; i < laneCooldown.length; i++) {
      if (laneCooldown[i] > 0) {
        laneCooldown[i] -= dt;
      }
    }

    spawnTimer += dt;

    if (spawnTimer >= spawnInterval) {
      spawnTimer = 0;

      spawnEnemy();
    }
  }

  void spawnEnemy() {
    List<int> available = [];

    for (int i = 0; i < 3; i++) {
      if (laneCooldown[i] <= 0) {
        available.add(i);
      }
    }

    //available.removeWhere((lane) => activeLanes.contains(lane));

    if (available.isEmpty) {
      return;
    }

    final lane = available[random.nextInt(available.length)];

    laneCooldown[lane] = laneCooldownTime;

    final enemy = EnemyComponent();

    enemy.position = Vector2(lanePositions[lane], -250);

    parent!.add(enemy);
  }
}
