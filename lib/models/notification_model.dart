
class NotificationModel {
  final String name;
  final String title;
  final String message;
  final bool isRead;
  final String creation;

  NotificationModel({
    required this.name,
    required this.title,
    required this.message,
    required this.isRead,
    required this.creation,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      creation: json['creation'] ?? '',
    );
  }
}
