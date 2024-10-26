import 'package:app_sit/resources/app_resources.dart';
import 'package:app_sit/widget/indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChartPie extends StatefulWidget {
  final List<int> data;

  const ChartPie({Key? key, required this.data}) : super(key: key);

  @override
  State<ChartPie> createState() => _ChartPieState();
}

class _ChartPieState extends State<ChartPie> {
  int touchedIndex = -1;
  @override
  Widget build(BuildContext context) {
    // Color headColor= Color(0xFFFF595E);

    return widget.data.isNotEmpty
        ? AspectRatio(
            aspectRatio: 0.9,
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                // Align(
                //   alignment: Alignment.center,
                //   child: Text(
                //     'จำนวนครั้งที่ผิดในแต่ละจุด',
                //     style: GoogleFonts.mitr(fontSize: 20),
                //   ),
                // ),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        sectionsSpace: 10,
                        centerSpaceRadius: 70,
                        startDegreeOffset: 180,
                        sections: showingSections(),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      children: [
                        const Indicator(
                          color: Color(0xFFFF595E),
                          text: '',
                          isSquare: false,
                        ),
                        Text('ศีรษะ', style: GoogleFonts.mitr(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      children: [
                        const Indicator(
                          color: Color(0xFFFFCA3A),
                          text: '',
                          isSquare: false,
                        ),
                        Text(
                          'หลัง',
                          style: GoogleFonts.mitr(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      children: [
                        const Indicator(
                          color: Color(0xFF8AC926),
                          text: '',
                          isSquare: false,
                        ),
                        Text(
                          'แขน',
                          style: GoogleFonts.mitr(fontSize: 16),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      children: [
                        const Indicator(
                          color: Color(0xFF1982C4),
                          text: '',
                          isSquare: false,
                        ),
                        Text(
                          'ขา',
                          style: GoogleFonts.mitr(fontSize: 16),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
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

  List<PieChartSectionData> showingSections() {
    if (widget.data.length < 4) {
      return [];
    }
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      int numHead = widget.data[0];
      int numBack = widget.data[1];
      int numArm = widget.data[2];
      int numLeg = widget.data[3];

      return PieChartSectionData(
        color: i == 0
            ? const Color(0xFFFF595E)
            : i == 1
                ? const Color(0xFFFFCA3A)
                : i == 2
                    ? const Color(0xFF8AC926)
                    : const Color(0xFF1982C4),
        value: i == 0
            ? numHead.toDouble()
            : i == 1
                ? numBack.toDouble()
                : i == 2
                    ? numArm.toDouble()
                    : numLeg.toDouble(),
        title: i == 0
            ? '$numHead'
            : i == 1
                ? '$numBack'
                : i == 2
                    ? '$numArm'
                    : '$numLeg',
        radius: radius,
        titleStyle: GoogleFonts.mitr(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.mainTextColor1,
          shadows: shadows,
        ),
      );
    });
  }
}
