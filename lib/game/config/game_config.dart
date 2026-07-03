import 'package:flutter/material.dart';

class GameConfig {
  // ----------------------------
  // Screen
  // ----------------------------

  static const int laneCount = 3;

  static const double minRoadWidth = 280;

  static const double maxRoadWidth = 620;

  static const double sideShoulderWidth = 48;

  static const double roadHorizonRatio = 0.35; //camera view angle set

  static const double roadHorizonScale = 0.40;

  static double roadWidth(double screenWidth) {
    final availableWidth = screenWidth - (sideShoulderWidth * 2);

    return availableWidth.clamp(minRoadWidth, maxRoadWidth).toDouble();
  }

  static double roadHorizonY(double screenHeight) {
    return screenHeight * roadHorizonRatio;
  }

  static double perspectiveDepth(double screenHeight, double y) {
    final horizonY = roadHorizonY(screenHeight);
    final normalizedY = ((y - horizonY) / (screenHeight - horizonY)).clamp(
      0.0,
      1.0,
    );

    return normalizedY * normalizedY * (3 - 2 * normalizedY);
  }

  static double perspectiveScale(double screenHeight, double y) {
    return roadHorizonScale +
        perspectiveDepth(screenHeight, y) * (1 - roadHorizonScale);
  }

  static double roadWidthAtY(
    double screenWidth,
    double screenHeight,
    double y,
  ) {
    return roadWidth(screenWidth) * perspectiveScale(screenHeight, y);
  }

  static double roadLeftAtY(double screenWidth, double screenHeight, double y) {
    return (screenWidth - roadWidthAtY(screenWidth, screenHeight, y)) / 2;
  }

  static double roadRightAtY(
    double screenWidth,
    double screenHeight,
    double y,
  ) {
    return roadLeftAtY(screenWidth, screenHeight, y) +
        roadWidthAtY(screenWidth, screenHeight, y);
  }

  static double laneWidthAtY(
    double screenWidth,
    double screenHeight,
    double y,
  ) {
    return roadWidthAtY(screenWidth, screenHeight, y) / laneCount;
  }

  static double laneCenterAtY(
    double screenWidth,
    double screenHeight,
    int lane,
    double y,
  ) {
    final width = laneWidthAtY(screenWidth, screenHeight, y);

    return roadLeftAtY(screenWidth, screenHeight, y) + width * lane + width / 2;
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

  static const Size playerSize = Size(360, 260);

  static const double playerBottomPadding = 110; // 250 earlier

  static const double laneChangeDuration = 0.12;

  static const double minSwipeDistance = 32;

  static const double horizontalSwipeBias = 1.25;

  // ----------------------------
  // Enemy
  // ----------------------------

  static const Size enemySize = Size(160, 100);

  static const double enemySpeed = 400;

  static const int enemyCount = 5;

  static const double enemySpawnGap = 800;
}
