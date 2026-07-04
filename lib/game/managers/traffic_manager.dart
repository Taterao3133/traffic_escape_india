import 'dart:math';

import 'package:flame/components.dart';

import '../components/enemy_component.dart';

class TrafficManager extends Component {
  final Random _random = Random();

  static const double minWaveGap = 450;
  static const double maxWaveGap = 700;

  static const int maxCarsOnScreen = 10;

  double _nextSpawnY = 200;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    for (int i = 0; i < 5; i++) {
      _spawnWave();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    final gameHeight = parent!.findGame()!.size.y;

    // Remove cars that passed the player
    for (final enemy in parent!.children.whereType<EnemyComponent>().toList()) {
      if (enemy.position.y > gameHeight + enemy.size.y + 100) {
        enemy.removeFromParent();
      }
    }

    final currentCars = parent!.children.whereType<EnemyComponent>().length;

    if (currentCars < maxCarsOnScreen) {
      _spawnWave();
    }
  }

  void _spawnWave() {
    // Wave Types
    final waves = <List<int>>[
      [0], // Left
      [1], // Middle
      [2], // Right

      [0, 1], // Left + Middle
      [1, 2], // Middle + Right
      [0, 2], // Left + Right
    ];

    final wave = waves[_random.nextInt(waves.length)];

    for (final lane in wave) {
      final enemy = EnemyComponent();

      enemy.currentLane = lane;
      enemy.position.y = _nextSpawnY;

      parent!.add(enemy);
    }

    _nextSpawnY -=
        minWaveGap + _random.nextDouble() * (maxWaveGap - minWaveGap);
  }
}
