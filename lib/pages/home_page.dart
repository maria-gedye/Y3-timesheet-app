import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timesheet_app/components/timer_button.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
// state variables...
  final user = FirebaseAuth.instance.currentUser!;
  Position? _currentLocation;
  late bool servicePermission = false;
  late LocationPermission permission;
  String _currentAddress = '';

  int seconds = 0, minutes = 0, hours = 0;
  String digitSeconds = "00", digitMinutes = "00", digitHours = "00";
  Timer? timer;
  bool started = false;
  List shifts = [];

// state methods...

  //sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  // get current location method
  Future<Position> _getCurrentLocation() async {
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

  // geocoding method to convert coordinates to addresses
  _getAddressFromCoordinates() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentLocation!.latitude, _currentLocation!.longitude);

      Placemark place = placemarks[0];

      setState(() {
        _currentAddress =
            "${place.street}, ${place.subLocality}, ${place.locality}";
      });
    } catch (e) {
      debugPrint('$e');
    }
  }

  // methods for timer
  void stop() {
    timer!.cancel();
    setState(() {
      started = false;
      addShifts(); // adds entries to the shifts list
    });
  }

  void reset() {
    timer!.cancel();
    setState(() {
      seconds = 0;
      minutes = 0;
      hours = 0;

      digitSeconds = "00";
      digitMinutes = "00";
      digitHours = "00";
      started = false;
    });
  }

  void addShifts() {
    String shift = "$digitHours:$digitMinutes:$digitSeconds";
    setState(() {
      (shift != "00:00:00") ? shifts.add(shift) : null;
      reset();
    });
  }

  // start the timer function
  void start() {
    started = true;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      int localSeconds = seconds + 1;
      int localMinutes = minutes;
      int localHours = hours;

      if (localSeconds > 59) {
        if (localMinutes > 59) {
          localHours++;
          localMinutes = 0;
        } else {
          localMinutes++;
          localSeconds = 0;
        }
      }
      setState(() {
        seconds = localSeconds;
        minutes = localMinutes;
        hours = localHours;
        digitSeconds = (seconds >= 10) ? "$seconds" : "0$seconds";
        digitHours = (hours >= 10) ? "$hours" : "0$hours";
        digitMinutes = (minutes >= 10) ? "$minutes" : "0$minutes";
      });
    });
  }

  // builds ui as...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(64, 46, 50, 1),

        // log out, settings
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(64, 46, 50, 1),
          actions: [
            IconButton(onPressed: signUserOut, icon: Icon(Icons.logout)),
          ],
          leading: IconButton(onPressed: () {}, icon: Icon(Icons.settings)),
        ),
        body: SafeArea(
            child: Center(
          child: SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Clock in title
              Text((!started) ? 'Clock in' : 'Clock out',
                  style: TextStyle(
                    color: Color.fromRGBO(250, 195, 32, 1),
                    fontSize: 40,
                  )),

              SizedBox(height: 20),

              // Current location display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.place_rounded,
                    color: Colors.white,
                  ),
                  Flexible(
                    child: Column(children: [
                      Text(
                        _currentAddress.isNotEmpty
                            ? _currentAddress
                            : 'unknown',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.fade,
                      ),
                    ]),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Timer display
              Text('$digitHours:$digitMinutes:$digitSeconds',
                  style: TextStyle(
                    color: Color.fromRGBO(250, 195, 32, 1),
                    fontSize: 60,
                  )),

              // clock in button
              ElevatedButton(
                  onPressed: () async {
                    _currentLocation = await _getCurrentLocation();
                    await _getAddressFromCoordinates();

                    print('$_currentLocation');
                    print(_currentAddress);

                    (!started) ? start() : stop();
                  },
                  style: ElevatedButton.styleFrom(
                      textStyle: TextStyle(
                        fontSize: 50,
                      ),
                      backgroundColor: (!started)
                          ? Color.fromRGBO(250, 195, 32, 1)
                          : Color.fromRGBO(64, 46, 50, 1),
                      foregroundColor: (!started)
                          ? Color.fromRGBO(64, 46, 50, 1)
                          : Color.fromRGBO(250, 195, 32, 1),
                      fixedSize: Size.fromRadius(100),
                      shape: CircleBorder(),
                      shadowColor: Colors.black,
                      elevation: 10.0,
                      side: BorderSide(
                        color: Color.fromRGBO(164, 142, 101, 1),
                        width: 10.0,
                      )),
                  child: Text((!started) ? 'Start' : 'Stop')),

              SizedBox(height: 10),
              // cancel the timer
              TextButton(
                  onPressed: () {
                    (started) ? reset() : null;
                  },
                  style: TextButton.styleFrom(
                    disabledForegroundColor: Colors.grey,
                    foregroundColor: (!started)
                        ? Color.fromRGBO(64, 46, 50, 1)
                        : Color.fromRGBO(250, 195, 32, 1),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16.0),
                  )),

              // total hours worked card
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 160.0,
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 73, 53, 57),
                      borderRadius: BorderRadius.circular(10.0)),
                  //list of shifts
                  child: ListView.builder(
                    itemCount: shifts.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Shift# ${index + 1}",
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 16.0,
                              ),
                            ),
                            Text(
                              "${shifts[index]}",
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Bottom Nav Bar with three buttons:
              // 1. User details
              // 2. add shift (manual entry)
              // 3. send timesheet
            ],
          )),
        )));
  }
}
