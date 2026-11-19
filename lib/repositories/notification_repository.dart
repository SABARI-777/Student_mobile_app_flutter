
import 'package:dio/dio.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final Dio dio;

  NotificationRepository(this.dio);

  // Fetch notifications
  Future<List<NotificationModel>> getNotifications() async {
    final response = await dio.get(
      '/api/method/student_management.api.get_my_notifications',
    );

    final List data = response.data['message'];

    return data
        .map((item) => NotificationModel.fromJson(item))
        .toList();
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationName) async {
    await dio.post(
      '/api/method/student_management.api.mark_notification_as_read',
      data: {
        'notification_name': notificationName,
      },
    );
  }

  // Create login notification
  Future<void> createLoginNotification() async {
    await dio.post(
      '/api/method/student_management.api.create_login_notification',
    );
  }
}
