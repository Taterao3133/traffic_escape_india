import 'dart:math';

import 'package:flame/components.dart';

import '../components/coin_component.dart';
import '../components/enemy_component.dart';

class CoinManager extends Component {
  final Random _random = Random();

  double nextSpawnY = -300;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    for (int i = 0; i < 5; i++) {
      _spawnCoin();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    final currentCoins = parent!.children.whereType<CoinComponent>().length;

    if (currentCoins < 5) {
      _spawnCoin();
    }
  }

  // void _spawnCoin() {
  //   final lane = _random.nextInt(3);

  //   final enemies = parent!.children.whereType<EnemyComponent>();

  //   bool laneBusy = enemies.any(
  //     (enemy) =>
  //         enemy.currentLane == lane &&
  //         (enemy.position.y - nextSpawnY).abs() < 180,
  //   );

  //   if (laneBusy) return;

  //   // Number of coins in this chain
  //   final coinCount = 3 + _random.nextInt(4); // 3–6 coins

  //   for (int i = 0; i < coinCount; i++) {
  //     parent!.add(CoinComponent(lane: lane, spawnY: nextSpawnY - (i * 90)));
  //   }

  //   // Gap before next chain
  //   nextSpawnY -= 700 + _random.nextInt(300);
  // }
  void _spawnCoin() {
    final pattern = _random.nextInt(4);

    switch (pattern) {
      case 0:
        _spawnStraight();
        break;

      case 1:
        _spawnDiagonalLeft();
        break;

      case 2:
        _spawnDiagonalRight();
        break;

      case 3:
        _spawnZigZag();
        break;
    }
  }

  void _spawnStraight() {
    final lane = _random.nextInt(3);

    for (int i = 0; i < 5; i++) {
      parent!.add(CoinComponent(lane: lane, spawnY: nextSpawnY - i * 90));
    }

    nextSpawnY -= 800;
  }

  void _spawnDiagonalLeft() {
    int lane = 2;

    for (int i = 0; i < 3; i++) {
      parent!.add(CoinComponent(lane: lane, spawnY: nextSpawnY - i * 90));

      lane--;
    }

    nextSpawnY -= 700;
  }

  void _spawnDiagonalRight() {
    int lane = 0;

    for (int i = 0; i < 3; i++) {
      parent!.add(CoinComponent(lane: lane, spawnY: nextSpawnY - i * 90));

      lane++;
    }

    nextSpawnY -= 700;
  }

  void _spawnZigZag() {
    final lanes = [0, 1, 2, 1, 0];

    for (int i = 0; i < lanes.length; i++) {
      parent!.add(CoinComponent(lane: lanes[i], spawnY: nextSpawnY - i * 90));
    }

    nextSpawnY -= 850;
  }
}
