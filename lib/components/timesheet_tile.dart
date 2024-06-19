
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timesheet_app/components/my_textfield.dart';


class TimesheetTile extends StatefulWidget {
  final String? uniqueID;
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
                title: const Text('Send to email'),
                backgroundColor: Color.fromRGBO(250, 195, 32, 1),
                content: MyTextField(
                    controller: emailText,
                    hintText: 'email',
                    obscureText: false),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color:Color.fromRGBO(64, 46, 50, 1) ),),
                  ),
                  TextButton(
                    onPressed: () async {
                      // email trigger service
                      // get timesheet object
                      // cast object to email format
                    },
                    child: const Text('Send', style: TextStyle(color:Color.fromRGBO(64, 46, 50, 1) ),),
                  )
                ]));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      textColor: Colors.white,
      title: Text(widget.uniqueID!),
      subtitle: Text('Week starting:  ${widget.weekStarting}'),
      trailing: IconButton(
        icon: Icon(Icons.send, color: Color.fromRGBO(250, 195, 32, 1) ,), 
        onPressed: sendtoEmail,)
    );
  }
}
