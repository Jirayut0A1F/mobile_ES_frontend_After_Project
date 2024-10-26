import 'package:flutter/material.dart';
import 'package:d_chart/d_chart.dart';
import 'package:google_fonts/google_fonts.dart'; // Import your chart package

class ChartTestSliding extends StatefulWidget {
  @override
  _ChartTestSlidingState createState() => _ChartTestSlidingState();
}

class _ChartTestSlidingState extends State<ChartTestSliding> {
  // You can add any state variables here if needed

  @override
  Widget build(BuildContext context) {
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
            aspectRatio: 16 / 9,
            child: DChartBarO(
              groupList: [
                OrdinalGroup(
                  id: 'id',
                  data: [
                    OrdinalData(domain: '1', measure: 1),
                    OrdinalData(domain: '2', measure: 2),
                    OrdinalData(domain: '3', measure: 3),
                    OrdinalData(domain: '4', measure: 4),
                    OrdinalData(domain: '5', measure: 5),
                    OrdinalData(domain: '6', measure: 6),
                    OrdinalData(domain: '7', measure: 7),
                    OrdinalData(domain: '8', measure: 8),
                    OrdinalData(domain: '9', measure: 9),
                    OrdinalData(domain: '10', measure: 10),
                    OrdinalData(domain: '12', measure: 12),
                    OrdinalData(domain: '13', measure: 13),
                    OrdinalData(domain: '14', measure: 14),
                  ],
                ),
              ],
              domainAxis: DomainAxis(
                ordinalViewport: OrdinalViewport('1', 5),
              ),
              measureAxis: const MeasureAxis(
                numericViewport: NumericViewport(0, 15),
              ),
              allowSliding: true,
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
