import 'dart:math';

import 'package:flame/components.dart';

import '../components/enemy_component.dart';
import '../config/game_config.dart';
import '../road/road_provider.dart';
import 'game_manager.dart';

class TrafficManager extends Component with RoadProvider {
  final Random _random = Random();
  final List<List<int>> trafficPatterns = [
    [0],
    [1],
    [2],

    [0, 1],
    [1, 2],
    [0, 2],

    [0, 1, 2],
  ];
  static const double minSpawnGap = 320;
  bool _laneHasSpace(int lane) {
    for (final enemy in parent!.children.whereType<EnemyComponent>()) {
      if (enemy.currentLane != lane) continue;

      if (enemy.position.y < road.horizonY + minSpawnGap) {
        return false;
      }
    }

    return true;
  }

  List<int> _availableLanes() {
    final lanes = <int>[];

    for (int lane = 0; lane < GameConfig.laneCount; lane++) {
      if (_laneHasSpace(lane)) {
        lanes.add(lane);
      }
    }

    return lanes;
  }

  double spawnTimer = 0;

  double nextSpawnTime() {
    final d = GameManager.instance.difficulty;

    final minTime = (0.70 / d).clamp(0.25, 0.70);
    final maxTime = (1.50 / d).clamp(0.50, 1.50);

    return minTime + _random.nextDouble() * (maxTime - minTime);
  }

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

      // _spawnSingleCar();
      // _spawnRandomPattern();
      _spawnVehicle();
    }
  }

  void _spawnRandomPattern() {
    final pattern = trafficPatterns[_random.nextInt(trafficPatterns.length)];

    _spawnPattern(pattern);
  }

  void _spawnVehicle() {
    final lanes = _availableLanes();

    if (lanes.isEmpty) return;

    final lane = lanes[_random.nextInt(lanes.length)];

    final enemy = EnemyComponent();

    enemy.currentLane = lane;

    enemy.position.y = road.horizonY - 20;

    parent!.add(enemy);
  }

  void _spawnPattern(List<int> lanes) {
    final spawnY = road.spawnY(420 + _random.nextDouble() * 220);

    for (final lane in lanes) {
      final enemy = EnemyComponent();
      enemy.currentLane = lane;
      enemy.position.y = spawnY;

      parent!.add(enemy);
    }
  }
}
