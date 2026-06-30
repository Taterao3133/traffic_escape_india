import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flame/events.dart';
import 'components/road_component.dart';
import 'components/player_component.dart';
import 'components/enemy_component.dart';
import 'components/environment_component.dart';
import 'config/game_config.dart';
//import 'package:flame/collisions.dart';
//import 'managers/enemy_manager.dart';
import 'managers/game_manager.dart';
import 'managers/spawn_manager.dart';
import 'ui/hud.dart';

class TrafficGame extends FlameGame
    with
        HasKeyboardHandlerComponents,
        HasCollisionDetection,
        DragCallbacks,
        TapCallbacks {
  late PlayerComponent _player;
  double _dragDistanceX = 0;

  @override
  Future<void> onLoad() async {
    debugPrint("🎮 Traffic Escape India Started!");
    //await add(GameManager());

    await add(RoadComponent());
    for (int i = 0; i < 12; i++) {
      await add(
        EnvironmentComponent(
          side: i.isEven ? RoadSide.left : RoadSide.right,
          initialY: -i * 130,
        ),
      );
    }

    for (int i = 0; i < GameConfig.enemyCount; i++) {
      debugPrint("Creating Enemy $i");
      await add(EnemyComponent());
    }
    _player = PlayerComponent();
    await add(_player);
    await add(Hud());
    await add(SpawnManager());

    await super.onLoad();
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _dragDistanceX = 0;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    _dragDistanceX += event.canvasDelta.x;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);

    if (GameManager.instance.isGameOver) {
      return;
    }

    if (_dragDistanceX <= -GameConfig.minSwipeDistance) {
      _player.moveLeft();
    } else if (_dragDistanceX >= GameConfig.minSwipeDistance) {
      _player.moveRight();
    }

    _dragDistanceX = 0;
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    if (GameManager.instance.isGameOver) {
      _restartGame();
    }
  }

  void _restartGame() {
    GameManager.instance.restart();
    _player.resetPlayer();
    debugPrint("Game Restarted");
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
