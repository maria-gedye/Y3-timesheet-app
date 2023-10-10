import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timesheet_app/components/my_textfield.dart';
import 'package:timesheet_app/components/my_button.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmedPasswordController = TextEditingController();

  // sign user in method
  void signUserIn() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // should also check if user doesn't already exist

// try creating the user
    try {
      // check if password is confirmed
      if (passwordController.text == confirmedPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      } else {
        // pop loading circle
        Navigator.pop(context);
        // show password error message
        showErrorMessage('Oops. Passwords do not match');
        return;
      }

      // pop the loading circle once user created
      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      // pop loading circle
      Navigator.pop(context);
      print(e.message); // for other errors
      showErrorMessage('Sorry there was an issue. Please try again');
    } // end of FirebaseAuthException catch
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color.fromRGBO(64, 46, 50, 1),
          title: Center(
              child: Text(
            message,
            style: TextStyle(color: Colors.white),
          )),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(250, 195, 32, 1),
        body: SafeArea(
            child: Center(
                child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // logo
              Icon(
                Icons.lock,
                size: 80,
                color: Color.fromRGBO(64, 46, 50, 1),
              ),

              SizedBox(height: 20),

              // let's create an account for you
              Text('Let\'s create an account for you',
                  style: TextStyle(
                    color: Color.fromRGBO(64, 46, 50, 1),
                    fontSize: 20,
                  )),

              SizedBox(height: 20),

              // username text field
              MyTextField(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
              ),
              SizedBox(height: 20),

              // password text field
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              SizedBox(height: 20),

              // confirm password text field
              MyTextField(
                controller: confirmedPasswordController,
                hintText: 'Confirm Password',
                obscureText: true,
              ),

              SizedBox(height: 20),

              // sign up button
              MyButton(
                text: "Sign up",
                onTap: signUserIn,
              ),

              // or continue with
              // google + apple sign in buttons (optional feature!!)

              SizedBox(height: 20),

              // revert back to login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?'),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      'Login now',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            ],
          ),
        ))));
  } // widget build
} //  class _loginStatePage

