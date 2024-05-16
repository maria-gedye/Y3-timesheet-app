import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timesheet_app/models/work_item.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser!;

  Stream<List<WorkItem>> get workItems {
    return _firestore.collection('${user.email}').snapshots().map((QuerySnapshot querySnapshot) => 
      querySnapshot.docs
      .map((DocumentSnapshot documentSnapshot) => WorkItem(
        uniqueID: "UniqueID", 
        placeName: "PlaceName", 
        address: "Address", 
        workedTime: "WorkedTime", 
        startTime: "StartTime", 
        endTime: "EndTime", 
        dateTime: "DateTime")) 
      .toList());

// continue the firestore provider tutorial (6:16)
  }
}
