// import 'dart:math';

// import 'package:flame/components.dart';

// import '../components/enemy_component.dart';
// import '../config/game_config.dart';

// class TrafficManager extends Component {
//   final Random _random = Random();

//   static const double minWaveGap = 450;
//   static const double maxWaveGap = 700;

//   static const int maxCarsOnScreen = 10;

//   late double _nextSpawnY;

//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();

//     final gameHeight = parent!.findGame()!.size.y;

//     _nextSpawnY = GameConfig.roadHorizonY(gameHeight) + 20;

//     for (int i = 0; i < 5; i++) {
//       _spawnWave();
//     }
//   }

//   @override
//   void update(double dt) {
//     super.update(dt);

//     final gameHeight = parent!.findGame()!.size.y;

//     // Remove cars that have gone off-screen
//     for (final enemy in parent!.children.whereType<EnemyComponent>().toList()) {
//       if (enemy.position.y > gameHeight + enemy.size.y + 100) {
//         enemy.removeFromParent();
//       }
//     }

//     final currentCars = parent!.children.whereType<EnemyComponent>().length;

//     while (currentCars +
//             parent!.children
//                 .whereType<EnemyComponent>()
//                 .where((e) => e.isRemoving)
//                 .length <
//         maxCarsOnScreen) {
//       _spawnWave();
//       break;
//     }
//   }

//   void _spawnWave() {
//     final waves = <List<int>>[
//       [0],
//       [1],
//       [2],
//       [0, 1],
//       [1, 2],
//       [0, 2],
//     ];

//     final wave = waves[_random.nextInt(waves.length)];

//     for (final lane in wave) {
//       final enemy = EnemyComponent();

//       enemy.currentLane = lane;
//       enemy.position.y = _nextSpawnY;

//       parent!.add(enemy);
//     }

//     // Next wave spawns further above the current one
//     // Always spawn just above the visible road
//     final horizonY = GameConfig.roadHorizonY(parent!.findGame()!.size.y);

//     _nextSpawnY =
//         horizonY -
//         (minWaveGap + _random.nextDouble() * (maxWaveGap - minWaveGap));
//   }
// }

import 'dart:math';

import 'package:flame/components.dart';

import '../components/enemy_component.dart';
import '../config/game_config.dart';

class TrafficManager extends Component {
  final Random _random = Random();

  double spawnTimer = 0;

  double nextSpawnTime() => 0.7 + _random.nextDouble() * 0.8;
  late double spawnInterval;

  static const int maxCarsOnScreen = 8;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    spawnInterval = nextSpawnTime();
  }

  @override
  void update(double dt) {
    super.update(dt);

    final gameHeight = parent!.findGame()!.size.y;

    // Remove off-screen cars
    for (final enemy in parent!.children.whereType<EnemyComponent>().toList()) {
      if (enemy.position.y > gameHeight + enemy.size.y + 100) {
        enemy.removeFromParent();
      }
    }

    final currentCars = parent!.children.whereType<EnemyComponent>().length;

    spawnTimer += dt;

    if (currentCars >= maxCarsOnScreen) return;

    if (spawnTimer >= spawnInterval) {
      spawnTimer = 0;
      spawnInterval = nextSpawnTime();

      _spawnSingleCar();
    }
  }

  void _spawnSingleCar() {
    final enemy = EnemyComponent();

    enemy.currentLane = _random.nextInt(GameConfig.laneCount);

    enemy.position.y =
        GameConfig.roadHorizonY(parent!.findGame()!.size.y) -
        (420 + _random.nextDouble() * 220); // 220,180 earlier

    parent!.add(enemy);
  }
}
