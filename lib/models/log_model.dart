import 'package:cloud_firestore/cloud_firestore.dart';

class LogModel {
  final String id;
  final String type; // 'event' | 'booking' | 'system'
  final String action;
  final String actorId;
  final DateTime timestamp;

  LogModel({
    required this.id,
    required this.type,
    required this.action,
    required this.actorId,
    required this.timestamp,
  });

  factory LogModel.fromMap(Map<String, dynamic> data, String id) {
    return LogModel(
      id: id,
      type: data['type'] ?? '',
      action: data['action'] ?? '',
      actorId: data['actorId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'action': action,
      'actorId': actorId,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
