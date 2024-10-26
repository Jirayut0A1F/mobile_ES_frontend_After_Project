import 'dart:typed_data';

class UserData {
  String id;
  String displayName;
  String email;
  String? photoUrl;
  Uint8List? imageProfile;

  UserData({
    required this.id,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.imageProfile,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        id: json["id"],
        displayName: json["displayName"],
        email: json["email"],
        photoUrl: json["photoUrl"],
        imageProfile: json["imageProfile"] != null
            ? Uint8List.fromList(List<int>.from(json["imageProfile"]))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "displayName": displayName,
        "email": email,
        "photoUrl": photoUrl,
        "imageProfile": imageProfile,
      };

  void update({
    // String? id,
    // String? displayName,
    // String? email,
    // String? photoUrl,
    Uint8List? imageProfile,
  }) {
    // if (id != null) {
    //   this.id = id;
    // }
    // if (displayName != null) {
    //   this.displayName = displayName;
    // }
    // if (email != null) {
    //   this.email = email;
    // }
    // if (photoUrl != null) {
    //   this.photoUrl = photoUrl;
    // }
    if (imageProfile != null) {
      this.imageProfile = imageProfile;
    }
  }
}
