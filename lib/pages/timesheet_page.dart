import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timesheet_app/components/my_button.dart';
import 'package:timesheet_app/models/timesheet_item.dart';
import 'package:timesheet_app/components/timesheet_tile.dart';

import 'package:timesheet_app/models/work_item.dart';
import 'package:timesheet_app/providers/database_provider.dart';
import 'package:provider/provider.dart';
import 'package:timesheet_app/data/work_data.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TimesheetPage extends StatefulWidget {
  const TimesheetPage({Key? key}) : super(key: key);

  @override
  State<TimesheetPage> createState() => _TimesheetPageState();
}

class _TimesheetPageState extends State<TimesheetPage> {
  final DatabaseProvider _databaseProvider = DatabaseProvider();
  final user = FirebaseAuth.instance.currentUser!;
  final userID = FirebaseAuth.instance.currentUser?.uid;

  List<bool> _isSelected = [];
  Set<WorkItem> selectedWorkItems = {};
  int hours = 0, minutes = 0;
  double newTotal = 0;

  double convertWorkedTimeToHours(WorkItem workItem) {
    String timeString = workItem.workedTime;

    // Use a regular expression to match hours and minutes
    RegExp regex = RegExp(r"^(\d+)hrs (\d+)min");
    Match? match = regex.firstMatch(timeString);

    if (match != null) {
      String hoursString = match.group(1)!;
      String minutesString = match.group(2)!;
      double hours = double.parse(hoursString);
      double minutes = double.parse(minutesString);

      // Convert total time to hours (considering minutes as fractions)
      double totalHours = hours + minutes / 60.0;

      // Shorten the decimal value to one digit
      return double.parse(totalHours.toStringAsFixed(1));
    } else {
      // Handle invalid format
      print("Invalid time format: $timeString");
      return 0.0;
    }
  }

  createTimesheet(Set<WorkItem> objects) async {
    // convert set to a list
    List<WorkItem> workList = objects.toList();
    // create instance of timesheet object
    TimesheetItem newTimesheet = TimesheetItem(
        uniqueID: await Provider.of<WorkData>(context, listen: false)
            .generateCounterID(userID),
        workItems: workList,
        weekStarting:
            Provider.of<WorkData>(context, listen: false).startOfWeekDate(),
        totalTime: newTotal);

    try {
      // access firestore collection
      CollectionReference collectionRef =
          FirebaseFirestore.instance.collection('${user.email}');

      DocumentReference timesheetDocRef = collectionRef.doc('timesheets');

      // reference to the subcollection
      CollectionReference timesheetsCollection =
          timesheetDocRef.collection('timesheetItems');

// create new document for firestore
      Map<String, dynamic> timesheetData = {
        'uniqueID': newTimesheet.uniqueID,
        'workItems':
            newTimesheet.workItems.map((item) => item.toMap()).toList(),
        'weekStarting': newTimesheet.weekStarting,
        'totalTime': newTimesheet.totalTime
      };

      timesheetsCollection.add(timesheetData).then((_) => {
            print('Timesheet added successfully!'),
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Timesheet Saved!'),
                content:
                    Text('Your timesheet data has been saved successfully.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
                backgroundColor: Color.fromRGBO(250, 195, 32, 1),
              ),
            )
          });
    } catch (error) {
      print('Error adding document: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WorkItem>>(
      stream: _databaseProvider.weeklyWorkItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show loading indicator
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
// Retrieve a list of current week's workItems
          final filteredWorkItems = snapshot.data!;

// allow for seperate checkbox values
          // Initialize _isSelected only when data is received
          if (_isSelected.length != filteredWorkItems.length) {
            _isSelected =
                List.generate(filteredWorkItems.length, (index) => false);
          }

          return DefaultTabController(
            length: 2,
            // initialIndex: 1,
            child: Scaffold(
              backgroundColor: Color.fromRGBO(64, 46, 50, 1),
              appBar: AppBar(
                title: const Text('Timesheets'),
                backgroundColor: Color.fromRGBO(54, 40, 43, 1),
                bottom: const TabBar(
                  tabs: <Widget>[
                    Tab(
                      text: 'Create',
                    ),
                    Tab(text: 'All'),
                  ],
                ),
              ),
              body: TabBarView(children: <Widget>[
                // create timesheet tab
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Select items to add to your timesheet:",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      // show workItems in a Listview with a checkbox next to each item
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredWorkItems.length,
                          itemBuilder: (context, index) {
                            String shortDate = filteredWorkItems[index]
                                .dateString
                                .substring(0, 10);
                            return ListTile(
                              leading: Checkbox(
                                value: _isSelected[index],
                                hoverColor: Color.fromRGBO(250, 195, 32, 1),
                                activeColor: Color.fromRGBO(250, 195, 32, 1),
                                onChanged: (newValue) {
                                  setState(() {
                                    _isSelected[index] = newValue!;

                                    if (newValue) {
                                      // get an item's workedTime String and convert to a number
                                      double workedTime =
                                          convertWorkedTimeToHours(
                                              filteredWorkItems[index]);
                                      newTotal += workedTime;

                                      // if it doesn't already exist in selectedWorkItems
                                      if (!selectedWorkItems
                                          .contains(filteredWorkItems[index])) {
                                        selectedWorkItems
                                            .add(filteredWorkItems[index]);
                                      }
                                    } else {
                                      // get an item's workedTime String and convert to a number
                                      double workedTime =
                                          convertWorkedTimeToHours(
                                              filteredWorkItems[index]);
                                      newTotal = newTotal - workedTime;
                                      // uses custom == operator within contains
                                      if (selectedWorkItems
                                          .contains(filteredWorkItems[index])) {
                                        print('does contain matching object');
                                        selectedWorkItems
                                            .remove(filteredWorkItems[index]);
                                      }
                                    }
                                  });
                                },
                              ),
                              textColor: Colors.white,
                              title: Text(filteredWorkItems[index].placeName),
                              subtitle: Text(
                                  "$shortDate    Total: ${filteredWorkItems[index].workedTime}"),
                            );
                          },
                        ),
                      ),

                      // Display total hours from user's selection
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(164, 142, 101, 1),
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Total hours this week: $newTotal",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            // save button creates a TimesheetItem object and sends to firestore
                            MyButton(
                              onTap: () {
                                createTimesheet(selectedWorkItems);
                              },
                              text: 'Create Timesheet',
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // all timesheets tab
                Center(
                  child: StreamBuilder<List<TimesheetItem>>(
                    stream: _databaseProvider.timesheetItems,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        print(
                            "data: ${snapshot.data}  and the error is: ${snapshot.error}");
                        return Text('Boo-Error: ${snapshot.error}');
                      }

                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }

                      final timesheetList = snapshot.data!;
                      // Display the list of timesheet items (e.g., in a ListView)
                      return ListView.builder(
                        itemCount: timesheetList.length,
                        itemBuilder: (context, index) {
                          final timesheetItem = timesheetList[index];
                          // timesheet date and ID
                          return TimesheetTile(
                            // make uniqueID => timesheet name
                            uniqueID: timesheetItem.uniqueID,
                            weekStarting: timesheetItem.weekStarting.toString(),
                            timesheet: timesheetItem,
                          );
                        },
                      );
                    },
                  ),
                )
              ]),
            ),
          );
        }
      },
    );
  }
}
