import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize notifications
  Future<void> initialize() async {
    await _firebaseMessaging.requestPermission();
    _setupPushNotifications();
  }

  // Send notification (Admin only)
  Future<void> sendNotification({
    required String title,
    required String body,
  }) async {
    await _firestore.collection('notifications').add({
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  // Listen to notifications (Students)
  Stream<QuerySnapshot> getNotifications() {
    return _firestore
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Handle push notifications
  void _setupPushNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground notifications
      print('Foreground Notification: ${message.notification?.title}');
    });

    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Handle background/terminated notifications
    print('Background Notification: ${message.notification?.title}');
  }
}