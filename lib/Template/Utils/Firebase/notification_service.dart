import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'firebase_utils.dart';

class NotificationService extends GetxService {
  static NotificationService get instance => Get.find<NotificationService>();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Request permissions (especially for iOS and Android 13+)
    final NotificationSettings settings = await _fcm.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted notification permissions');
    } else {
      log('User declined or has not accepted notification permissions');
    }

    // 2. Initialize local notifications for foreground alerts
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Latest version (v21+) uses named parameter for initialize
    await _localNotifications.initialize(settings: initializationSettings);

    // 3. Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Received a foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // 4. Handle token setup
    // Do NOT await this, as getToken() will hang the entire app boot indefinitely if offline!
    setupToken();

    // 5. Listen for token refreshes
    _fcm.onTokenRefresh.listen((newToken) async {
      log('FCM Token Refreshed: $newToken');
      await _saveTokenToFirestore(newToken);
    });
  }

  Future<void> setupToken() async {
    try {
      final String? token = await _fcm.getToken();
      if (token != null) {
        log('FCM Token: $token');
        await _saveTokenToFirestore(token);
      }
    } catch (e) {
      log('Error getting FCM token: $e');
    }
  }

  Future<void> _saveTokenToFirestore(String token) async {
    final uid = FirebaseUtils.currentUid;
    if (uid != null) {
      log('Saving FCM token for user $uid');
      try {
        await FirebaseUtils.userDoc(uid).update({
          'fcmToken': token,
          'lastTokenUpdate': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        log('Error saving FCM token to Firestore: $e');
      }
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'high_importance_channel', // positional id
          'High Importance Notifications', // positional name
          channelDescription: 'Used for important document notifications',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      id: message.hashCode,
      title: message.notification?.title,
      body: message.notification?.body,
      notificationDetails: platformChannelSpecifics,
    );
  }
}
