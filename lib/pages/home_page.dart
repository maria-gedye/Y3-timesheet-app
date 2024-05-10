import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timesheet_app/components/my_textfield.dart';
import 'package:timesheet_app/components/shift_tile.dart';
import 'package:timesheet_app/components/shift_dialog.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:timesheet_app/data/shift_data.dart';
import 'package:timesheet_app/models/shift_item.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});
  //bool manualShift = false;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
// state variables...
  Position? _currentLocation;
  late bool servicePermission = false;
  late LocationPermission permission;
  String _currentAddress = '', _currentDuration = '';
  String titleOfTab = 'Shift Tracker';
  final newPlaceController = TextEditingController();

// timer variables
  int seconds = 0, minutes = 0, hours = 0;
  String digitSeconds = "00", digitMinutes = "00", digitHours = "00";
  Timer? timer;
  bool started = false;
  List shifts = [];
  int currentPageIndex = 0;
  String placeNameStr = 'Add place name';
  String endTime = '', startTime = '';

  // FAB Icons
  //List<IconData>? icons = const [Icons.add, Icons.document_scanner_rounded];
  //final int _selectedIndex = 1;
  final user = FirebaseAuth.instance.currentUser!;

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
      saveTracker();
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

// use this function to fill out workedTime property to be passed to new shift objects
  void timerDuration() {
    String shiftTime = "$digitHours hrs $digitMinutes min";
    setState(() {
      if (minutes > 0) {
        // add this duration to new shift obj's workedTime property via this global variable
        _currentDuration = shiftTime;
      }

      reset();
    });
  }

  // DO LATER put all this logic (except for setState) into timer dart file
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

  // put info into new shift object then save to overallShiftList []
  void saveTracker() {

    String newID =
        Provider.of<ShiftData>(context, listen: false).generateRandomId();
    // create shift_item object via timetracker
    ShiftItem newShift = ShiftItem(
      uniqueID: newID,
      placeName: placeNameStr,
      address: _currentAddress,
      startTime: startTime,
      endTime: endTime,
      workedTime: _currentDuration,
      dateTime: DateTime.now().toString(),
    );

    // add newShift to overallShiftList []
    Provider.of<ShiftData>(context, listen: false).addNewShift(newShift);
    print("manual shift added to overallShiftList []");

    sendShiftToDB(newShift); // saves new obj to firebase

    placeNameStr = 'Add place name';
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
                    placeNameStr = newPlaceController.text;
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
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ));
  }

  void clearController(TextEditingController a) {
    a.clear();
  }

// uses shift_dialog component
  void addShiftDialog() {
    showDialog(context: context, builder: (context) => ShiftDialog());
  }

  // sends shift item from list to firebase DB (also used in shift_dialog.dart)
  void sendShiftToDB(ShiftItem newShift) {
    if (newShift.startTime.isNotEmpty && newShift.endTime.isNotEmpty) {
      // store in firebase
      FirebaseFirestore.instance.collection("${user.email}").add({
        'PlaceName': newShift.placeName,
        'StartTime': newShift.startTime,
        'EndTime': newShift.endTime,
        'WorkedTime': newShift.workedTime,
        'DateTime': newShift.dateTime,
        'UniqueID': newShift.uniqueID
        // Add other properties for your Shift object
      });
    }
  }

  // builds ui as...
  @override
  Widget build(BuildContext context) {
    return Consumer<ShiftData>(
      builder: (context, value, child) => DefaultTabController(
          initialIndex: 1,
          length: 3,
          child: Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: addShiftDialog,
                backgroundColor: Color.fromRGBO(250, 195, 32, 1),
                child: const Icon(Icons.add),
              ),
              backgroundColor: Color.fromRGBO(64, 46, 50, 1),
              appBar: AppBar(
                // TODO: change titles as user selects different tabs
                title: Text(titleOfTab),
                backgroundColor: Color.fromRGBO(64, 46, 50, 1),
                bottom: const TabBar(
                  tabs: <Widget>[
                    Tab(
                      icon: Icon(Icons.person_2_rounded,
                          color: Color.fromRGBO(164, 142, 101, 1), size: 30),
                    ),
                    Tab(
                      icon: Icon(
                        Icons.punch_clock_rounded,
                        color: Color.fromRGBO(250, 195, 32, 1),
                        size: 40.0,
                      ),
                    ),
                    Tab(
                      icon: Icon(Icons.menu_book_rounded,
                          color: Color.fromRGBO(164, 142, 101, 1), size: 30),
                    ),
                  ],
                ),
              ),

              // main body
              body: SafeArea(
                child: TabBarView(children: <Widget>[
                  // user tab
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Logged in as ${user.email!}",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        SizedBox(height: 20),
                        IconButton(
                          onPressed: signUserOut,
                          icon: Icon(Icons.logout),
                          color: Colors.white,
                          iconSize: 30,
                        ),
                      ],
                    ),
                  ),
                  // tracker tab
                  Center(
                    child: SingleChildScrollView(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
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

                        // Button to add place name
                        TextButton(
                            onPressed: () {
                             (started) ? openPlaceDialog() : null;
                            },
                            style: TextButton.styleFrom(
                              disabledForegroundColor: Colors.grey,
                              foregroundColor: (!started)
                                  ? Color.fromRGBO(64, 46, 50, 1)
                                  : Colors.white,
                            ),
                            child: Text(placeNameStr)),

                        SizedBox(height: 10),

                        // total hours worked card
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            height: 160.0,
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 73, 53, 57),
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Align(
                              alignment: Alignment.topCenter,
                              // make simple view list of last 7 shifts
                            ),
                          ),
                        ),
                      ],
                    )),
                  ),
                  // WOrkbook tab
                  Center(
                    child: Column(children: [
                      Expanded(
                          child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("${user.email}")
                            .orderBy("DateTime", descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                // get the doc entries from firestore
                                final shift = snapshot.data!.docs[index];

                                return ShiftTile(
                                  uniqueID: shift['UniqueID'],
                                  placeName: shift['PlaceName'],
                                  workedTime: shift['WorkedTime'],
                                  // this needs reformatting somehow
                                  shiftDate: shift['DateTime'],
                                );
                              },
                            );
                            // check for any errors
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      )),
                    ]),
                  ),
                ]),
              ))),
    );
  }
}
