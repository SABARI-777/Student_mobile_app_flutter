
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notification_provider.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState
    extends ConsumerState<NotificationScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(notificationProvider.notifier)
          .fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),

      body: notificationState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load notifications'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  ref.read(notificationProvider.notifier)
                      .fetchNotifications();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),

        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Text('No notifications yet'),
            );
          }

          return RefreshIndicator(
            onRefresh: () {
              return ref.read(notificationProvider.notifier)
                  .fetchNotifications();
            },

            child: ListView.builder(
              itemCount: notifications.length,

              itemBuilder: (context, index) {
                final notification = notifications[index];

                return ListTile(
                  leading: Icon(
                    Icons.notifications,
                    color: notification.isRead
                        ? Colors.grey
                        : Colors.blue,
                  ),

                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(notification.message),

                  trailing: notification.isRead
                      ? null
                      : const Icon(
                          Icons.circle,
                          color: Colors.blue,
                          size: 10,
                        ),

                  onTap: () async {
                    if (!notification.isRead) {
                      await ref
                          .read(notificationProvider.notifier)
                          .markAsRead(notification.name);
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
