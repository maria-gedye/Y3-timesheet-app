import 'package:flutter/material.dart';

class TimerButton extends StatefulWidget {
  final Function()? onTap;
  final String text;

  // implement three states - start, break, stop
  const TimerButton({super.key, required this.onTap, required this.text});

  @override
  State<TimerButton> createState() => _TimerButtonState();
}

class _TimerButtonState extends State<TimerButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
    );
  }
}
