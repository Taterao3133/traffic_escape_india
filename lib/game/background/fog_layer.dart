import 'package:flame/components.dart';

import 'scene_layer.dart';

class FogLayer extends SceneLayer {
  late SpriteComponent fog;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    fog = SpriteComponent(
      sprite: await Sprite.load('effects/horizon_fog.png'),
      position: Vector2(0, size.y * 0.17),
      size: Vector2(size.x, size.y * 0.12),
    );

    add(fog);
  }
}
