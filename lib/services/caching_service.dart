import 'dart:math';

import 'package:hive_flutter/adapters.dart';

import 'message.dart';

class AppCache {
  static String kChatBox = 'userBox';
  static String kOtherBox = 'otherBox';
  static const String userKey = 'userKeyrgewr';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(kChatBox);
    await Hive.openBox<dynamic>(kOtherBox);
  }

  static Box<dynamic> get chatBox => Hive.box<dynamic>(kChatBox);
  static Box<dynamic> get _otherBox => Hive.box<dynamic>(kOtherBox);

  static String getUser() {
    String? u = _otherBox.get(userKey);
    if (u == null) {
      int randomNumber = Random().nextInt(users.length);
      String user = users[randomNumber];
      _otherBox.put(userKey, user);
      return user;
    } else {
      return u;
    }
  }

  static Future<void> setMessage(String user, MyMessage msg) async {
    List msgs = _getMessages(user);
    msgs.add(msg.toJson());
    await chatBox.put(user, msgs);
  }

  static Future<void> updateMessage(String user) async {
    List msgs = _getMessages(user);
    if (msgs.isEmpty) return;
    dynamic d = msgs.last;
    d['isRead'] = true;
    msgs.removeLast();
    msgs.add(d);

    await chatBox.put(user, msgs);
  }

  static List _getMessages(String user) {
    return chatBox.get(user, defaultValue: []);
  }

  static List<MyMessage> getMessages(String user) {
    List<MyMessage> all = [];
    _getMessages(user).forEach((e) {
      all.add(MyMessage.fromJson(e));
    });

    return all;
  }

  static Future<void> clear() async {
    await chatBox.clear();
  }

  static void clean(String key) {
    chatBox.delete(key);
  }
}

List<String> users = [
  'Goodness',
  'Ella',
  'Oslo',
  "Ahl",
  "Ahlgren",
  "Ahmad",
  "Ahmar",
  "Ahmed",
  "Jawhara",
  "Raaniya",
  "Ghaada",
  "Ghazaala",
  "Raabia",
  "Ahola",
  "Aholah",
  "Aholla",
  "Ahoufe",
  "Ahouh",
  "Bashir",
  "Shaquille",
  "Ursery",
  "Keilan",
  "Marlow",
  "Marvin",
  "Bell",
  "Daishavon",
  "Hammond",
  "Kyle",
  "Ahrendt",
  "Ahrens",
  "Ahron",
  "Aia",
  "Aida",
  "Mossberg",
  "Cassie",
  "Mendiaz",
  "Victoria",
  "Miner",
  "Cassidy",
  "Austin",
  "Brook",
  "Babcock",
  "Lloyd",
  "Aidan",
  "Ambrogio",
  "Ambros",
  "Ambrosane",
  "Ambrose",
  "Ambrosi",
  "Ambrosia",
  "Ambrosine",
  "Bruckner",
  "Birva",
  "Caringer",
  "Madelyn",
  "Mendoza",
  "Rebecca",
  "El-Haque",
  "Jaleela",
  "Williams",
  "Miranda",
  "Ambrosio",
  "Ambrosius",
  "Ambur",
  "Amby",
  "Ame",
  "al-Salam",
  "Rida",
  "Debus",
  "Kai",
  "Al-Aly",
  "Jaabir",
  "Garces",
  "Markus",
  "Robertson",
  "Trevor",
  "Amedeo",
  "Amelia",
  "Amelie",
  "Amelina",
  "Ameline",
  "Amelita",
  "Amena",
  "Amend",
  "Aiden",
  "Aiello",
  "Aigneis",
  "Aiken",
  "Aila",
  "Ailbert",
  "Aile",
  'richard',
  'Israel'
];
