import 'package:flame/components.dart';

import 'cloud_layer.dart';
import 'fog_layer.dart';
import 'mountain_layer.dart';
import 'sky_layer.dart';
import 'ground_layer.dart';

class BackgroundComponent extends Component {
  @override
  Future<void> onLoad() async {
    priority = -100;
    await super.onLoad();

    await add(SkyLayer());

    await add(MountainLayer());
    await add(CloudLayer());
    await add(GroundLayer());
    await add(FogLayer());
  }
}
