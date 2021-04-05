class UserData {
  final String displayName;
  final String uid;
  final bool isAuthorized;

  UserData({this.uid, this.displayName, this.isAuthorized = false});

  factory UserData.fromMap(Map<String, dynamic> object) {
    return UserData(
        uid: object['uid'],
        displayName: object['displayName'],
        isAuthorized: object['isAuthorized']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = new Map<String, dynamic>();
    json['uid'] = this.uid;
    json['displayName'] = this.displayName;
    json['isAuthorized'] = this.isAuthorized;
    return json;
  }
}
