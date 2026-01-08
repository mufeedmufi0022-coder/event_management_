import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../models/chat_model.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  
  Stream<List<ChatModel>> getMyChats(String userId) {
    return _chatService.getMyChats(userId);
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _chatService.getMessages(chatId);
  }

  Future<void> sendMessage(String chatId, String senderId, String content) async {
    final message = MessageModel(
      senderId: senderId,
      content: content,
      timestamp: DateTime.now(),
    );
    await _chatService.sendMessage(chatId, message);
  }

  Future<String> startChat(String userId, String otherId) async {
    return await _chatService.getOrCreateChat(userId, otherId);
  }
}
