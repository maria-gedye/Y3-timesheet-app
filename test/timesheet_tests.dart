import 'package:flutter_test/flutter_test.dart';
import 'package:timesheet_app/models/timesheet_item.dart';
// import 'package:flutter_email_sender/flutter_email_sender.dart';
// import 'package:timesheet_app/components/timesheet_tile.dart';
// import 'package:timesheet_app/pages/timesheet_page.dart';
// import 'package:flutter/material.dart';
// import 'package:mockito/mockito.dart';

void main() {
  group('DatabaseProvider Tests', () {
    test('TimesheetItem validation - empty workItems list', () {
      final invalidItem = TimesheetItem(
          uniqueID: '',
          weekStarting: DateTime.now(),
          workItems: List.empty(),
          totalTime: 0);
      expect(() => invalidItem.isValid(),
          throwsA(predicate((e) => e is ArgumentError)));
    });

//     testWidgets('Timesheet list tile tap triggers sendEmail with valid email',
//         (WidgetTester tester) async {
//       // Mock data for TimesheetTile
//       final mockTimesheetItem = TimesheetItem(
//         uniqueID: '...',
//         workItems: [],
//         weekStarting: DateTime.now(),
//         totalTime: 0.0,
//       );

//       // Build TimesheetTile with mock data
//       await tester.pumpWidget(
//         TimesheetTile(
//           uniqueID: mockTimesheetItem.uniqueID,
//           weekStarting: mockTimesheetItem.weekStarting.toString(),
//           timesheet: mockTimesheetItem,
//         ),
//       );

//       // Find the ListTile widget
//       final listTileFinder = find.byType(ListTile);
//       expect(listTileFinder, findsOneWidget);

//       // Simulate tap on ListTile
//       await tester.tap(listTileFinder);

//       // Enter a valid email address in the dialog
//       final emailTextFieldFinder = find.byType(TextField);
//       await tester.enterText(emailTextFieldFinder, '');

//       // Find and tap the Send button within the dialog
//       final sendButtonFinder = find.text('Send');
//       expect(sendButtonFinder, findsOneWidget);
//       await tester.tap(sendButtonFinder);

//       // Verify sendEmail is called and with a non-null argument
//       verify(() => FlutterEmailSender.send(captureAny()));

// // Assuming sendEmail is called only once after user interaction
//       final capturedEmail =
//           verify(() => FlutterEmailSender.send(captureAny())).captured.single;
//       expect(capturedEmail, isNotNull); // Verify Email object is not null

// // Verify sendEmail is called with the expected email address
//       verify(() => FlutterEmailSender.send(argThat(
//             (dynamic email) =>
//                 email is Email &&
//                 email.recipients.single == 'valid_email@example.com',
//           )));
//     });
  });
}
