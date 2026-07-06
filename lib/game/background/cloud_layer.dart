import 'package:flame/components.dart';

import 'scene_layer.dart';

class CloudLayer extends SceneLayer {
  late SpriteComponent cloud;

  static const double cloudSpeed = 8;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    cloud = SpriteComponent(
      sprite: await Sprite.load('sky/clouds-1.png'),
      size: Vector2(size.x, size.y * 0.18),
      position: Vector2(0, size.y * 0.05),
    );

    add(cloud);
  }

  @override
  void update(double dt) {
    super.update(dt);

    cloud.position.x += cloudSpeed * dt;

    if (cloud.position.x > size.x) {
      cloud.position.x = -cloud.size.x;
    }
  }
}
