// import 'dart:ui';

// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:jhumo/service/methods/foreground.dart';

// @pragma("vm:entry-point")
// void onStart(ServiceInstance service) {
//   DartPluginRegistrant.ensureInitialized();
//   print("hello ===========");
//   service.on("setAsForeground").listen(foregroundService);

//   service.on("setAsBackground").listen((event) {
//     print("background ===============");
//   });


//   service.on("stopService").listen((event) {
//     service.stopSelf();
//   });
// }
