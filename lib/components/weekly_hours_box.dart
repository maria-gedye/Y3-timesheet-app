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
        if (snapshot.hasData) {
          final workItems = snapshot.data!;
          // double _weeklyTotal;
          // DateTime now = DateTime.now();
          // DateTime startDate = now.subtract(Duration(days: now.weekday - 1));
          // DateTime endDate = startDate.add(Duration(days: 6));

          // final filteredWorkItems = workItems
          //     .where((item) =>
          //         item.dateTime.isAfter(startDate) &&
          //         item.dateTime.isBefore(endDate))
          //     .toList();
          // _weeklyTotal = filteredWorkItems.fold(
          //     0.0, (sum, item) => sum + item.hours); // Calculate total hours
          return Container(
            height: 100,
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 73, 53, 57),
                borderRadius: BorderRadius.circular(10.0)),
            child: Align(
              child: Text(
                "Total hours worked this week",
                style: TextStyle(color: Colors.amber, fontSize: 18),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
