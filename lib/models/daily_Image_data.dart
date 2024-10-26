import 'dart:convert';


DailyHistoryImageData dailyHistoryImageDataFromJson(String str) => DailyHistoryImageData.fromJson(json.decode(str));

String dailyHistoryImageDataToJson(DailyHistoryImageData data) => json.encode(data.toJson());

class DailyHistoryImageData {
  List<List<dynamic>> detectImgList;

  DailyHistoryImageData({
    required this.detectImgList,
  });

  factory DailyHistoryImageData.fromJson(Map<String, dynamic> json) {
    return DailyHistoryImageData(
      detectImgList: List<List<dynamic>>.from(json["detectImgList"].map((x) {
        return [
          x[0], // Assuming the first element is some identifier or other data
          base64Decode(x[1]), // Decode the base64 string to Uint8List
        ];
      })),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "detectImgList": List<dynamic>.from(detectImgList.map((x) {
        return [
          x[0], // Assuming the first element is some identifier or other data
          base64Encode(x[1]), // Encode the Uint8List to a base64 string
        ];
      })),
    };
  }
}
