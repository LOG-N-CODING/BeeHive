import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:AIAPIS/constants.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  static const LatLng _initialLatLng = LatLng(37.7749, -122.4194);

  final Set<Marker> _markers = {};
  final CollectionReference _hivesRef =
      FirebaseFirestore.instance.collection('hives');

  @override
  void initState() {
    super.initState();
    _loadHivesFromFirestore();
  }

  Future<void> _loadHivesFromFirestore() async {
    final querySnapshot = await _hivesRef.get();
    for (var doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final lat = data['lat'] as double;
      final lng = data['lng'] as double;
      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(lat, lng),
            infoWindow: const InfoWindow(title: 'Hive Site'),
          ),
        );
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _goToUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    final userLatLng = LatLng(position.latitude, position.longitude);

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(userLatLng, 14),
    );

    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('userMarker'),
          position: userLatLng,
          infoWindow: const InfoWindow(title: 'You Are Here'),
        ),
      );
    });
  }

  Future<void> _addHiveMarker() async {
    if (_mapController == null) return;

    final visibleRegion = await _mapController!.getVisibleRegion();
    final centerLat =
        (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) /
            2;
    final centerLng = (visibleRegion.northeast.longitude +
            visibleRegion.southwest.longitude) /
        2;
    final center = LatLng(centerLat, centerLng);

    final docRef =
        await _hivesRef.add({'lat': center.latitude, 'lng': center.longitude});
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(docRef.id),
          position: center,
          infoWindow: const InfoWindow(title: 'Hive Site'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'GPS & Map',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: darkBlue,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: darkBlue),
            onPressed: _goToUserLocation,
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: _initialLatLng,
          zoom: 10,
        ),
        markers: _markers,
        myLocationButtonEnabled: false,
        myLocationEnabled: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addHiveMarker,
        backgroundColor: themeYellow,
        child: const Icon(Icons.add_location, color: darkBlue),
      ),
    );
  }
}
