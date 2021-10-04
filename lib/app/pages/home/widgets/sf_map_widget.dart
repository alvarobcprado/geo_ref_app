import 'package:flutter/material.dart';

import 'package:geo_ref/app/providers/interest_points_provider.dart';

import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class SfMapWidget extends StatefulWidget {
  const SfMapWidget({Key? key}) : super(key: key);

  @override
  _SfMapWidgetState createState() => _SfMapWidgetState();
}

class _SfMapWidgetState extends State<SfMapWidget> {
  late MapZoomPanBehavior _mapZoomPanBehavior;
  late MapTileLayerController _mapTileLayerController;
  late InterestPointsProvider _airportsProvider;

  @override
  void initState() {
    super.initState();
    _airportsProvider =
        Provider.of<InterestPointsProvider>(context, listen: false);
    _mapTileLayerController = _airportsProvider.mapTileLayerController;
    _mapZoomPanBehavior = MapZoomPanBehavior(
      enableDoubleTapZooming: true,
      zoomLevel: 5,
    );
    _airportsProvider.startNearbyAirports();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _startCurrentLocation();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _airportsProvider.dispose();
  }

  Future<void> _startCurrentLocation() async {
    _showLoadingDialog('Buscando localização atual');
    await _airportsProvider.findCurrentPosition();
    Navigator.of(context).pop();
  }

  void _showLoadingDialog(String loadingText) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(10),
        insetPadding: EdgeInsets.symmetric(
          vertical: 24,
          horizontal: 125 - (loadingText.length * 2),
        ),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 10),
            Text(
              loadingText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _lineTooltipBuilder(BuildContext context, int index) => Container(
        padding: const EdgeInsets.only(left: 5, top: 5),
        height: 75,
        width: 250,
        color: Colors.white,
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'De: ${_airportsProvider.refPointStringLat}'
                  ', ${_airportsProvider.nearestPointStringLng}',
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Até: ${_airportsProvider.nearestPointStringLat}'
                  ', ${_airportsProvider.nearestPointStringLng}',
                  overflow: TextOverflow.clip,
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Text(
                  'Distância: ${_airportsProvider.nearestDistance}Km',
                ),
              ],
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _startCurrentLocation,
          child: const Icon(Icons.gps_fixed),
        ),
        body: Container(
          height: double.infinity,
          child: GestureDetector(
            onTapUp: (tapUpDetails) async {
              _showLoadingDialog('Buscando acidentes próximos');
              await _airportsProvider
                  .updateMarkerChange(tapUpDetails.localPosition);
              Navigator.of(context).pop();
            },
            child: SfMaps(
              layers: [
                MapTileLayer(
                  controller: _mapTileLayerController,
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  initialFocalLatLng: const MapLatLng(-15.598889, -56.095),
                  initialZoomLevel: 5,
                  zoomPanBehavior: _mapZoomPanBehavior,
                  markerBuilder: (ctx, index) => MapMarker(
                    latitude: _airportsProvider.markerPosition.latitude,
                    longitude: _airportsProvider.markerPosition.longitude,
                    child: Icon(
                      index == 0 ? Icons.location_on : Icons.report,
                      color: index == 0
                          ? Colors.blue.shade900
                          : Colors.red.shade900,
                      size: index == 0 ? 34 : 24,
                    ),
                  ),
                  sublayers: [
                    MapLineLayer(
                      lines: <MapLine>{
                        if (Provider.of<InterestPointsProvider>(context)
                            .lineToNearestPoint
                            .isNotEmpty)
                          MapLine(
                            color: Colors.red.shade500,
                            width: 3,
                            from: Provider.of<InterestPointsProvider>(context)
                                .lineToNearestPoint[0],
                            to: Provider.of<InterestPointsProvider>(context)
                                .lineToNearestPoint[1],
                          ),
                      },
                      tooltipBuilder: _lineTooltipBuilder,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
