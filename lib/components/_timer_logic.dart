 // TODO: refactor timer logic
import 'dart:async';
import 'package:flutter/material.dart';

class TimerLogic {
  // timer variables
  int seconds = 0, minutes = 0, hours = 0;
  String digitSeconds = "00", digitMinutes = "00", digitHours = "00";
  Timer? timer;
  bool started = false;
  List shifts = [];
  int currentPageIndex = 0;

  void startTimer(Function(int, int, int) onUpdate) {
    started = true;
    TimeOfDay now = TimeOfDay.now();
    String startTime = '${now.hour}:${now.minute} ${now.period.name}';

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
    // Remember to call onUpdate with updated values
  }

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
}



