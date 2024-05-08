import 'package:timesheet_app/datetime/date_time_helper.dart';
import 'package:timesheet_app/models/shift_item.dart';
import 'package:flutter/material.dart';

class ShiftData extends ChangeNotifier {

  // list all shifts
  // currently resets to 0 everytime app is reloaded? restarted?
  List<ShiftItem> overallShiftList = [];

  // get shift list
  List<ShiftItem> getAllShifts() {
    return overallShiftList;
  }

  // add new shift
  void addNewShift(ShiftItem newShift) {
    overallShiftList.add(newShift);

    notifyListeners();
  }

  // delete shift
  void deleteShift(ShiftItem shift) {
    overallShiftList.remove(shift);

    notifyListeners();
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

  
  // combine all shifts on weekly basis (bar graph)
  Map<String, double> calculateWeeklyWorkSummary() {
    Map<String, double> weeklyWorkSummary = {
      //startingdate (yyyymmdd) : Totalhours
    };
    // reuse this method to check starting date for any shift
    DateTime getStartOfWeekDate(DateTime shiftDate) {
      DateTime? startOfWeek;
      // go backwards from a shift's date to find sunday
      for (int i = 0; i < 7; i++) {
        if (getDayName(shiftDate.subtract(Duration(days: i))) == 'Sun') {
          startOfWeek = shiftDate.subtract(Duration(days: i));
        }
      }
      return startOfWeek!;
    }

    for (var shift in overallShiftList) {
      String dateStr = shift.dateTime;
      DateTime dateTime = DateTime.parse(dateStr);

      String startWeekDate = convertDateTimeToSTring(getStartOfWeekDate(dateTime)); 
      double hours = double.parse(
          shift.workedTime); // turn string into double to do the math

// if shifts starts in the same week:
      if (weeklyWorkSummary.containsKey(startWeekDate)) {
        double currentHours =
            weeklyWorkSummary[startWeekDate]!; // if date already exist in map
        currentHours += hours; // add hours on
        weeklyWorkSummary[startWeekDate] = currentHours;
      } else {
        weeklyWorkSummary.addAll({
          startWeekDate: hours
        }); // else if its a new date, add date and hours
      }
    }

    return weeklyWorkSummary;
  }

  // ONEDAY combine all shifts for a monthly view
}
