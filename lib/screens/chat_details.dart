import 'package:dfdfdfdf/services/caching_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

import '../services/message.dart';
import '../services/realtime_service.dart';

class ChatDetailsScreen extends StatefulWidget {
  final RealtimeService ablyService;

  final String name;
  const ChatDetailsScreen(
      {required this.ablyService, Key? key, required this.name})
      : super(key: key);

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  late RealtimeService realtimeService;

  @override
  void initState() {
    super.initState();

    realtimeService = widget.ablyService;
    realtimeService.onTheirChannel(widget.name);
  }

  @override
  void dispose() {
    realtimeService.resetChannel();
    super.dispose();
  }

  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: realtimeService.hideKeyboard,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
          centerTitle: true,
        ),
        body: SafeArea(
          child: FooterLayout(
            footer: Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey),
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (controller.text.trim().isEmpty) return;
                      realtimeService.publish(widget.name, controller.text);
                      controller.clear();
                    },
                    icon: const Icon(Icons.send),
                  )
                ],
              ),
            ),
            child: ValueListenableBuilder<List<MyMessage>>(
              valueListenable: realtimeService.allMessages,
              builder: (_, List<MyMessage> value, __) {
                return value.isEmpty
                    ? const Center(
                        child: Text(
                          'No Chats right now\nMessage below',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : NotificationListener<OverscrollIndicatorNotification>(
                        onNotification:
                            (OverscrollIndicatorNotification overscroll) {
                          overscroll.disallowIndicator();
                          return true;
                        },
                        child: ListView.builder(
                          shrinkWrap: true,
                          reverse: true,
                          physics: const ClampingScrollPhysics(),
                          controller: realtimeService.controller,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: value.length,
                          itemBuilder: (_, i) {
                            MyMessage msg = value.reversed.toList()[i];
                            bool isMine = msg.from == AppCache.getUser();
                            return Container(
                              margin: EdgeInsets.only(
                                bottom: 12,
                                right: !isMine ? 100 : 0,
                                left: isMine ? 100 : 0,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isMine)
                                    Text(
                                      msg.from!,
                                      style: const TextStyle(
                                        color: Colors.deepOrange,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  Text(msg.text!),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        DateFormat('EEE, MMM dd hh:mm:ss a')
                                            .format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              msg.date!),
                                        ),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 10),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      );
              },
            ),
          ),
        ),
      ),
    );
  }
}
