import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geofence_service/geofence_service.dart';

class GeofenceNotificationDebouncer {
  final int seconds;
  Timer? _timer;

  final List<Geofence> _cachedGeofences = [];

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  GeofenceNotificationDebouncer({required this.seconds});

  void add(Geofence geofence) {
    print('🤑 got geofence');
    _cachedGeofences.add(geofence);
    _timer?.cancel();
    _timer = Timer(Duration(seconds: seconds), _sendNotification);
  }

  void _sendNotification() async {
    if (_cachedGeofences.length == 1) {
      final geofence = _cachedGeofences.first;
      await _showNotification(geofence.id, geofence.data);
      _cachedGeofences.clear();
    } else {
      await _showNotification(
        'Hay varios aliados cerca de tí',
        'Clickea aquí para ver las ofertas',
      );
      _cachedGeofences.clear();
    }
  }

  Future<void> _showNotification(String title, String value) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'geofence',
      'Geofence Notifications',
      channelDescription: 'Geofence Notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentBanner: true,
    );

    int notificationId = 1;
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      value,
      notificationDetails,
    );
  }

  void dispose() {
    _timer?.cancel();
  }
}
