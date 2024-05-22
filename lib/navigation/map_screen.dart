import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapController mapController = MapController();
  double zoomLevel = 14.0;
  List<Marker> markers = [];

  @override
  void initState() {
    super.initState();
    fetchMarkers();
  }

  void fetchMarkers() async {
    FirebaseFirestore.instance.collection('markers').snapshots().listen((snapshot) {
      List<Marker> newMarkers = [];
      for (var document in snapshot.docs) {
        GeoPoint geoPoint = document['location'];
        newMarkers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(geoPoint.latitude, geoPoint.longitude),
            child: Icon(
              Icons.location_pin,
              color: Colors.red,
              size: 50.0,
              ),
            ),
          );
      }
      setState(() {
        markers = newMarkers;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Карта'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(55.344281, 86.064375), // Начальные координаты карты
          initialZoom: zoomLevel, // Начальный уровень масштабирования
          onPositionChanged: (MapPosition pos, bool hasGesture) {
            // Обновление уровня масштабирования при изменении позиции карты
            setState(() {
              zoomLevel = pos.zoom!;
            });
          },
        ),
        mapController: mapController,
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: markers,
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Увеличение масштаба карты
              mapController.move(mapController.center, mapController.zoom + 1);
            },
            child: Icon(Icons.add),
          ),
          SizedBox(height: 10.0),
          FloatingActionButton(
            onPressed: () {
              // Уменьшение масштаба карты
              mapController.move(mapController.center, mapController.zoom - 1);
            },
            child: Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
