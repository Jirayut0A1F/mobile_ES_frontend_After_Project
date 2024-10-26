import 'dart:convert';
import 'dart:typed_data';

// import 'package:app_sit/models/daily_Image_data.dart';
// import 'package:app_sit/models/daily_history_data.dart';
import 'package:app_sit/models/history_daily_data.dart';
import 'package:app_sit/services/userAPI.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class History_Day extends StatefulWidget {
  const History_Day({super.key});

  @override
  State<History_Day> createState() => _History_DayState();
}

Future<HistoryDailyData?> getHistoryDate(String selectedDate, String id) async {
  const url = 'http://43.229.133.174:8000/daily_history_data_img/';
  try {
    final res = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'accountID': id,
        'date': selectedDate,
      }),
    );

    if (res.statusCode == 200) {
      // print(res.body);
      final Map<String, dynamic> jsonResponse = jsonDecode(res.body);
      // print(jsonResponse);
      HistoryDailyData dateData = HistoryDailyData.fromJson(jsonResponse);
      print(dateData);
      return dateData;
    } else {
      print('Failed to get data: ${res.statusCode}');
      return null;
    }
  } catch (e) {
    print('An error occurred: $e');
    return null;
  }
}

class _History_DayState extends State<History_Day> {
  TextEditingController _dateController = TextEditingController();
  HistoryDailyData? dateData;
  int? head;
  int? back;
  int? arm;
  int? leg;
  int? sitDuration;
  int? amountSitOverLimit;
  List<DetectList> detectList = [];
  bool isLoading = true;
  bool dataNull = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd').format(now);
    _fetchDateHistory(_dateController.text);
  }

  Future<void> _fetchDateHistory(String date) async {
    setState(() {
      isLoading = true; // เริ่มโหลดข้อมูล
    });
    final data = await getHistoryDate(
        date, Provider.of<UserAPI>(context, listen: false).user!.id);
    if (mounted) {
      setState(() {
        dateData = data;
        if (dateData != null) {
          head = dateData?.head;
          back = dateData?.back;
          arm = dateData?.arm;
          leg = dateData?.leg;
          sitDuration = dateData?.sitDuration;
          amountSitOverLimit = dateData?.amountSitOverLimit;
          detectList = dateData!.detectList;
          dataNull = false;
        } else {
          // ignore: avoid_print
          print("data is null");
          dataNull = true;
        }
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Card(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                // width: 350,
                // height: 50,
                child: TextField(
                  controller: _dateController,
                  style: GoogleFonts.mitr(),
                  decoration: InputDecoration(
                    labelText: 'วันที่',
                    labelStyle: GoogleFonts.mitr(),
                    filled: true,
                    prefixIcon: const Icon(Icons.calendar_today),
                    enabledBorder:
                        const OutlineInputBorder(borderSide: BorderSide.none),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  readOnly: true,
                  onTap: () {
                    chooseDate();
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    dataNull
                        ? 'นั่งสะสม (นาที): 0'
                        : 'นั่งสะสม (นาที): ${formatNumber(sitDuration ?? 0)}',
                    style: GoogleFonts.mitr(fontSize: 16),
                  ),
                  Text(
                    dataNull
                        ? 'นั่งเกินระยะเวลา (ครั้ง): 0'
                        : 'นั่งเกินระยะเวลา (ครั้ง): ${formatNumber(amountSitOverLimit ?? 0)}',
                    style: GoogleFonts.mitr(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              Align(
                child: Text(
                  'จุดที่ผิด',
                  style: GoogleFonts.mitr(fontSize: 25),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    dataNull
                        ? 'ศีรษะ (ครั้ง): 0'
                        : 'ศีรษะ (ครั้ง): ${formatNumber(head ?? 0)}',
                    style: GoogleFonts.mitr(fontSize: 16),
                  ),
                  Text(
                    dataNull
                        ? 'หลัง (ครั้ง): 0'
                        : 'หลัง (ครั้ง): ${formatNumber(back ?? 0)}',
                    style: GoogleFonts.mitr(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    dataNull
                        ? 'แขน (ครั้ง): 0'
                        : 'แขน (ครั้ง): ${formatNumber(arm ?? 0)}',
                    style: GoogleFonts.mitr(fontSize: 16),
                  ),
                  Text(
                    dataNull
                        ? 'ขา (ครั้ง): 0'
                        : 'ขา (ครั้ง): ${formatNumber(leg ?? 0)}',
                    style: GoogleFonts.mitr(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        Expanded(
            child: MyListView(
          data: detectList,
          isLoading: isLoading,
          dataNull: dataNull,
        )),
      ],
    );
  }

  String formatNumber(int value) {
    final formatter = NumberFormat('#,###');
    return formatter.format(value);
  }

  Future<void> chooseDate() async {
    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (_picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(_picked);
      });
      _fetchDateHistory(_dateController.text);
      // _fetchDateHistoryImage(_dateController.text);
      print(_dateController.text);
    }
  }

  // @override
  // void dispose() {
  //   _dateController.dispose();
  //   super.dispose();
  // }
}

class MyListView extends StatelessWidget {
  final List<DetectList> data;
  final bool isLoading;
  final bool dataNull;
  const MyListView(
      {super.key,
      required this.data,
      required this.isLoading,
      required this.dataNull});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child:
            CircularProgressIndicator(), // แสดงวงกลมโหลดเมื่อ isLoading เป็น true
      );
    }
    if (dataNull) {
      return Center(
        child: Text(
          'ไม่มีข้อมูล', // แสดงข้อความนี้ถ้า detectList ไม่มีข้อมูล
          style: GoogleFonts.mitr(fontSize: 18),
        ),
      );
    }
    if (data.isEmpty) {
      return Center(
        child: Text(
          'ไม่มีข้อมูล', // แสดงข้อความนี้ถ้า detectList ไม่มีข้อมูล
          style: GoogleFonts.mitr(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: data.length,
      itemBuilder: (context, index) {
        DetectList detect = data[index];
        // int number = detect.detectId;
        String time = detect.time;
        Uint8List? imageBytes = detect.detectImg;
        bool head = detect.detectedHead;
        bool back = detect.detectedBack;
        bool arm = detect.detectedArm;
        bool leg = detect.detectedLeg;

        return Container(
          width: 370,
          child: Card(
            child: Row(
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    width: 200,
                    height: 290,
                    child: imageBytes != null
                        ? Image.memory(
                            imageBytes,
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.image_not_supported,
                            size: 50,
                          ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 70,
                    ),
                    Text(
                      'ครั้งที่ ${index + 1}',
                      style: GoogleFonts.mitr(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text('เวลา $time น.',
                        style: GoogleFonts.mitr(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('จุดที่ผิด', style: GoogleFonts.mitr(fontSize: 16)),
                    if (head)
                      Text('ศีรษะ', style: GoogleFonts.mitr(fontSize: 16)),
                    if (back)
                      Text('หลัง', style: GoogleFonts.mitr(fontSize: 16)),
                    if (arm) Text('แขน', style: GoogleFonts.mitr(fontSize: 16)),
                    if (leg) Text('ขา', style: GoogleFonts.mitr(fontSize: 16))
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
