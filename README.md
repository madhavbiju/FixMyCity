# FixMyCity

#### An Open Source application for tracking and reporting civic issues such as potholes, streetlight outages, and garbage collection. This app allows users to take a photo of the issue and submit it along with their location. The app then use this information to create a map of reported issues, which could be made available to city officials to help prioritize and address the most pressing problems. The app also has a feauture where the issue once posted will be marked in a map of that area.


## How it works?
FixMyCity is an open source application made using Flutter and Firebase. Since it is made using Flutter we can use it as both mobile app as well as web application. A user is supposed to Login with their registered credentials. Once logged in, the user is asked permission to access the location they are in. When accepted, the app automatically reads the location in terms of latitude and longitude. The user can then choose the issue they want to point out from a dropdown or type out the issues along with an image of the issue. The image can either be taken from camera or uploaded from gallery. The user can then just submit the complaint issue.

When the user submits a matter that needs to be taken care of, the location coordinates, the issue and the photo is saved to the database which is firebase in this case. Then the list of coordinates from all the issues are used to place markers over the map.

## Libraries used
- Cloud Firestore
- Geolocator
- Image Picker
- Firebase Storage
- Flutter Map

## How to configure
The app is using Firebase, you have to configure it from your side to test the app. 

## How to run

To run tests, run the following command

- Clone this repo
- Run for installing dependencies
dart
  flutter pub get

- Run the app using
dart
  flutter run

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
