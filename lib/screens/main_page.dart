import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jhumo/main.dart';
import 'package:jhumo/moduls/controller/audio_controller.dart';
import 'package:jhumo/moduls/controller/page_controller.dart';
import 'package:jhumo/moduls/model/themer.dart';
import 'package:jhumo/screens/collaboration_page.dart';
import 'package:jhumo/screens/fav_page.dart';
import 'package:jhumo/screens/home_page.dart';
import 'package:jhumo/screens/player_page.dart';
import 'package:jhumo/screens/playlist_page.dart';
import 'package:jhumo/screens/playlists_page.dart';
import 'package:jhumo/screens/search_page.dart';
import 'package:jhumo/screens/setting_page.dart';
import 'package:jhumo/screens/side_bar.dart';

class MainPage extends StatefulWidget {
  MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var _audioController = Get.put(AudioController());

  List<Map> pages = [
    {"name": "Home", "page": HomePage(), "icon": Icons.home},
    {"name": "Collaboration", "page": CollaborationPage(), "icon": Icons.add},
    {"name": "Setting", "page": SettingPage(), "icon": Icons.settings},
    {"name": "playlist", "page": PlaylistsPage(), "icon": Icons.library_music},
  ];

  int currentPage = 0;
  setPage(int i) {
    currentPage = i;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = Get.width < 750;
        return Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.black.withOpacity(0.01),
              title: Text(
                "jhumo",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Themer.main),
              ),
              actions: [
                GestureDetector(
                  onTap: () {
                    Get.to(
                      SearchPage(),
                      transition: Transition.upToDown,
                      duration: Duration(milliseconds: 500),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration( shape: BoxShape.circle),
                    child: Icon(Icons.search),
                  ),
                )
              ]),
          body: Row(
            children: [
              if (!isMobile)
                Expanded(
                  flex: 2,
                  child: SideBar(),
                ),
              Expanded(
                flex: 5,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    if (!isMobile)
                      GetBuilder(
                          init: ScreenController(),
                          builder: (contr) {
                            return pages[contr.currentScreen]['page'];
                          }),
                    if (isMobile) pages[currentPage]['page'],
                    GetBuilder<AudioController>(
                        init: AudioController(),
                        builder: (context) {
                          int cur =
                              _audioController.currentPosition.inSeconds != 0
                                  ? _audioController.currentPosition.inSeconds
                                  : 1;
                          int tot = _audioController.total.inSeconds != 0
                              ? _audioController.total.inSeconds
                              : 100;
                          return _audioController.rs == null
                              ? Container()
                              : GestureDetector(
                                  onPanUpdate: (d) {
                                    if (d.delta.dy > 0) {
                                      print("swipe down");
                                    }

                                    if (d.delta.dy < 0) {
                                      print("swipe up");
                                      Get.to(
                                        PlayerPage(
                                          isPlaying:
                                              _audioController.rs != null,
                                          result: _audioController.rs!,
                                        ),
                                        transition: Transition.downToUp,
                                        duration: Duration(milliseconds: 500),
                                      );
                                    }
                                    // if (d.delta.dx > 0) {
                                    //   print("swipe right");
                                    // }

                                    // if (d.delta.dx < 0) {
                                    //   print("swipe left");
                                    // }
                                  },
                                  onTap: () {
                                    Get.to(
                                      PlayerPage(
                                        isPlaying: _audioController.rs != null,
                                        result: _audioController.rs!,
                                      ),
                                      transition: Transition.downToUp,
                                      duration: Duration(milliseconds: 500),
                                    );
                                  },
                                  child: Container(
                                  padding: EdgeInsets.zero,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(20),
                                        border:
                                            Border.all(color: Get.theme.scaffoldBackgroundColor.withOpacity(0.2),strokeAlign: BorderSide.strokeAlignOutside),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black38,
                                              blurRadius: 20,
                                              offset: Offset(0, 10))
                                        ],
                                      ),
                                      // height: 70,
                                      child: BackdropFilter(

                                        filter: ImageFilter.blur(
                                            sigmaX: 20, sigmaY: 20),
                                        child: Stack(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                      colors: [
                                                    Themer.main,
                                                    Colors.transparent
                                                  ],
                                                      stops: [
                                                    (cur / tot),
                                                    0
                                                  ])),
                                              child: ListTile(
                                                title: Text(
                                                  _audioController.rs!.name ?? "",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                subtitle: Text(
                                                  _audioController.rs!.label ?? "",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                leading: Container(
                                                    height: 50,
                                                    width: 50,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      image: DecorationImage(
                                                          image: NetworkImage(
                                                              _audioController
                                                                  .rs!
                                                                  .image![0]
                                                                  .url!),
                                                          fit: BoxFit.cover),
                                                    )),
                                                trailing: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        _audioController
                                                            .onPlayPause();
                                                      },
                                                      child: _audioController
                                                              .isPlay
                                                          ? Icon(
                                                              Icons.pause,
                                                              size: 40,
                                                              color:
                                                                  Colors.white,
                                                            )
                                                          : Icon(
                                                              Icons
                                                                  .play_arrow_outlined,
                                                              size: 40,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    GestureDetector(
                                                      onTap: () {
                                                        _audioController
                                                            .onNext();
                                                      },
                                                      child: player.hasNext
                                                          ? Icon(
                                                              Icons
                                                                  .skip_next_rounded,
                                                              size: 35,
                                                              color:
                                                                  Colors.white,
                                                            )
                                                          : Icon(
                                                              Icons
                                                                  .skip_next_outlined,
                                                              size: 35,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                    ),
                                                    SizedBox(width: 10),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                );
                        })
                  ],
                ),
              ),
              if (!isMobile) Expanded(flex: 3, child: SettingPage())
            ],
          ),
          bottomNavigationBar: isMobile
              ? BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  currentIndex: currentPage,
                  onTap: (i) {
                    currentPage = i;
                    setState(() {});
                  },
                  items: pages
                      .map((e) => BottomNavigationBarItem(
                          icon: Icon(e['icon']), label: e['name']))
                      .toList(),
                )
              : null,
        );
      },
    );
  }
}
