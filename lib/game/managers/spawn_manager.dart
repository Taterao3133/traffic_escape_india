import 'dart:math';

import 'package:flame/components.dart';

import '../components/enemy_component.dart';

class SpawnManager extends Component {
  final Random random = Random();

  double spawnTimer = 0;

  double spawnInterval = 2.2;

  static const int maxEnemies = 5;

  @override
  void update(double dt) {
    super.update(dt);

    spawnTimer += dt;

    if (spawnTimer >= spawnInterval) {
      spawnTimer = 0;

      // Don't create more than 5 enemies
      final currentEnemies = parent!.children
          .whereType<EnemyComponent>()
          .length;

      if (currentEnemies < maxEnemies) {
        _spawnPattern();
      }

      if (spawnInterval > 1.3) {
        spawnInterval -= 0.01;
      }
    }
  }

  void _spawnPattern() {
    final patterns = <List<int>>[
      [0],
      [1],
      [2],
      [0, 2],
      [0, 1],
      [1, 2],
    ];

    final pattern = patterns[random.nextInt(patterns.length)];

    for (final lane in pattern) {
      // Check if lane already has a nearby car
      bool laneBusy = false;

      for (final enemy in parent!.children.whereType<EnemyComponent>()) {
        if (enemy.currentLane == lane && enemy.position.y < 350) {
          laneBusy = true;
          break;
        }
      }

      if (laneBusy) continue;

      final enemy = EnemyComponent();
      enemy.currentLane = lane;

      parent!.add(enemy);
    }
  }
}
