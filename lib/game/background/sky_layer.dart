import 'package:flame/components.dart';

import 'scene_layer.dart';

class SkyLayer extends SceneLayer {
  late SpriteComponent sky;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    sky = SpriteComponent(
      sprite: await Sprite.load('sky/sky_day.png'),
      size: Vector2(
        size.x * 1.2, // Increase width
        size.y * 0.70, // Increase image height
      ),
      position: Vector2(
        -(size.x * 0.1), // Center after increasing width
        -130, // Move slightly upward
      ),
    );

    add(sky);
  }
}
