import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:timesheet_app/bar%20graph/bar_graph.dart';
import 'package:timesheet_app/components/work_tile.dart';
import 'package:timesheet_app/components/work_dialog.dart';
import 'package:timesheet_app/components/weekly_hours_box.dart';
import 'package:timesheet_app/pages/timesheet_page.dart';

import 'package:provider/provider.dart';
import 'package:timesheet_app/data/work_data.dart';
import 'package:timesheet_app/models/work_item.dart';
import 'package:timesheet_app/tracker/time_tracker.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
// state variables...
  String titleOfTab = 'Work Tracker';
  final user = FirebaseAuth.instance.currentUser!;
  final _key = GlobalKey<ExpandableFabState>();

  //sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

// uses Work_dialog component
  void addWorkDialog() {
    showDialog(context: context, builder: (context) => WorkDialog());
  }

  // builds ui as...
  @override
  Widget build(BuildContext context) {
    // call firestore provider
    List<WorkItem> workList = Provider.of<List<WorkItem>>(context);

    return Consumer<WorkData>(builder: (context, value, child) {
      return DefaultTabController(
          length: 3,
          initialIndex: 1,
          child: Scaffold(
              // extended fab
              floatingActionButtonLocation: ExpandableFab.location,
              floatingActionButton: ExpandableFab(
                key: _key,
                overlayStyle: ExpandableFabOverlayStyle(
                  // color: Colors.black.withOpacity(0.5),
                  blur: 5,
                ),
                children: [
                  // add work shift button
                  FloatingActionButton.large(
                    // shape: const CircleBorder(),
                    heroTag: null,
                    onPressed: () {
                      addWorkDialog();
                      final state = _key.currentState;
                      if (state != null) {
                        debugPrint('isOpen:${state.isOpen}');
                        state.toggle();
                      }
                    },
                    child: const Icon(Icons.work),
                  ),
                  // create timesheet button
                  FloatingActionButton.large(
                    heroTag: null,
                    child: const Icon(Icons.view_timeline),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: ((context) => const TimesheetPage())));
                      final state = _key.currentState;
                      if (state != null) {
                        debugPrint('isOpen:${state.isOpen}');
                        state.toggle();
                      }
                    },
                  ),
                ],
              ),
              backgroundColor: Color.fromRGBO(64, 46, 50, 1),
              appBar: AppBar(
                // backlog change titles as user selects different tabs
                title: Text(titleOfTab),
                backgroundColor: Color.fromRGBO(64, 46, 50, 1),
                bottom: const TabBar(
                  tabs: <Widget>[
                    Tab(
                      icon: Icon(Icons.person_2_rounded,
                          color: Color.fromRGBO(164, 142, 101, 1), size: 30),
                    ),
                    Tab(
                      icon: Icon(
                        Icons.punch_clock_rounded,
                        color: Color.fromRGBO(250, 195, 32, 1),
                        size: 40.0,
                      ),
                    ),
                    Tab(
                      icon: Icon(Icons.menu_book_rounded,
                          color: Color.fromRGBO(164, 142, 101, 1), size: 30),
                    ),
                  ],
                ),
              ),

              // main body
              body: SafeArea(
                child: TabBarView(children: <Widget>[
                  // user tab
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Logged in as ${user.email!}",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        SizedBox(height: 20),
                        IconButton(
                          onPressed: signUserOut,
                          icon: Icon(Icons.logout),
                          color: Colors.white,
                          iconSize: 30,
                        ),
                      ],
                    ),
                  ),
                  // tracker tab
                  Center(
                    child: SingleChildScrollView(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        WorkTracker(),
                        SizedBox(height: 10),

                        // total hours worked card
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: WeeklyHoursBox(),
                        ),
                      ],
                    )),
                  ),
                  // WOrkbook tab
                  Center(
                    child: Column(children: [
                      // Bar GRAPH
                      Container(
                          padding: EdgeInsets.only(top: 30),
                          height: 200,
                          child: WeeklyBarChart()),
                      SizedBox(height: 20),
                      Text(
                        "All Entries",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),

                      Expanded(
                        // Work LIST
                        child: ListView.builder(
                          itemCount: workList.length,
                          itemBuilder: (context, index) {
                            return WorkTile(
                              uniqueID: workList[index].uniqueID,
                              placeName: workList[index].placeName,
                              workedTime: workList[index].workedTime,
                              workDate: workList[index].dateString,
                            );
                          },
                        ),
                      ),
                    ]),
                  ),
                ]),
              )));
    });
  }
}
