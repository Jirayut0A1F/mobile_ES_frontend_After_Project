import 'package:d_chart/commons/data_model.dart';
import 'package:d_chart/d_chart.dart'; // Ensure this supports the widget needed
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChartTestBar extends StatefulWidget {
  final List<List<int>> dataAmount;
  const ChartTestBar({
    Key? key,
    required this.dataAmount,
  }) : super(key: key);

  @override
  State<ChartTestBar> createState() => _ChartTestBarState();
}

class _ChartTestBarState extends State<ChartTestBar> {
  @override
  Widget build(BuildContext context) {
    List<List<int>> dataAmount = widget.dataAmount;

    // Convert testData to OrdinalData list
    List<OrdinalData> ordinalList = [];
    for (var sublist in dataAmount) {
      if (sublist.length >= 2) {
        ordinalList.add(OrdinalData(
          domain:
              sublist[1].toString(), // Use the second element as domain (date)
          measure: sublist[0], // Use the first element as measure
        ));
      }
    }

    final ordinalGroup = [
      OrdinalGroup(
        id: '1',
        data: ordinalList,
        color: Colors.blue,
        // seriesCategory: 
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
            child: DChartBarO(
              // Use the widget designed for ordinal bar charts
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
