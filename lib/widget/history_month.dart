import 'dart:convert';
import 'package:app_sit/widget/chart/chartAmountBar.dart';
import 'package:app_sit/widget/chart/chartBar.dart';
import 'package:app_sit/widget/chart/chartLine.dart';
// import 'package:app_sit/chart/chartPie.dart';
// import 'package:app_sit/chart/chartTestBar.dart';
// import 'package:app_sit/chart/chartTestBarTime.dart';
// import 'package:app_sit/chart/chartTestLine2.dart';
// import 'package:app_sit/chart/chartTestSliding.dart';
// import 'package:app_sit/chart/chartTestLine.dart';
import 'package:app_sit/models/month_history_data.dart';
import 'package:app_sit/services/userAPI.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mat_month_picker_dialog/mat_month_picker_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class History_Month extends StatefulWidget {
  const History_Month({super.key});

  @override
  State<History_Month> createState() => _History_MonthState();
}

Future<MonthHistoryData?> getHistoryMonth(
    String selectedMonthYear, String id, String urlIP) async {
  final url = '$urlIP/month_history/';
  try {
    final res = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'accountID': id,
        'monthYear': selectedMonthYear,
      }),
    );

    if (res.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(res.body);
      MonthHistoryData mhData = MonthHistoryData.fromJson(jsonResponse);
      print(res.body);
      return mhData;
    } else {
      print('Failed to get data: ${res.statusCode}');
      return null;
    }
  } catch (e) {
    print('An error occurred: $e');
    return null;
  }
}

class _History_MonthState extends State<History_Month> {
  String _selectedChart = 'sitDuration'; // Default chart selection
  String _selectedMonth = '';
  int month = 0;
  int year = 0;
  List<List<double>> line = [];
  List<List<int>> line2_1 = [];
  // List<List<int>> dataNull = [
  //   [0, 0]
  // ];
  List<List<int>> testData = [
    [10, 1],
    [15, 2],
    [11, 3],
    [5, 4],
    [1, 5],
    [1, 6],
    [1, 7],
    [1, 8],
    [1, 9],
    [3, 10],
    [1, 11],
    [8, 12],
    [12, 13],
    [1, 14],
    [15, 15],
    [1, 16],
    [1, 17],
    [1, 18],
    [1, 19],
    [12, 20],
    [12, 21],
    [1, 22],
    [1, 23],
    [1, 24],
    [1, 25],
    [1, 26],
    [1, 27],
    [1, 28],
    [15, 29],
    [11, 30],
    [30, 31]
  ];

  List<List<double>> testDataLine = [
    [120, 1],
    [50, 2],
    [230, 3],
    [330, 4],
    [40, 5],
    [320, 6],
    [120, 7],
    [340, 8],
    [440, 9],
    [550, 10],
    [101, 11],
    [230, 12],
    [330, 13],
    [440, 14],
    [960, 15],
    // [1140, 16],
    // [1, 17],
    // [1, 18],
    // [1, 19],
    // [12, 20],
    // [12, 21],
    // [1, 22],
    // [1, 23],
    // [1, 24],
    // [1, 25],
    // [1, 26],
    [1, 27],
    // [1, 28],
    // [15, 29],
    // [11, 30],
    // [30, 31]
  ];
  List<int> pieTest = [0, 1, 1, 1];
  List<List<double>> line2_2 = [];
  List<List<int>> pie = [];
  int selectedYear = DateTime.now().year; // Current year in Buddhist calendar
  MonthHistoryData? mhData;
  bool dataNull = true;

  @override
  void initState() {
    super.initState();
    // Set the default selected month to the current month and year
    final now = DateTime.now();
    _selectedMonth = '${now.month}-${now.year}';
    _fetchMonthHistory();
  }

  Future<void> _fetchMonthHistory() async {
    final data = await getHistoryMonth(
        _selectedMonth,
        Provider.of<UserAPI>(context, listen: false).user!.id,
        Provider.of<UserAPI>(context, listen: false).urlIP!);
    if (!mounted) return; // Check if the widget is still mounted
    setState(() {
      mhData = data;
      if (mhData != null) {
        // Convert data to line format (example logic, adapt as needed)
        line = mhData!.detectImgRecords
            .map((record) =>
                [record.sitDuration.toDouble(), record.day.toDouble()])
            .toList();
        line2_1 = mhData!.detectImgRecords
            .map((record) =>
                [record.amountSitOverLimit.toInt(), record.day.toInt()])
            .toList();
        line2_2 = mhData!.detectImgRecords
            .map((record) =>
                [record.sitLimitOnDay.toDouble(), record.day.toDouble()])
            .toList();
        pie = [
          [mhData!.totalMonthDetect.totalHead, 0],
          [mhData!.totalMonthDetect.totalBack, 1],
          [mhData!.totalMonthDetect.totalArm, 2],
          [mhData!.totalMonthDetect.totalLeg, 3],
        ];
        dataNull = false;
        print(
            "chart1:$line\nchart3:$line2_1\nchart3_1:$line2_2\nchart2 pie:$pie");
      } else {
        dataNull = true;
      }
    });
  }

