import 'dart:convert';
import 'dart:typed_data';
import 'package:app_sit/models/setting_data.dart';
import 'package:app_sit/models/user_data.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class UserAPI with ChangeNotifier {
  final url = 'http://43.229.133.174:8000/login/';

  UserData? user;
  SettingData? setting;
  bool isLoading = false;
  String? errorMessage;
  Uint8List? imageProfile;
  GoogleSignInAccount? userGoogle;
  String? id;
  int? selectedDetectFreq;
  int? selectedSitLimit;
  int? selectedSitLimitAlarmFreq;
  List<dynamic>? detectFreq;
  List<dynamic>? sitLimit;
  List<dynamic>? sitLimitAlarmFreq;
  // bool newNoti = true;

  Future<UserData?> getUserData(GoogleSignInAccount userG) async {
    try {
      userGoogle = userG;
      final response = await http
          .post(
            Uri.parse(url),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'email': userG.email,
              'name': userG.displayName,
            }),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final data = await jsonDecode(response.body);
        id = data['accountID'].toString();
        selectedDetectFreq = data['detectFreq'];
        detectFreq = data['detectFreqChoice'];
        selectedSitLimit = data['sitLimit'];
        sitLimit = data['sitLimitChoice'];
        selectedSitLimitAlarmFreq = data['sitLimitFreq'];
        sitLimitAlarmFreq = data['sitLimitFreqChoice'];
        // newNoti = data['newNotification'];
        // // newNoti = true;
        // print('newNoti:$newNoti');
        imageProfile = data['imgProfileAxis'] != null
            ? base64Decode(data['imgProfileAxis'])
            : null;

        final userData = UserData.fromJson({
          'id': id,
          'displayName': userG.displayName,
          'email': userG.email,
          'photoUrl': userG.photoUrl,
          'imageProfile': imageProfile,
        });
        user = userData;
        notifyListeners();
        return user;
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      errorMessage = 'Error fetching user data: $e';
      notifyListeners();
      return null;
    }
  }

  // void readNoti() {
  //   newNoti = false;
  // }

  void clearData() {
    user = null;
    setting = null;
    imageProfile = null;
    userGoogle = null;
    id = null;
    selectedDetectFreq = null;
    selectedSitLimit = null;
    selectedSitLimitAlarmFreq = null;
    detectFreq = null;
    sitLimit = null;
    sitLimitAlarmFreq = null;
    errorMessage = null;
    // newNoti = true;
    print('Clear all Data');
    notifyListeners();
  }

  void clearProfileData() {
    user = null;
    setting = null;
    imageProfile = null;
    id = null;
    selectedDetectFreq = null;
    selectedSitLimit = null;
    selectedSitLimitAlarmFreq = null;
    detectFreq = null;
    sitLimit = null;
    sitLimitAlarmFreq = null;
    errorMessage = null;
    print('Clear profile data');
    notifyListeners();
  }

  Future<SettingData?> getSettingData() async {
    selectedDetectFreq ??= 5;
    selectedSitLimit ??= 60;
    selectedSitLimitAlarmFreq ??= 7;
    final Map<String, dynamic> data = {
      "id": id,
      "selectedDetectFreq": selectedDetectFreq,
      "detectFreq": detectFreq,
      "sitLimit": sitLimit,
      "selectedSitLimit": selectedSitLimit,
      "sitLimitAlarmFreq": sitLimitAlarmFreq,
      "selectedSitLimitAlarmFreq": selectedSitLimitAlarmFreq,
    };
    setting = SettingData.fromJson(data);
    print(setting?.id);
    print(
        'Get setting: ${setting?.selectedDetectFreq}, ${setting?.detectFreq}, ${setting?.selectedSitLimit}, ${setting?.sitLimit}, ${setting?.selectedSitLimitAlarmFreq}, ${setting?.sitLimitAlarmFreq}');
    isLoading = false;
    notifyListeners();
    return setting;
  }

  // void clearSettingData() {
  //   setting = null;
  //   errorMessage = null;
  //   notifyListeners();
  // }

  void updateSetting({
    int? selectedDetectFreq,
    int? selectedSitLimit,
    int? selectedSitLimitAlarmFreq,
  }) {
    setting?.update(
      selectedDetectFreq: selectedDetectFreq,
      selectedSitLimit: selectedSitLimit,
      selectedSitLimitAlarmFreq: selectedSitLimitAlarmFreq,
    );

    print('Setting Update Pass');
    print(
        "${setting?.selectedDetectFreq}, ${setting?.selectedSitLimit}, ${setting?.selectedSitLimitAlarmFreq}");
    notifyListeners();
  }
}
