import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timesheet_app/components/my_textfield.dart';
import 'dart:async';

import 'package:provider/provider.dart';
import 'package:timesheet_app/data/work_data.dart';
import 'package:timesheet_app/models/work_item.dart';

class WorkTracker extends StatefulWidget {
  const WorkTracker({super.key});

  @override
  State<WorkTracker> createState() => _WorkTrackerState();
}

class _WorkTrackerState extends State<WorkTracker> {
  final user = FirebaseAuth.instance.currentUser!;
  int seconds = 0, minutes = 0, hours = 0;
  String digitSeconds = "00", digitMinutes = "00", digitHours = "00";
  Timer? timer;
  bool started = false;
  List works = [];
  int currentPageIndex = 0;
  String endTime = '', startTime = '';
  Position? _currentLocation;
  late bool servicePermission = false;
  late LocationPermission permission;
  String _currentAddress = '', _currentDuration = '';
  final newPlaceController = TextEditingController();

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
        _currentAddress = "${place.street}, ${place.subLocality}";
      });
    } catch (e) {
      debugPrint('$e');
    }
  }

  // methods for timer(5)
  void stopTimer() {
    timer!.cancel();
    TimeOfDay now = TimeOfDay.now();

    setState(() {

      started = false;
      timerDuration();
      endTime =
          '${now.hour}:${now.minute} ${now.period.name}'; // get endTime str from now

      openPlaceDialog(); 
      
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

// use this function to fill out workedTime property to be passed to new Work objects
  void timerDuration() {
    String workTime = "${digitHours}hrs ${digitMinutes}min";
    setState(() {
      if (minutes > 0) {
        // add this duration to new Work obj's workedTime property via this global variable
        _currentDuration = workTime;
      }

      reset();
    });
  }

  // DO LATER make a seperate timer widget
  void startTimer() {
    started = true;
    TimeOfDay now = TimeOfDay.now();
    startTime = '${now.hour}:${now.minute} ${now.period.name}';

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

  // put info into new Work object then save to overallWorkList []
  void saveTracker(String place) {
    String newID =
        Provider.of<WorkData>(context, listen: false).generateRandomId();
    
    // create Work_item object via timetracker
    WorkItem newWork = WorkItem(
        uniqueID: newID,
        placeName: place,
        address: _currentAddress,
        startTime: startTime,
        endTime: endTime,
        workedTime: _currentDuration,
        dateString: DateTime.now().toString(),
        dateTime: DateTime.now());

    // add newWork to overallWorkList []
    Provider.of<WorkData>(context, listen: false).addNewWork(newWork);
    print("manual Work added to overallWorkList []");

    sendWorkToDB(newWork); // saves new obj to firebase
  }

  // user to enter place name before stopping timer
  void openPlaceDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Enter Place'),
              backgroundColor: Color.fromRGBO(250, 195, 32, 1),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyTextField(
                        controller: newPlaceController,
                        hintText: 'Place Name',
                        obscureText: false)
                  ],
                ),
              ),
              actions: [
                // save dialog
                MaterialButton(
                  onPressed: () {
                    // saveTracker here
                    saveTracker(newPlaceController.text);

                    Navigator.pop(context);
                    clearController(newPlaceController);
                  },
                  child: const Text('Save'),
                ),
                //cancel dialog
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    clearController(newPlaceController);
                    _currentAddress = '';
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ));
  }

  void clearController(TextEditingController a) {
    a.clear();
  }

  // sends Work item from list to firebase DB (also used in Work_dialog.dart)
  void sendWorkToDB(WorkItem newWork) {
    if (newWork.startTime.isNotEmpty && newWork.endTime.isNotEmpty) {
      // store in firebase
      FirebaseFirestore.instance.collection("${user.email}").add({
        'PlaceName': newWork.placeName,
        'StartTime': newWork.startTime,
        'EndTime': newWork.endTime,
        'WorkedTime': newWork.workedTime,
        'DateTime': newWork.dateTime,
        'UniqueID': newWork.uniqueID,
        'Address': newWork.address,
        'DateString': newWork.dateString
        // Add the address
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Clock in title
      Text((!started) ? 'Clock in' : 'Clock out',
          style: TextStyle(
            color: Color.fromRGBO(250, 195, 32, 1),
            fontSize: 30,
          )),

      SizedBox(height: 10),

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
                _currentAddress.isNotEmpty ? _currentAddress : 'unknown',
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

      // Timer display
      Text('$digitHours:$digitMinutes:$digitSeconds',
          style: TextStyle(
            color: Color.fromRGBO(250, 195, 32, 1),
            fontSize: 60,
          )),

      SizedBox(height: 10),

      // clock in button
      ElevatedButton(
          onPressed: () async {
            _currentLocation = await _getCurrentLocation();
            await _getAddressFromCoordinates();

            (!started) ? startTimer() : stopTimer();
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
    ]);
  }
}
