import 'package:d_chart/commons/data_model.dart';
import 'package:d_chart/d_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChartTestBarTime extends StatefulWidget {
  final List<List<int>> dataAmount;
  const ChartTestBarTime({
    Key? key,
    required this.dataAmount,
  }) : super(key: key);

  @override
  State<ChartTestBarTime> createState() => _ChartTestBarTimeState();
}

class _ChartTestBarTimeState extends State<ChartTestBarTime> {
  @override
  Widget build(BuildContext context) {
    List<List<int>> dataAmount = widget.dataAmount;
    // List<List<int>> testData = [
    //   [10, 1], [15, 2], [5, 4], [3, 10],
    //   [8, 13], [12, 20], [12, 21], [15, 29],
    //   [11, 30], [30, 31]
    // ];

    // Convert testData to OrdinalData list
    List<TimeData> timeList = [];
    for (var sublist in dataAmount) {
      if (sublist.length >= 2) {
        timeList.add(TimeData(
          domain: DateTime(
              2024, 9, sublist[1]), // Use the second element as domain (date)
          measure: sublist[0], // Use the first element as measure
        ));
      }
    }

    final timeGroup = [
      TimeGroup(
        id: '1',
        data: timeList,
      ),
    ];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 3,
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              'จำนวนครั้งที่นั่งเกินเวลา',
              style: GoogleFonts.mitr(fontSize: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 6.0,
              right: 340.0,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'ครั้ง',
                textAlign: TextAlign.center,
                style: GoogleFonts.mitr(fontSize: 15),
              ),
            ),
          ),
          AspectRatio(
            aspectRatio: 0.9,
            child: DChartBarT(
              // Use the widget designed for ordinal bar charts
              animate: true,
              groupList: timeGroup, // Use ordinalGroup here
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 6.0,
              right: 178.0,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'วันที่',
                textAlign: TextAlign.center,
                style: GoogleFonts.mitr(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
