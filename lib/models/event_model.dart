class EventModel {
  final String eventId;
  final String userId;
  final String eventName;
  final String eventType;
  final String date;
  final String location;
  final String status; // 'draft', 'active', 'completed', 'archived'
  final bool isActive; // For soft delete

  EventModel({
    required this.eventId,
    required this.userId,
    required this.eventName,
    required this.eventType,
    required this.date,
    required this.location,
    required this.status,
    this.isActive = true,
  });

  factory EventModel.fromMap(Map<String, dynamic> data, String id) {
    return EventModel(
      eventId: id,
      userId: data['userId'] ?? '',
      eventName: data['eventName'] ?? '',
      eventType: data['eventType'] ?? '',
      date: data['date'] ?? '',
      location: data['location'] ?? '',
      status: data['status'] ?? 'draft',
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'eventName': eventName,
      'eventType': eventType,
      'date': date,
      'location': location,
      'status': status,
      'isActive': isActive,
    };
  }
}
