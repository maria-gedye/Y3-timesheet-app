import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timesheet_app/components/my_textfield.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:timesheet_app/models/timesheet_item.dart';

class TimesheetTile extends StatefulWidget {
  final String? uniqueID;
  final String weekStarting;
  final TimesheetItem timesheet;

  const TimesheetTile(
      {super.key,
      required this.uniqueID,
      required this.weekStarting,
      required this.timesheet});

  @override
  State<TimesheetTile> createState() => _TimesheetTileState();
}

class _TimesheetTileState extends State<TimesheetTile> {
  // variables
  final user = FirebaseAuth.instance.currentUser!;
  final _key =
      GlobalKey(); // may need to explicitly add GlobalKey type <ListTile>

// get recipient email
  getEmailAddress() {
    TextEditingController emailAddress = TextEditingController();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Send to email'),
                backgroundColor: Color.fromRGBO(250, 195, 32, 1),
                content: MyTextField(
                    controller: emailAddress,
                    hintText: 'email',
                    obscureText: false),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Color.fromRGBO(64, 46, 50, 1)),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      // email trigger service
                      sendEmail(emailAddress.text);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Send',
                      style: TextStyle(color: Color.fromRGBO(64, 46, 50, 1)),
                    ),
                  )
                ]));
  }

  sendEmail(String recipient) async {
// format body using timesheet object
    final String emailBody = formatEmailBody(widget.timesheet);
    final String emailSubject = widget.timesheet.uniqueID!;
// cast object to email format
    final Email email = Email(
        subject: emailSubject,
        recipients: [recipient],
        body: emailBody,
        isHTML: true);

    await FlutterEmailSender.send(email);
  }

  String formatEmailBody(TimesheetItem timesheetItem) {
    String tableData = '';

    for (final workItem in timesheetItem.workItems) {
      String shortDate = workItem.dateString.substring(0, 10);
      tableData += """<p>CLIENT/VENUE: ${workItem.placeName} \n </p>""";
      tableData += """
      <p>DATE: $shortDate </p>
      <p>START TIME: ${workItem.startTime} </p>
      <p>FINISH TIME: ${workItem.endTime} </p>
      <p>TOTAL: ${workItem.workedTime}   </p>
      <p>+-------------------------------------+ \n </p>
""";
    }

    String startWeek = timesheetItem.weekStarting.toString();
    String shortStartWeek = startWeek.substring(0, 10);

    return """
      <h1>Timesheet Details</h1>
      <p><b>Week starting:</b> $shortStartWeek</p>
      <p> </p>
      <p> </p>

      $tableData

      <p><b>TOTAL HOURS:</b> ${timesheetItem.totalTime}</p>
      """;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        key: _key,
        textColor: Colors.white,
        title: Text(widget.uniqueID!),
        subtitle: Text('Week starting:  ${widget.weekStarting}'),
        trailing: IconButton(
          icon: Icon(
            Icons.send,
            color: Color.fromRGBO(250, 195, 32, 1),
          ),
          onPressed: () {
            getEmailAddress();
          },
        ));
  }
}
