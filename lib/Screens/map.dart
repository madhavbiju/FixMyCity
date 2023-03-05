import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fixmycity/Screens/home.dart';

import '../Functions/bottomnav.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Position? _currentPosition;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNav(selectedIndex: 1),
      appBar: AppBar(
        elevation: 4,
        centerTitle: true,
        title: Text("Issues Currently Posted"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('issues').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if ((snapshot.connectionState == ConnectionState.waiting) ||
              (_currentPosition == null)) {
            return Text('Loading...');
          }

          List<LatLng> coordinates = [];
          snapshot.data!.docs.forEach((doc) {
            double lat = doc['latitude'];
            double lng = doc['longitude'];
            coordinates.add(LatLng(lat, lng));
          });

          return FlutterMap(
            options: MapOptions(
              center: LatLng(
                  _currentPosition!.latitude, _currentPosition!.longitude),
              zoom: 10.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: coordinates
                    .map((coord) => Marker(
                          point: coord,
                          builder: (BuildContext context) {
                            return Icon(Icons.location_on, color: Colors.black);
                          },
                        ))
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
