import 'package:app_sit/resources/app_resources.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class Chart2Line extends StatefulWidget {
  final List<List<double>> dataAmount;
  final List<List<double>> dataTime;

  const Chart2Line({Key? key, required this.dataAmount, required this.dataTime})
      : super(key: key);

  @override
  State<Chart2Line> createState() => _Chart2LineState();
}

class _Chart2LineState extends State<Chart2Line> {
  List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];

  List<Color> gradientColors2 = [
    AppColors.contentColorPink,
    AppColors.contentColorPurple,
  ];

  bool showAvg = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 3,
        ),
         Align(
          alignment: Alignment.center,
          child: Text(
            'จำนวนครั้งที่นั่งเกินเวลา',
            style: GoogleFonts.mitr(fontSize:20),
          ),
        ),
        Stack(
          children: <Widget>[
            //Text('\tวันที่'),
            AspectRatio(
              aspectRatio: 0.85,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 18,
                  left: 12,
                  top: 24,
                  bottom: 12,
                ),
                child: LineChart(
                  showAvg ? avgData() : mainData(),
                ),
              ),
            ),
            const Positioned(
              bottom: -2,
              right: 20,
              child: Text(
                'ครั้ง',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // เพิ่มชื่อแกน y
            const Positioned(
              top: 1,
              left: 4,
              child: Text(
                '\t\tวันที่',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Positioned(
              top: 1,
              right: 15,
              child: Text(
                '\t\tนาที',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              child: Row(
                children: <Widget>[
                  Container(
                    width: 12,
                    height: 12,
                    color: gradientColors[0],
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'จำนวนครั้งที่เกินระยะเวลาที่จำกัด',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Container(
                    width: 12,
                    height: 12,
                    color: gradientColors2[0],
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'ระยะเวลาที่จำกัด',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        // เพิ่มชื่อสำหรับกราฟเส้น 2 (สีเหลือง)
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    Widget text;
    switch (value.toInt()) {
      case 5:
        text = const Text('5', style: style);
        break;
      case 10:
        text = const Text('10', style: style);
        break;
      case 15:
        text = const Text('15', style: style);
        break;
      case 20:
        text = const Text('20', style: style);
        break;
      case 25:
        text = const Text('25', style: style);
        break;
      case 30:
        text = const Text('30', style: style);
        break;
      case 35:
        text = const Text('35', style: style);
        break;
      case 40:
        text = const Text('40', style: style);
        break;
      case 45:
        text = const Text('45', style: style);
        break;
      case 50:
        text = const Text('50', style: style);
        break;
      case 55:
        text = const Text('55', style: style);
        break;
      case 60:
        text = const Text('60', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget topTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    Widget text;
    switch (value.toInt()) {
      case 10:
        text = const Text('10', style: style);
        break;
      case 20:
        text = const Text('20', style: style);
        break;
      case 30:
        text = const Text('30', style: style);
        break;
      case 40:
        text = const Text('40', style: style);
        break;
      case 50:
        text = const Text('50', style: style);
        break;
      case 60:
        text = const Text('60', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      // case 1:
      //   text = '1';
      //   break;
      // case 2:
      //   text = '2';
      //   break;
      case 3:
        text = '3';
        break;
      // case 4:
      //   text = '4';
      //   break;
      // case 5:
      //   text = '5';
      //   break;
      case 6:
        text = '6';
        break;
      // case 7:
      //   text = '7';
      //   break;
      // case 8:
      //   text = '8';
      //   break;
      case 9:
        text = '9';
        break;
      // case 10:
      //   text = '10';
      //   break;
      // case 11:
      //   text = '11';
      //   break;
      case 12:
        text = '12';
        break;
      // case 13:
      //   text = '13';
      //   break;
      // case 14:
      //   text = '14';
      //   break;
      case 15:
        text = '15';
        break;
      // case 16:
      //   text = '16';
      //   break;
      // case 17:
      //   text = '17';
      //   break;
      case 18:
        text = '18';
        break;
      // case 19:
      //   text = '19';
      //   break;
      // case 20:
      //   text = '20';
      //   break;
      case 21:
        text = '21';
        break;
      // case 22:
      //   text = '22';
      //   break;
      // case 23:
      //   text = '23';
      //   break;
      case 24:
        text = '24';
        break;
      // case 25:
      //   text = '25';
      //   break;
      // case 26:
      //   text = '26';
      //   break;
      case 27:
        text = '27';
        break;
      // case 28:
      //   text = '28';
      //   break;
      // case 29:
      //   text = '29';
      //   break;
      case 30:
        text = '30';
        break;
      // case 31:
      //   text = '31';
      //   break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  LineChartData mainData() {
    List<FlSpot> spotsAmount =
        widget.dataAmount.map((data) => FlSpot(data[0], data[1])).toList();
    List<FlSpot> spotsTime =
        widget.dataTime.map((data) => FlSpot(data[0], data[1])).toList();
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 3,
        verticalInterval: 5,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            // color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            // color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
            reservedSize: 30,
            interval: 1,
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: topTitleWidgets,
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
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
      minX: 0,
      maxX: 60,
      minY: 1,
      maxY: 31,
      lineBarsData: [
        LineChartBarData(
          spots: spotsAmount,
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
        LineChartBarData(
          spots: spotsTime,
          isCurved: false,
          gradient: LinearGradient(
            colors: gradientColors2,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              // กำหนดสีของจุด
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.grey.shade200, // กำหนดสีของจุดที่นี่
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

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3.44),
            FlSpot(2.6, 3.44),
            FlSpot(4.9, 3.44),
            FlSpot(6.8, 3.44),
            FlSpot(8, 3.44),
            FlSpot(9.5, 3.44),
            FlSpot(11, 3.44),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
