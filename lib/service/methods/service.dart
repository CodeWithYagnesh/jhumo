// import 'dart:async';
// import 'dart:io';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:jhumo/moduls/data/constants.dart';
// import 'package:jhumo/service/methods/iosBackground.dart';
// import 'package:jhumo/service/methods/on_start.dart';
// import 'package:just_audio/just_audio.dart';

// Future<void> initservice() async {

//   await service.configure(
//     iosConfiguration: IosConfiguration(
//       onBackground: iosBackground,
//       onForeground: onStart,
//     ),
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       autoStart: true,
//       isForegroundMode: false,
//       notificationChannelId: CHANNEL,
//       initialNotificationTitle: "Coding is life",
//       autoStartOnBoot: true,
//       initialNotificationContent: "Awsome Content",
//       foregroundServiceNotificationId: 100,
//     ),
//   );
//   await service.startService();
//   service.invoke("setAsForeground");
// }

// Future<void> destroyService() async {
//   service.invoke("stopService");
// }
