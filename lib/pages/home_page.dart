import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timesheet_app/components/timer_button.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

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
  bool showStartButton = true;
  ButtonStyle style = ElevatedButton.styleFrom(
        textStyle: TextStyle(
          fontSize: 50,
        ),
        backgroundColor: Color.fromRGBO(250, 195, 32, 1),
        foregroundColor: Color.fromRGBO(64, 46, 50, 1),
        fixedSize: Size.fromRadius(100),
        shape: CircleBorder(),
        shadowColor: Colors.black,
        elevation: 10.0,
        side: BorderSide(
          color: Color.fromRGBO(164, 142, 101, 1),
          width: 10.0,
        )
        );

// state methods...

  //sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  // toggle between start and stop buttons
  void toggleStartStop() {
    setState(() {
      showStartButton = !showStartButton;
    });
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

  // builds ui as...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(64, 46, 50, 1),

        // log out
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
              Text('Clock in',
                  style: TextStyle(
                    color: Color.fromRGBO(250, 195, 32, 1),
                    fontSize: 40,
                  )),

              SizedBox(height: 20),

              // Timer display
              Text('0:00:00',
                  style: TextStyle(
                    color: Color.fromRGBO(250, 195, 32, 1),
                    fontSize: 60,
                  )),

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
                        _currentAddress, 
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

              // clock in button
              ElevatedButton(
                  onPressed: () async {
                    _currentLocation = await _getCurrentLocation();
                    await _getAddressFromCoordinates();
                    print('$_currentLocation');
                    print(_currentAddress);
                    // change to new state                    
                  },
                  style: style,  
                  child: Text('button'))

              // total hours worked card

              // Bottom Nav Bar with three buttons
              // User button
              // add shift button
              // time log? timesheet?
            ],
          )),
        )));
  }
}
