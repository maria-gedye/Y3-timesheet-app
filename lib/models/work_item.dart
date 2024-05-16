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

  // constructor to map firestore properties to WorkItem properties
  WorkItem.fromMap(Map<String, dynamic> map)
      : assert(map['UniqueID'] != null),
        assert(map['PlaceName'] != null),
        assert(map['Address'] != null),
        assert(map['WorkedTime'] != null),
        assert(map['StartTime'] != null),
        assert(map['EndTime'] != null),
        assert(map['DateTime'] != null),
        uniqueID = map['UniqueID'],
        placeName = map['PlaceName'],
        address = map['Address'],
        workedTime = map['WorkedTime'],
        startTime = map['StartTime'],
        endTime = map['EndTime'],
        dateTime = map['DateTime'];

  @override
  String toString() => "Record <$uniqueID:$placeName:$workedTime>";
}
