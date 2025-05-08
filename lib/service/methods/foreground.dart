// import 'dart:async';

// import 'package:jhumo/main.dart';
// import 'package:jhumo/moduls/data/constants.dart';
// import 'package:just_audio/just_audio.dart';

// void foregroundService(Map<String, dynamic>? event) {
//   print("foreground ===============");

//   double? previousVolume;
//   volumeController.removeListener();
//   int increaseCount = 0;
//   int decreaseCount = 0;
//   Timer.periodic(Duration(seconds: 3), (timer) {
//     increaseCount = 0;
//     decreaseCount = 0;
//   });
//   volumeController.addListener((volume) async {
//     print('CHANGED_VOLUME');

//     if (previousVolume != null) {
//       if (volume > previousVolume!) {
//         increaseCount++;
//         decreaseCount = 0; // Reset decrease count
//         if (increaseCount >= 5) {
//           print('Volume increased 5 times');
//           await audioHandler.skipToNext().catchError((e){
//             print("IYagnesh_ERROR: $e");
//           });
//           increaseCount = 0; // Reset increase count
//         }
//       } else if (volume < previousVolume!) {
//         decreaseCount++;
//         increaseCount = 0; // Reset increase count
//         if (decreaseCount >= 5) {
//           print('Volume decreased 5 times');
//           await audioHandler.skipToPrevious();

//           decreaseCount = 0; // Reset decrease count
//         }
//       }
//     }
//     previousVolume = volume;
//   });
//   // MethodChannel("FOREGROUND_SVC").invokeMethod("onShortPress");

//   // Timer.periodic(Duration(seconds: 2), (timer) {
//   //   print("Background service ${DateTime.now()}");

//   //   flutterLocalPlugin.show(
//   //     90,
//   //     "Cool Service",
//   //     "Awsome ${DateTime.now()}",

//   //     NotificationDetails(
//   //       android: AndroidNotificationDetails(
//   //         CHANNEL,
//   //         "coding is life service",
//   //         importance: Importance.high, // REQUIRED
//   //         priority: Priority.high, // REQUIRED
//   //         ongoing: true,
//   //         icon: "ic_launcher",
//   //       ),
//   //     ),
//   //   );
//   // });
// }
