import 'package:timesheet_app/models/work_item.dart';

class TimesheetItem {
  final String? uniqueID;
  final List<WorkItem> workItems;
  final DateTime weekStarting;
  final double totalTime;

  TimesheetItem({
    required this.uniqueID,
    required this.workItems,
    required this.weekStarting,
    required this.totalTime
    });
}
