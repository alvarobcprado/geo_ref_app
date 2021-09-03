import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geojson/geojson.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:geopoint/geopoint.dart';

class InterestPointsProvider extends ChangeNotifier {
  final markers = <MapLatLng>[];
  List<GeoJsonPoint> airportsData = <GeoJsonPoint>[];
  final geo = GeoJson();
  late StreamSubscription<GeoJsonPoint> sub;
  final dataIsLoaded = Completer();

  @override
  void dispose() {
    super.dispose();
    sub.cancel();
  }

  void startNearbyAirports() {
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
