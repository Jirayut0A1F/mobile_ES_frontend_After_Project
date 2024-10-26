// To parse this JSON data, do
//
//     final monthHistoryData = monthHistoryDataFromJson(jsonString);

import 'dart:convert';

MonthHistoryData monthHistoryDataFromJson(String str) => MonthHistoryData.fromJson(json.decode(str));

String monthHistoryDataToJson(MonthHistoryData data) => json.encode(data.toJson());

class MonthHistoryData {
    List<DetectImgRecord> detectImgRecords;
    TotalMonthDetect totalMonthDetect;

    MonthHistoryData({
        required this.detectImgRecords,
        required this.totalMonthDetect,
    });

    factory MonthHistoryData.fromJson(Map<String, dynamic> json) => MonthHistoryData(
        detectImgRecords: List<DetectImgRecord>.from(json["detect_img_records"].map((x) => DetectImgRecord.fromJson(x))),
        totalMonthDetect: TotalMonthDetect.fromJson(json["totalMonthDetect"]),
    );

    Map<String, dynamic> toJson() => {
        "detect_img_records": List<dynamic>.from(detectImgRecords.map((x) => x.toJson())),
        "totalMonthDetect": totalMonthDetect.toJson(),
    };
}

class DetectImgRecord {
    int day;
    int sitDuration;
    int amountSitOverLimit;
    int sitLimitOnDay;

    DetectImgRecord({
        required this.day,
        required this.sitDuration,
        required this.amountSitOverLimit,
        required this.sitLimitOnDay,
    });

    factory DetectImgRecord.fromJson(Map<String, dynamic> json) => DetectImgRecord(
        day: json["day"],
        sitDuration: json["sitDuration"],
        amountSitOverLimit: json["amountSitOverLimit"],
        sitLimitOnDay: json["sitLimitOnDay"],
    );

    Map<String, dynamic> toJson() => {
        "day": day,
        "sitDuration": sitDuration,
        "amountSitOverLimit": amountSitOverLimit,
        "sitLimitOnDay": sitLimitOnDay,
    };
}

class TotalMonthDetect {
    int totalHead;
    int totalBack;
    int totalArm;
    int totalLeg;

    TotalMonthDetect({
        required this.totalHead,
        required this.totalBack,
        required this.totalArm,
        required this.totalLeg,
    });

    factory TotalMonthDetect.fromJson(Map<String, dynamic> json) => TotalMonthDetect(
        totalHead: json["total_head"],
        totalBack: json["total_back"],
        totalArm: json["total_arm"],
        totalLeg: json["total_leg"],
    );

    Map<String, dynamic> toJson() => {
        "total_head": totalHead,
        "total_back": totalBack,
        "total_arm": totalArm,
        "total_leg": totalLeg,
    };
}
