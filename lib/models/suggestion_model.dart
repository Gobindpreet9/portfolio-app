class Suggestion {
  final String displayName;
  final String suggestion;
  final String timeStamp;

  Suggestion(this.displayName, this.suggestion, this.timeStamp);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = new Map<String, dynamic>();
    json['displayName'] = this.displayName;
    json['suggestion'] = this.suggestion;
    json['timeStamp'] = this.timeStamp;
    return json;
  }
}
