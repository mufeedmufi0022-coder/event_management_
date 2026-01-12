import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get or create a chat between two users
  Future<String> getOrCreateChat(String userId, String otherId) async {
    // We should verify if a booking exists between these two.
    final isAdminChat = userId == 'admin@event.com' || otherId == 'admin@event.com';
    
    if (!isAdminChat) {
      final bookingExists = await _checkIfBookingExists(userId, otherId);
      if (!bookingExists) {
        throw Exception('Chat allowed only after booking request.');
      }
    }

    List<String> ids = [userId, otherId];
    ids.sort();
    String chatId = ids.join('_');

    DocumentSnapshot chatDoc = await _firestore.collection('chats').doc(chatId).get();

    if (!chatDoc.exists) {
      await _firestore.collection('chats').doc(chatId).set({
        'participants': ids,
        'lastMessage': '',
        'lastTimestamp': FieldValue.serverTimestamp(),
      });
    }

    return chatId;
  }

  Future<bool> _checkIfBookingExists(String userId, String otherId) async {
    // Check bookings for both ways (User->Vendor or Vendor->User context)
    final snapshot = await _firestore.collection('bookings')
        .where('userId', whereIn: [userId, otherId])
        .where('vendorId', whereIn: [userId, otherId])
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  // Check if chat is read only (booking completed or cancelled)
  Future<bool> isChatReadOnly(String chatId) async {
    List<String> ids = chatId.split('_');
    if (ids.length != 2) return false;

    final snapshot = await _firestore.collection('bookings')
        .where('userId', whereIn: ids)
        .where('vendorId', whereIn: ids)
        .where('isActive', isEqualTo: true)
        .get();
    
    if (snapshot.docs.isEmpty) return true;

    // If all related active bookings are completed or cancelled
    bool allClosed = true;
    for (var doc in snapshot.docs) {
      String status = doc['status'] ?? '';
      if (status != 'completed' && status != 'cancelled') {
        allClosed = false;
        break;
      }
    }
    return allClosed;
  }

  // Get all chats for a user
  Stream<List<ChatModel>> getMyChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastTimestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get messages for a specific chat
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data()))
            .toList());
  }

  // Send a message
  Future<void> sendMessage(String chatId, MessageModel message) async {
    // Verify if still allowed to chat
    final isAdminChat = chatId.contains('admin@event.com');
    if (!isAdminChat && await isChatReadOnly(chatId)) {
      throw Exception('Chat is read-only for this booking.');
    }

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': message.content,
      'lastTimestamp': FieldValue.serverTimestamp(),
    });
  }
}
