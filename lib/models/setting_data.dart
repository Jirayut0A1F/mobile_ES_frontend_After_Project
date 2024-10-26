import 'dart:convert';

SettingData settingDataFromJson(String str) => SettingData.fromJson(json.decode(str));

String settingDataToJson(SettingData data) => json.encode(data.toJson());

class SettingData {
  String id;
  int? selectedDetectFreq;
  List<int>? detectFreq;
  List<int>? sitLimit;
  int? selectedSitLimit;
  List<int>? sitLimitAlarmFreq;
  int? selectedSitLimitAlarmFreq;

  SettingData({
    required this.id,
    required this.selectedDetectFreq,
    required this.detectFreq,
    required this.sitLimit,
    required this.selectedSitLimit,
    required this.sitLimitAlarmFreq,
    required this.selectedSitLimitAlarmFreq,
  });

  factory SettingData.fromJson(Map<String, dynamic> json) => SettingData(
        id: json["id"],
        selectedDetectFreq: json["selectedDetectFreq"],
        detectFreq: List<int>.from(json["detectFreq"].map((x) => x as int)),
        sitLimit: List<int>.from(json["sitLimit"].map((x) => x as int)),
        selectedSitLimit: json["selectedSitLimit"],
        sitLimitAlarmFreq: List<int>.from(json["sitLimitAlarmFreq"].map((x) => x as int)),
        selectedSitLimitAlarmFreq: json["selectedSitLimitAlarmFreq"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "selectedDetectFreq": selectedDetectFreq,
        "detectFreq": detectFreq,
        "sitLimit": sitLimit,
        "selectedSitLimit": selectedSitLimit,
        "sitLimitAlarmFreq": sitLimitAlarmFreq,
        "selectedSitLimitAlamFreq": selectedSitLimitAlarmFreq,
      };

  void update({
    int? selectedDetectFreq,
    int? selectedSitLimit,
    int? selectedSitLimitAlarmFreq,
  }) {
    if (selectedDetectFreq != null) {
      this.selectedDetectFreq = selectedDetectFreq;
    }
   
    if (selectedSitLimit != null) {
      this.selectedSitLimit = selectedSitLimit;
    }
   
    if (selectedSitLimitAlarmFreq != null) {
      this.selectedSitLimitAlarmFreq = selectedSitLimitAlarmFreq;
    }
  }
}
