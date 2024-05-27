// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:timesheet_app/bar%20graph/individual_bar.dart';
// import 'package:provider/provider.dart';
// import 'package:timesheet_app/models/work_item.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class WorkBarGraph extends StatefulWidget {
//   final List<double> weeklySummary; // max of 24HRs
//   final int day; // 0 SUN, 1 MON ...

//   const WorkBarGraph({
//     super.key,
//     required this.weeklySummary,
//     required this.day,
//   });

//   @override
//   State<WorkBarGraph> createState() => _WorkBarGraphState();
// }

// class _WorkBarGraphState extends State<WorkBarGraph> {
//   List<IndividualBar> barData = [];

//   void initialiseBarData() {
//     barData = List.generate(widget.weeklySummary.length,
//         (index) => IndividualBar(x: index, y: widget.weeklySummary[index]));
//   }

//   // attempt2
//   Future<int> getTotalWorkedHoursForWeek(DateTime referenceDate) async {
//     final user = FirebaseAuth.instance.currentUser!;

//     // Get current week start and end dates (assuming Sunday as week start)
//     final weekStart = referenceDate
//         .subtract(Duration(days: referenceDate.weekday - DateTime.sunday));
//     final weekEnd = weekStart.add(Duration(days: DateTime.daysPerWeek - 1));

//     // Stream of WorkItems within the week
//     final workItemsStream = FirebaseFirestore
//         .instance // Assuming _firestore is your Firestore instance
//         .collection('${user.email}') // Assuming collection based on user email
//         .where('DateTime', isGreaterThanOrEqualTo: weekStart)
//         .where('DateTime', isLessThanOrEqualTo: weekEnd)
//         .snapshots();

//     // Calculate total worked hours
//     int totalWorkedHours = 0;
//     await for (var snapshot in workItemsStream) {
//       for (var doc in snapshot.docs) {
//         final workItem = WorkItem.fromFirestore(doc.data());
//         totalWorkedHours += workItem.workedHours;
//       }
//     }

//     return totalWorkedHours;
//   }

// // Future<Map<int, double>> calculateWeeklyHours() async {

// //   List<WorkItem> workList = Provider.of<List<WorkItem>>(context);

// //   // create map to collect total hours
// //   Map<int, double> weeklyTotals = {};
// // // accessing workItems to store dates and workedHours...
// //   for (var item in workList) {
// //     try {
// //       DateTime dateTime = DateTime.parse(item.dateTime);
// //       print(dateTime); // Output: 2024-05-23 10:20:30.000000Z

// //       int workDay = dateTime.day;
// //     // if day is not in map, initialise to 0
// //     if(!weeklyTotals.containsKey(week)) {
// //     weeklyTotals[week] = 0;
// //     }

// //     // add workedHours amount to the total for the week

// //     weeklyTotals[week] = weeklyTotals[week]!+ workedHours;

// //     } catch (e) {
// //       print("Invalid date format: $e");
// //       // Handle parsing error (optional)
// //     }
// //   }
// //     return weeklyTotals;
// // }

//   @override
//   Widget build(BuildContext context) {
//     return BarChart(
//       BarChartData(backgroundColor: Colors.white24, barGroups: [
//         BarChartGroupData(
//           x: 0, // change to day name
//           barRods: [
//             BarChartRodData(
//               toY: 10,
//               color: Color.fromRGBO(250, 195, 32, 1),
//             ), // displays a single bar
//           ],
//         ),
//         BarChartGroupData(
//           x: 1,
//           barRods: [
//             BarChartRodData(
//               toY: 16,
//               color: Color.fromRGBO(250, 195, 32, 1),
//             ), // displays a single bar
//           ],
//         ),
//         BarChartGroupData(
//           x: 2,
//           barRods: [
//             BarChartRodData(
//               toY: 1,
//               color: Color.fromRGBO(250, 195, 32, 1),
//             ), // displays a single bar
//           ],
//         ),
//         BarChartGroupData(
//           x: 3,
//           barRods: [
//             BarChartRodData(
//               toY: 1,
//               color: Color.fromRGBO(250, 195, 32, 1),
//             ), // displays a single bar
//           ],
//         ),
//         BarChartGroupData(
//           x: 4,
//           barRods: [
//             BarChartRodData(
//               toY: 1,
//               color: Color.fromRGBO(250, 195, 32, 1),
//             ), // displays a single bar
//           ],
//         ),
//         BarChartGroupData(
//           x: 5,
//           barRods: [
//             BarChartRodData(
//               toY: 1,
//               color: Color.fromRGBO(250, 195, 32, 1),
//             ), // displays a single bar
//           ],
//         ),
//         BarChartGroupData(
//           x: 6,
//           barRods: [
//             BarChartRodData(
//               toY: 1,
//               color: Color.fromRGBO(250, 195, 32, 1),
//             ), // displays a single bar
//           ],
//         ),
//       ]),
//       swapAnimationDuration: Duration(milliseconds: 150),
//       swapAnimationCurve: Curves.linear,
//     );

//     // return BarChart(
//     //   BarChartData(
//     //     minY: 0,
//     //     maxY: 100,
//     //   ),
//     //   swapAnimationDuration: Duration(milliseconds: 150),
//     //   swapAnimationCurve: Curves.linear,);
//   }
// }


