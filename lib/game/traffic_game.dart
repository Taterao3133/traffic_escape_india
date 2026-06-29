import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flame/events.dart';
import 'components/road_component.dart';
import 'components/player_component.dart';
import 'components/enemy_component.dart';
//import 'package:flame/collisions.dart';
//import 'managers/enemy_manager.dart';
//import 'managers/game_manager.dart';
import 'package:flutter/services.dart';
import 'managers/spawn_manager.dart';
import 'ui/hud.dart';

class TrafficGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  @override
  Future<void> onLoad() async {
    debugPrint("🎮 Traffic Escape India Started!");
    //await add(GameManager());

    await add(RoadComponent());

    for (int i = 0; i < 5; i++) {
      debugPrint("Creating Enemy $i");
      await add(EnemyComponent());
    }
    await add(PlayerComponent());
    await add(Hud());
    await add(SpawnManager());

    await super.onLoad();
  }

  // @override
  // KeyEventResult onKeyEvent(
  //   KeyEvent event,
  //   Set<LogicalKeyboardKey> keysPressed,
  // ) {
  //   if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyR) {
  //     debugPrint("Restart Pressed");
  //   }

  //   return KeyEventResult.handled;
  // }
}
