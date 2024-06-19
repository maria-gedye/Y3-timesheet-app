import 'package:timesheet_app/models/work_item.dart';
import 'package:flutter/material.dart';
import 'package:timesheet_app/providers/database_provider.dart';

// HELPER METHODS

class WorkData extends ChangeNotifier {
  // list all works
  List<WorkItem> overallWorkList = [];
  DatabaseProvider _provider = DatabaseProvider();

  // get work list
  List<WorkItem> getAllWorks() {
    return overallWorkList;
  }

  // add new workItem
  void addNewWork(WorkItem newWork) {
    overallWorkList.add(newWork);

    notifyListeners();
  }

  // delete work
  void deleteWork(WorkItem work) {
    overallWorkList.remove(work);

    notifyListeners();
  }

  // generate ID for workItem
  String generateRandomId({int length = 20}) {
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789';
    int timeStamp = DateTime.now().millisecondsSinceEpoch;
    String result = '';

    for (int i = 0; i < length; i++) {
      final index = (timeStamp + i) % chars.length;
      final char = chars[index];
      result += char;
    }
    return result;
  }

  // generate ID for timesheet (uses counter)
  Future<String> generateCounterID(String? userID) async {
    // Access the counter value for the current user (implementation depends on storage method)
    int userCounter =  await _provider.getCounterForUser(userID);
    userCounter++; // Increment the counter for this user

    // Update the counter value for the current user (implementation depends on storage method)
    _provider.setUserCounter(userID, userCounter);

    return "Timesheet#_$userCounter"; 
  }

  // get weekday from dateTime object
  int getDayNumber(DateTime day) {
    switch (day.weekday) {
      case DateTime.sunday:
        return 1;
      case DateTime.monday:
        return 2;
      case DateTime.tuesday:
        return 3;
      case DateTime.wednesday:
        return 4;
      case DateTime.thursday:
        return 5;
      case DateTime.friday:
        return 6;
      case DateTime.saturday:
        return 7;
      default:
        return 0;
    }
  }

  // get date for start of the week
  DateTime startOfWeekDate() {
    DateTime? startOfWeek;

    // get todays date
    DateTime today = DateTime.now();

    // go backwards from today to find sunday
    for (int i = 0; i < 7; i++) {
      if (getDayNumber(today.subtract(Duration(days: i))) == 1) {
        startOfWeek = today.subtract(Duration(days: i));
      }
    }
    return startOfWeek!;
  }
} // end of class