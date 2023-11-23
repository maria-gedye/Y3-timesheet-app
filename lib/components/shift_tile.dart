import 'package:flutter/material.dart';

class ShiftTile extends StatelessWidget {
  final String shiftDate;
  final String placeName;
  final String workedTime;

  const ShiftTile({super.key, required this.shiftDate, required this.placeName, required this.workedTime});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      textColor: Colors.white,
      title: Text(placeName),
      subtitle: Text(shiftDate),
      trailing: Text(workedTime),
    );
  }
}
