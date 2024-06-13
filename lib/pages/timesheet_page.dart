import 'package:flutter/material.dart';

import 'package:timesheet_app/models/work_item.dart';
import 'package:timesheet_app/providers/database_provider.dart';
import 'package:timesheet_app/components/work_tile.dart';

class TimesheetPage extends StatefulWidget {
  const TimesheetPage({Key? key}) : super(key: key);

  @override
  State<TimesheetPage> createState() => _TimesheetPageState();
}

class _TimesheetPageState extends State<TimesheetPage> {
  final DatabaseProvider _databaseProvider = DatabaseProvider();
  List<bool> _isSelected = [];

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
          int hours, minutes;

// allow for seperate checkbox values
        // Initialize _isSelected only when data is received
          if (_isSelected.length != filteredWorkItems.length) {
            _isSelected = List.generate(filteredWorkItems.length, (index) => false);
          }

// mapping snapshot.data to convert and sum all the filtered workedTimes in each WorkItem object
          double weeklyTotal = filteredWorkItems.fold(0.0, (sum, item) {
            String timeString = item.workedTime; // 9hrs 30min

            // convert workedTime from string into double using RegEx
            RegExp regex = RegExp(
                r"^(\d+)hrs (\d+)min"); // Match digits followed by "hrs" and "min"

            Match? match = regex.firstMatch(timeString);
            double workedHours;

            if (match != null) {
              String hoursString = match.group(1)!;
              String minutesString = match.group(2)!;
              hours = int.parse(hoursString);
              minutes = int.parse(minutesString);
              // Convert total time to hours (considering minutes as fractions of hours)
              workedHours = hours + minutes / 60.0;
            } else {
              // Handle invalid format (e.g., only "hrs")
              print("Invalid time format: $timeString");
              hours = 0; // Or provide a default value
              minutes = 0;
              workedHours = 0;
            }

            return sum + workedHours;
          });

          return Scaffold(
            backgroundColor: Color.fromRGBO(64, 46, 50, 1),
            appBar: AppBar(
              // could add another tab menu here- 1> new timesheet 2> timesheets
              title: const Text('Create Timesheet'),
              backgroundColor: Color.fromRGBO(54, 40, 43, 1),
            ),
            body: Center(
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
                        return ListTile(
                          leading: Checkbox(
                            value: _isSelected[index],
                            activeColor: Color.fromRGBO(250, 195, 32, 1),
                            onChanged: (newValue) {
                              setState(() {
                                _isSelected[index] = newValue!;
                              });
                            },
                          ),
                          textColor: Colors.white,
                          title: Text(filteredWorkItems[index].placeName),
                          // subtitle: Text("$shortDate    Total: ${filteredWorkItems[index].workedTime}"),
                        );

                        // return WorkTileForTimesheetPage(
                        //   uniqueID: filteredWorkItems[index].uniqueID,
                        //   placeName: filteredWorkItems[index].placeName,
                        //   workedTime: filteredWorkItems[index].workedTime,
                        //   workDate: filteredWorkItems[index].dateString,
                        // );
                      },
                    ),
                  ),

                  // Display total hours from user's selection
                  // Text(
                  //     "Hours worked this week: $weeklyTotal",
                  //     style: TextStyle(color: Colors.white, fontSize: 20),
                  //   ),

                  // save button creates a TimesheetItem object and sends to firestore
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
