import 'package:flame/components.dart';

abstract class SceneLayer extends PositionComponent with HasGameReference {
  @override
  Future<void> onLoad() async {
    size = game.size;
    await super.onLoad();
  }
}
