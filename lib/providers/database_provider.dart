import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timesheet_app/models/work_item.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser!;

// create a get weeklyWorkItems
  Stream<List<WorkItem>> get weeklyWorkItems {
    DateTime now = DateTime.now();
    DateTime startDate =
        now.subtract(Duration(days: now.weekday - 1)); // Start of current week
    DateTime endDate = startDate
        .add(Duration(days: 6)); // End of current week (including Saturday)

    return _firestore
        .collection('${user.email}')
        .where('DateTime', isGreaterThanOrEqualTo: startDate)
        .where('DateTime', isLessThanOrEqualTo: endDate)
        .snapshots()
        .map((QuerySnapshot querySnapshot) {
          
      // print(
      //     "Fetched documents: ${querySnapshot.docs.length} /n start: $startDate  \n  end:  $endDate"); // Check the number of documents
return
      querySnapshot.docs
          .map((DocumentSnapshot snapshot) => WorkItem(
              uniqueID: snapshot['UniqueID'],
              placeName: snapshot["PlaceName"],
              address: snapshot["Address"],
              workedTime: snapshot["WorkedTime"],
              startTime: snapshot["StartTime"],
              endTime: snapshot["EndTime"],
              dateString: snapshot["DateString"],
              dateTime: snapshot["DateTime"].toDate()))
          .toList();
    });
  }

// get all workItems
  Stream<List<WorkItem>> get workItems {
    return _firestore.collection('${user.email}').snapshots().map(
        (QuerySnapshot querySnapshot) => querySnapshot.docs
            .map((DocumentSnapshot snapshot) => WorkItem(
                uniqueID: snapshot['UniqueID'],
                placeName: snapshot["PlaceName"],
                address: snapshot["Address"],
                workedTime: snapshot["WorkedTime"],
                startTime: snapshot["StartTime"],
                endTime: snapshot["EndTime"],
                dateString: snapshot["DateString"],
                dateTime: snapshot["DateTime"].toDate()))
            .toList());
  }
}
