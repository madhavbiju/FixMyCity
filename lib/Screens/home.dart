import 'dart:io';
import 'package:fixmycity/Screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class Issue {
  final LatLng location;
  final String type;
  final String photoUrl;

  Issue({
    required this.location,
    required this.type,
    required this.photoUrl,
  });
}

class IssueDatabase {
  final List<Issue> _issues = [];

  void addIssue(Issue issue) {
    _issues.add(issue);
  }

  List<Issue> getIssues() {
    return _issues;
  }
}

class _HomePageState extends State<HomePage> {
  final IssueDatabase _database = IssueDatabase();
  final ImagePicker _picker = ImagePicker();
  final MapController _mapController = MapController();
  Position? _currentPosition;
  String? _photoUrl;
  String? _issueType;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
  }

  Future<void> _takePhoto() async {
    XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _photoUrl = photo.path;
      });
    }
  }

  void _submitIssue() {
    if (_currentPosition != null && _issueType != null && _photoUrl != null) {
      Issue issue = Issue(
          location:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          type: _issueType!,
          photoUrl: _photoUrl!);
      _database.addIssue(issue);
      setState(() {
        _photoUrl = null;
        _issueType = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        centerTitle: true,
        title: Text('Fix My City'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.account_circle_outlined,
            ),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      ProfilePage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitIssue,
        label: const Text('Submit'),
        icon: const Icon(Icons.save),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Report a Civic Issue',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            _currentPosition != null
                ? Text(
                    'Your location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
                    style: TextStyle(fontSize: 16),
                  )
                : CircularProgressIndicator(),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: _issueType,
              hint: Text('Select an issue type'),
              onChanged: (String? value) {
                setState(() {
                  _issueType = value;
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
            Container(
              decoration: _photoUrl != null
                  ? BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    )
                  : null,
              padding: EdgeInsets.all(8.0),
              child: _photoUrl != null
                  ? Image.file(
                      File(_photoUrl!),
                      width: 150.0,
                      height: 150.0,
                      fit: BoxFit.cover,
                    )
                  : ElevatedButton(
                      onPressed: _takePhoto,
                      child: Text('Take a Photo'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
