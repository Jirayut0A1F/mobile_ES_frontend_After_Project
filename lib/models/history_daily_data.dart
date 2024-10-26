import 'dart:convert';
import 'dart:typed_data';

HistoryDailyData historyDailyDataFromJson(String str) => HistoryDailyData.fromJson(json.decode(str));

String historyDailyDataToJson(HistoryDailyData data) => json.encode(data.toJson());

class HistoryDailyData {
    int detectAmount;
    int sitDuration;
    int amountSitOverLimit;
    int head;
    int arm;
    int back;
    int leg;
    List<DetectList> detectList;

    HistoryDailyData({
        required this.detectAmount,
        required this.sitDuration,
        required this.amountSitOverLimit,
        required this.head,
        required this.arm,
        required this.back,
        required this.leg,
        required this.detectList,
    });

    factory HistoryDailyData.fromJson(Map<String, dynamic> json) => HistoryDailyData(
        detectAmount: json["detectAmount"],
        sitDuration: json["sitDuration"],
        amountSitOverLimit: json["amountSitOverLimit"],
        head: json["head"],
        arm: json["arm"],
        back: json["back"],
        leg: json["leg"],
        detectList: List<DetectList>.from(json["detectList"].map((x) => DetectList.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "detectAmount": detectAmount,
        "sitDuration": sitDuration,
        "amountSitOverLimit": amountSitOverLimit,
        "head": head,
        "arm": arm,
        "back": back,
        "leg": leg,
        "detectList": List<dynamic>.from(detectList.map((x) => x.toJson())),
    };
}

class DetectList {
    int detectId;
    String time;
    Uint8List? detectImg;
    bool detectedHead;
    bool detectedArm;
    bool detectedBack;
    bool detectedLeg;

    DetectList({
        required this.detectId,
        required this.time,
        required this.detectImg,
        required this.detectedHead,
        required this.detectedArm,
        required this.detectedBack,
        required this.detectedLeg,
    });

    factory DetectList.fromJson(Map<String, dynamic> json) => DetectList(
        detectId: json["detectID"],
        time: json["time"],
        detectImg: json["detectImg"] != null ? base64Decode(json["detectImg"]) : null,
        detectedHead: json["detectedHead"],
        detectedArm: json["detectedArm"],
        detectedBack: json["detectedBack"],
        detectedLeg: json["detectedLeg"],
    );

    Map<String, dynamic> toJson() => {
        "detectID": detectId,
        "time": time,
        "detectImg": detectImg != null ? base64Encode(detectImg!) : null,
        "detectedHead": detectedHead,
        "detectedArm": detectedArm,
        "detectedBack": detectedBack,
        "detectedLeg": detectedLeg,
    };
}
