// ignore_for_file: avoid_print, camel_case_types

import 'dart:convert';

import 'package:app_sit/services/userAPI.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
// import 'package:flutter_month_picker/flutter_month_picker.dart';

class History_Delete extends StatefulWidget {
  const History_Delete({super.key});

  @override
  State<History_Delete> createState() => _History_DeleteState();
}

Future<bool> deleteByDate(
    String startDate, String endDate, String id, String urlIP) async {
  final url = '$urlIP/delete_img_by_date_and_accId/';
  final res = await http.post(Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UtF-8'
      },
      body: jsonEncode(<String, String>{
        'accId': id,
        'startDate': startDate,
        'endDate': endDate,
      }));
  if (res.statusCode == 200) {
    print('Retrun ${res.body}');
    if (res.body == 'true') {
      return true;
    } else {
      return false;
    }
  } else {
    print('Failed to end');
    return false;
  }
}

Future<List<String>> getMaxMin(String id, String urlIP) async {
  final url = "$urlIP/get_detectDT_max_min/";
  List<String> getMaxMin = [];
  final res = await http.post(Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UtF-8'
      },
      body: jsonEncode(<String, String>{
        'accountID': id,
      }));
  if (res.statusCode == 200) {
    print('getMaxMin: ${res.body} of id: $id');
    final data = jsonDecode(res.body);
    print(data.runtimeType);
    String? max = data['max'];
    String? min = data['min'];
    max != null ? getMaxMin.add(max.substring(0, 10)) : getMaxMin.add('');
    min != null ? getMaxMin.add(min.substring(0, 10)) : getMaxMin.add('');
    return getMaxMin;
  } else {
    return getMaxMin;
  }
}

Future<int> getAmount(
    String startDate, String endDate, String id, String urlIP) async {
  final url = '$urlIP/pre_delete_by_date_and_accId/';
  final res = await http.post(Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UtF-8'
      },
      body: jsonEncode(<String, String>{
        'accId': id,
        'startDate': startDate,
        'endDate': endDate,
      }));
  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    int amount = data['amount'];
    print(
        'Sucess ${res.statusCode} id:$id startDate:$startDate endDate:$endDate');
    print('Amount: $amount');
    return amount;
  } else {
    print('Error ${res.statusCode}');
    return 0;
  }
}

class _History_DeleteState extends State<History_Delete> {
  final TextEditingController _dateStartController = TextEditingController();
  final TextEditingController _dateEndController = TextEditingController();
  DateTime? _pickedStart;
  DateTime? _pickedEnd;
  String? idUser;
  List<String> listMaxMin = [];
  bool display = false;
  int amount = 0;

  @override
  void initState() {
    super.initState();
    idUser = Provider.of<UserAPI>(context, listen: false).user!.id;
    fetchMaxMinDates(idUser!);
  }

