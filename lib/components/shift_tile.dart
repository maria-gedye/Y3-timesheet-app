import 'package:flutter/material.dart';

class ShiftTile extends StatelessWidget {
  final String placeName;
  final String workedTime;
  final DateTime dateTime;

  const ShiftTile({super.key, required this.placeName, required this.dateTime, required this.workedTime});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      textColor: Colors.white,
      title: Text(placeName),
      subtitle: Text('${dateTime.day}/${dateTime.month}/${dateTime.year}'),
      trailing: Text(workedTime),
    );
  }
}
