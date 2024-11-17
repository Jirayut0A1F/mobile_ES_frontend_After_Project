import 'dart:convert';
import 'dart:io';

import 'package:app_sit/services/google_signin_api.dart';
import 'package:app_sit/widget/BTbar.dart';
import 'package:app_sit/services/userAPI.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class LoadPage extends StatefulWidget {
  final GoogleSignInAccount user;
  const LoadPage({super.key, required this.user});

  @override
  State<LoadPage> createState() => _LoadPageState();
}

class _LoadPageState extends State<LoadPage> {
  Future<void>? _loadDataFuture;

  @override
  void initState() {
    super.initState();
    _checkIfNewMember();
  }

  Future<bool> checkMember(String email, String urlIP) async {
    final url = '$urlIP/ckNewMember/';
    final res = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['newMember'] ?? false;
    } else {
      print('Failed to check membership');
      return false;
    }
  }

  void _checkIfNewMember() async {
    bool isNewMember = await checkMember(
        widget.user.email, Provider.of<UserAPI>(context, listen: false).urlIP!);
    if (mounted) {
      if (!isNewMember) {
        _showPDPADialog(context);
      } else {
        _startLoadingData();
      }
    }
  }

  void _startLoadingData() {
    setState(() {
      _loadDataFuture = _loadData();
    });
  }

  Future<void> _loadData() async {
    await Provider.of<UserAPI>(context, listen: false).getUserData(widget.user);
    await Provider.of<UserAPI>(context, listen: false).getSettingData();
  }

  void stopDetect(String urlIP) {
    final user = Provider.of<UserAPI>(context, listen: false).user;
    if (user != null) {
      final id = user.id;
      final url = '$urlIP/end_detect/';
      http
          .post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'accountID': id}),
      )
          .then((res) {
        if (res.statusCode == 200) {
          print('stopDetect: ${res.body}');
        } else {
          print('Failed to end detection');
        }
      });
    } else {
      print('User is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (_loadDataFuture == null) {
            // กรณีที่ยังไม่ได้เริ่มโหลดข้อมูล รอการกดยอมรับ PDPA
            return Center(
                child: Text(
              'Waiting...',
              style: GoogleFonts.mitr(),
            ));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                stopDetect(Provider.of<UserAPI>(context, listen: false).urlIP!);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const BTbar()),
                  ModalRoute.withName('/BTbar'),
                );
              }
            });
            return Container(); // Return an empty container until navigation
          }
        },
      ),
    );
  }

  void _showPDPADialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // ignore: deprecated_member_use
        return WillPopScope(
          onWillPop: () async {
            _exitApp();
            return false;
          },
          child: AlertDialog(
            title: Text(
              'ขอความยินยอมตามกฎหมาย PDPA',
              style: GoogleFonts.mitr(),
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'เรียน ผู้ใช้งาน\nเพื่อให้เป็นไปตามกฎหมายคุ้มครองข้อมูลส่วนบุคคล (PDPA) แอปพลิเคชันนี้มีความจำเป็นที่จะต้องขออนุญาตจากท่านในการเก็บรวบรวม ประมวลผล และใช้ข้อมูลส่วนบุคคลของท่านสำหรับวัตถุประสงค์ในการปรับปรุงการให้บริการและเพื่อประสบการณ์การใช้งานที่ดียิ่งขึ้น ข้อมูลดังกล่าวอาจรวมถึง ชื่อ ที่อยู่อีเมล ข้อมูลการเข้าใช้งาน และข้อมูลการตั้งค่าที่เกี่ยวข้อง โดยข้อมูลของท่านจะได้รับการเก็บรักษาอย่างปลอดภัยและนำไปใช้เฉพาะในขอบเขตที่กฎหมายอนุญาตเท่านั้น\nหากท่านไม่ยินยอมในการให้สิทธิ์ แอปพลิเคชันจะปิดการใช้งานทันที แต่หากท่านยอมรับข้อตกลง ท่านสามารถใช้งานแอปพลิเคชันนี้ต่อไปได้',
                    style: GoogleFonts.mitr(fontSize: 18),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Provider.of<UserAPI>(context, listen: false).clearData();
                  await GoogleSignInApi.logout();
                  _exitApp();
                },
                child: Text(
                  'ไม่ยอบรับ',
                  style: GoogleFonts.mitr(),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _startLoadingData(); // เริ่มโหลดข้อมูลเมื่อกดยอมรับ
                },
                child: Text(
                  'ยอบรับ',
                  style: GoogleFonts.mitr(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _exitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
  }
}
