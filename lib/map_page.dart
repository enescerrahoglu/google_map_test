import 'package:flutter/material.dart';
import 'package:google_map_test/map_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // In this test project, only iOS integration was made for the google_maps_flutter package.
  // First of all, you must define your own API_KEY value in this directory: ios/Runner/AppDelegate.swift

  @override
  void initState() {
    context.read<MapState>().clearData();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<MapState>().setLoading(true);
      await context.read<MapState>().getPolygonList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topRight,
        children: [
          GoogleMap(
            polygons: context.watch<MapState>().polygons,
            compassEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            trafficEnabled: false,
            buildingsEnabled: false,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            initialCameraPosition: const CameraPosition(
              target: LatLng(40.8010121, 29.3905112),
              zoom: 5,
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.4)),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Lag Test Indicator',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  CircularProgressIndicator(color: Colors.white),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
