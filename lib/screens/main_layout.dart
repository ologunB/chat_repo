import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/ably_service.dart';
import '../services/caching_service.dart';
import '../services/message.dart';
import '../services/realtime_service.dart';
import 'chat_details.dart';
import 'new_chat.dart';

class MainLayout extends StatefulWidget {
  final AblyService ablyService;

  const MainLayout({required this.ablyService, Key? key}) : super(key: key);
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentPage = 0;
  PageController pageController = PageController();
  late RealtimeService realtimeService;
  @override
  void initState() {
    realtimeService = RealtimeService(widget.ablyService);
    realtimeService.connect();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ValueListenableBuilder<ably.ConnectionState>(
              valueListenable: realtimeService.connectionState,
              builder: (_, ably.ConnectionState value, __) {
                String a = value.name;
                return Text(
                  '${AppCache.getUser()} Status: $a',
                  style: TextStyle(
                    color: a == 'connected' ? Colors.green : Colors.red,
                  ),
                );
              },
            ),
            Row(children: [item(0)]),
            Expanded(
              child: PageView(
                controller: pageController,
                onPageChanged: (a) {
                  currentPage = a;
                  setState(() {});
                },
                children: [
                  ChatScreen(service: realtimeService),
                  //   ChatScreen(ablyService: realtimeService),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add_rounded),
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => NewChat(service: realtimeService),
              ),
            );
          }),
    );
  }

  Widget item(int i) {
    return Expanded(
      child: InkWell(
        onTap: () {
          pageController.animateToPage(
            i,
            duration: const Duration(seconds: 1),
            curve: Curves.linearToEaseOut,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          color: currentPage == i ? Colors.deepPurple : null,
          alignment: Alignment.center,
          child: Text(
            'Chats',
            style: TextStyle(
              fontSize: 18,
              color: currentPage == i ? Colors.white : null,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final RealtimeService service;

  const ChatScreen({required this.service, Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
        valueListenable: widget.service.usersWithChat,
        builder: (_, List<String> value, __) {
          return value.isEmpty
              ? const Center(
                  child: Text(
                    'No Chats right now\nAdd Chat below',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: value.length,
                  itemBuilder: (_, i) {
                    String key = value[i];
                    MyMessage last = AppCache.getMessages(key).last;

                    return ListTile(
                      onTap: () {
                        Navigator.push(
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
                      trailing: last.isRead == true
                          ? null
                          : const Text(
                              'NEW',
                              style: TextStyle(color: Colors.green),
                            ),
                      subtitle: Text(
                        last.text!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: last.isRead == true
                              ? Colors.grey
                              : Colors.black45,
                          fontWeight: last.isRead == true
                              ? FontWeight.w400
                              : FontWeight.w500,
                        ),
                      ),
                    );
                  },
                );
        });
  }
}
