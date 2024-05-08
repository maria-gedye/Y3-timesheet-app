import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timesheet_app/data/shift_data.dart';
import 'pages/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  //initialise firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // this object is exported by the configuration file
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ShiftData(),
      builder: (context, child) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthPage(),
      ),
    ); // MaterialApp
  }
}
