import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game/traffic_game.dart';

void main() {
  runApp(
    GameWidget(
      game: TrafficGame(),
    ),
  );
}