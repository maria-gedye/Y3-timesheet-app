import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timesheet_app/data/shift_data.dart';
import 'package:timesheet_app/models/shift_item.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:timesheet_app/pages/home_page.dart';

class ShiftDialog extends StatefulWidget {
  const ShiftDialog({super.key});

  @override
  State<ShiftDialog> createState() => _ShiftDialogState();
}

class _ShiftDialogState extends State<ShiftDialog> {
  // add shift dialog variables
  final newPlaceController = TextEditingController();
  final newAddressController = TextEditingController();
  final newDateController = TextEditingController();
  final newStartTimeController = TextEditingController();
  final newEndTimeController = TextEditingController();
  String pickedDate = '', startTime = '', endTime = '';
  TimeOfDay startTimeDialog = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay endTimeDialog = TimeOfDay(hour: 0, minute: 0);

  final user = FirebaseAuth.instance.currentUser!;
  //final HomePage _homePageState;
  //_ShiftDialogState(this._homePageState);

  // datepicker method
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now()); // they can't select date in future

    if (picked != null) {
      setState(() {
        pickedDate = picked.toString();
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

  // put info into new shift object then save to list (shift_data.dart)
  void saveDialog(String newDate) {
    // calculate duration (find difference between two timeOfDay objects)
    TimeOfDay duration = calculateTimeDuration(startTimeDialog, endTimeDialog);
    String workedTime = '${duration.hour}hrs ${duration.minute}min';

    // create shift_item object via dialog
    ShiftItem newShift = ShiftItem(
        uniqueID: Provider.of<ShiftData>(context, listen: false).generateRandomId() ,
        placeName: newPlaceController.text,
        address: newAddressController.text,
        startTime: newStartTimeController.text,
        endTime: newEndTimeController.text,
        workedTime: workedTime,
        dateTime: newDate);

// add newShift to overallShiftList []
    Provider.of<ShiftData>(context, listen: false).addNewShift(newShift);
    print("manual shift added to overallShiftList []");

    sendShiftToDB();

    Navigator.pop(context);
    clear();
  }

  // sends shift item from list to firebase DB (also used in shift_dialog.dart)
  void sendShiftToDB() {
    // checking locally stored user data
    List<ShiftItem> shiftList =
        Provider.of<ShiftData>(context, listen: false).getAllShifts();
    print("list length: ${shiftList.length}");
    for (ShiftItem shift in shiftList) {
      print("place: ${shift.placeName}, duration: ${shift.workedTime}");
    }
// get the last item in overallShiftList (shift_data.dart)
    ShiftItem newShift = shiftList.last;

    if (newShift.startTime.isNotEmpty && newShift.endTime.isNotEmpty) {
     // access firestore collection
      CollectionReference collectionRef =
          FirebaseFirestore.instance.collection('${user.email}');

      Map<String, dynamic> newShiftData = {
        'PlaceName': newShift.placeName,
        'StartTime': newShift.startTime,
        'EndTime': newShift.endTime,
        'WorkedTime': newShift.workedTime,
        'DateTime': newShift.dateTime,
        'UniqueID' : newShift.uniqueID
        // Add other properties for your Shift object
      };

      String newDocumentId = newShift.uniqueID;

      collectionRef.doc(newDocumentId).set(newShiftData).then((_) {
        print('Document added successfully!');
      }).catchError((error) => print('Error adding document: $error'));
    }
  }

  // clear the controllers (for dialog)
  void clear() {
    newAddressController.clear();
    newDateController.clear();
    newEndTimeController.clear();
    newStartTimeController.clear();
    newPlaceController.clear();

    startTimeDialog = TimeOfDay(hour: 0, minute: 0);
    endTimeDialog = TimeOfDay(hour: 0, minute: 0);
  }

  // cancel the dialog
  void cancel() {
    Navigator.pop(context);
    clear();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Shift'),
      backgroundColor: Color.fromRGBO(250, 195, 32, 1),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // place name
            TextField(
              controller: newPlaceController,
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: const InputDecoration(labelText: 'Place Name'),
            ),

            // address (optional)
            TextField(
              controller: newAddressController,
              decoration:
                  const InputDecoration(labelText: 'Address (optional)'),
            ),

            // date picker
            TextField(
              controller: newDateController,
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: const InputDecoration(labelText: 'Select date'),
              readOnly: true,
              onTap: () {
                _selectDate();
              },
            ),

            // start time - time picker
            TextField(
              controller: newStartTimeController,
              readOnly: true,
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: const InputDecoration(labelText: 'Start Time'),
              onTap: () => {
                _selectTime(newStartTimeController),
              },
            ),

            // end time time picker
            TextField(
              controller: newEndTimeController,
              readOnly: true,
              style: TextStyle(fontWeight: FontWeight.bold),
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
    );
  }
}
