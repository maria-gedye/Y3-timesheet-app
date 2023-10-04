import 'package:flutter/material.dart';
import 'package:timesheet_app/components/my_textfield.dart';
import 'package:timesheet_app/components/my_button.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // sign user in method
  void signUserIn() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(250, 195, 32, 1),
        body: SafeArea(
            child: Center(
                child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),

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
                controller: usernameController,
                hintText: 'Username',
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

              // forgot password?
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
                onTap: signUserIn,
              ),

              // or continue with
              // google + apple sign in buttons (optional feature!!)

              SizedBox(height: 20),

              // First time? Register now
              Row(
                children: [
                  Text('First time?'),
                  const SizedBox(width: 4),
                  const Text(
                    'Register now',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
        ))));
  }
}
