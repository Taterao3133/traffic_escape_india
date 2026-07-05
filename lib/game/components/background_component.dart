import 'package:flame/components.dart';
// import 'package:flame/sprite.dart';

class BackgroundComponent extends Component with HasGameReference {
  late SpriteComponent sky;
  late SpriteComponent clouds;
  late SpriteComponent mountainFar;
  late SpriteComponent mountainNear;
  late SpriteComponent fog;

  @override
  Future<void> onLoad() async {
    final size = game.size;

    sky = SpriteComponent(
      sprite: await Sprite.load('background/sky_day.png'),
      size: Vector2(size.x, size.y * 0.55),
      position: Vector2.zero(),
    );

    clouds = SpriteComponent(
      sprite: await Sprite.load('background/clouds_01.png'),
      size: Vector2(size.x, size.y * 0.20),
      position: Vector2(0, size.y * 0.08),
    );

    mountainFar = SpriteComponent(
      sprite: await Sprite.load('background/mountain_far.png'),
      size: Vector2(size.x, size.y * 0.18),
      position: Vector2(0, size.y * 0.22),
    );

    mountainNear = SpriteComponent(
      sprite: await Sprite.load('background/mountain_near.png'),
      size: Vector2(size.x, size.y * 0.20),
      position: Vector2(0, size.y * 0.28),
    );

    fog = SpriteComponent(
      sprite: await Sprite.load('background/horizon_fog.png'),
      size: Vector2(size.x, size.y * 0.12),
      position: Vector2(0, size.y * 0.39),
    );

    add(sky);
    add(clouds);
    add(mountainFar);
    add(mountainNear);
    add(fog);

    await super.onLoad();
  }
}
