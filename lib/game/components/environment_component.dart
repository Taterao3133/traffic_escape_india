import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/game_config.dart';
import '../managers/game_manager.dart';

late Sprite treeSprite;
late Sprite signSprite;

enum EnvironmentObjectType { tree, trafficSign }

enum RoadSide { left, right }

class EnvironmentComponent extends PositionComponent {
  EnvironmentComponent({Random? random, RoadSide? side, double? initialY})
    : this._(random ?? Random(), side, initialY);

  EnvironmentComponent._(Random random, RoadSide? side, this.initialY)
    : _random = random,
      _side = side ?? (random.nextBool() ? RoadSide.left : RoadSide.right),
      super();

  static const double _baseScrollSpeed = 200;
  static const double _roadPadding = 8;
  static const double _screenPadding = 8;

  final Random _random;
  final double? initialY;

  late EnvironmentObjectType _type;
  RoadSide _side;

  @override
  Future<void> onLoad() async {
    priority = 10;
    anchor = Anchor.topLeft;

    treeSprite = await Sprite.load('roadside/trees_1.png');
    signSprite = await Sprite.load('signs/roadsign_1.png');

    _chooseObject();

    position.y = initialY ?? -_random.nextDouble() * findGame()!.size.y;

    _placeOutsideRoad();
    _updatePerspective();

    await super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (GameManager.instance.isGameOver) return;

    position.y += _baseScrollSpeed * dt;
    _updatePerspective();

    if (position.y > findGame()!.size.y + size.y) {
      _recycle();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    switch (_type) {
      case EnvironmentObjectType.tree:
        treeSprite.render(canvas, size: size);
        break;

      case EnvironmentObjectType.trafficSign:
        signSprite.render(canvas, size: size);
        break;
    }
  }

  void _recycle() {
    _side = _random.nextBool() ? RoadSide.left : RoadSide.right;

    _chooseObject();

    position.y = -size.y - _random.nextDouble() * 300;

    _placeOutsideRoad();
  }

  void _chooseObject() {
    final roll = _random.nextInt(100);

    if (roll < 75) {
      _type = EnvironmentObjectType.tree;
      size = Vector2(90, 130);
    } else {
      _type = EnvironmentObjectType.trafficSign;
      size = Vector2(60, 90);
    }
  }

  void _placeOutsideRoad() {
    final gameSize = findGame()!.size;

    final roadLeft = GameConfig.roadLeft(gameSize.x);
    final roadRight = GameConfig.roadRight(gameSize.x);

    if (_side == RoadSide.left) {
      final maxX = roadLeft - size.x - _roadPadding;

      position.x = _randomRange(_screenPadding, max(_screenPadding, maxX));
    } else {
      final minX = roadRight + _roadPadding;
      final maxX = gameSize.x - size.x - _screenPadding;

      position.x = _randomRange(min(minX, maxX), max(minX, maxX));
    }
  }

  void _updatePerspective() {
    final gameSize = findGame()!.size;

    final depth = (position.y / gameSize.y).clamp(0.0, 1.0);

    final scaleValue = 0.25 + (depth * 1.35);

    scale = Vector2.all(scaleValue);
  }

  double _randomRange(double minValue, double maxValue) {
    if (maxValue <= minValue) return minValue;

    return minValue + _random.nextDouble() * (maxValue - minValue);
  }
}
