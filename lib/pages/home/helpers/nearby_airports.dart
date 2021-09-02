import 'dart:async';

import 'package:flutter/services.dart';
import 'package:geojson/geojson.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

import 'package:geopoint/geopoint.dart';

class NearbyAirports {
  final markers = <MapLatLng>[];
  List<GeoJsonPoint> airportsData = <GeoJsonPoint>[];
  final geo = GeoJson();
  late StreamSubscription<GeoJsonPoint> sub;
  final dataIsLoaded = Completer();

  void start() {
    loadAirports().then((_) {
      dataIsLoaded.complete();
    });
    sub = geo.processedPoints.listen((point) {
      final latLng = point.geoPoint.toLatLng()!;

      // listen for the geofenced airports
      markers.add(
        MapLatLng(latLng.latitude, latLng.longitude),
      );
    });
  }

  void dispose() {
    sub.cancel();
  }

  Future<void> searchNearbyAirports(MapLatLng point) async {
    await dataIsLoaded.future;
    // geofence in radius
    const kilometers = 1000;
    final geoJsonPoint = GeoJsonPoint(
        geoPoint:
            GeoPoint(latitude: point.latitude, longitude: point.longitude));
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
