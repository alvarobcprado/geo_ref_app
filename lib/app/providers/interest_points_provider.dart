import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geojson/geojson.dart';
import 'package:geolocator/geolocator.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:geopoint/geopoint.dart';

class InterestPointsProvider extends ChangeNotifier {
  late Position currentPosition;
  late MapLatLng markerPosition;
  late StreamSubscription<GeoJsonPoint> sub;
  final markers = <MapLatLng>[];
  final geo = GeoJson();
  final dataIsLoaded = Completer();
  final mapTileLayerController = MapTileLayerController();
  List<GeoJsonPoint> airportsData = <GeoJsonPoint>[];

  @override
  void dispose() {
    super.dispose();
    sub.cancel();
  }

  void startNearbyAirports() {
    //_changeIsLoading(true);
    loadAirports().then(
      (_) {
        dataIsLoaded.complete();
      },
    );
    sub = geo.processedPoints.listen(
      (point) {
        final latLng = point.geoPoint.toLatLng()!;
        // listen for the geofenced airports
        markers.add(
          MapLatLng(latLng.latitude, latLng.longitude),
        );
      },
    );
    // _changeIsLoading(false);
  }

  Future<void> findCurrentPosition() async {
    //_changeIsLoading(true);
    currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    markerPosition =
        MapLatLng(currentPosition.latitude, currentPosition.longitude);
    mapTileLayerController.insertMarker(0);
    await searchNearbyAirports(markerPosition);
    for (final airport in markers) {
      markerPosition = airport;
      mapTileLayerController.insertMarker(1);
    }
    // _changeIsLoading(false);
  }

  Future<void> updateMarkerChange(Offset position) async {
    markerPosition = mapTileLayerController.pixelToLatLng(position);
    if (mapTileLayerController.markersCount > 0) {
      mapTileLayerController.clearMarkers();
    }
    mapTileLayerController.insertMarker(0);
    await searchNearbyAirports(markerPosition);
    for (final airport in markers) {
      markerPosition = airport;
      mapTileLayerController.insertMarker(1);
    }
  }

  Future<void> searchNearbyAirports(MapLatLng point) async {
    await dataIsLoaded.future;
    // geofence in radius
    const kilometers = 1000;
    final geoJsonPoint = GeoJsonPoint(
      geoPoint: GeoPoint(
        latitude: point.latitude,
        longitude: point.longitude,
      ),
    );
    await geo.geofenceDistance(
        point: geoJsonPoint, points: airportsData, distance: kilometers * 1000);
  }

  Future<void> loadAirports() async {
    final data =
        await rootBundle.loadString('assets/geo_json/airports.geojson');
    await geo.parse(data, disableStream: true, verbose: true);
    airportsData = geo.points;
  }
}
