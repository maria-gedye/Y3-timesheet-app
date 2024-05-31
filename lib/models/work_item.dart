class WorkItem {
  final String uniqueID;
  final String placeName;
  final String address;
  final String workedTime;
  final String startTime;
  final String endTime;
  final String dateString;
  final DateTime dateTime;

  WorkItem({
    required this.uniqueID,
    required this.placeName,
    required this.address,
    required this.workedTime,
    required this.startTime,
    required this.endTime,
    required this.dateString,
    required this.dateTime,
  });
}
