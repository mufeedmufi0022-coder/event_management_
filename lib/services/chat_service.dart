import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get or create a chat between two users
  Future<String> getOrCreateChat(String userId, String otherId) async {
    // Admin chat check: one of the participants is an admin
    // Note: Admin ID in this system is 'admin@event.com'
    // But we should also check the users collection for the 'role' if needed.
    // However, the system initializes admin with docId 'admin@event.com'.
    
    List<String> ids = [userId, otherId];
    ids.sort();
    String chatId = ids.join('_');

    DocumentSnapshot chatDoc = await _firestore.collection('chats').doc(chatId).get();

    if (!chatDoc.exists) {
      await _firestore.collection('chats').doc(chatId).set({
        'participants': ids,
        'lastMessage': '',
        'lastTimestamp': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return chatId;
  }

  Future<bool> _checkIfBookingExists(String userId, String otherId) async {
    // Keep this for UI markers if needed, but no longer blocking chat.
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
    // Admin chats are never read-only
    if (chatId.contains('admin@event.com')) return false;

    List<String> ids = chatId.split('_');
    if (ids.length != 2) return false;

    // We check if there are ANY active bookings between these two.
    // In our system, bookings are 'isActive=true' by default.
    final snapshot = await _firestore.collection('bookings')
        .where('userId', whereIn: ids)
        .where('vendorId', whereIn: ids)
        .where('isActive', isEqualTo: true)
        .get();
    
    // If no booking exists, it's an inquiry chat, so NOT read-only.
    if (snapshot.docs.isEmpty) return false;

    // If bookings exist, we check if they are all closed.
    bool hasOpenBooking = false;
    for (var doc in snapshot.docs) {
      String status = doc['status'] ?? '';
      // Statuses like 'requested', 'quotation', 'accepted' are open.
      if (status != 'completed' && status != 'cancelled') {
        hasOpenBooking = true;
        break;
      }
    }

    // If it has at least one open booking, it's NOT read-only.
    // If all existing bookings are closed, then it's read-only.
    return !hasOpenBooking;
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
