// location_logic.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationLogic {
// variables
  Position? _currentLocation;
  String _currentAddress = '';
  late bool servicePermission = false;
  late LocationPermission permission;
  Function(String) onUpdateAddress;

  LocationLogic(this.onUpdateAddress);

// methods
  Future<Position> getCurrentLocation() async {
    // this block checks if we have permission to access location services
    servicePermission = await Geolocator.isLocationServiceEnabled();
    if (!servicePermission) {
      debugPrint("service disabled");
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return await Geolocator.getCurrentPosition();
  }

  // geocoding method
  Future<void> getAddressFromCoordinates() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentLocation!.latitude, _currentLocation!.longitude);

      Placemark place = placemarks[0];

      _currentAddress = "${place.street}, ${place.subLocality}";
      onUpdateAddress(_currentAddress);

    } catch (e) {
      debugPrint('$e');
    }
  }
}
