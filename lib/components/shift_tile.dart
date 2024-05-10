import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timesheet_app/components/delete_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timesheet_app/data/shift_data.dart';
import 'package:timesheet_app/models/shift_item.dart';
import 'package:provider/provider.dart';

class ShiftTile extends StatefulWidget {
  final String shiftDate;
  final String placeName;
  final String workedTime;
  final String uniqueID;

  const ShiftTile(
      {super.key,
      required this.shiftDate,
      required this.placeName,
      required this.workedTime,
      required this.uniqueID});

  @override
  State<ShiftTile> createState() => _ShiftTileState();
}

class _ShiftTileState extends State<ShiftTile> {
  // variables
  final user = FirebaseAuth.instance.currentUser!;

// methods
  void deleteShift() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Delete Shift'),
              content:
                  const Text('Are you sure you want to delete this entry?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    // delete from local data
                    List<ShiftItem> shiftList =
                        Provider.of<ShiftData>(context, listen: false)
                            .getAllShifts();

                    // loop through item in overallShiftList (shift_data.dart)
                    for (ShiftItem shift in shiftList) {
                      if (shift.uniqueID == widget.uniqueID) {
                        Provider.of<ShiftData>(context, listen: false)
                            .deleteShift(shift);
                        print('shift removed locally');
                      } else {
                        print('shift not found locally');
                      }
                    }

                    print("list length: ${shiftList.length}");
                    for (ShiftItem shift in shiftList) {
                      print(
                          "place: ${shift.placeName}, duration: ${shift.workedTime}");
                    }

                    // access firestore collection
                    CollectionReference collectionRef =
                        FirebaseFirestore.instance.collection('${user.email}');
                    // Write a query to find the desired document (e.g., by a specific field)
                    Query query = collectionRef.where('UniqueID',
                        isEqualTo: widget.uniqueID);
                    // Get a Future<QuerySnapshot> to handle the query result
                    Future<QuerySnapshot> querySnapshot = query.get();

                    // Process the query results and delete the document if found
                    querySnapshot.then((snapshot) {
                      if (snapshot.docs.isNotEmpty) {
                        DocumentReference documentRef =
                            snapshot.docs[0].reference;
                        // Call the delete method on the document reference
                        documentRef
                            .delete()
                            .then((value) => print('shift deleted'));
                      } else {
                        print(
                            'Document not found!'); // Handle case where document doesn't exist
                      }
                    }).catchError(
                        (error) => print('Error fetching documents: $error'));

                    Navigator.pop(context);
                  },
                  child: const Text('Delete'),
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      textColor: Colors.white,
      title: Text(widget.placeName),
      subtitle: Text("${widget.shiftDate} Total: ${widget.workedTime}"),
      trailing: DeleteButton(onTap: deleteShift),
    );
  }
}
