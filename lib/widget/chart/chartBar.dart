import 'dart:math';

import 'package:app_sit/resources/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChartBar extends StatefulWidget {
  final List<List<int>> data;
  final bool dataNull;

  const ChartBar({super.key, required this.data, required this.dataNull});

  @override
  State<ChartBar> createState() => _ChartBarState();
}

class _ChartBarState extends State<ChartBar> {
  List<Color> gradientColors = [
    AppColors.contentColorBlue,
    AppColors.contentColorBlue,
  ];
  int maxValueY = 10;

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
              children: [
                // Align(
                //   alignment: Alignment.center,
                //   child: Text(
                //     'จำนวนครั้งที่นั่งเกินระยะเวลา',
                //     style: GoogleFonts.mitr(fontSize: 20),
                //   ),
                // ),
                const SizedBox(
                  height: 20,
                ),
                Stack(
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: 0.79,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 18,
                          left: 12,
                          top: 24,
                          bottom: 12,
                        ),
                        child: BarChart(
                          mainData(),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -1,
                      left: maxValueY > 999 ? 20 : 10,
                      child: Text(
                        '\tครั้ง',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.mitr(),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: -4,
                      left: 0,
                      child: Text(
                        'วันที่',
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
      // ถ้า maxValueY มากกว่า 30 ให้แสดงแค่ 5 เส้นโดยใช้ช่วง
      int interval = (maxValueY / 10).round(); // คำนวณช่วงของแต่ละเส้น
      if (value.toInt() % interval == 0) {
        if (value.toInt() > 999) {
          double sum = value / 1000;

          return Text('${sum.toStringAsFixed(1)}K',
              style: style, textAlign: TextAlign.center);
        } else {
          return Text(value.toInt().toString(),
              style: style, textAlign: TextAlign.center);
        }
      } else {
        return Container(); // ไม่แสดงเส้นสำหรับค่าอื่นๆ
      }
    } else {
      // ถ้า maxValueY น้อยกว่าหรือเท่ากับ 30 แสดงทุกๆ 2 หน่วย
      if (value.toInt() % 2 == 0) {
        return Text(value.toInt().toString(),
            style: style, textAlign: TextAlign.center);
      } else {
        return Container(); // ไม่แสดงเส้นสำหรับค่าอื่นๆ
      }
    }
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
      textAlign: TextAlign.center,
    );
  }

  BarChartData mainData() {
    int interval = (maxValueY / 10).round();
    if (widget.data.isNotEmpty) {
      maxValueY = ((widget.data.map((item) => item[0]).reduce(max)));
    }
    interval = (maxValueY / 10).round();
    List<BarChartGroupData> barGroups = widget.data.map((data) {
      return BarChartGroupData(
        x: data[1].toInt(),
        barRods: [
          BarChartRodData(
            toY: data[0].toDouble(),
            gradient: LinearGradient(
              colors: gradientColors,
            ),
            width: 20,
            borderRadius: BorderRadius.zero,
          ),
        ],
      );
    }).toList();

    return BarChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: maxValueY > 30 ? interval.toDouble() : 2,
        verticalInterval: 3,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            strokeWidth: 0.5,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            strokeWidth: 1,
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
            reservedSize: 24,
            interval: 1,
            getTitlesWidget: widget.data.length > 15
                ? bottomTitleWidgets
                : bottomTitleWidgetsMin,
          ),
        ),
        leftTitles: AxisTitles(
          drawBelowEverything: true,
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: maxValueY > 999 ? 55 : 31,
            interval: 2,
            getTitlesWidget: leftTitleWidgets,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      barGroups: barGroups.isNotEmpty ? barGroups : _emptyBarGroups(),
      alignment: BarChartAlignment.spaceAround,
    );
  }

  List<BarChartGroupData> _emptyBarGroups() {
    return List.generate(31, (index) {
      return BarChartGroupData(
        x: index + 1,
        barRods: [
          BarChartRodData(
            toY: 0,
            gradient: LinearGradient(
              colors: gradientColors,
            ),
          ),
        ],
      );
    });
  }
}
