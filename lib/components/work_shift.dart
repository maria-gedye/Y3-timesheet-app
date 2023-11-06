import 'package:flutter/material.dart';
// possibly Im already doubling up and need to decide between this and shift_item?
class WorkShift extends StatelessWidget {
  final String date;
  final String duration;
  final String place;
  const WorkShift({
    super.key,
    required this.date,
    required this.duration,
    required this.place
    });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Text(date),
            Text(place),
          ],
        )
      ],
    );
  }
}
