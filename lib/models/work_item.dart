// please add address properties to all methods posting WorkItems (dialog, tracker)
// remove old documents in firestore and create new entries with the corrected props
// test bar graph
class WorkItem {
  final String uniqueID;
  final String placeName;
  final String address;
  final String workedTime;
  final String startTime;
  final String endTime;
  final String dateTime;

  WorkItem({
    required this.uniqueID,
    required this.placeName,
    required this.address,
    required this.workedTime,
    required this.startTime,
    required this.endTime,
    required this.dateTime,
  });

  
  @override
  String toString() => "Record <$uniqueID:$placeName:$workedTime>";
}
