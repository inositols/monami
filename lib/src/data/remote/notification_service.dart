import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:monami/src/data/state/constants/firebase_collection.dart';
import 'package:monami/src/models/notification_model.dart';
import 'package:monami/src/utils/logger.dart';

/// Service to handle Firebase Cloud Messaging and notifications
class NotificationService {
  final _logger = Logger(NotificationService);
  final _firestore = FirebaseFirestore.instance;
  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  /// Initialize Firebase Messaging and Local Notifications
  Future<void> initialize() async {
    try {
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permission for notifications
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      _logger.log('User granted permission: ${settings.authorizationStatus}');

      // Get FCM token
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token);
        _logger.log('FCM Token: $token');
      }

      // Handle token refresh
      _messaging.onTokenRefresh.listen(_saveTokenToFirestore);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle notification tap when app is terminated
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

    } catch (e) {
      _logger.log('Error initializing Firebase Messaging: $e');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request notification permissions
      await _requestNotificationPermissions();

      _logger.log('Local notifications initialized successfully');
    } catch (e) {
      _logger.log('Error initializing local notifications: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestNotificationPermissions() async {
    try {
      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        print('DEBUG: Android notification permission granted: $granted');
      }

      final iosPlugin = _localNotifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        print('DEBUG: iOS notification permission granted: $granted');
      }
    } catch (e) {
      print('DEBUG: Error requesting notification permissions: $e');
    }
  }

  /// Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    _logger.log('Local notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }

  /// Save FCM token to Firestore
  Future<void> _saveTokenToFirestore(String token) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      await _firestore
          .collection(FirebaseCollectionName.users)
          .doc(currentUser.uid)
          .update({
        'fcmToken': token,
        'lastTokenUpdate': DateTime.now().toIso8601String(),
      });

      _logger.log('FCM token saved to Firestore');
    } catch (e) {
      _logger.log('Error saving FCM token: $e');
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    _logger.log('Received foreground message: ${message.messageId}');
    
    // Show local notification or in-app notification
    _showInAppNotification(message);
  }

  /// Handle notification taps
  void _handleNotificationTap(RemoteMessage message) {
    _logger.log('Notification tapped: ${message.messageId}');
    
    // Handle navigation based on notification data
    final data = message.data;
    if (data.containsKey('type')) {
      _handleNotificationNavigation(data);
    }
  }

  /// Show in-app notification
  void _showInAppNotification(RemoteMessage message) {
    // This would typically show a banner or snackbar
    // Implementation depends on your app's navigation setup
    _logger.log('Showing in-app notification: ${message.notification?.title}');
  }

  /// Handle navigation based on notification data
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final productId = data['productId'] as String?;
    
    switch (type) {
      case 'like':
        // Navigate to product detail
        _logger.log('Navigate to product: $productId (liked)');
        break;
      case 'review':
        // Navigate to product reviews
        _logger.log('Navigate to product reviews: $productId');
        break;
      case 'purchase':
        // Navigate to order details
        _logger.log('Navigate to order details: $productId');
        break;
    }
  }

  /// Send notification to product owner when someone likes their product
  Future<void> sendLikeNotification({
    required String productId,
    required String productName,
    required String likerName,
    required String productOwnerId,
  }) async {
    try {
      print('DEBUG: sendLikeNotification called - productId: $productId, ownerId: $productOwnerId');
      
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: productOwnerId,
        type: NotificationType.like,
        title: 'Someone liked your product!',
        body: '$likerName liked your product "$productName"',
        data: {
          'productId': productId,
          'likerName': likerName,
          'type': 'like',
        },
        isRead: false,
        createdAt: DateTime.now(),
      );

      print('DEBUG: About to save notification to Firestore');
      await _saveNotificationToFirestore(notification);
      
      print('DEBUG: About to send push notification');
      await _sendPushNotification(notification);
      
      print('DEBUG: Like notification process completed successfully');
      _logger.log('Like notification sent successfully');
    } catch (e) {
      _logger.log('Error sending like notification: $e');
    }
  }

  /// Send notification to product owner when someone reviews their product
  Future<void> sendReviewNotification({
    required String productId,
    required String productName,
    required String reviewerName,
    required String productOwnerId,
    required double rating,
  }) async {
    try {
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: productOwnerId,
        type: NotificationType.review,
        title: 'New review on your product!',
        body: '$reviewerName rated your product "$productName" ${rating.toStringAsFixed(1)} stars',
        data: {
          'productId': productId,
          'reviewerName': reviewerName,
          'rating': rating.toString(),
          'type': 'review',
        },
        isRead: false,
        createdAt: DateTime.now(),
      );

      await _saveNotificationToFirestore(notification);
      await _sendPushNotification(notification);
      
      _logger.log('Review notification sent successfully');
    } catch (e) {
      _logger.log('Error sending review notification: $e');
    }
  }

  /// Send notification to product owner when someone purchases their product
  Future<void> sendPurchaseNotification({
    required String productId,
    required String productName,
    required String buyerName,
    required String productOwnerId,
    required int quantity,
    required double totalAmount,
  }) async {
    try {
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: productOwnerId,
        type: NotificationType.purchase,
        title: 'New sale! 🎉',
        body: '$buyerName purchased $quantity x "$productName" for \$${totalAmount.toStringAsFixed(2)}',
        data: {
          'productId': productId,
          'buyerName': buyerName,
          'quantity': quantity.toString(),
          'totalAmount': totalAmount.toString(),
          'type': 'purchase',
        },
        isRead: false,
        createdAt: DateTime.now(),
      );

      await _saveNotificationToFirestore(notification);
      await _sendPushNotification(notification);
      
      _logger.log('Purchase notification sent successfully');
    } catch (e) {
      _logger.log('Error sending purchase notification: $e');
    }
  }

  /// Save notification to Firestore
  Future<void> _saveNotificationToFirestore(NotificationModel notification) async {
    try {
      print('DEBUG: Saving notification to Firestore: ${notification.title}');
      
      await _firestore
          .collection(FirebaseCollectionName.notifications)
          .doc(notification.id)
          .set(notification.toJson());

      _logger.log('Notification saved to Firestore');
      print('DEBUG: Notification saved successfully to Firestore');
    } catch (e) {
      _logger.log('Error saving notification to Firestore: $e');
      print('DEBUG: Error saving notification: $e');
    }
  }

  /// Send push notification via FCM and local notifications
  Future<void> _sendPushNotification(NotificationModel notification) async {
    try {
      print('DEBUG: _sendPushNotification called for: ${notification.title}');
      
      // Send local notification immediately
      print('DEBUG: About to show local notification');
      await _showLocalNotification(notification);

      // Get the user's FCM token for future cloud notifications
      final userDoc = await _firestore
          .collection(FirebaseCollectionName.users)
          .doc(notification.userId)
          .get();

      if (!userDoc.exists) {
        _logger.log('User document not found');
        return;
      }

      final userData = userDoc.data();
      final fcmToken = userData?['fcmToken'] as String?;

      if (fcmToken == null) {
        _logger.log('User FCM token not found');
        return;
      }

      _logger.log('FCM token available for future cloud notifications: $fcmToken');
      _logger.log('Local notification sent: ${notification.title} - ${notification.body}');

    } catch (e) {
      _logger.log('Error sending push notification: $e');
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(NotificationModel notification) async {
    try {
      print('DEBUG: Showing local notification: ${notification.title}');
      
      const androidDetails = AndroidNotificationDetails(
        'monami_notifications',
        'Monami Notifications',
        channelDescription: 'Notifications for likes, reviews, and purchases',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      print('DEBUG: About to call _localNotifications.show');
      await _localNotifications.show(
        notification.id.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
        payload: notification.id,
      );

      print('DEBUG: Local notification displayed successfully: ${notification.title}');
      _logger.log('Local notification displayed: ${notification.title}');
    } catch (e) {
      _logger.log('Error showing local notification: $e');
    }
  }

  /// Get user notifications
  Future<List<NotificationModel>> getUserNotifications() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('DEBUG: No current user found for getUserNotifications');
        throw Exception('User not authenticated');
      }

      print('DEBUG: Getting notifications for user: ${currentUser.uid}');

      final querySnapshot = await _firestore
          .collection(FirebaseCollectionName.notifications)
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .get();

      print('DEBUG: Found ${querySnapshot.docs.length} notification documents');

      final notifications = querySnapshot.docs
          .map((doc) {
            print('DEBUG: Processing notification document: ${doc.id}');
            print('DEBUG: Document data: ${doc.data()}');
            return NotificationModel.fromJson(doc.data());
          })
          .toList();

      print('DEBUG: Successfully parsed ${notifications.length} notifications');
      _logger.log('Retrieved ${notifications.length} notifications');
      return notifications;
    } catch (e) {
      print('DEBUG: Error getting user notifications: $e');
      _logger.log('Error getting user notifications: $e');
      return [];
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(FirebaseCollectionName.notifications)
          .doc(notificationId)
          .update({'isRead': true});

      _logger.log('Notification marked as read: $notificationId');
    } catch (e) {
      _logger.log('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final querySnapshot = await _firestore
          .collection(FirebaseCollectionName.notifications)
          .where('userId', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      _logger.log('All notifications marked as read');
    } catch (e) {
      _logger.log('Error marking all notifications as read: $e');
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadCount() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return 0;

      final querySnapshot = await _firestore
          .collection(FirebaseCollectionName.notifications)
          .where('userId', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .get();

      _logger.log('Unread notifications count: ${querySnapshot.docs.length}');
      return querySnapshot.docs.length;
    } catch (e) {
      _logger.log('Error getting unread count: $e');
      return 0;
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final querySnapshot = await _firestore
          .collection(FirebaseCollectionName.notifications)
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      _logger.log('All notifications cleared');
    } catch (e) {
      _logger.log('Error clearing notifications: $e');
    }
  }

  /// Debug method to check all notifications in Firestore
  Future<void> debugCheckAllNotifications() async {
    try {
      print('DEBUG: Checking all notifications in Firestore...');
      
      final querySnapshot = await _firestore
          .collection(FirebaseCollectionName.notifications)
          .get();
      
      print('DEBUG: Total notifications in Firestore: ${querySnapshot.docs.length}');
      
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        print('DEBUG: Notification ${doc.id}: userId=${data['userId']}, title=${data['title']}');
      }
    } catch (e) {
      print('DEBUG: Error checking all notifications: $e');
    }
  }

  /// Send test notification (for testing purposes)
  Future<void> sendTestNotification() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('DEBUG: No current user found for test notification');
        return;
      }

      print('DEBUG: Sending test notification to user: ${currentUser.uid}');

      final testNotification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUser.uid,
        type: NotificationType.general,
        title: 'Test Notification',
        body: 'This is a test notification to verify the system is working!',
        data: {'type': 'test'},
        isRead: false,
        createdAt: DateTime.now(),
      );

      print('DEBUG: Test notification created, saving to Firestore...');
      await _saveNotificationToFirestore(testNotification);
      
      print('DEBUG: Test notification saved, showing local notification...');
      await _showLocalNotification(testNotification);
      
      print('DEBUG: Test notification process completed');
      _logger.log('Test notification sent successfully');
    } catch (e) {
      print('DEBUG: Error in test notification: $e');
      _logger.log('Error sending test notification: $e');
    }
  }
}

/// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already done
  // await Firebase.initializeApp();
  
  print('Handling a background message: ${message.messageId}');
}