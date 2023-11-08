import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/caching_service.dart';
import '../services/realtime_service.dart';
import 'chat_details.dart';

class NewChat extends StatefulWidget {
  const NewChat({super.key, required this.service});
  final RealtimeService service;
  @override
  State<NewChat> createState() => _NewChatState();
}

class _NewChatState extends State<NewChat> {
  @override
  void initState() {
    users.remove(AppCache.getUser());
    users.shuffle();
    filtered.addAll(users);
    super.initState();
  }

  List<String> filtered = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('All Chats'), centerTitle: true),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CupertinoTextField(
                placeholder: 'Search...',
                onChanged: (a) {
                  a = a.trim();
                  if (a.isNotEmpty) {
                    a = a.toUpperCase();
                    filtered.clear();
                    for (String item in users) {
                      if (item.toUpperCase().contains(a)) {
                        filtered.add(item);
                      }
                    }
                  } else {
                    filtered.clear();
                    filtered.addAll(users);
                  }
                  setState(() {});
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  dynamic key = filtered[i];
                  return ListTile(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => ChatDetailsScreen(
                            ablyService: widget.service,
                            name: key,
                          ),
                        ),
                      );
                    },
                    leading: const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey,
                    ),
                    title: Text(
                      key,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }
}
