import 'package:flutter/material.dart';

class MyFab extends StatelessWidget {
  const MyFab({super.key});

  static const _actionTitles = ['Add new work', 'Create Timesheet'];

  void _showAction(BuildContext context, int index) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(_actionTitles[index]),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const MyFab();
  }
}
