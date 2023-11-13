import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timesheet_app/components/shift_tile.dart';
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
  String place = '';

  // add shift dialog variables
  final newPlaceController = TextEditingController();
  final newAddressController = TextEditingController();
  final newDateController = TextEditingController();
  final newStartTimeController = TextEditingController();
  final newEndTimeController = TextEditingController();
  late DateTime pickedDate = DateTime(2023, 0, 0, 0, 0);
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

  // user to enter place name when stopping timer
  void showPlaceDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Enter Place'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: newPlaceController,
                      decoration:
                          const InputDecoration(labelText: 'Place Name'),
                    ),
                  ],
                ),
              ),
              actions: [
                // save dialog
                MaterialButton(
                  onPressed: () {
                    savePlaceDialog();
                  },
                  child: const Text('Save'),
                ),
                //cancel dialog
                MaterialButton(
                  onPressed: cancel,
                  child: const Text('Cancel'),
                ),
              ],
            ));

    Navigator.pop(context);
  }

  void savePlaceDialog() {
    place = newPlaceController.text;
  }

  // put info into new shift object then save to list
  void saveTracker() {
    // create shift_item object via timetracker
    ShiftItem newShift = ShiftItem(
      placeName: place,
      address: _currentAddress,
      startTime: startTime,
      endTime: endTime,
      workedTime: _currentDuration,
      dateTime: DateTime.now(),
    );
    // add new shift from shift_data.dart
    Provider.of<ShiftData>(context, listen: false).addNewShift(newShift);
  }

  // add shift dialog functions(5)
  void addShiftDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Add Shift'),
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
                      },
                    ),

                    // end time time picker
                    TextField(
                      controller: newEndTimeController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'End Time'),
                      onTap: () => {
                        _selectTime(newEndTimeController),
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

  // timepicker method -- needs to also store start/end times to calc duration
  Future<void> _selectTime(final controller) async {
    final TimeOfDay? getTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
    );

    if (getTime != null) {
      if (startTimeDialog != TimeOfDay(hour: 0, minute: 0)) {
        setState(() {
          endTimeDialog = getTime;
          String newTimeText =
              "${getTime.hour}:${getTime.minute} ${getTime.period.name}";
          controller.text = newTimeText;
        });

      } else {
        setState(() {
          startTimeDialog = getTime;
          String newTimeText =
              "${getTime.hour}:${getTime.minute} ${getTime.period.name}";
          controller.text = newTimeText;
        });
      }
    }
  }

  // clear the controllers (for dialog)
  void clear() {
    newAddressController.clear();
    newDateController.clear();
    newEndTimeController.clear();
    newStartTimeController.clear();
    newPlaceController.clear();
  }

  // cancel the dialog
  void cancel() {
    Navigator.pop(context);
    clear();
  }

  // calculate duration between two user input times
  TimeOfDay calculateTimeDuration(TimeOfDay startTime, TimeOfDay endTime) {
    int startMinutes = startTime.hourOfPeriod * 60 + startTime.minute;
    int endMinutes = endTime.hourOfPeriod * 60 + endTime.minute;
    int durationInMinutes = (endMinutes - startMinutes).abs();

    int hours = durationInMinutes ~/ 60;
    int minutes = durationInMinutes % 60;

    return TimeOfDay(hour: hours, minute: minutes);
  }

  // put info into new shift object then save to list
  void saveDialog(DateTime newDate) {
    // find difference between two timeOfDay objects
    print(
        'start time before calculation: $startTimeDialog end time before calc: $endTimeDialog');

    TimeOfDay duration = calculateTimeDuration(startTimeDialog, endTimeDialog);
    String workedTime = '${duration.hour}hrs ${duration.minute}min';

    // create shift_item object via dialog
    ShiftItem newShift = ShiftItem(
        placeName: newPlaceController.text,
        address: newAddressController.text,
        startTime: newStartTimeController.text,
        endTime: newEndTimeController.text,
        workedTime: workedTime,
        dateTime: newDate);
    // add new shift from shift_data.dart
    Provider.of<ShiftData>(context, listen: false).addNewShift(newShift);

    print(
        'start: ${newShift.startTime}, end: ${newShift.endTime}, total: ${newShift.workedTime}');

    Navigator.pop(context);
    clear();
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
                title: const Text('Shift Tracker'),
                backgroundColor: Color.fromRGBO(64, 46, 50, 1),
                actions: [
                  IconButton(onPressed: signUserOut, icon: Icon(Icons.logout)),
                ],
                bottom: const TabBar(
                  tabs: <Widget>[
                    Tab(
                      icon: Icon(Icons.person_2_rounded,
                          color: Colors.white, size: 30),
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
                          color: Colors.white, size: 30),
                    ),
                  ],
                ),
              ),

              // main body
              body: SafeArea(
                child: TabBarView(children: <Widget>[
                  // access to firebase firestore
                  /*  Expanded(
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
                  )), */

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
                              //print(_currentAddress);

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
                        /* TextButton(
                          onPressed: showPlaceDialog(context),
                          style: TextButton.styleFrom(
                              disabledForegroundColor: Colors.grey,
                              foregroundColor: (!started)
                                  ? Color.fromRGBO(64, 46, 50, 1)
                                  : Color.fromRGBO(250, 195, 32, 1),
                            ),
                          child: Text('Add Place Name')
                          ),
 */
                        SizedBox(height: 10),

                        // total hours worked card
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            height: 160.0,
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 73, 53, 57),
                                borderRadius: BorderRadius.circular(10.0)),

                            // simple view list of last 5 shifts
                            child: ListView.builder(
                              reverse: true,
                              itemCount: value.getAllShifts().length < 5
                                  ? value.getAllShifts().length
                                  : 5,
                              itemBuilder: (context, index) => ShiftTile(
                                  placeName:
                                      value.getAllShifts()[index].placeName,
                                  dateTime:
                                      value.getAllShifts()[index].dateTime,
                                  workedTime:
                                      value.getAllShifts()[index].workedTime),
                            ),
                          ),
                        ),
                      ],
                    )),
                  ),
                  // WOrkbook tab
                  Center(
                    child: Text("shift tiles, bar graph, trigger email"),
                  ),
                ]),
              ))),
    );
  }
}
