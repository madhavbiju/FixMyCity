import 'dart:io';

import 'package:fixmycity/Screens/map.dart';
import 'package:fixmycity/Screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../Functions/bottomnav.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final issueController = TextEditingController();
  Position? _currentPosition;
  final textController = TextEditingController();
File? _imageFile;
  String dropdownValue = 'Pothole';
  bool showOtherTextField = false;

  List<String> dropdownItems = [
    'Pothole',
    'Streetlight Outage',
    'Garbage Collection',
    'Other'
  ];

  GlobalKey<FormState> key = GlobalKey();

  CollectionReference _reference =
      FirebaseFirestore.instance.collection('issues');

  String imageUrl = '';

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
      bottomNavigationBar: BottomNav(selectedIndex: 0),
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
        onPressed: () async {
          if (imageUrl.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please upload an image')));

            return;
          }

          if (key.currentState!.validate()) {
            String issue = issueController.text;
            String location = _currentPosition.toString();
            double latitude = _currentPosition!.latitude;
            double longitude = _currentPosition!.longitude;

            Map<String, dynamic> dataToSend = {
              'issue': issue,
              'location': location,
              'image': imageUrl,
              'latitude': latitude,
              'longitude': longitude
            };
            _reference.add(dataToSend);
          }
        },
        label: const Text('Submit'),
        icon: const Icon(Icons.save),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: key,
                child: Column(
                  children: [
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
                    Padding(
                        padding:
                            const EdgeInsets.fromLTRB(50.0, 16.0, 50.0, 16.0),
                        child: DropdownButton<String>(
                          value: issueController.text.isNotEmpty
                              ? issueController.text
                              : null,
                          hint: Text('Select an issue type'),
                          items: dropdownItems.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue == 'Other') {
                              setState(() {
                                showOtherTextField = true;
                                issueController.text = 'Other';
                              });
                            } else {
                              setState(() {
                                showOtherTextField = false;
                                issueController.text = newValue ?? '';
                              });
                            }
                          },
                        )),
                    if (showOtherTextField)
                      Padding(
                          padding:
                              const EdgeInsets.fromLTRB(50.0, 16.0, 50.0, 16.0),
                          child: TextField(
                            controller: issueController,
                            decoration: InputDecoration(
                                labelText: 'Enter any other issue type'),
                          ))
                    else
                      Container(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _imageFile != null
                  ? Image.file(
                      _imageFile!,
                      width: 150.0,
                      height: 150.0,
                      fit: BoxFit.cover,
                    )
                  : ElevatedButton(
                        child: Text('Take a Photo'),
                        onPressed: () async {
                          ImagePicker imagePicker = ImagePicker();
                          XFile? file = await imagePicker.pickImage(
                              source: ImageSource.camera);
                          print('${file?.path}');
                    
                          if (file == null) return;
                          setState(() {
                            _imageFile = File(file.path);
                          });

                          if (file == null) return;
                          //Import dart:core
                          String uniqueFileName =
                              DateTime.now().millisecondsSinceEpoch.toString();
                          Reference referenceRoot =
                              FirebaseStorage.instance.ref();
                          Reference referenceDirImages =
                              referenceRoot.child('images');
                    
                          Reference referenceImageToUpload =
                              referenceDirImages.child('name');
                    
                          try {
                            await referenceImageToUpload
                                .putFile(File(file.path));
                            imageUrl =
                                await referenceImageToUpload.getDownloadURL();
                          } catch (error) {}
                        },
                      ),
                    ),
                  Visibility(
  visible: _imageFile == null,
  child: ElevatedButton( 
                       child: Text('Upload a Photo'),
                      onPressed: () async{
                        ImagePicker imagePicker = ImagePicker();
                          XFile? file = await imagePicker.pickImage(
                              source: ImageSource.gallery);
                          print('${file?.path}');

                          if (file == null) return;
                          setState(() {
                            _imageFile = File(file.path);
                          });
                    
                          if (file == null) return;
                          //Import dart:core
                          String uniqueFileName =
                              DateTime.now().millisecondsSinceEpoch.toString();
                          Reference referenceRoot =
                              FirebaseStorage.instance.ref();
                          Reference referenceDirImages =
                              referenceRoot.child('images');
                    
                          Reference referenceImageToUpload =
                              referenceDirImages.child('name');
                    
                          try {
                            await referenceImageToUpload
                                .putFile(File(file.path));
                            imageUrl =
                                await referenceImageToUpload.getDownloadURL();
                          } catch (error) {}
                      },
                    ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
