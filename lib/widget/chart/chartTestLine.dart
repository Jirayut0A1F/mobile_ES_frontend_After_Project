import 'package:d_chart/commons/data_model.dart';
import 'package:d_chart/d_chart.dart'; // Make sure this imports `DChartComboO`
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChartTestLine extends StatefulWidget {
  final List<List<double>> dataAmount;
  const ChartTestLine({
    Key? key,
    required this.dataAmount,
  }) : super(key: key);

  @override
  State<ChartTestLine> createState() => _ChartTestLineState();
}

class _ChartTestLineState extends State<ChartTestLine> {
  @override
  Widget build(BuildContext context) {
    // List<List<int>> testData = [
    //   [10, 1], [15, 2], [5, 4], [3, 10],
    //   [8, 13], [12, 20], [12, 21], [15, 29],
    //   [11, 30], [30, 31]
    // ];

    // Convert testData to OrdinalData list
    List<OrdinalData> ordinalList = [];
    for (var sublist in widget.dataAmount) {
      if (sublist.length >= 2) {
        ordinalList.add(OrdinalData(
          domain:
              sublist[1].toInt().toString(), // Use the second element as domain
          measure: ((sublist[0] / 60 * 100).roundToDouble()) /
              100, // Use the first element as measure
        ));
      }
    }

    final ordinalGroup = [
      OrdinalGroup(
        id: '1',
        data: ordinalList,
        color: Colors.blue,
      ),
      // You can add more groups if needed
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
              'ระยะเวลานั่งรวม',
              style: GoogleFonts.mitr(fontSize: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 6.0,
              right: 325.0,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'ชั่วโมง',
                textAlign: TextAlign.center,
                style: GoogleFonts.mitr(fontSize: 15),
              ),
            ),
          ),
          AspectRatio(
            aspectRatio: 0.9,
            child: DChartComboO(
              // Use DChartComboO for OrdinalGroup
              animate: true,
              groupList: ordinalGroup, // Use ordinalGroup here
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
