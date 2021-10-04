import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geojson/geojson.dart';
import 'package:geolocator/geolocator.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:geopoint/geopoint.dart';
import 'package:geodesy/geodesy.dart';

class InterestPointsProvider extends ChangeNotifier {
  late Position currentPosition;
  late MapLatLng markerPosition;
  late StreamSubscription<GeoJsonPoint> sub;
  final markers = <MapLatLng>[];
  final geo = GeoJson();
  final dataIsLoaded = Completer();
  final mapTileLayerController = MapTileLayerController();
  List<GeoJsonPoint> airportsData = <GeoJsonPoint>[];
  List<MapLatLng> lineToNearestPoint = [];
  num distanceBetweenNearestPoints = 0;
  final geodesy = Geodesy();

  @override
  void dispose() {
    super.dispose();
    sub.cancel();
  }

  String get refPointStringLat =>
      lineToNearestPoint[0].latitude.toStringAsFixed(7);
  String get refPointStringLng =>
      lineToNearestPoint[0].longitude.toStringAsFixed(7);

  String get nearestPointStringLat =>
      lineToNearestPoint[1].latitude.toStringAsFixed(7);
  String get nearestPointStringLng =>
      lineToNearestPoint[1].longitude.toStringAsFixed(7);

  String get nearestDistance => distanceBetweenNearestPoints.toStringAsFixed(2);

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
    if (mapTileLayerController.markersCount > 0) {
      mapTileLayerController.clearMarkers();
      markers.clear();
      lineToNearestPoint.clear();
      notifyListeners();
    }
    currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    markerPosition =
        MapLatLng(currentPosition.latitude, currentPosition.longitude);
    mapTileLayerController.insertMarker(0);
    await searchNearbyAirports(markerPosition);
    await setLineToNearestPoint(markerPosition, markers);
    for (final airport in markers) {
      markerPosition = airport;
      mapTileLayerController.insertMarker(1);
    }
    notifyListeners();
  }

  Future<void> setLineToNearestPoint(
    MapLatLng initialPosition,
    List<MapLatLng> allPoints,
  ) async {
    try {
      final refPosition = LatLng(
        initialPosition.latitude,
        initialPosition.longitude,
      );

      final allPositions = <MapLatLng, num>{};
      allPoints.forEach(
        (e) => allPositions[e] = geodesy.distanceBetweenTwoGeoPoints(
          refPosition,
          LatLng(e.latitude, e.longitude),
        ),
      );

      distanceBetweenNearestPoints = allPositions.values.reduce(min) / 1000;

      lineToNearestPoint = [
        initialPosition,
        allPositions.keys
            .where(
              (element) =>
                  allPositions[element] == allPositions.values.reduce(min),
            )
            .first,
      ];
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> updateMarkerChange(Offset position) async {
    markerPosition = mapTileLayerController.pixelToLatLng(position);
    if (mapTileLayerController.markersCount > 0) {
      mapTileLayerController.clearMarkers();
      markers.clear();
      lineToNearestPoint.clear();
      notifyListeners();
    }
    mapTileLayerController.insertMarker(0);
    await searchNearbyAirports(markerPosition);
    await setLineToNearestPoint(markerPosition, markers);
    for (final airport in markers) {
      markerPosition = airport;
      mapTileLayerController.insertMarker(1);
    }
    notifyListeners();
  }

  Future<void> searchNearbyAirports(MapLatLng point) async {
    await dataIsLoaded.future;
    // geofence in radius
    const kilometers = 50;
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
        await rootBundle.loadString('assets/geo_json/acidentsfixed.geojson');
    await geo.parse(data, disableStream: true, verbose: true);
    airportsData = geo.points;
  }
}
