import 'dart:math';

import 'package:flame/components.dart';

import '../components/enemy_component.dart';
import '../config/game_config.dart';

class TrafficManager extends Component {
  final Random _random = Random();

  static const double minWaveGap = 450;
  static const double maxWaveGap = 700;

  static const int maxCarsOnScreen = 10;

  late double _nextSpawnY;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final gameHeight = parent!.findGame()!.size.y;

    _nextSpawnY = GameConfig.roadHorizonY(gameHeight) + 20;

    for (int i = 0; i < 5; i++) {
      _spawnWave();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    final gameHeight = parent!.findGame()!.size.y;

    // Remove cars that have gone off-screen
    for (final enemy in parent!.children.whereType<EnemyComponent>().toList()) {
      if (enemy.position.y > gameHeight + enemy.size.y + 100) {
        enemy.removeFromParent();
      }
    }

    final currentCars = parent!.children.whereType<EnemyComponent>().length;

    while (currentCars +
            parent!.children
                .whereType<EnemyComponent>()
                .where((e) => e.isRemoving)
                .length <
        maxCarsOnScreen) {
      _spawnWave();
      break;
    }
  }

  void _spawnWave() {
    final waves = <List<int>>[
      [0],
      [1],
      [2],
      [0, 1],
      [1, 2],
      [0, 2],
    ];

    final wave = waves[_random.nextInt(waves.length)];

    for (final lane in wave) {
      final enemy = EnemyComponent();

      enemy.currentLane = lane;
      enemy.position.y = _nextSpawnY;

      parent!.add(enemy);
    }

    // Next wave spawns further above the current one
    _nextSpawnY -=
        minWaveGap + _random.nextDouble() * (maxWaveGap - minWaveGap);
  }
}