  Future<void> fetchMaxMinDates(String idUser) async {
    List<String> maxMin = await getMaxMin(
        idUser, Provider.of<UserAPI>(context, listen: false).urlIP!);
    if (mounted) {
      setState(() {
        listMaxMin = maxMin;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String minString = listMaxMin.length > 1 ? listMaxMin[1] : '';
    String maxString = listMaxMin.isNotEmpty ? listMaxMin[0] : '';
    return Column(
      children: <Widget>[
        Card(
          child: Container(
            padding: const EdgeInsets.all(10),
            height: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ข้อมูลที่มี',
                    style: GoogleFonts.mitr(fontSize: 20),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: minString != ''
                      ? Text(
                          '$minString   ถึง   $maxString',
                          style: GoogleFonts.mitr(fontSize: 16),
                        )
                      : Text(
                          'ยังไม่มีข้อมูลในระบบ',
                          style: GoogleFonts.mitr(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
        // const SizedBox(
        //   height: 1,
        // ),
        Card(
          child: Container(
            padding: const EdgeInsets.all(10),
            height: 130,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'เลือกวันที่ลบ',
                  style: GoogleFonts.mitr(fontSize: 20),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(width: 165, child: startDate()),
                    Text(
                      'ถึง',
                      style: GoogleFonts.mitr(),
                    ),
                    Container(width: 165, child: endDate()),
                  ],
                ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            buttonClear(),
            buttonDisplay(),
          ],
        ),
        display
            ? Card(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'มีทั้งหมด $amount รายการ ',
                          style: GoogleFonts.mitr(fontSize: 20),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      buttonDelete(),
                    ],
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  TextField startDate() {
    return TextField(
        controller: _dateStartController,
        style: GoogleFonts.mitr(),
        decoration: InputDecoration(
            labelText: 'วันที่เริ่มต้น',
            labelStyle: GoogleFonts.mitr(fontSize: 16),
            filled: true,
            prefixIcon: const Icon(Icons.calendar_today),
            enabledBorder:
                const OutlineInputBorder(borderSide: BorderSide.none),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue))),
        readOnly: true,
        onTap: () {
          chooseDateStart();
        });
  }

  TextField endDate() {
    return TextField(
        controller: _dateEndController,
        style: GoogleFonts.mitr(),
        decoration: InputDecoration(
            labelText: 'วันที่สิ้นสุด',
            labelStyle: GoogleFonts.mitr(fontSize: 16),
            filled: true,
            prefixIcon: const Icon(Icons.calendar_today),
            enabledBorder:
                const OutlineInputBorder(borderSide: BorderSide.none),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue))),
        readOnly: true,
        onTap: () {
          chooseDateEnd();
        });
  }

  Future<void> chooseDateStart() async {
    _pickedStart = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (_pickedStart != null) {
      setState(() {
        _dateStartController.text = _pickedStart.toString().split(' ')[0];
        print(_pickedStart);
        // Clear the end date if it is before the new start date
        if (_pickedEnd != null && _pickedEnd!.isBefore(_pickedStart!)) {
          _pickedEnd = null;
          _dateEndController.clear();
        }
        display = false;
      });
    }
  }

  Future<void> chooseDateEnd() async {
    _pickedEnd = await showDatePicker(
      context: context,
      initialDate: _pickedStart ?? DateTime.now(),
      firstDate: _pickedStart ?? DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (_pickedEnd != null) {
      setState(() {
        _dateEndController.text = _pickedEnd.toString().split(' ')[0];
        display = false;
        print(_pickedEnd);
      });
    }
  }

  ElevatedButton buttonDelete() {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'แน่ใจไหม?',
                style: GoogleFonts.mitr(),
              ),
              content: Text(
                'เราจะทำการลบประวัติตามวันที่คุณเลือก',
                style: GoogleFonts.mitr(),
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    if (await deleteByDate(
                        _dateStartController.text,
                        _dateEndController.text,
                        idUser!,
                        Provider.of<UserAPI>(context, listen: false).urlIP!)) {
                      showInSnackBar('ลบรูปภาพสำเร็จ');
                    } else {
                      showInSnackBar('เกิดข้อผิดพลาดในการลบ');
                    }
                    setState(() {
                      _pickedStart = null;
                      _dateStartController.clear();
                      _pickedEnd = null;
                      _dateEndController.clear();
                      display = false;
                    });
                    Navigator.pop(context);
                  },
                  child: Text(
                    'ตกลง',
                    style: GoogleFonts.mitr(),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'ยกเลิก',
                    style: GoogleFonts.mitr(),
                  ),
                ),
              ],
            );
          },
        );

        print('Start: $_pickedStart \n');
        print('End: $_pickedEnd \n');
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
            const Color.fromARGB(255, 185, 68, 60)),
      ),
      child: Text(
        'ยืนยันลบ',
        style: GoogleFonts.mitr(color: Colors.white),
      ),
    );
  }

  ElevatedButton buttonDisplay() {
    return ElevatedButton(
        onPressed: () async {
          if (_pickedStart == null || _pickedEnd == null) {
            print('DATE NULL');
            showInSnackBar('คุณยังไม่ได้เลือกวันที่');
          } else {
            int fetchedAmount = await getAmount(
                _dateStartController.text,
                _dateEndController.text,
                idUser!,
                Provider.of<UserAPI>(context, listen: false).urlIP!);
            if (mounted) {
              setState(() {
                display = true;
                amount = fetchedAmount;
              });
            }
          }
        },
        child: Text(
          'แสดงจำนวนรายการ',
          style: GoogleFonts.mitr(fontSize: 16),
        ));
  }

  ElevatedButton buttonClear() {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            _pickedStart = null;
            _dateStartController.clear();
            _pickedEnd = null;
            _dateEndController.clear();
            display = false;
          });
        },
        child: Text('ล้าง', style: GoogleFonts.mitr(fontSize: 16)));
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      message,
      style: GoogleFonts.mitr(),
    )));
  }
}
