import 'package:flutter/material.dart';

class TimerButton extends StatefulWidget {
  final Function()? onPressed;

  const TimerButton({ super.key, required this.onPressed });

  @override
  State<TimerButton> createState() => _TimerButtonState();
}

class _TimerButtonState extends State<TimerButton> {
  // initially show start button
  bool showStartButton = true;

  // toggle between start and stop buttons
  void toggleStartStop() {
    setState(() {
      showStartButton = !showStartButton;
    });
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle style = ElevatedButton.styleFrom(
        textStyle: TextStyle(
          fontSize: 50,
        ),
        backgroundColor: Color.fromRGBO(250, 195, 32, 1),
        foregroundColor: Color.fromRGBO(64, 46, 50, 1),
        fixedSize: Size.fromRadius(115),
        shape: CircleBorder(),
        shadowColor: Colors.black,
        elevation: 10.0,
        side: BorderSide(
          color: Color.fromRGBO(164, 142, 101, 1),
          width: 10.0,
        )
        );

    if (showStartButton) {
      return ElevatedButton(
        onPressed: toggleStartStop,
        style: style,
        child: Text('Start'),
      );
    } else {
      //return stop button
      style = ElevatedButton.styleFrom(
        textStyle: TextStyle(
          fontSize: 50,
        ),
        backgroundColor: Color.fromRGBO(64, 46, 50, 1),
        foregroundColor: Color.fromRGBO(250, 195, 32, 1),
        fixedSize: Size.fromRadius(115),
        shape: CircleBorder(),
        shadowColor: Colors.black,
        elevation: 10.0,
        side: BorderSide(
          color: Color.fromRGBO(164, 142, 101, 1),
          width: 10.0,
        )
      );
      return ElevatedButton(
        onPressed: toggleStartStop,
        style: style,
        child: Text('Stop'),
      );
    }
  }
}
