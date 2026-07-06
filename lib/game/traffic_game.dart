import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flame/events.dart';
import 'components/road_component.dart';
import 'components/player_component.dart';
// import 'components/enemy_component.dart';
import 'components/environment_component.dart';
import 'managers/traffic_manager.dart';
import 'config/game_config.dart';
//import 'package:flame/collisions.dart';
//import 'managers/enemy_manager.dart';
import 'managers/game_manager.dart';
// import 'managers/spawn_manager.dart';
import 'background/background_component.dart';
import 'managers/coin_manager.dart';

// import 'components/background_component.dart';
import 'ui/hud.dart';

class TrafficGame extends FlameGame
    with
        HasKeyboardHandlerComponents,
        HasCollisionDetection,
        DragCallbacks,
        TapCallbacks {
  late PlayerComponent _player;
  double _dragDistanceX = 0;
  double _dragDistanceY = 0;
  bool _swipeConsumed = false;

  @override
  Future<void> onLoad() async {
    debugPrint("🎮 Traffic Escape India Started!");
    //await add(GameManager());

    await add(BackgroundComponent());

    await add(RoadComponent());

    for (int i = 0; i < 12; i++) {
      await add(
        EnvironmentComponent(
          side: i.isEven ? RoadSide.left : RoadSide.right,
          initialY: -i * 130,
        ),
      );
    }

    await add(TrafficManager());

    await add(CoinManager());

    _player = PlayerComponent();
    await add(_player);

    await add(Hud());

    await super.onLoad();
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _dragDistanceX = 0;
    _dragDistanceY = 0;
    _swipeConsumed = false;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);

    if (GameManager.instance.isGameOver || _swipeConsumed) {
      return;
    }

    _dragDistanceX += event.canvasDelta.x;
    _dragDistanceY += event.canvasDelta.y;

    if (_isHorizontalSwipe()) {
      _swipeConsumed = true;

      if (_dragDistanceX < 0) {
        _player.moveLeft();
      } else {
        _player.moveRight();
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    GameManager.instance.update(dt);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);

    _dragDistanceX = 0;
    _dragDistanceY = 0;
    _swipeConsumed = false;
  }

  bool _isHorizontalSwipe() {
    final horizontalDistance = _dragDistanceX.abs();
    final verticalDistance = _dragDistanceY.abs();

    return horizontalDistance >= GameConfig.minSwipeDistance &&
        horizontalDistance >= verticalDistance * GameConfig.horizontalSwipeBias;
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
}
