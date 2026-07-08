import 'dart:math';

class RoadGeometry {
  RoadGeometry({
    required this.screenWidth,
    required this.screenHeight,
    this.topRoadRatio = 0.12,
    this.bottomRoadRatio = 0.96,
    this.horizonRatio = 0.18,
    this.laneCount = 3,
  });

  final double screenWidth;
  final double screenHeight;

  final double topRoadRatio;
  final double bottomRoadRatio;
  final double horizonRatio;

  final int laneCount;

  double get horizonY => screenHeight * horizonRatio;
  double spawnYRandom({
    double minDistance = 420,
    double maxDistance = 640,
    Random? random,
  }) {
    final r = random ?? Random();

    return horizonY -
        (minDistance + r.nextDouble() * (maxDistance - minDistance));
  }

  double roadWidth(double y) {
    final t = ((y - horizonY) / (screenHeight - horizonY)).clamp(0.0, 1.0);

    return lerp(topRoadRatio * screenWidth, bottomRoadRatio * screenWidth, t);
  }

  double roadLeft(double y) {
    return (screenWidth - roadWidth(y)) / 2;
  }

  double roadRight(double y) {
    return roadLeft(y) + roadWidth(y);
  }

  double laneWidth(double y) {
    return roadWidth(y) / laneCount;
  }

  double laneCenter(int lane, double y) {
    return roadLeft(y) + laneWidth(y) * (lane + 0.5);
  }

  static double lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  double perspective(double y) {
    return ((y - horizonY) / (screenHeight - horizonY)).clamp(0.0, 1.0);
  }

  double spawnY([double offset = 0]) {
    return horizonY - offset;
  }
}
