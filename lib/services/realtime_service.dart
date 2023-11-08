import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:dfdfdfdf/services/caching_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'ably_service.dart';
import 'message.dart';

class RealtimeService extends ChangeNotifier {
  final ValueNotifier<ably.ConnectionState> connectionState =
      ValueNotifier<ably.ConnectionState>(ably.ConnectionState.initialized);
  final ValueNotifier<ably.ChannelState> yourChannelState =
      ValueNotifier<ably.ChannelState>(ably.ChannelState.initialized);
  final ValueNotifier<ably.ChannelState> myChannelState =
      ValueNotifier<ably.ChannelState>(ably.ChannelState.initialized);
  final ValueNotifier<List<String>> usersWithChat =
      ValueNotifier<List<String>>([]);
  final ValueNotifier<List<MyMessage>> allMessages =
      ValueNotifier<List<MyMessage>>([]);

  final AblyService ablyService;
  final ably.Realtime realtime;
  late ably.RealtimeChannel myChannel;
  late ably.RealtimeChannel yourChannel;
  ScrollController controller = ScrollController();
  List<StreamSubscription<dynamic>> _subscriptions = [];
  String? onChatScreen; // to update the isRead when chatting
  String get me => AppCache.getUser();

  RealtimeService(this.ablyService, {Key? key})
      : realtime = ablyService.realtime;

  void resetChannel() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    onChatScreen = null;
    _subscriptions = [];
    allMessages.value = [];
  }

  Future<void> connect() async {
    // get previous users chat;
    usersWithChat.value = AppCache.chatBox.keys.toList().cast<String>();
    myChannel = realtime.channels.get(me);
    setupListeners();
    await realtime.connect();
    // start my channel
    await onMyChannel();
    // start streaming for new chats on my channel
    subscribe();
    hideKeyboard();
  }

  void publish(String to, String message) async {
    if (yourChannelState.value == ably.ChannelState.attached &&
        myChannelState.value == ably.ChannelState.attached) {
      try {
        DateTime now = DateTime.now();
        String msgId = const Uuid().v4();
        // send to my channel or hardcode it.
        MyMessage mm = MyMessage(
          msgId: msgId,
          text: message,
          date: now.millisecondsSinceEpoch,
          to: to,
          from: me,
          isRead: true,
        );
        setMessage(to, mm);
/*        myChannel.publish(
          message: ably.Message(
            data: message,
            timestamp: DateTime.now(),
            extras: ably.MessageExtras({
              'headers': {
                'to': user,
                'from': deviceName,
                'date': DateTime.now().toIso8601String()
              },
            }),
          ),
        );*/
        // send to their channel
        yourChannel.publish(
          message: ably.Message(
            data: {
              'message': message,
              'to': to,
              'msgId': msgId,
              'from': me,
              'blacklisted': const ['b'],
              'isRead': false,
              'date': now.millisecondsSinceEpoch,
            },
          ),
        );
      } on ably.AblyException catch (e) {
        print(e);
      }
    }
  }

  Future<void> onMyChannel() async {
    myChannel.on().listen((stateChange) {
      myChannelState.value = myChannel.state;
    });
    await myChannel.attach();
  }

  Future<void> updateMessage(user) async {
    AppCache.updateMessage(user);
    usersWithChat.value = AppCache.chatBox.keys.toList().cast<String>();
  }

  Future<void> onTheirChannel(String dName) async {
    onChatScreen = dName;
    yourChannel = realtime.channels.get(dName);
    final channelStateSub = yourChannel.on().listen((stateChange) {
      yourChannelState.value = yourChannel.state;
    });
    await yourChannel.attach();

    _subscriptions.add(channelStateSub);
    allMessages.value = AppCache.getMessages(dName);
    updateMessage(dName);
  }

  void subscribe() async {
    if (myChannelState.value == ably.ChannelState.attached) {
      myChannel.subscribe().listen((message) {
        dynamic data = message.data;
        String to = data['to'];
        String from = data['from'];
        String other = to == me ? from : to;
        MyMessage mm = MyMessage(
          text: data['message'],
          date: data['date']?.toInt(),
          to: to,
          from: from,
          msgId: data['msgId'],
          isRead: data['isRead'],
        );
        setMessage(other, mm);
      });
    }
  }

  void setMessage(String other, MyMessage mm) {
    allMessages.value.add(mm);
    AppCache.setMessage(other, mm);
    usersWithChat.value = AppCache.chatBox.keys.toList().cast<String>();

    allMessages.value = AppCache.getMessages(other);
    if (onChatScreen != null) updateMessage(onChatScreen);
    if (controller.hasClients) {
      controller.jumpTo(controller.position.minScrollExtent);
    }
  }

  void setupListeners() {
    dispose();
    realtime.connection.on().listen((connectionStateChange) {
      if (connectionStateChange.current == ably.ConnectionState.failed) {
        print(connectionStateChange.reason);
      }
      connectionState.value = connectionStateChange.current;
    });
  }

  void hideKeyboard() {
    SystemChannels.textInput.invokeMethod<dynamic>('TextInput.hide');
  }
}
