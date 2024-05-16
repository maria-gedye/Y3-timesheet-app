import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timesheet_app/components/my_textfield.dart';
import 'package:timesheet_app/components/work_tile.dart';
import 'package:timesheet_app/components/work_dialog.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:timesheet_app/data/work_data.dart';
import 'package:timesheet_app/models/work_item.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
// state variables...
  Position? _currentLocation;
  late bool servicePermission = false;
  late LocationPermission permission;
  String _currentAddress = '', _currentDuration = '';
  String titleOfTab = 'Work Tracker';
  final newPlaceController = TextEditingController();

// timer variables
  int seconds = 0, minutes = 0, hours = 0;
  String digitSeconds = "00", digitMinutes = "00", digitHours = "00";
  Timer? timer;
  bool started = false;
  List works = [];
  int currentPageIndex = 0;
  String placeNameStr = 'Add place name';
  String endTime = '', startTime = '';

  final user = FirebaseAuth.instance.currentUser!;

  //sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  // for the bar chart
  // List<charts.Series<WorkItem, String>> _seriesBarData =
  //     []; // holds bar series data
  // List<WorkItem> fsData = []; // holds firestore data
  // _generateData(fsData) {
  //   //so here we use the charts add method:
  //   _seriesBarData.add(charts.Series(
  //           domainFn: (WorkItem workItem, _) =>
  //               workItem.dateTime.toString(), // x axis (date)
  //           measureFn: (WorkItem workItem, _) =>
  //               int.parse(workItem.workedTime), // y axis (worked hours)
  //           id: 'Total Weekly Hours',
  //           data: fsData) // end of chart.Series
  //       ); // end of add()
  // } // end of generateData

  // Widget _buildBody(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
  //   // return StreamBuilder<QuerySnapshot>(
  //   //     stream:
  //   //         FirebaseFirestore.instance.collection('${user.email}').snapshots(),
  //   //     builder: (context, snapshot) {
  //         if (!snapshot.hasData) {
  //           print('no data found for this user');
  //           return LinearProgressIndicator();
  //         } else {
  //           List<WorkItem> workItems = snapshot.data!.docs
  //               .map((documentSnapshot) => WorkItem.fromMap(
  //                   documentSnapshot.data()))
  //               .toList();
  //           return _buildChart(context, workItems);
  //         }
  //       // });
  // }

  // Widget _buildChart(BuildContext context, List<WorkItem> workItem) {
  //   fsData = workItem;
  //   _generateData(fsData);
  //   return Expanded(child: charts.BarChart(_seriesBarData)); // end of expanded
  // } // end of _buildChart

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

// use this function to fill out workedTime property to be passed to new Work objects
  void timerDuration() {
    String workTime = "$digitHours hrs $digitMinutes min";
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
  void saveTracker() {
    String newID =
        Provider.of<WorkData>(context, listen: false).generateRandomId();
    // create Work_item object via timetracker
    WorkItem newWork = WorkItem(
      uniqueID: newID,
      placeName: placeNameStr,
      address: _currentAddress,
      startTime: startTime,
      endTime: endTime,
      workedTime: _currentDuration,
      dateTime: DateTime.now().toString(),
    );

    // add newWork to overallWorkList []
    Provider.of<WorkData>(context, listen: false).addNewWork(newWork);
    print("manual Work added to overallWorkList []");

    sendWorkToDB(newWork); // saves new obj to firebase

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

// uses Work_dialog component
  void addWorkDialog() {
    showDialog(context: context, builder: (context) => WorkDialog());
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
        'Address': newWork.address
        // Add the address
      });
    }
  }

  // builds ui as...
  @override
  Widget build(BuildContext context) {
    return Consumer<WorkData>(builder: (context, value, child) {
      return DefaultTabController(
          length: 3,
          child: Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: addWorkDialog,
                backgroundColor: Color.fromRGBO(250, 195, 32, 1),
                child: const Icon(Icons.add),
              ),
              backgroundColor: Color.fromRGBO(64, 46, 50, 1),
              appBar: AppBar(
                // backlog change titles as user selects different tabs
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
                              // what should go here? Total number of weekly hours
                              // Number of records timesheeted or not timesheeted?
                              child: Text("Total hours worked this week"),
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
                            // BAR GRAPH
                            // _buildBody(snapshot);
                            // Work LIST
                            return ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                // get the doc entries from firestore
                                final doc = snapshot.data!.docs[index];

                                return WorkTile(
                                  uniqueID: doc['UniqueID'],
                                  placeName: doc['PlaceName'],
                                  workedTime: doc['WorkedTime'],
                                  // this needs reformatting somehow
                                  workDate: doc['DateTime'],
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
              )));
    });
  }
}
