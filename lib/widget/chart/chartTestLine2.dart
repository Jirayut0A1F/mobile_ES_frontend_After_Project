import 'dart:math';

import 'package:app_sit/resources/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class ChartTestLine2 extends StatefulWidget {
  final List<List<double>> data;

  const ChartTestLine2({Key? key, required this.data}) : super(key: key);

  @override
  State<ChartTestLine2> createState() => _ChartTestLine2State();
}

class _ChartTestLine2State extends State<ChartTestLine2> {
  List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];
  // final List<List<double>> rawData = [
  //   [4.3, 1],
  //   [5, 3],
  //   [7.5, 6],
  //   [2, 7],
  //   [9.3, 8],
  //   [10.4, 10],
  //   [12, 12],
  // ];
  // bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            'ระยะเวลานั่งรวม',
            style: GoogleFonts.mitr(fontSize: 20),
          ),
        ),
        Stack(
          children: <Widget>[
            //Text('\tวันที่'),
            AspectRatio(
              aspectRatio: 0.79,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 18,
                  left: 12,
                  top: 24,
                  bottom: 12,
                ),
                child: LineChart(
                  mainData(),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              left: 0,
              child: Text(
                'วันที่',
                textAlign: TextAlign.center,
                style: GoogleFonts.mitr(),
              ),
            ),
            // เพิ่มชื่อแกน y
            Positioned(
              top: -1,
              left: 1,
              child: Text(
                '\tชั่วโมง',
                textAlign: TextAlign.center,
                style: GoogleFonts.mitr(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    TextStyle style = GoogleFonts.mitr(
      fontSize: 15,
    );
    if (value.toInt() % 2 == 0) {
      return Text(value.toInt().toString(),
          style: style, textAlign: TextAlign.left);
    } else {
      return Container(); // Return an empty container for odd numbers
    }
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    TextStyle style = GoogleFonts.mitr(fontSize: 15);
    int intValue = value.toInt();

    if (intValue % 3 == 0) {
      return Text(
        intValue.toString(),
        style: style,
        textAlign: TextAlign.left,
      );
    } else
      return Container();
  }

  Widget bottomTitleWidgetsMin(double value, TitleMeta meta) {
    TextStyle style = GoogleFonts.mitr(fontSize: 15);
    int intValue = value.toInt();

    return Text(
      intValue.toString(),
      style: style,
      textAlign: TextAlign.left,
    );
  }

  LineChartData mainData() {
    double maxValue =
        ((widget.data.map((item) => item[0]).reduce(max)) / 60).roundToDouble();
    double maxY = maxValue % 2 == 0 ? maxValue + 2 : maxValue + 1;
    List<FlSpot> spots = widget.data
        .map((data) =>
            FlSpot(data[1], (data[0] / 60 * 100).roundToDouble() / 100))
        .toList();
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 2,
        verticalInterval: 3,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            // color: AppColors.mainGridLineColor,
            strokeWidth: 0.5,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            // color: AppColors.mainGridLineColor,
            strokeWidth: 0.5,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: widget.data.length > 15
                ? bottomTitleWidgets
                : bottomTitleWidgetsMin,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 30,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      // minX: 1,
      // maxX: 31,
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              // กำหนดสีของจุด
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.red, // กำหนดสีของจุดที่นี่
              );
            },
          ),
          belowBarData: BarAreaData(
            show: false,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
