import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timesheet_app/components/my_textfield.dart';
import 'package:timesheet_app/components/my_button.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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

// try sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // pop the loading circle once signed in
      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      // wrong email or password
      if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        showErrorMessage('Incorrect email or password');
      } else {
        print(e.message); // for other errors
        showErrorMessage('Internal error. Restart the app');
      }
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
                size: 100,
                color: Color.fromRGBO(64, 46, 50, 1),
              ),

              // welcome! please log in
              Text('Employee Login',
                  style: TextStyle(
                    color: Color.fromRGBO(64, 46, 50, 1),
                    fontSize: 30,
                  )),

              SizedBox(height: 20),

              // username text field
              MyTextField(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
              ),
              SizedBox(height: 30),

              // password text field
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              SizedBox(height: 10),

              // TO DO: forgot password?
              // implement functionality for this
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forgot Password?',
                      style: TextStyle(color: Color.fromRGBO(64, 46, 50, 1)),
                    )
                  ],
                ),
              ),

              SizedBox(height: 20),

              // sign in button
              MyButton(
                text: "Sign in",
                onTap: signUserIn,
              ),

              // or continue with
              // google + apple sign in buttons (optional feature!!)

              SizedBox(height: 20),

              // First time? Register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('First time?'),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      'Register now',
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

