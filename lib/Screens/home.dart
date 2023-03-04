import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedIssue = 'Select an Issue';
  String _currentLocation = '';
  Null _issueType=null;

  Future<void> _getCurrentLocation() async {
    final location = Location();
    try {
      final currentLocation = await location.getLocation();
      setState(() {
        _currentLocation =
            'Latitude: ${currentLocation.latitude}, Longitude: ${currentLocation.longitude}';
      });
    } catch (error) {
      print('Error getting current location: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: _issueType,
                hint: Text('Select an issue type'),
                onChanged: (String? value) {
                  setState(() {
                    _issueType = value as Null;
                  });
                },
                items: <String>[
                  'Pothole',
                  'Streetlight Outage',
                  'Garbage Collection',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Text(
                _currentLocation,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getCurrentLocation,
                child: Text('Get Current Location'),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.camera_alt),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {},
                child: Text('Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}