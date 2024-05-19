import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timesheet_app/models/work_item.dart';
import 'package:firebase_auth/firebase_auth.dart';


class DatabaseProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser!;

  Stream<List<WorkItem>> get workItems {
    return _firestore.collection('${user.email}').snapshots().map((QuerySnapshot querySnapshot) => 
      querySnapshot.docs
      .map((DocumentSnapshot snapshot) => WorkItem(
        
        uniqueID: snapshot['UniqueID'], 
        placeName: snapshot["PlaceName"], 
        address: snapshot["Address"], 
        workedTime: snapshot["WorkedTime"], 
        startTime: snapshot["StartTime"], 
        endTime: snapshot["EndTime"], 
        dateTime: snapshot["DateTime"])) 
      .toList());

  }
}

