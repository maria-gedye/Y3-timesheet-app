import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timesheet_app/pages/home_page.dart';
import 'package:timesheet_app/pages/login_or_register_page.dart';
import 'package:timesheet_app/models/work_item.dart';
import 'package:provider/provider.dart';
import 'package:timesheet_app/providers/database_provider.dart';

// check if user is signed in or not
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              // user is logged in
              if (snapshot.hasData) {
 
                // add stream provider to access firestore data
                return StreamProvider<List<WorkItem>>.value(
                    initialData: [],
                    value: DatabaseProvider().workItems,
                    child: HomePage());
              }

              // user is NOT logged in
              else {
                return LoginOrRegisterPage();
              }
            }));
  }
}
