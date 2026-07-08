import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/game_config.dart';
import '../road/road_provider.dart';
import '../managers/game_manager.dart';

// late Map<EnvironmentObjectType, Sprite> sprites;
Map<EnvironmentObjectType, Sprite>? sprites;

enum EnvironmentObjectType { tree, bush, rock, electricPole }

enum RoadSide { left, right }

class EnvironmentComponent extends PositionComponent with RoadProvider {
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
  late double roadOffset;

  @override
  Future<void> onLoad() async {
    priority = 10;
    // anchor = Anchor.bottomCenter;

    sprites ??= {
      EnvironmentObjectType.tree: await Sprite.load('roadside/tree_1.png'),

      EnvironmentObjectType.bush: await Sprite.load('roadside/bushes_1.png'),

      EnvironmentObjectType.rock: await Sprite.load('roadside/rock_1.png'),

      EnvironmentObjectType.electricPole: await Sprite.load(
        'roadside/Epole_1.png',
      ),
    };
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

    // sprites![_type]!.render(canvas, size: size);
    // canvas.drawRect(
    //   Rect.fromLTWH(0, 0, size.x, size.y),
    //   Paint()..color = Colors.red,
    // );

    sprites![_type]!.render(canvas, size: size);
  }

  void _recycle() {
    _side = _random.nextBool() ? RoadSide.left : RoadSide.right;

    _chooseObject();

    position.y = -size.y - _random.nextDouble() * 300;

    _placeOutsideRoad();
  }

  void _chooseObject() {
    final roll = _random.nextInt(100);

    if (roll < 45) {
      _type = EnvironmentObjectType.tree;
      size = Vector2(90, 130);
    } else if (roll < 70) {
      _type = EnvironmentObjectType.bush;
      size = Vector2(55, 45);
    } else if (roll < 85) {
      _type = EnvironmentObjectType.rock;
      size = Vector2(50, 40);
    } else {
      _type = EnvironmentObjectType.electricPole;
      size = Vector2(40, 170);
    }
  }
  // void _chooseObject() {
  //   _type = EnvironmentObjectType.tree;
  //   size = Vector2(120, 160);
  // }

  void _placeOutsideRoad() {
    double minOffset;
    double maxOffset;

    switch (_type) {
      case EnvironmentObjectType.tree:
        minOffset = 70;
        maxOffset = 140;
        break;

      case EnvironmentObjectType.bush:
        minOffset = 25;
        maxOffset = 60;
        break;

      case EnvironmentObjectType.rock:
        minOffset = 15;
        maxOffset = 40;
        break;

      case EnvironmentObjectType.electricPole:
        minOffset = 5;
        maxOffset = 15;
        break;
    }

    roadOffset = minOffset + _random.nextDouble() * (maxOffset - minOffset);
  }

  void _updatePerspective() {
    final gameSize = findGame()!.size;

    final depth = (position.y / gameSize.y).clamp(0.0, 1.0);

    final scaleValue = 0.25 + (depth * 1.35);

    scale = Vector2.all(scaleValue);
    if (_side == RoadSide.left) {
      position.x = road.roadLeft(position.y) - roadOffset;
    } else {
      position.x = road.roadRight(position.y) + roadOffset;
    }
  }

  double _randomRange(double minValue, double maxValue) {
    if (maxValue <= minValue) return minValue;

    return minValue + _random.nextDouble() * (maxValue - minValue);
  }
}
