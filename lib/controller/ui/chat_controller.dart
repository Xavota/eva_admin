import 'dart:async';
import 'dart:io';

import 'package:medicare/helpers/utils/generator.dart';
import 'package:medicare/model/chat_model.dart';
import 'package:medicare/views/my_controller.dart';
import 'package:flutter/material.dart';

class ChatController extends MyController {
  List<ChatModel> chat = [];
  List<ChatModel> searchChat = [];
  ChatModel? selectChat;
  SearchController searchController = SearchController();
  TextEditingController messageController = TextEditingController();
  ScrollController? scrollController;
  late Timer _timer;
  int _nowTime = 0;
  String timeText = "00 : 00";
  File? image;
  File? imageSelect;
  int selectedChat = 0;

  ChatController() {
    ChatModel.dummyList.then((value) {
      chat = value;
      selectChat = chat[0];
      searchChat = value;
      update();
    });
    scrollController = ScrollController();
    startTimer();
  }

  void onSelectChat(id) {
    selectedChat = id;
    update();
  }

  void onChangeChat(ChatModel selectSingleChat) {
    selectChat = selectSingleChat;
    update();
  }

  void onSearchChat(String query) {
    final input = query.toLowerCase();
    searchChat = chat.where((chat) => chat.firstName.toLowerCase().contains(input) || chat.messages.lastOrNull!.message.toLowerCase().contains(input)).toList();
    update();
  }

  void sendMessage() {
    if (messageController.value.text.isNotEmpty && selectChat != null) {
      selectChat!.messages.add(ChatMessageModel(-1, messageController.text, DateTime.now(), true, ""));
      messageController.clear();
      scrollToBottom(isDelayed: true);
      update();
    }
  }

  scrollToBottom({bool isDelayed = false}) {
    final int delay = isDelayed ? 400 : 0;
    Future.delayed(Duration(milliseconds: delay), () {
      scrollController!
          .animateTo(scrollController!.position.maxScrollExtent, duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubicEmphasized);
    });
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      _nowTime = _nowTime + 1;
      timeText = Generator.getTextFromSeconds(time: _nowTime);
      update();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }
}
