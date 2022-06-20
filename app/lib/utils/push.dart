import 'package:app/firebase_options.dart';
import 'package:app/global.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

PushUtil pushUtil = PushUtil._internal();
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   debugPrint("background message=$message");
// }

class PushUtil {
  /// 顶层变量，单例模式
  late final FirebaseMessaging _messaging;

  PushUtil._internal();

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    _messaging = FirebaseMessaging.instance;
    // _messaging.onTokenRefresh.listen((fcmToken) {
    //   User? user = ref.read(globalUserInfoProvider);
    //   if (user == null) {
    //     return;
    //   }
    //   _uploadToken(user, fcmToken);
    //   // Note: This callback is fired at each app startup and whenever a new
    //   // token is generated.
    // }).onError((err) {
    //   debugPrint("error=$err");
    //   // Error getting token.
    // });
    _messaging.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.', // description
      importance: Importance.max,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin
        .initialize(InitializationSettings(android: AndroidInitializationSettings('icon_small_notification'), iOS: IOSInitializationSettings()));
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("onMessage message=$message");
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                // icon: android.smallIcon,
                // other properties...
              ),
            ));
      }
    });

    // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    debugPrint("push ready");
  }

  Future<void> clearUserToken(WidgetRef ref) async {
    User? user = ref.read(globalUserInfoProvider);
    if (user == null) {
      return;
    }
    String? token = preferences.getString(Preferences.KEY_FCM_TOKEN);
    if (token != null) {
      network.deleteFcmToken(user.id, token);
    }
  }

  Future<void> updateUserToken(WidgetRef ref) async {
    // Get the token each time the application loads
    User? user = ref.read(globalUserInfoProvider);
    if (user == null) {
      return;
    }
    final String? token = await _messaging.getToken();
    if (token != null) {
      preferences.putString(Preferences.KEY_FCM_TOKEN, token);
      // Save the initial token to the database
      await _uploadToken(user, token);
    }

    // Any time the token refreshes, store this in the database too.
    // FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
  }

  Future<void> _uploadToken(User user, String token) async {
    network.addFcmToken(user.id, token);
  }
}
