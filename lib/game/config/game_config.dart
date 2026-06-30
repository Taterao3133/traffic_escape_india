import 'package:flutter/material.dart';

class GameConfig {
  // ----------------------------
  // Screen
  // ----------------------------

  static const int laneCount = 3;

  static const double minRoadWidth = 280;

  static const double maxRoadWidth = 620;

  static const double sideShoulderWidth = 48;

  static double roadWidth(double screenWidth) {
    final availableWidth = screenWidth - (sideShoulderWidth * 2);

    return availableWidth.clamp(minRoadWidth, maxRoadWidth).toDouble();
  }

  static double roadLeft(double screenWidth) {
    return (screenWidth - roadWidth(screenWidth)) / 2;
  }

  static double roadRight(double screenWidth) {
    return roadLeft(screenWidth) + roadWidth(screenWidth);
  }

  static double laneWidth(double screenWidth) {
    return roadWidth(screenWidth) / laneCount;
  }

  static List<double> laneCenters(double screenWidth) {
    final left = roadLeft(screenWidth);
    final width = laneWidth(screenWidth);

    return List<double>.generate(
      laneCount,
      (index) => left + width * index + width / 2,
      growable: false,
    );
  }

  // ----------------------------
  // Player
  // ----------------------------

  static const Size playerSize = Size(160, 100);

  static const double playerBottomPadding = 250;

  static const double laneChangeDuration = 0.18;

  static const double minSwipeDistance = 40;

  // ----------------------------
  // Enemy
  // ----------------------------

  static const Size enemySize = Size(160, 100);

  static const double enemySpeed = 400;

  static const int enemyCount = 5;

  static const double enemySpawnGap = 800;
}
