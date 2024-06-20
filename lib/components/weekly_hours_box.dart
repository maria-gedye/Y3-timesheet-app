import 'package:flutter/material.dart';

import 'package:timesheet_app/models/work_item.dart';
import 'package:timesheet_app/providers/database_provider.dart';

class WeeklyHoursBox extends StatefulWidget {
  const WeeklyHoursBox({super.key});

  @override
  State<WeeklyHoursBox> createState() => _WeeklyHoursBoxState();
}

class _WeeklyHoursBoxState extends State<WeeklyHoursBox> {
  final DatabaseProvider _databaseProvider = DatabaseProvider();

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
          final filteredWorkItems = snapshot.data!;
          int hours, minutes;
          // print(filteredWorkItems.isEmpty);

          double weeklyTotal = filteredWorkItems.fold(0.0, (sum, item) {
            String timeString = item.workedTime; // 9hrs 30min
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
          // display total hours selected
          return Container(
            height: 50,
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 73, 53, 57),
                borderRadius: BorderRadius.circular(10.0)),
            child: Align(
              child: Text(
                "Hours worked this week: ${weeklyTotal.toStringAsFixed(1)}",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          );
        }
      },
    );
  }
}
