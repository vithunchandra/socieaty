import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_notification_service.g.dart';

@Riverpod(keepAlive: true)
LocalNotificationService localNotificationService(Ref ref) {
  return LocalNotificationService();
}

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  @pragma('vm:entry-point')
  Function(String?)? _onNotificationTap;

  void setOnNotificationTap(Function(String?) onTap) {
    _onNotificationTap = onTap;
  }

  Future<void> init() async {
    if (_isInitialized) return;

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    // Initialize settings for both platforms
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked: ${response.payload}');
        // Handle notification click
        if (_onNotificationTap != null) {
          _onNotificationTap!(response.payload);
        }
      },
    );

    await _createNotificationChannels();

    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? granted = await androidImplementation.requestNotificationsPermission();
        debugPrint('Android notification permission granted: $granted');
      }
    } catch (e) {
      debugPrint('Error requesting Android notification permission: $e');
    }

    try {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

      if (iosImplementation != null) {
        final bool? granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint('iOS notification permission granted: $granted');
      }
    } catch (e) {
      debugPrint('Error requesting iOS notification permission: $e');
    }

    _isInitialized = true;
    debugPrint('LocalNotificationService initialized');
  }

  Future<void> _createNotificationChannels() async {
    final AndroidNotificationChannel newOrderChannel = AndroidNotificationChannel(
      'new_order_channel',
      'New Orders',
      description: 'Priority notifications for new restaurant orders',
      importance: Importance.high,
      enableLights: true,
      ledColor: const Color(0xFF00C853),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 100, 200, 300]),
      showBadge: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(newOrderChannel);

    debugPrint('Created enhanced notification channels');
  }

  Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      await init();
    }

    bool permissionGranted = false;

    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? granted = await androidImplementation.requestNotificationsPermission();
        debugPrint('Android notification permission granted: $granted');
        permissionGranted = granted ?? false;
      }
    } catch (e) {
      debugPrint('Error requesting Android notification permission: $e');
    }

    try {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

      if (iosImplementation != null) {
        final bool? granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint('iOS notification permission granted: $granted');
        permissionGranted = granted ?? false;
      }
    } catch (e) {
      debugPrint('Error requesting iOS notification permission: $e');
    }

    return permissionGranted;
  }

  Future<void> showNewOrderNotification({
    required String title,
    required String body,
    String? payload,
    Map<String, dynamic>? orderDetails,
  }) async {
    if (!_isInitialized) {
      await init();
    }

    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'new_order_channel',
      'New Orders',
      channelDescription: 'Notifications for new restaurant orders',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'New Order',
      color: Colors.green,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        body,
        htmlFormatBigText: true,
        contentTitle: '<b>$title</b>',
        htmlFormatContentTitle: true,
        summaryText: 'New restaurant order',
        htmlFormatSummaryText: true,
      ),
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.message,
      fullScreenIntent: true,
      enableLights: true,
      ledColor: const Color(0xFF00C853),
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    final DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      badgeNumber: 1,
      interruptionLevel: InterruptionLevel.timeSensitive,
      categoryIdentifier: 'new_order',
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}
