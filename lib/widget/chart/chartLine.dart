import 'dart:math';

import 'package:app_sit/resources/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class ChartLine extends StatefulWidget {
  final List<List<double>> data;
  final bool dataNull;

  const ChartLine({super.key, required this.data, required this.dataNull});

  @override
  State<ChartLine> createState() => _ChartLineState();
}

class _ChartLineState extends State<ChartLine> {
  List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];
  double maxValueY = 10;

  @override
  void initState() {
    super.initState();
    if (widget.data.isNotEmpty) {
      maxValueY = ((widget.data.map((item) => item[0]).reduce(max)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return !widget.dataNull
        ? Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                // Align(
                //   alignment: Alignment.center,
                //   child: Text(
                //     'ระยะเวลานั่งสะสม',
                //     style: GoogleFonts.mitr(fontSize: 20),
                //   ),
                // ),
                const SizedBox(
                  height: 20,
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
                      left: maxValueY > 999 ? 20 : 10,
                      child: Text(
                        '\tนาที',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.mitr(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        : Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                'ไม่มีข้อมูล',
                style: GoogleFonts.mitr(fontSize: 30),
              ),
            ),
          );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    TextStyle style = GoogleFonts.mitr(
      fontSize: 15,
    );
    if (maxValueY > 30) {
      int interval = (maxValueY / 10).round();
      if (value.toInt() % interval == 0) {
        return Text(value.toInt().toString(),
            style: style, textAlign: TextAlign.center);
      } else {
        return Container();
      }
    } else {
      if (value.toInt() % 2 == 0) {
        return Text(value.toInt().toString(),
            style: style, textAlign: TextAlign.center);
      } else {
        return Container(); // ไม่แสดงเส้นสำหรับค่าอื่นๆ
      }
    }
  }

  Widget leftTitleWidgetMin(double value, TitleMeta meta) {
    TextStyle style = GoogleFonts.mitr(
      fontSize: 15,
    );
    return Text(value.toInt().toString(),
        style: style, textAlign: TextAlign.center);
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    TextStyle style = GoogleFonts.mitr(fontSize: 15);
    int intValue = value.toInt();

    if (intValue % 3 == 0) {
      return Text(
        intValue.toString(),
        style: style,
        textAlign: TextAlign.center,
      );
    } else {
      return Container();
    }
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
    // double maxValueY = 0;
    int interval = (maxValueY / 10).round();
    double maxValueX = 0;
    if (widget.data.isNotEmpty) {
      // maxValueY = ((widget.data.map((item) => item[0]).reduce(max)) / 60)
      //     .roundToDouble();
      maxValueY = widget.data.map((item) => item[0]).reduce(max);
    }
    if (widget.data.isNotEmpty) {
      maxValueX =
          (widget.data.map((item) => item[1]).reduce(max)).roundToDouble();
    }
    // double maxY = maxValueY % 2 == 0 ? maxValueY + 2 : maxValueY + 1;
    interval = (maxValueY / 10).round();
    List<FlSpot> spots =
        widget.data.map((data) => FlSpot(data[1], data[0])).toList();
    print(maxValueY);

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: maxValueY > 30 ? interval.toDouble() : 2,
        verticalInterval: maxValueX > 15 ? 3 : 2,
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
            getTitlesWidget:
                maxValueX > 15 ? bottomTitleWidgets : bottomTitleWidgetsMin,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: maxValueY > 999 ? 55 : 31,
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
      maxY: maxValueY,
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
