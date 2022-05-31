import 'package:firebase_messaging/firebase_messaging.dart';

PushUtil pushUtil = PushUtil._internal();

class PushUtil {
  /// 顶层变量，单例模式
  late final FirebaseMessaging messaging;

  PushUtil._internal() {
    messaging = FirebaseMessaging.instance;
  }

  Future<void> getToken() async {
    String? token = await messaging.getToken(
      vapidKey: "BOePBv0Mh2LPajef9rJ4qKWDt_h7Rnd6ofT13S3wXFDELv-WYd2U2Dv27j6UOxAO-szCIdwOJYi_bI7viqPqxG8",
    );
  }
}
