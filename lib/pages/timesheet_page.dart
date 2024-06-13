import 'package:flutter/material.dart';

import 'package:timesheet_app/models/work_item.dart';
import 'package:timesheet_app/providers/database_provider.dart';

class TimesheetPage extends StatefulWidget {
  const TimesheetPage({Key? key}) : super(key: key);

  @override
  State<TimesheetPage> createState() => _TimesheetPageState();
}

class _TimesheetPageState extends State<TimesheetPage> {
  final DatabaseProvider _databaseProvider = DatabaseProvider();
  List<bool> _isSelected = [];
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
      return hours + minutes / 60.0;
    } else {
      // Handle invalid format
      print("Invalid time format: $timeString");
      return 0.0; // Or provide a default value
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
                        String shortDate = filteredWorkItems[index]
                            .dateString
                            .substring(0, 10);
                        return ListTile(
                          leading: Checkbox(
                            value: _isSelected[index],
                            activeColor: Color.fromRGBO(250, 195, 32, 1),
                            onChanged: (newValue) {
                              setState(() {
                                _isSelected[index] = newValue!;

                                if (newValue) {
                                    // get an item's workedTime String and convert to a number
                                    double workedTime = convertWorkedTimeToHours(
                                        filteredWorkItems[index]);
                                    newTotal += workedTime;
                                    
                                  } else {
                                  // get an item's workedTime String and convert to a number
                                  double workedTime = convertWorkedTimeToHours(
                                        filteredWorkItems[index]);
                                  newTotal = newTotal - workedTime;
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
                        color: Color.fromARGB(255, 73, 53, 57),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Column(
                      children: [
                        Text(
                          "Total hours this week: $newTotal",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),

                        // save button creates a TimesheetItem object and sends to firestore
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
