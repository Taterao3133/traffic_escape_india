import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../config/game_config.dart';
import '../config/speed_config.dart';
import '../managers/game_manager.dart';
import 'player_component.dart';

class CoinComponent extends SpriteComponent with CollisionCallbacks {
  CoinComponent({required this.lane, required double spawnY})
    : super(position: Vector2(0, spawnY));

  final int lane;

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('ui/coin.png');

    anchor = Anchor.center;

    final gameSize = findGame()!.size;

    position.x = GameConfig.laneCenterAtY(
      gameSize.x,
      gameSize.y,
      lane,
      position.y,
    );

    size = Vector2.all(40);

    add(CircleHitbox());

    await super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    final roadSpeed = SpeedConfig.playerSpeed;

    position.y += roadSpeed * dt;

    final gameSize = findGame()!.size;

    position.x = GameConfig.laneCenterAtY(
      gameSize.x,
      gameSize.y,
      lane,
      position.y,
    );

    if (position.y > gameSize.y + 80) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points, other);

    if (other is PlayerComponent) {
      GameManager.instance.score += 10;

      removeFromParent();
    }
  }
}
