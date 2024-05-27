import 'package:timesheet_app/datetime/date_time_helper.dart';
import 'package:timesheet_app/models/work_item.dart';
import 'package:flutter/material.dart';



// HELPER METHODS

class WorkData extends ChangeNotifier {
  // list all works
  List<WorkItem> overallWorkList = [];

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

  // generate ID for work
  String generateRandomId({int length = 20}) {
    final _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789';
    int timeStamp = DateTime.now().millisecondsSinceEpoch;
    String result = '';

    for (int i = 0; i < length; i++) {
      final index = (timeStamp + i) % _chars.length;
      final char = _chars[index];
      result += char;
    }
    return result;
  }

  // get weekday from dateTime object
  String getDayName(DateTime dateTime) {
    switch (dateTime.weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  // get date for start of the week
  DateTime startOfWeekDate() {
    DateTime? startOfWeek;

    // get todays date
    DateTime today = DateTime.now();

    // go backwards from today to find sunday
    for (int i = 0; i < 7; i++) {
      if (getDayName(today.subtract(Duration(days: i))) == 'Sun') {
        startOfWeek = today.subtract(Duration(days: i));
      }
    }
    return startOfWeek!;
  }
}

// old method
//   Map<String, double> calculateWeeklyWorkSummary() {
//     Map<String, double> weeklyWorkSummary = {
//       //startingdate (yyyymmdd) : Totalhours
//     };
//     // reuse this method to check starting date for any work
//     DateTime getStartOfWeekDate(DateTime workDate) {
//       DateTime? startOfWeek;
//       // go backwards from a work's date to find sunday
//       for (int i = 0; i < 7; i++) {
//         if (getDayName(workDate.subtract(Duration(days: i))) == 'Sun') {
//           startOfWeek = workDate.subtract(Duration(days: i));
//         }
//       }
//       return startOfWeek!;
//     }

//     for (var work in overallWorkList) {
//       String dateStr = work.dateTime;
//       DateTime dateTime = DateTime.parse(dateStr);

//       String startWeekDate =
//           convertDateTimeToSTring(getStartOfWeekDate(dateTime));
//       double hours = double.parse(
//           work.workedTime); // turn string into double to do the math

// // if works starts in the same week:
//       if (weeklyWorkSummary.containsKey(startWeekDate)) {
//         double currentHours =
//             weeklyWorkSummary[startWeekDate]!; // if date already exist in map
//         currentHours += hours; // add hours on
//         weeklyWorkSummary[startWeekDate] = currentHours;
//       } else {
//         weeklyWorkSummary.addAll({
//           startWeekDate: hours
//         }); // else if its a new date, add date and hours
//       }
//     }

//     return weeklyWorkSummary;
//   }

  // ONEDAY combine all works for a monthly view