import 'package:flame/components.dart';

import 'scene_layer.dart';

class MountainLayer extends SceneLayer {
  late SpriteComponent farMountain;
  late SpriteComponent nearMountain;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    farMountain = SpriteComponent(
      sprite: await Sprite.load('mountains/mountain_far.png'),
      position: Vector2(0, size.y * 0.10),
      size: Vector2(size.x, size.y * 0.18),
    );

    nearMountain = SpriteComponent(
      sprite: await Sprite.load('mountains/mountain_near.png'),
      position: Vector2(
        0,
        size.y * 0.13,
      ), // Adjusted position for near mountain
      size: Vector2(size.x, size.y * 0.20),
    );

    add(farMountain);
    add(nearMountain);
  }
}
