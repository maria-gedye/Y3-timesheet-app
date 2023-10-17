import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timesheet_app/components/timer_button.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  //sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  // get user location method
  // start timer method
  // stop or save timer methods?

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(64, 46, 50, 1),

        // log out
        appBar: AppBar(
          //title: Text(),
          backgroundColor: Color.fromRGBO(64, 46, 50, 1),
          actions: [
            IconButton(onPressed: signUserOut, icon: Icon(Icons.logout)),
          ],
          leading: IconButton(onPressed: () {}, icon: Icon(Icons.settings)),
        ),
        body: SafeArea(
            child: Center(
          child: SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Clock in title
              Text('Clock in',
                  style: TextStyle(
                    color: Color.fromRGBO(250, 195, 32, 1),
                    fontSize: 40,
                  )),

              SizedBox(height: 20),

              // Timer display
              Text('0:00:00',
                  style: TextStyle(
                    color: Color.fromRGBO(250, 195, 32, 1),
                    fontSize: 60,
                  )),

              // Current location display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.place_rounded,
                    color: Colors.white,
                  ),
                  Text('unknown location',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      )),
                ],
              ),
              SizedBox(height: 20),

              // timer button (switches between start and stop)
              TimerButton(onTap: () {})
              // total hours worked card

              // Bottom Nav Bar with three buttons
              // User button
              // add shift button
              // time log? timesheet?
            ],
          )),
        )));
  }
}
