import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:timesheet_app/models/work_item.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:timesheet_app/providers/database_provider.dart';

class WeeklyBarChart extends StatefulWidget {
  const WeeklyBarChart({Key? key}) : super(key: key);

  @override
  State<WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<WeeklyBarChart> {
  final DatabaseProvider _databaseProvider = DatabaseProvider();
  final List<String> xAxisLabels = [
    'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday'
];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WorkItem>>(
      stream: _databaseProvider.workItems, // Access the stream
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // query for data that exists in the current week here
          final workItems = snapshot.data!; // Get the list of WorkItems
          final chartData = _getChartData(workItems); // Convert to chart data
          return BarChart(
            BarChartData(    
              minY: 0,
              maxY: 20,
              backgroundColor: Colors.white10,
              barGroups: chartData,
              borderData: FlBorderData(
                show: false, // Optional: hide chart border
              ),
            titlesData: FlTitlesData(
              show: true,
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: getTitles,
                  reservedSize: 30,
                ),
              ),
            ),
            ),
            
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return const CircularProgressIndicator(); // Loading indicator
      },
    );
  }

//methods
  List<BarChartGroupData> _getChartData(List<WorkItem> workItems) {
    final List<BarChartGroupData> chartData = [];
  for (int i = 0; i < xAxisLabels.length; i++) {
    final day = xAxisLabels[i];
    double workedHours = 0.0; // Initialize workedHours for each day
    int hours, minutes;

    for (final workItem in workItems) {
      DateTime dateTime = DateTime.parse(workItem.dateTime);
      if (DateFormat('EEEE').format(dateTime) == day) {
        String timeString = workItem.workedTime;
        RegExp regex = RegExp(
            r"^(\d+)hrs (\d+)min"); // Match digits followed by "hrs" and "min"

        Match? match = regex.firstMatch(timeString);
        if (match != null) {
          String hoursString = match.group(1)!;
          String minutesString = match.group(2)!;
          hours = int.parse(hoursString);
          minutes = int.parse(minutesString);
          // Convert total time to hours (considering minutes as fractions of hours)
          workedHours = hours + minutes / 60.0;
        } else {
          // Handle invalid format (e.g., only "hrs")
          print("Invalid time format: $timeString");
          hours = 0; // Or provide a default value
          minutes = 0;
          workedHours = 0;
        }

      }
    }
    
    chartData.add(
      BarChartGroupData(
        x: i, // Use index for X-axis positioning
        barRods: [
          BarChartRodData(
            toY: workedHours, // Total worked hours for the day
            color: Color.fromRGBO(250, 195, 32, 1), // Set bar color
          ),
        ],
      ),
    );
  }
  return chartData;
  
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('S', style: style);
        break;
      case 1:
        text = const Text('M', style: style);
        break;
      case 2:
        text = const Text('T', style: style);
        break;
      case 3:
        text = const Text('W', style: style);
        break;
      case 4:
        text = const Text('T', style: style);
        break;
      case 5:
        text = const Text('F', style: style);
        break;
      case 6:
        text = const Text('S', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }


}
