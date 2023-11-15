import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timesheet_app/components/shift_tile.dart';
import 'package:timesheet_app/components/_location_logic.dart';
import 'package:timesheet_app/components/_shift_dialog_logic.dart';
import 'package:timesheet_app/components/_timer_logic.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:timesheet_app/data/shift_data.dart';
import 'package:timesheet_app/models/shift_item.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
// state variables...
  final user = FirebaseAuth.instance.currentUser!;
  late LocationLogic locationLogic;
  String currentAddress = '';

// state methods(14+)
  @override
  void initState() {
    super.initState();
    locationLogic = LocationLogic(updateAddress);
  }

  void updateAddress(String address) {
    setState(() {
      currentAddress = address;
    });
  }

  //sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
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

  // user to enter place name when stopping timer
  void openPlaceDialog() {
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
                    Navigator.pop(context);
                    clear();
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

  }

  void savePlaceDialog() {
    place = newPlaceController.text;
  }

  // clear the controllers (for dialog)
  void clear() {
    newAddressController.clear();
    newDateController.clear();
    newEndTimeController.clear();
    newStartTimeController.clear();
    newPlaceController.clear();

    startTimeDialog = TimeOfDay(hour: 0, minute: 0);
    endTimeDialog = TimeOfDay(hour: 0, minute: 0);
  }

  // cancel the dialog
  void cancel() {
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Logged in as ${user.email!}", style: TextStyle(color: Colors.white, fontSize: 18),),
                        SizedBox(height: 20),
                        IconButton(onPressed: signUserOut, icon: Icon(Icons.logout), color: Colors.white, iconSize: 30,),
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
                        TextButton(
                            onPressed: () {
                              openPlaceDialog();
                            },
                            style: TextButton.styleFrom(
                              disabledForegroundColor: Colors.grey,
                              foregroundColor: (!started)
                                  ? Color.fromRGBO(64, 46, 50, 1)
                                  : Colors.white,
                              backgroundColor: (!started)
                                ? Color.fromRGBO(64, 46, 50, 1)
                                : Color.fromRGBO(164, 142, 101, 1),
                            ),
                            child: Text('Add Place Name')),

                        SizedBox(height: 10),

                        // total hours worked card
                        Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('This Week', 
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                alignment: Alignment.topCenter,
                                height: 120.0,
                                decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 73, 53, 57),
                                    borderRadius: BorderRadius.circular(10.0)),

                                // Todo: WEEKLY SUMMARY HERE
                                child: Text('weekly summary')
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                  ),

                  // WOrkbook tab, bar graph
                  Center(
                    child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Work History', 
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 10),

                              Container(
                                alignment: Alignment.topCenter,
                                height: 200,
                                decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 73, 53, 57),
                                    borderRadius: BorderRadius.circular(10.0)),

                                // all shifts
                                child: ListView.builder(
                                  reverse: true,
                                  itemCount: value.getAllShifts().length,
                                  itemBuilder: (context, index) => ShiftTile(
                                      placeName:
                                          value.getAllShifts()[index].placeName,
                                      dateTime:
                                          value.getAllShifts()[index].dateTime,
                                      workedTime:
                                          value.getAllShifts()[index].workedTime),
                                ),
                              ),
                            ],
                          ),
                        ),
                  ),
                ]),
              ))),
    );
  }
}
