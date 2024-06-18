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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkItem && other.uniqueID == uniqueID;
  }

  @override
  int get hashCode => uniqueID.hashCode;

  toMap() {
    Map<String, dynamic> workItem = {
      'UniqueID': uniqueID,
      'PlaceName': placeName,
      'Address': address,
      'WorkedTime': workedTime,
      'StartTime': startTime,
      'EndTime': endTime,   
      'DateTime': dateTime,   
      'DateString': dateString
    };

    return workItem;
  }

  static fromMap(Map<String, dynamic> object) {
    WorkItem workItem = WorkItem(
      uniqueID: object["UniqueID"],
        placeName: object["PlaceName"],
        address: object["Address"],
        workedTime: object["WorkedTime"],
        startTime: object["StartTime"],
        endTime: object["EndTime"],
        dateString: object["DateString"],
        dateTime: object["DateTime"].toDate()
    );

    return workItem;
  }
}
