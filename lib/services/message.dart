class MyMessage {
  String? from;
  String? to;
  String? text;
  String? msgId;
  int? date;
  bool? isRead;
  MyMessage(
      {this.text, this.from, this.date, this.to, this.isRead, this.msgId});

  MyMessage.fromJson(dynamic json) {
    text = json['text'] ?? '---';
    from = json['from'];
    date = json['date'];
    to = json['to'];
    msgId = json['msgId'];
    isRead = json['isRead'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['from'] = from;
    data['date'] = date;
    data['to'] = to;
    data['msgId'] = msgId;
    data['isRead'] = isRead;
    return data;
  }
}
