// TODO: refactor add shift dialog logic
import 'package:flutter/material.dart';

class ShiftDialogLogic {
  // add shift dialog variables
  final newPlaceController = TextEditingController();
  final newAddressController = TextEditingController();
  final newDateController = TextEditingController();
  final newStartTimeController = TextEditingController();
  final newEndTimeController = TextEditingController();
  late DateTime pickedDate = DateTime(2023, 0, 0, 0, 0);
  String startTime = '', endTime = '';
  TimeOfDay startTimeDialog = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay endTimeDialog = TimeOfDay(hour: 0, minute: 0);

   // add shift dialog functions(5)
  void addShiftDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Add Shift'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // place name
                    TextField(
                      controller: newPlaceController,
                      decoration:
                          const InputDecoration(labelText: 'Place Name'),
                    ),

                    // address (optional)
                    TextField(
                      controller: newAddressController,
                      decoration: const InputDecoration(
                          labelText: 'Address (optional)'),
                    ),

                    // date picker
                    TextField(
                      controller: newDateController,
                      decoration:
                          const InputDecoration(labelText: 'Select date'),
                      readOnly: true,
                      onTap: () {
                        _selectDate();
                      },
                    ),

                    // start time - time picker
                    TextField(
                      controller: newStartTimeController,
                      readOnly: true,
                      decoration:
                          const InputDecoration(labelText: 'Start Time'),
                      onTap: () => {
                        _selectTime(newStartTimeController),
                      },
                    ),

                    // end time time picker
                    TextField(
                      controller: newEndTimeController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'End Time'),
                      onTap: () => {
                        _selectTime(newEndTimeController),
                      },
                    ),

                    SizedBox(height: 5),
                  ],
                ),
              ),
              actions: [
                // save button
                MaterialButton(
                  onPressed: () {
                    saveDialog(pickedDate);
                  },
                  child: const Text('Save'),
                ),
                // cancel button
                MaterialButton(
                  onPressed: cancel,
                  child: const Text('Cancel'),
                ),
              ],
            ));
  }

  // datepicker method
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now()); // they can't select date in future

    if (picked != null) {
      setState(() {
        pickedDate = picked;
        newDateController.text = picked.toString().split(" ")[0];
      });
    }
  }

  // timepicker method -- needs to also store start/end times to calc duration
  Future<void> _selectTime(final controller) async {
    final TimeOfDay? getTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
    );

    if (getTime != null) {
      setState(() {
        if (startTimeDialog != TimeOfDay(hour: 0, minute: 0)) {
          endTimeDialog = getTime;
        } else {
          startTimeDialog = getTime;
        }

        // Update text in controller after setting TimeOfDay variable
        String newTimeText =
            "${getTime.hour}:${getTime.minute} ${getTime.period.name}";
        controller.text = newTimeText;
      });
    }
  }

  // calculate duration between two user input times
  TimeOfDay calculateTimeDuration(TimeOfDay startTime, TimeOfDay endTime) {
    int startMinutes = startTime.hour * 60 + startTime.minute;
    int endMinutes = endTime.hour * 60 + endTime.minute;

    // Check if the end time is earlier than the start time (indicating it's on the next day)
    if (endMinutes < startMinutes) {
      endMinutes += 24 * 60; // Add 24 hours to account for the next day
    }

    int durationInMinutes = (endMinutes - startMinutes).abs();

    int hours = durationInMinutes ~/ 60;
    int minutes = durationInMinutes % 60;

    return TimeOfDay(hour: hours, minute: minutes);
  }

  // put info into new shift object then save to list
  void saveDialog(DateTime newDate) {
    // find difference between two timeOfDay objects
    print(
        'start time before calculation: $startTimeDialog end time before calc: $endTimeDialog');

    TimeOfDay duration = calculateTimeDuration(startTimeDialog, endTimeDialog);
    print('after duration call: $duration');
    String workedTime = '${duration.hour}hrs ${duration.minute}min';

    // create shift_item object via dialog
    ShiftItem newShift = ShiftItem(
        placeName: newPlaceController.text,
        address: newAddressController.text,
        startTime: newStartTimeController.text,
        endTime: newEndTimeController.text,
        workedTime: workedTime,
        dateTime: newDate);
    // add new shift from shift_data.dart
    Provider.of<ShiftData>(context, listen: false).addNewShift(newShift);

    print(
        'start: ${newShift.startTime}, end: ${newShift.endTime}, total: ${newShift.workedTime}');

    Navigator.pop(context);
    clear();
  }

}