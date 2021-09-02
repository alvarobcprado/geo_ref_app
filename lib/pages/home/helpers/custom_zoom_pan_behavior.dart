import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class CustomZoomPanBehavior extends MapZoomPanBehavior {
  CustomZoomPanBehavior();
  late MapTapCallback onTap;

  @override
  void handleEvent(PointerEvent event) {
    onTap(event.localPosition);
    print('tocou');

    super.handleEvent(event);
  }
}

typedef MapTapCallback = void Function(Offset position);
