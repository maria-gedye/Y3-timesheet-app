import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:timesheet_app/components/work_shift.dart';
import 'package:provider/provider.dart';
import 'package:timesheet_app/data/shift_data.dart';
import 'package:timesheet_app/models/shift_item.dart';

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
  String _currentAddress = '', _currentDuration = '';

// timer variables
  int seconds = 0, minutes = 0, hours = 0;
  String digitSeconds = "00", digitMinutes = "00", digitHours = "00";
  Timer? timer;
  bool started = false;
  List shifts = [];
  int currentPageIndex = 0;

  // add shift dialog variables
  final newPlaceController = TextEditingController();
  final newAddressController = TextEditingController();
  final newDateController = TextEditingController();
  final newStartTimeController = TextEditingController();
  final newEndTimeController = TextEditingController();
  late DateTime pickedDate;
  String startTime = '', endTime = '';
  TimeOfDay thisTime = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay startTimeDialog = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay endTimeDialog = TimeOfDay(hour: 0, minute: 0);

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

  // methods for timer(5)
  void stopTimer() {
    timer!.cancel();
    TimeOfDay now = TimeOfDay.now();
    DateTime today = DateTime.now();

    setState(() {
      started = false;
      timerDuration();
      endTime =
          '${now.hour}:${now.minute} ${now.period.name}'; // get endTime str from now
      saveTracker(today);
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
    String shift = "$digitHours:$digitMinutes:$digitSeconds";
    setState(() {
      if (shift != "00:00:00") {
        shifts.add(shift); // SWAP out when you make the shift tiles
        _currentDuration = shift;
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

  // put info into new shift object then save to list
  void saveTracker(DateTime currentDate) {
    // create shift_item object via timetracker
    ShiftItem newShift = ShiftItem(
        placeName: "open dialog for user to type place",
        address: _currentAddress,
        startTime: startTime,
        endTime: endTime,
        workedTime: _currentDuration,
        dateTime: currentDate);
    // add new shift from shift_data.dart
    Provider.of<ShiftData>(context, listen: false).addNewShift(newShift);
  }

  // add shift dialog functions(5)
  void addShiftDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Add shift manually'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // place name
                    TextField(
                      controller: newPlaceController,
                      decoration:
                          const InputDecoration(labelText: 'Place Name'),
                    ),

                    // address (optional)
                    TextField(
                      controller: newAddressController,
                      decoration: const InputDecoration(
                          labelText: 'Address (optional)'),
                    ),

                    // date picker
                    TextField(
                      controller: newDateController,
                      decoration:
                          const InputDecoration(labelText: 'Select date'),
                      readOnly: true,
                      onTap: () {
                        _selectDate();
                      },
                    ),

                    // start time - time picker
                    TextField(
                      controller: newStartTimeController,
                      readOnly: true,
                      decoration:
                          const InputDecoration(labelText: 'Start Time'),
                      onTap: () => {
                        _selectTime(newStartTimeController),
                        startTimeDialog = thisTime
                      },
                    ),

                    // end time time picker
                    TextField(
                      controller: newEndTimeController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'End Time'),
                      onTap: () => {
                        _selectTime(newEndTimeController),
                        endTimeDialog = thisTime
                      },
                    ),

                    SizedBox(height: 5),
                  ],
                ),
              ),
              actions: [
                // save button
                MaterialButton(
                  onPressed: () {
                    saveDialog(pickedDate);
                  },
                  child: const Text('Save'),
                ),
                // cancel button
                MaterialButton(
                  onPressed: cancel,
                  child: const Text('Cancel'),
                ),
              ],
            ));
  }

  // datepicker method
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now()); // they can't select date in future

    if (picked != null) {
      setState(() {
        pickedDate = picked;
        newDateController.text = picked.toString().split(" ")[0];
      });
    }
  }

  // timepicker method
  Future<void> _selectTime(final controller) async {
    final TimeOfDay? getTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dialOnly,
    );

    if (getTime != null) {
      setState(() {
        String newTimeText =
            "${getTime.hour}:${getTime.minute} ${getTime.period.name}";
        controller.text = newTimeText;
      });

      thisTime = getTime;
    }
  }

  // cancel the dialog
  void cancel() {
    Navigator.pop(context);
  }

  // calculate duration between two user input times
  TimeOfDay calculateTimeDuration(TimeOfDay startTime, TimeOfDay endTime) {
    int startMinutes = startTime.hour * 60 + startTime.minute;
    int endMinutes = endTime.hour * 60 + endTime.minute;
    int durationInMinutes = (endMinutes - startMinutes).abs();

    int hours = durationInMinutes ~/ 60;
    int minutes = durationInMinutes % 60;

    return TimeOfDay(hour: hours, minute: minutes);
  }

  // put info into new shift object then save to list
  void saveDialog(DateTime newDate) {
    // find difference between two timeOfDay objects
    TimeOfDay duration = calculateTimeDuration(startTimeDialog, endTimeDialog);
    String workedTime = '${duration.hour}hrs ${duration.minute}min';

    // create shift_item object via dialog
    ShiftItem newShift = ShiftItem(
        placeName: newPlaceController.text,
        address: newAddressController.text,
        startTime: startTime,
        endTime: endTime,
        workedTime: workedTime,
        dateTime: newDate);
    // add new shift from shift_data.dart
    Provider.of<ShiftData>(context, listen: false).addNewShift(newShift);

    Navigator.pop(context);
  }

  // builds ui as...
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: 1,
        length: 3,
        child: Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: addShiftDialog,
              child: const Icon(Icons.add),
            ),
            backgroundColor: Color.fromRGBO(64, 46, 50, 1),
            appBar: AppBar(
              title: const Text('Timesheet Tracker'),
              backgroundColor: Color.fromRGBO(64, 46, 50, 1),
              actions: [
                IconButton(onPressed: signUserOut, icon: Icon(Icons.logout)),
              ],
              bottom: const TabBar(
                tabs: <Widget>[
                  Tab(
                    icon: Icon(Icons.person_2_outlined,
                        color: Color.fromRGBO(250, 195, 32, 1), size: 30),
                  ),
                  Tab(
                    icon: Icon(
                      Icons.punch_clock,
                      color: Color.fromRGBO(250, 195, 32, 1),
                      size: 40.0,
                    ),
                  ),
                  Tab(
                    icon: Icon(Icons.document_scanner_outlined,
                        color: Color.fromRGBO(250, 195, 32, 1), size: 30),
                  ),
                ],
              ),
            ),

            // main body
            body: SafeArea(
              child: TabBarView(children: <Widget>[
                // access to firebase firestore
                Expanded(
                    child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("User Shifts")
                      .orderBy("Timestamp", descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      // TODO: somehow bring this RETURN block into third tab...
                      return ListView.builder(
                        itemCount: 0,
                        itemBuilder: (context, index) {
                          // get the shift_item from db
                          final shift = snapshot.data!.docs[index];
                          return WorkShift(
                              date: shift['DateTime'],
                              duration: shift['WorkedTime'],
                              place: shift['PlaceName']);
                        },
                      );
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

                // user tab
                Center(
                  child: Text("user page"),
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

                            print('$_currentLocation');
                            print(_currentAddress);

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

                      // total hours worked card
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          height: 160.0,
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 73, 53, 57),
                              borderRadius: BorderRadius.circular(10.0)),
                          // simple view list of shifts
                          child: ListView.builder(
                            itemCount: shifts.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "StartDate, PlaceName",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    Text(
                                      "${shifts[index]}",
                                      style: const TextStyle(
                                        color: Colors.white,
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
                    ],
                  )),
                ),
                // timesheet tab
                Center(
                  child: Text("shift tiles, bar graph, trigger email"),
                ),
              ]),
            )));
  }
}
