// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:typed_data';

import 'package:app_sit/screen/login.dart';
import 'package:app_sit/models/user_data.dart';
import 'package:app_sit/resources/app_resources.dart';
import 'package:app_sit/services/google_signin_api.dart';
import 'package:app_sit/services/userAPI.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:badges/badges.dart' as badges;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

Future<void> sentReadNoti(String id) async {
  const url = "http://43.229.133.174:8000/read_notification/";
  final res = await http.post(Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UtF-8'
      },
      body: jsonEncode(<String, String>{
        'accountID': id,
      }));
  if (res.statusCode == 200) {
    print(res.body);
  } else {
    print('Error: ${res.statusCode}');
  }
}

Future<bool> newNoti(String id) async {
  const url = "http://43.229.133.174:8000/newNoti/";
  final res = await http.post(Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UtF-8'
      },
      body: jsonEncode(<String, String>{
        'accountID': id,
      }));
  if (res.statusCode == 200) {
    print(res.body);
    final data = jsonDecode(res.body);
    bool newNoti = data['newNoti'];
    return newNoti;
  } else {
    print('Error: ${res.statusCode}');
    return false;
  }
}

class _HomePageState extends State<HomePage> {
  bool hasData = false;
  final int _currentIndex = 0; // State variable for current image index
  bool _pressed = false;
  bool isLoading = true;

  List<String> image = [
    'assets/images/Ex_image.jpg',
    'assets/images/Example.jpeg',
    'assets/images/TeachCamera.jpeg',
  ]; // List of image file names or paths

  // void _nextImage() {
  //   setState(() {
  //     if (_currentIndex < image.length - 1) {
  //       _currentIndex++;
  //     }
  //   });
  // }

  // void _prevImage() {
  //   setState(() {
  //     if (_currentIndex > 0) {
  //       _currentIndex--;
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();
    fetchNewNoti();
  }

  Future<void> fetchNewNoti() async {
    final userAPI = Provider.of<UserAPI>(context, listen: false);
    if (userAPI.user != null) {
      _pressed = await newNoti(userAPI.user!.id);
    }
    setState(() {
      isLoading = false; // หยุดการโหลดเมื่อดึงข้อมูลเสร็จ
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.contentColorBlueSky,
      appBar: AppBar(
        backgroundColor: AppColors.contentColorBlue,
        actions: [
          IconButton(
            onPressed: () async {
              Provider.of<UserAPI>(context, listen: false).clearData();
              await GoogleSignInApi.logout();
              // await GoogleSingInApi.disconnect();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  ModalRoute.withName('/'));
            },
            icon: const Icon(Icons.logout),
            color: AppColors.contentColorWhite,
            iconSize: 30,
          ),
        ],
        title: Text(
          'หน้าแรก',
          style: GoogleFonts.mitr(
              color: AppColors.contentColorWhite, fontSize: 30),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // แสดงโหลดข้อมูล
          : Stack(
              children: [
                // Container(
                //   decoration: const BoxDecoration(
                //     image: DecorationImage(
                //       image: AssetImage('assets/images/background.png'),
                //       fit: BoxFit.cover,
                //     ),
                //   ),
                // ),
                Consumer<UserAPI>(
                  builder: (context, userAPI, child) {
                    if (userAPI.user == null) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      UserData user = userAPI.user!;
                      String id = user.id;
                      String? displayName = user.displayName;
                      Uint8List? imageBase64 = user.imageProfile;
                      if (imageBase64 != null) {
                        hasData = true;
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Card(
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          if (user.photoUrl != null)
                                            CircleAvatar(
                                              radius: 25,
                                              backgroundImage:
                                                  NetworkImage(user.photoUrl!),
                                            ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            displayName,
                                            style: GoogleFonts.mitr(),
                                          ),
                                        ],
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          // Provider.of<UserAPI>(context,
                                          //         listen: false)
                                          //     .getSettingData();
                                          print('Go to teach');
                                          Navigator.pushNamed(
                                              context, '/teachSit');
                                        },
                                        child: Text(
                                          '\t\tปรับแต่ง\nท่านั่งอ้างอิง',
                                          style: GoogleFonts.mitr(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              exampleData(imageBase64, hasData),
                            ],
                          ),
                          badges.Badge(
                            position:
                                badges.BadgePosition.topEnd(top: -6, end: 183),
                            showBadge: _pressed,
                            badgeContent: Text(
                              'N',
                              style: GoogleFonts.mitr(color: Colors.white),
                            ),
                            badgeStyle: const badges.BadgeStyle(
                              badgeColor: Colors.red,
                              elevation: 0,
                            ),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  sentReadNoti(id);
                                  // Provider.of<UserAPI>(context, listen: false)
                                  //     .readNoti();
                                  setState(() {
                                    _pressed = false;
                                  });
                                  print('Go to infoPage');
                                  Navigator.pushNamed(context, '/infoAdmin');
                                },
                                child: Text(
                                  'ข่าวสารจากผู้ดูแลระบบ',
                                  style: GoogleFonts.mitr(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
    );
  }

  Widget exampleData(Uint8List? imageBase64, bool hasData) {
    return hasData
        ? Column(
            children: [
              Card(
                color: Colors.white,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  width: 270,
                  height: 400,
                  child: imageBase64 != null
                      ? Image.memory(
                          imageBase64,
                          fit: BoxFit.fill,
                        )
                      : const Icon(Icons.image_not_supported),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/cameraDetect');
                },
                child: Text(
                  'เริ่มตรวจจับ',
                  style: GoogleFonts.mitr(fontSize: 16),
                ),
              ),
              // ElevatedButton(
              //     onPressed: () {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => ChartTestSliding()),
              //       );
              //     },
              //     child: Text('test'))
            ],
          )
        : Column(
            children: [
              Card(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  width: 270,
                  height: 450,
                  // child: Icon(
                  //   Icons.broken_image,
                  //   size: 50,
                  // ),
                  child: Image.asset(
                    image[_currentIndex],
                    fit: BoxFit.fill,
                  ), // Display image from the list
                ),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceAround,
              //   children: [
              //     IconButton(
              //       icon: Icon(Icons.arrow_left),
              //       onPressed: _prevImage,
              //     ),
              //     IconButton(
              //       icon: Icon(Icons.arrow_right),
              //       onPressed: _nextImage,
              //     ),
              //   ],
              // ),
            ],
          );
  }
}
