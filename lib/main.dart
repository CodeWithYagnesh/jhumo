import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jhumo/moduls/controller/theme_controller.dart';
import 'package:jhumo/moduls/model/service.dart';
import 'package:jhumo/moduls/model/themer.dart';
import 'package:jhumo/screens/album_page/spotify_album_view.dart';
import 'package:jhumo/screens/home_page.dart';
import 'package:jhumo/screens/intro_page.dart';
import 'package:jhumo/screens/intro_page2.dart';
import 'package:jhumo/screens/main_page.dart';
import 'package:jhumo/screens/opened_playlist_page.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'firebase_options.dart';

AudioPlayer player = AudioPlayer();
Result? main_result;
void main() async {
  FlutterNativeSplash.preserve(
      widgetsBinding: WidgetsFlutterBinding.ensureInitialized());
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init("recent_songs");
  await GetStorage.init("user");
  await GetStorage.init("playlist");
  await GetStorage.init("favStorage");
  await GetStorage.init("collaboration_status");
  await GetStorage.init("playlistData");
  await GetStorage.init("env");
  await GetStorage.init("playlistName");
  await GetStorage.init("songData");
  await GetStorage.init("theme");
  await JustAudioBackground.init(
      androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
      androidNotificationChannelName: 'Audio',
      androidNotificationOngoing: true,
      androidNotificationClickStartsActivity: true,
      notificationColor: Colors.red);
  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    String name = GetStorage("user").read("name") ?? "";
    String lang = GetStorage("user").read("lang") ?? "";
    bool isDark = GetStorage("theme").read("mode") ?? false;

    return GetMaterialApp(
      title: 'Jhumo',
      scrollBehavior: ScrollBehaviorModified(),
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: !isDark ? ThemeMode.light : ThemeMode.dark,
      debugShowCheckedModeBanner: false,

      home: name == ""
          ? IntroPage()
          : (lang == "")
              ? IntroPage2()
              : MainPage(),
    );
  }
}
