import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;
  final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: TextStyle(fontSize: 50,),
      backgroundColor: Color.fromRGBO(250, 195, 32, 1),
      foregroundColor: Color.fromRGBO(64, 46, 50, 1),
      fixedSize: Size.fromRadius(100),
      shape: CircleBorder(),
      shadowColor: Color.fromRGBO(164,142,101, 1));

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
          leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
        ),
        body: SafeArea(
          //child: Center(
          child: SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // display the current user
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Text('Hi, ${user.email!}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        )),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Clock in
              Text('Clock In',
                  style: TextStyle(
                    color: Color.fromRGBO(250, 195, 32, 1),
                    fontSize: 40,
                  )),

              SizedBox(height: 20),

              // main button
              ElevatedButton(
                style: style,
                onPressed: () {},
                child: const Text('Start'),
    
              ),

              // Display stopwatch digits (if activated)
            ],
          )),
          // ),
        ));
  }
}
