class AppNotification {
  const AppNotification({
    required this.id,
    required this.groupId,
    required this.createdBy,
    required this.type,
    required this.message,
    required this.createdAt,
    required this.readAt,
  });

  final int id;
  final int groupId;
  final int createdBy;
  final String type;
  final String message;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get isRead => readAt != null;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int,
      groupId: json['group_id'] as int,
      createdBy: json['created_by'] as int,
      type: json['type'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
    );
  }
}