  Widget _getSelectedChart(String chartType) {
    switch (chartType) {
      case 'sitDuration':
        return ChartLine(
          data: line,
          dataNull: dataNull,
        );
      case 'wrongNumber':
        return ChartAmountBar(
          data: pie,
          dataNull: dataNull,
        );
      case 'amountSitOverLimit':
        return ChartBar(
          data: line2_1,
          dataNull: dataNull,
        );
      // return Chart2Line(
      //   dataAmount: line2_1,
      //   dataTime: line2_2,
      // );
      // case 'Test Chart':
      //   return ChartTestBar(
      //     dataAmount: testData,
      //   );
      // case 'Test Chart Bar':
      //   return ChartTestLine(dataAmount: testDataLine);
      // case 'Test Chart Sliding':
      //   return ChartTestSliding();
      // case 'Test Chart Line':
      //   return ChartTestLine2(data: testDataLine);
      // case 'Test Chart Bar Time':
      //   return ChartTestBarTime(dataAmount: testData);
      default:
        return Container();
    }
  }

  Future<void> chooseMonth() async {
    final selectedMonth = await showMonthPicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );

    if (selectedMonth != null) {
      setState(() {
        // Format the selected month and year to display
        _selectedMonth = '${selectedMonth.month}-${selectedMonth.year}';
        month = selectedMonth.month;
        year = selectedMonth.year;
      });
      print(
          'Selected month and year: ${selectedMonth.month}-${selectedMonth.year}');
      _fetchMonthHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListView(
        children: [
          _buildSelector(),
          _getSelectedChart(_selectedChart),
        ],
      ),
    );
  }

  Widget __buildMonthYear() {
    return GestureDetector(
      onTap: () {
        chooseMonth();
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month, color: Colors.black),
            const SizedBox(width: 10),
            Text(
              _selectedMonth.isNotEmpty ? _selectedMonth : 'เดือน/ปี',
              style: GoogleFonts.mitr(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        __buildMonthYear(),
        const SizedBox(width: 20),
        DropdownButton<String>(
          value: _selectedChart,
          items: [
            DropdownMenuItem(
              value: 'sitDuration',
              child: Text(
                'ระยะเวลานั่งสะสม',
                style: GoogleFonts.mitr(fontSize: 16),
              ),
            ),
            DropdownMenuItem(
              value: 'wrongNumber',
              child: Text('จำนวนครั้งที่ผิดในแต่ละจุด',
                  style: GoogleFonts.mitr(fontSize: 16)),
            ),
            DropdownMenuItem(
              value: 'amountSitOverLimit',
              child: Text('จำนวนครั้งที่นั่งเกินระยะเวลา',
                  style: GoogleFonts.mitr(fontSize: 16)),
            ),
            // DropdownMenuItem(
            //   value: 'Test Chart',
            //   child: Text('Test Chart', style: GoogleFonts.mitr()),
            // ),
            // DropdownMenuItem(
            //   value: 'Test Chart Bar',
            //   child: Text('Test Chart', style: GoogleFonts.mitr()),
            // ),
            // DropdownMenuItem(
            //   value: 'Test Chart Sliding',
            //   child: Text('Test Chart', style: GoogleFonts.mitr()),
            // ),
            // DropdownMenuItem(
            //   value: 'Test Chart Line',
            //   child: Text('Test Chart', style: GoogleFonts.mitr()),
            // ),
            // DropdownMenuItem(
            //   value: 'Test Chart Bar Time',
            //   child: Text('Test Chart', style: GoogleFonts.mitr()),
            // ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedChart = value!;
            });
          },
          style: const TextStyle(
              color: Colors.black), // เปลี่ยนสีของข้อความใน DropdownButton
          icon: const Icon(Icons.arrow_drop_down,
              color: Colors.black), // เปลี่ยนสีของ icon ลูกศรลงมา
          underline: Container(
            // เพิ่มขอบสีดำ
            height: 2,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
