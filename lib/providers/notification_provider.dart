
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';
import 'auth_provider.dart';

// Repository provider
final notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  return NotificationRepository(apiClient.dio);
});

// Notification state provider
final notificationProvider =
    AsyncNotifierProvider<NotificationNotifier,
        List<NotificationModel>>(
  NotificationNotifier.new,
);

class NotificationNotifier
    extends AsyncNotifier<List<NotificationModel>> {

  @override
  Future<List<NotificationModel>> build() async {
    return [];
  }

  // Fetch notifications from Frappe
  Future<void> fetchNotifications() async {
    state = const AsyncLoading();

    try {
      final repository =
          ref.read(notificationRepositoryProvider);

      final notifications =
          await repository.getNotifications();

      state = AsyncData(notifications);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  // Get unread notification count
  int get unreadCount {
    final notifications = state.asData?.value ?? [];

    return notifications
        .where((notification) => !notification.isRead)
        .length;
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationName) async {
    try {
      final repository =
          ref.read(notificationRepositoryProvider);

      // Update notification in Frappe
      await repository.markAsRead(notificationName);

      // Get current notifications
      final notifications = state.asData?.value ?? [];

      // Update Flutter state
      state = AsyncData(
        notifications.map((notification) {
          if (notification.name == notificationName) {
            return NotificationModel(
              name: notification.name,
              title: notification.title,
              message: notification.message,
              isRead: true,
              creation: notification.creation,
            );
          }

          return notification;
        }).toList(),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
