// To parse this JSON data, do
//
//     final dailyHistoryData = dailyHistoryDataFromJson(jsonString);

import 'dart:convert';

DailyHistoryData dailyHistoryDataFromJson(String str) => DailyHistoryData.fromJson(json.decode(str));

String dailyHistoryDataToJson(DailyHistoryData data) => json.encode(data.toJson());

class DailyHistoryData {
    int detectAmount;
    int sitDuration;
    int amountSitOverLimit;
    int head;
    int arm;
    int back;
    int leg;
    List<List<dynamic>> detectList;

    DailyHistoryData({
        required this.detectAmount,
        required this.sitDuration,
        required this.amountSitOverLimit,
        required this.head,
        required this.arm,
        required this.back,
        required this.leg,
        required this.detectList,
    });

    factory DailyHistoryData.fromJson(Map<String, dynamic> json) => DailyHistoryData(
        detectAmount: json["detectAmount"],
        sitDuration: json["sitDuration"],
        amountSitOverLimit: json["amountSitOverLimit"],
        head: json["head"],
        arm: json["arm"],
        back: json["back"],
        leg: json["leg"],
        detectList: List<List<dynamic>>.from(json["detectList"].map((x) => List<dynamic>.from(x.map((x) => x)))),
    );

    Map<String, dynamic> toJson() => {
        "detectAmount": detectAmount,
        "sitDuration": sitDuration,
        "amountSitOverLimit": amountSitOverLimit,
        "head": head,
        "arm": arm,
        "back": back,
        "leg": leg,
        "detectList": List<dynamic>.from(detectList.map((x) => List<dynamic>.from(x.map((x) => x)))),
    };
}
