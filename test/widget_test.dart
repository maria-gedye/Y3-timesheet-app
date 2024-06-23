import 'package:timesheet_app/providers/database_provider.dart'; 
import 'package:flutter_test/flutter_test.dart';
import 'package:timesheet_app/models/timesheet_item.dart';

// get these tests working
void main() {
  group('DatabaseProvider Tests', () {
    test('TimesheetItem validation - empty timesheet', () {
      final invalidItem = TimesheetItem(
        uniqueID: '',
        weekStarting: DateTime.now(),
        workItems: List.empty(),
        totalTime: 0
      );
      expect(() => invalidItem.isValid(), throwsA(predicate((e) => e is ArgumentError)));
    });

    testWidgets('List tile tap triggers email sending', (WidgetTester tester) async {
      final mockSendEmail = MockFunction();
      await tester.pumpWidget(
        TimesheetPage(sendEmail: mockSendEmail), // Inject mock function
      );

      final listTileFinder = find.byType(ListTile);
      expect(listTileFinder, findsOneWidget);

      await tester.tap(listTileFinder); // Simulate tap on ListTile

      verify(mockSendEmail(any)); // Verify mock function is called with any argument
    });

    // Assuming you have a StreamProvider for timesheets
  testWidgets('Timesheet list updates with new data', (WidgetTester tester) async {
    final timesheetStream = StreamController<List<TimesheetItem>>();
    await tester.pumpWidget(
      StreamProvider<List<TimesheetItem>>(
        initialData: [],
        create: (_) => timesheetStream.stream,
        child: TimesheetPage(), // Replace with your widget name
      ),
    );

    // Simulate new data arriving
    timesheetStream.add([
      TimesheetItem(date: DateTime.now(), project: 'New Project', totalTime: 3),
    ]);
    await tester.pump(); // Rebuild the widget with new data

    final listFinder = find.byType(ListView);
    expect(listFinder, findsOneWidget); // Verify ListView exists
    expect(tester.widgetList(listFinder).length, 1); // Expect one list item
  });

   
  });
}


