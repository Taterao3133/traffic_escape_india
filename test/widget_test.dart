import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_escape_india/game/config/game_config.dart';

void main() {
  test('lane centers stay evenly spaced inside the road', () {
    const screenWidth = 720.0;

    final lanes = GameConfig.laneCenters(screenWidth);
    final roadLeft = GameConfig.roadLeft(screenWidth);
    final roadRight = GameConfig.roadRight(screenWidth);
    final laneWidth = GameConfig.laneWidth(screenWidth);

    expect(lanes, hasLength(GameConfig.laneCount));
    expect(lanes.first, greaterThan(roadLeft));
    expect(lanes.last, lessThan(roadRight));
    expect(lanes[1] - lanes[0], closeTo(laneWidth, 0.001));
    expect(lanes[2] - lanes[1], closeTo(laneWidth, 0.001));
  });
}
