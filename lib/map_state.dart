import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_map_test/polygon_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapState extends ChangeNotifier {
  final dio = Dio();
  bool isLoading = false;
  List<PolygonModel> polygonList = [];
  Set<Polygon> polygons = {};
  LatLng? selectedLocation;

  void clearData() {
    polygonList.clear();
    polygons.clear();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> getPolygonList() async {
    polygons.clear();
    polygonList.clear();
    try {
      var result = await dio
          .get('https://raw.githubusercontent.com/enescerrahoglu/google_map_test/refs/heads/main/lib/data.json');
      polygonList = List<PolygonModel>.from(result.data.map((e) => PolygonModel.fromJson(e)));
    } catch (error) {
      polygonList.clear();
      rethrow;
    }
    await createPolygons();
  }

  Future<void> createPolygons() async {
    final holes = <int, List<List<LatLng>>>{};
    final onlyPolygons = <PolygonModel>[];

    for (var polygon in polygonList) {
      if (polygon.isPolygon) {
        onlyPolygons.add(polygon);
      } else {
        holes.putIfAbsent(polygon.parentId, () => []).add(polygon.polygon);
      }
    }

    polygons = onlyPolygons.map((polygon) {
      return Polygon(
        polygonId: PolygonId(polygon.id.toString()),
        holes: holes[polygon.id] ?? [],
        points: polygon.polygon,
        strokeWidth: 2,
        strokeColor: Colors.purple,
        fillColor: Colors.purple.withOpacity(0.2),
      );
    }).toSet();

    isLoading = false;
    notifyListeners();
  }

  void _navigateToCamera(
      {required GoogleMapController? controller, required double lat, required double lng, required double zoom}) {
    selectedLocation = LatLng(lat, lng);
    notifyListeners();

    controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, lng),
          zoom: zoom,
        ),
      ),
    );
  }

  LatLng _getCenterPoint({required Iterable<LatLng> points}) {
    double latitude = 0;
    double longitude = 0;
    int n = points.length;

    for (LatLng point in points) {
      latitude += point.latitude;
      longitude += point.longitude;
    }

    return LatLng((latitude / n), (longitude / n));
  }

  Future<void> showServiceAreas(GoogleMapController? controller) async {
    var latLngs = <LatLng>[];
    for (var polygon in polygonList) {
      latLngs.addAll(polygon.polygon);
    }
    var latLngBounds = boundsFromLatLngList(latLngs);
    var zoom = _getZoom(
            latA: latLngBounds.northeast.latitude,
            lngA: latLngBounds.northeast.longitude,
            latB: latLngBounds.southwest.latitude,
            lngB: latLngBounds.southwest.longitude) -
        0.5;

    var centerPoint = _getCenterPoint(points: [latLngBounds.southwest, latLngBounds.northeast]);

    _navigateToCamera(controller: controller, lat: centerPoint.latitude, lng: centerPoint.longitude, zoom: zoom);
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    assert(list.isNotEmpty);
    double? x0;
    double x1 = 0;
    double y0 = 0;
    double y1 = 0;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }

    return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0 ?? 0, y0));
  }

  double _getZoom({required double latA, required double lngA, required double latB, required double lngB}) {
    var latDif = (_latRad(latA) - _latRad(latB)).abs();
    var lngDif = (lngA - lngB).abs();

    var latFrac = latDif / pi;
    var lngFrac = lngDif / 360;

    var lngZoom = log(1 / latFrac) / log(2);
    var latZoom = log(1 / lngFrac) / log(2);

    var result = min(lngZoom, latZoom) + 1;

    if (result < 0) result = 1;

    return result;
  }

  double _latRad(lat) {
    var sinX = sin(lat * pi / 180);
    var radX2 = log((1 + sinX) / (1 - sinX)) / 2;
    return max(min(radX2, pi), -pi) / 2;
  }
}
