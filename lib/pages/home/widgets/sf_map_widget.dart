import 'package:flutter/material.dart';
import 'package:geo_ref/pages/home/helpers/custom_zoom_pan_behavior.dart';
import 'package:geo_ref/pages/home/helpers/nearby_airports.dart';
import 'package:geolocator/geolocator.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class SfMapWidget extends StatefulWidget {
  const SfMapWidget({Key? key}) : super(key: key);

  @override
  _SfMapWidgetState createState() => _SfMapWidgetState();
}

class _SfMapWidgetState extends State<SfMapWidget> {
  late MapZoomPanBehavior _mapZoomPanBehavior;
  late MapTileLayerController _mapTileLayerController;
  late MapLatLng _markerPosition;
  late Position _currentPosition;
  late NearbyAirports _nearbyAirports;

  void _updateMarkerChange(Offset position) {
    _markerPosition = _mapTileLayerController.pixelToLatLng(position);
    if (_mapTileLayerController.markersCount > 0) {
      _mapTileLayerController.clearMarkers();
    }
    _mapTileLayerController.insertMarker(0);
  }

  Future<void> _findCurrentPosition() async {
    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _markerPosition =
        MapLatLng(_currentPosition.latitude, _currentPosition.longitude);
    _mapTileLayerController.insertMarker(0);
    await _nearbyAirports.searchNearbyAirports(_markerPosition);
    for (final airport in _nearbyAirports.markers) {
      _markerPosition = airport;
      _mapTileLayerController.insertMarker(1);
    }
  }

  @override
  void initState() {
    super.initState();
    _mapTileLayerController = MapTileLayerController();
    _nearbyAirports = NearbyAirports();
    _mapZoomPanBehavior = CustomZoomPanBehavior()..onTap = _updateMarkerChange;
    _nearbyAirports.start();
    _findCurrentPosition();
  }

  @override
  void dispose() {
    super.dispose();
    _nearbyAirports.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        height: double.infinity,
        child: SfMaps(
          layers: [
            MapTileLayer(
              controller: _mapTileLayerController,
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              initialFocalLatLng: const MapLatLng(-15.598889, -56.095),
              initialZoomLevel: 5,
              zoomPanBehavior: _mapZoomPanBehavior,
              markerBuilder: (ctx, index) => MapMarker(
                latitude: _markerPosition.latitude,
                longitude: _markerPosition.longitude,
                child: Icon(
                  index == 0 ? Icons.location_on : Icons.airplanemode_on,
                  color: index == 0 ? Colors.red : Colors.blue,
                ),
              ),
            ),
          ],
        ),
      );
}
