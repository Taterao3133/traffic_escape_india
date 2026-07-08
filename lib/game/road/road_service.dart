import 'road_geometry.dart';

class RoadService {
  RoadService._();

  static final RoadService instance = RoadService._();

  late RoadGeometry geometry;
}
