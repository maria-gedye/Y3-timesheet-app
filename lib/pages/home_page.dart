import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;
  final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: TextStyle(
        fontSize: 50,
      ),
      backgroundColor: Color.fromRGBO(250, 195, 32, 1),
      foregroundColor: Color.fromRGBO(64, 46, 50, 1),
      fixedSize: Size.fromRadius(115),
      shape: CircleBorder(),
      shadowColor: Colors.black,
      elevation: 10.0,
      side: BorderSide(color: Color.fromRGBO(164, 142, 101, 1), width: 10.0,));

  //sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

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
                  Icon(Icons.place_rounded, color: Colors.white,),
                  Text('unknown location',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      )),
                ],
              ),
              SizedBox(height: 20),
         
              // timer button (switches between start and stop)
              ElevatedButton(
                style: style,
                onPressed: () {},
                child: const Text('Start'),
              ),

              // total hours worked card

              // Bottom Nav Bar with three buttons
              // User button
              // add shift button
              // time log? timesheet?
            ],
          )),
          )
        ));
  }
}
