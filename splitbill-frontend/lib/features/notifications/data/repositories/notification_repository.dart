import 'package:splitbill_frontend/app/core/network/api_client.dart';
import 'package:splitbill_frontend/features/notifications/data/models/app_notification.dart';

class NotificationRepository {
  NotificationRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<AppNotification>> getNotifications() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/notifications',
    );

    final data = response.data!['data'] as List<dynamic>;

    return data
        .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/notifications/unread-count',
    );

    return response.data!['data'] as int;
  }

  Future<void> markAsRead(int notificationId) async {
    await _apiClient.patch<Map<String, dynamic>>(
      '/notifications/$notificationId/read',
    );
  }
}
