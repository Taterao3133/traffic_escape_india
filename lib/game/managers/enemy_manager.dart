import 'dart:math';

import 'package:flame/components.dart';

import '../components/enemy_component.dart';

class EnemyManager extends Component {
  final Random random = Random();

  final List<double> lanePositions = [
    150,
    335,
    520,
  ];

  final List<int> activeLanes = [];

  double spawnTimer = 0;

  double spawnInterval = 1.5;

  @override
  void update(double dt) {
    super.update(dt);

    spawnTimer += dt;

    if (spawnTimer >= spawnInterval) {
      spawnTimer = 0;

      spawnEnemy();
    }
  }

  void spawnEnemy() {
    List<int> available = [0, 1, 2];

    available.removeWhere((lane) => activeLanes.contains(lane));

    if (available.isEmpty) {
      return;
    }

    final lane = available[random.nextInt(available.length)];

    activeLanes.add(lane);

    final enemy = EnemyComponent();

    enemy.position = Vector2(
      lanePositions[lane],
      -250,
    );

    parent!.add(enemy);
  }
}