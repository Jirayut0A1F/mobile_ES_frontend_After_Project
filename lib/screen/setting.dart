import 'dart:convert';
import 'dart:io';
import 'package:app_sit/models/setting_data.dart';
import 'package:app_sit/resources/app_resources.dart';
import 'package:app_sit/services/google_signin_api.dart';
import 'package:app_sit/services/userAPI.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

Future<void> postSetting(
    String id, int detectFreq, int sitLimit, int sitLimitFreq) async {
  const url = 'http://43.229.133.174:8000/update_setting/';
  try {
    final res = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "accountID": id,
        "detectFreq": detectFreq,
        "sitLimit": sitLimit,
        "sitLimitFreq": sitLimitFreq,
      }),
    );

    if (res.statusCode == 200) {
      print(res.body);
    } else {
      print('Failed to get data: ${res.statusCode}');
    }
  } catch (e) {
    print('An error occurred: $e');
  }
}

class _SettingPageState extends State<SettingPage> {
  int? _selectedSitLimit;
  List<int>? _sitLimit;
  int? _selectedSitLimitAlarmFreq;
  List<int>? _sitLimitAlarmFreq;
  int? _selectedDetectFreq;
  List<int>? _detectFreq;
  bool _enableSound = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSettings();
    });
  }

  Future<void> deleteMember(String id) async {
    const url = 'http://43.229.133.174:8000/deleteMember/';
    final res = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'accountID': id,
      }),
    );
    if (res.statusCode == 200) {
      print('Dlete Member Success');
    } else {
      print('Failed ${res.statusCode}');
    }
  }

  void _initializeSettings() async {
    final settingAPI = Provider.of<UserAPI>(context, listen: false);
    final setting = settingAPI.setting;
    await _loadSoundSetting(); // Load sound setting from SharedPreferences
    if (setting != null) {
      _setStateFromSetting(setting);
    } else {
      settingAPI.getSettingData().then((_) {
        final setting = settingAPI.setting;
        if (setting != null) {
          _setStateFromSetting(setting);
        }
      }).catchError((error) {
        print("Failed to fetch settings: $error");
      });
    }
  }

  void _setStateFromSetting(SettingData setting) {
    setState(() {
      _sitLimit = setting.sitLimit ?? [15, 30, 45, 60];
      _selectedSitLimit = setting.selectedSitLimit ?? _sitLimit![0];
      _sitLimitAlarmFreq = setting.sitLimitAlarmFreq ?? [5, 10, 15];
      _selectedSitLimitAlarmFreq =
          setting.selectedSitLimitAlarmFreq ?? _sitLimitAlarmFreq![0];
      _detectFreq = setting.detectFreq ?? [3, 5, 7, 9, 11];
      _selectedDetectFreq = setting.selectedDetectFreq ?? _detectFreq![0];
    });
  }

  Future<void> _loadSoundSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _enableSound = prefs.getBool('enableSound') ?? true;
    });
  }

  Future<void> _saveSoundSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enableSound', _enableSound);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.contentColorBlueSky,
      appBar: AppBar(
        title: Text(
          'ตั้งค่า',
          style: GoogleFonts.mitr(
              color: AppColors.contentColorWhite, fontSize: 30),
        ),
        backgroundColor: AppColors.contentColorBlue,
      ),
      body: Consumer<UserAPI>(
        builder: (context, settingAPI, child) {
          if (settingAPI.setting == null) {
            return const Center(child: CircularProgressIndicator());
          }
          String id = settingAPI.setting!.id;
          return Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: <Widget>[
                    Card(
                      child: ExpansionTile(
                        title: Text(
                          'การนั่งต่อเนื่อง',
                          style: GoogleFonts.mitr(),
                        ),
                        initiallyExpanded: true,
                        children: <Widget>[
                          ListTile(
                            title: Text(
                              'ระยะเวลา (นาที)',
                              style: GoogleFonts.mitr(),
                            ),
                            trailing: _buildDropdownButtonSitLimit(
                              _selectedSitLimit ?? 1,
                              (int? newValue) {
                                setState(() {
                                  _selectedSitLimit = newValue;
                                });
                              },
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'ความถี่แจ้งเตือน (นาที)',
                              style: GoogleFonts.mitr(),
                            ),
                            trailing: _buildDropdownButtonSitLimitAlarmFreq(
                              _selectedSitLimitAlarmFreq ?? 1,
                              (int? newValue) {
                                setState(() {
                                  _selectedSitLimitAlarmFreq = newValue;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: Text(
                          'ความถี่ในการตรวจจับ (วินาที)',
                          style: GoogleFonts.mitr(),
                        ),
                        trailing: _buildDropdownButtonDetectFreq(
                          _selectedDetectFreq ?? 1,
                          (int? newValue) {
                            setState(() {
                              _selectedDetectFreq = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                    Card(
                      child: SwitchListTile(
                        title: Text(
                          'เสียงแจ้งเตือน',
                          style: GoogleFonts.mitr(),
                        ),
                        value: _enableSound,
                        onChanged: (bool value) {
                          setState(() {
                            _enableSound = value;
                            print('Enable Sound: $_enableSound');
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton.icon(
                          onPressed: () {
                            _saveSettings();
                          },
                          icon: const Icon(Icons.save),
                          label: Text(
                            'บันทึก',
                            style: GoogleFonts.mitr(),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  onPressed: () {
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
                              'ลบบัญชีผู้ใช้งาน',
                              style: GoogleFonts.mitr(),
                            ),
                            content: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Text(
                                    'เราจะทำการลบบัญชีของคุณและข้อมูลทุกอย่างที่เกี่ยวกับบัญชีของคุณและบังคับออกจากแอปพลิเคชันของเราโดยทันที\nคุณแน่ใจไหม?',
                                    style: GoogleFonts.mitr(),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  Provider.of<UserAPI>(context, listen: false)
                                      .clearData();
                                  await GoogleSignInApi.logout();
                                  deleteMember(id);
                                  _exitApp();
                                },
                                child: Text(
                                  'ยืนยัน',
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
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  label: Text(
                    'ลบบัญชี',
                    style: GoogleFonts.mitr(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      textStyle: const TextStyle(fontSize: 16),
                      backgroundColor: const Color.fromARGB(255, 185, 68, 60)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _exitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop(); //ออกจากแอป
    } else if (Platform.isIOS) {
      exit(0);
    }
  }

  void _saveSettings() {
    showInSnackBar('บันทึกสำเร็จแล้ว');
    final settingAPI = Provider.of<UserAPI>(context, listen: false);
    settingAPI.updateSetting(
      selectedDetectFreq: _selectedDetectFreq,
      selectedSitLimit: _selectedSitLimit,
      selectedSitLimitAlarmFreq: _selectedSitLimitAlarmFreq,
    );
    _saveSoundSetting(); // Save sound setting when save button is pressed
    postSetting(Provider.of<UserAPI>(context, listen: false).setting!.id,
        _selectedDetectFreq!, _selectedSitLimit!, _selectedSitLimitAlarmFreq!);
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      message,
      style: GoogleFonts.mitr(),
    )));
  }

  DropdownButton<int> _buildDropdownButtonSitLimit(
      int selectedValue, ValueChanged<int?>? onChanged) {
    final List<int> frequencyList = (_sitLimit ?? [1]).toSet().toList();
    if (!frequencyList.contains(selectedValue)) {
      frequencyList.add(selectedValue);
    }
    return DropdownButton<int>(
      icon: const Icon(Icons.access_time_sharp),
      iconEnabledColor: Colors.black,
      value: selectedValue,
      onChanged: onChanged,
      items: frequencyList.map<DropdownMenuItem<int>>((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text(
            value.toString(),
            style: GoogleFonts.mitr(fontSize: 16),
          ),
        );
      }).toList(),
      underline: Container(
        height: 2,
        color: Colors.black,
      ),
    );
  }

  DropdownButton<int> _buildDropdownButtonSitLimitAlarmFreq(
      int selectedValue, ValueChanged<int?>? onChanged) {
    final List<int> frequencyList =
        (_sitLimitAlarmFreq ?? [1]).toSet().toList();
    if (!frequencyList.contains(selectedValue)) {
      frequencyList.add(selectedValue);
    }
    return DropdownButton<int>(
      icon: const Icon(Icons.access_time_sharp),
      iconEnabledColor: Colors.black,
      value: selectedValue,
      onChanged: onChanged,
      items: frequencyList.map<DropdownMenuItem<int>>((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text(
            value.toString(),
            style: GoogleFonts.mitr(fontSize: 16),
          ),
        );
      }).toList(),
      underline: Container(
        height: 2,
        color: Colors.black,
      ),
    );
  }

  DropdownButton<int> _buildDropdownButtonDetectFreq(
      int selectedValue, ValueChanged<int?>? onChanged) {
    // ตรวจสอบให้แน่ใจว่า _detectFreq ไม่เป็น null และรวม selectedValue เข้าไปด้วย
    final List<int> frequencyList = (_detectFreq ?? [1]).toSet().toList();
    if (!frequencyList.contains(selectedValue)) {
      frequencyList.add(selectedValue);
    }
    return DropdownButton<int>(
      icon: const Icon(Icons.access_time_sharp),
      iconEnabledColor: Colors.black,
      value: selectedValue,
      onChanged: onChanged,
      items: frequencyList.map<DropdownMenuItem<int>>((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text(
            value.toString(),
            style: GoogleFonts.mitr(fontSize: 16),
          ),
        );
      }).toList(),
      underline: Container(
        height: 2,
        color: Colors.black,
      ),
    );
  }
}
