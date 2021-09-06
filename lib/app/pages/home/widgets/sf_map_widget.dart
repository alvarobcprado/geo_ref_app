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
    _mapZoomPanBehavior = MapZoomPanBehavior();
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

  @override
  Widget build(BuildContext context) => Container(
        height: double.infinity,
        child: GestureDetector(
          onTapUp: (tapUpDetails) async {
            _showLoadingDialog('Buscando aeroportos');
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
                    index == 0 ? Icons.location_on : Icons.airplanemode_on,
                    color: index == 0 ? Colors.red : Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
