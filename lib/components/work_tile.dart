import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timesheet_app/components/delete_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timesheet_app/data/work_data.dart';
import 'package:timesheet_app/models/work_item.dart';
import 'package:provider/provider.dart';

class WorkTile extends StatefulWidget {
  final String workDate;
  final String placeName;
  final String workedTime;
  final String uniqueID;

  const WorkTile(
      {super.key,
      required this.workDate,
      required this.placeName,
      required this.workedTime,
      required this.uniqueID});

  @override
  State<WorkTile> createState() => _WorkTileState();
}

class _WorkTileState extends State<WorkTile> {
  // variables
  final user = FirebaseAuth.instance.currentUser!;

// methods
  deleteWork() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Delete Work'),
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
                    List<WorkItem> workList =
                        Provider.of<WorkData>(context, listen: false)
                            .getAllWorks();

                    // loop through item in overallWorkList (work_data.dart)
                    for (WorkItem work in workList) {
                      if (work.uniqueID == widget.uniqueID) {
                        Provider.of<WorkData>(context, listen: false)
                            .deleteWork(work);
                        print('work removed locally');
                      } else {
                        print('work not found locally');
                      }
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
                            .then((value) => print('work deleted'));
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
    String shortDate = widget.workDate.substring(0, 10);

    return ListTile(
      textColor: Colors.white,
      title: Text(widget.placeName),
      subtitle: Text("$shortDate    Total: ${widget.workedTime}"),
      trailing: DeleteButton(onTap: deleteWork),
    );
  }
}

