import 'package:flame/components.dart';

import 'road_geometry.dart';
import 'road_service.dart';

mixin RoadProvider on Component {
  RoadGeometry get road => RoadService.instance.geometry;
}
