import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolygonModel {
  int id;
  int parentId;
  int warehouseId;
  String name;
  List<LatLng> polygon;
  bool isPolygon;

  PolygonModel({
    required this.id,
    required this.parentId,
    required this.warehouseId,
    required this.name,
    required this.polygon,
    required this.isPolygon,
  });

  factory PolygonModel.fromJson(Map<String, dynamic> json) {
    return PolygonModel(
      id: json["Id"],
      parentId: json["ParentId"],
      warehouseId: json["WarehouseId"],
      name: json["Name"],
      polygon: List<LatLng>.from(
        json["Polygon"].map(
          (x) => LatLng(x["Lat"], x["Lng"]),
        ),
      ),
      isPolygon: json["IsPolygon"],
    );
  }
}
