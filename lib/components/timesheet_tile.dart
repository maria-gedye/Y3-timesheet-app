
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timesheet_app/components/my_textfield.dart';


class TimesheetTile extends StatefulWidget {
  final String uniqueID;
  final String weekStarting;

  const TimesheetTile(
      {super.key, required this.uniqueID, required this.weekStarting});

  @override
  State<TimesheetTile> createState() => _TimesheetTileState();
}

class _TimesheetTileState extends State<TimesheetTile> {
  // variables
  final user = FirebaseAuth.instance.currentUser!;

// send to email method
  sendtoEmail() {
    TextEditingController emailText = TextEditingController();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Enter an email'),
                content: MyTextField(
                    controller: emailText,
                    hintText: 'email',
                    obscureText: false),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      // email trigger service
                    },
                    child: const Text('Send'),
                  )
                ]));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      textColor: Colors.white,
      title: Text(widget.uniqueID),
      subtitle: Text('Week starting:  ${widget.weekStarting}'),
      trailing: IconButton(
        icon: Icon(Icons.send), 
        onPressed: sendtoEmail,)
    );
  }
}
