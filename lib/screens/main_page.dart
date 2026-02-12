import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jhumo/main.dart';
import 'package:jhumo/moduls/controller/audio_controller.dart';
import 'package:jhumo/moduls/controller/page_controller.dart';
import 'package:jhumo/screens/collaboration_page.dart';
import 'package:jhumo/screens/fav_page.dart';
import 'package:jhumo/screens/home_page.dart';
import 'package:jhumo/screens/player_page.dart';
import 'package:jhumo/screens/playlists_page.dart';
import 'package:jhumo/screens/search_page.dart';
import 'package:jhumo/screens/setting_page.dart';
import 'package:jhumo/screens/side_bar.dart';
// import 'package:simple_gradient_text/simple_gradient_text.dart'; // Assuming this might be used or keeping imports clean.

class MainPage extends StatefulWidget {
  MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var _audioController = Get.put(AudioController());

  List<Map> pages = [
    {"name": "Home", "page": HomePage(), "icon": Icons.home_rounded},
    {"name": "Collaboration", "page": CollaborationPage(), "icon": Icons.group_add_rounded},
    {"name": "Library", "page": PlaylistsPage(), "icon": Icons.library_music_rounded},
    {"name": "Settings", "page": SettingPage(), "icon": Icons.settings_rounded},
  ];

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    bool isMobile = Get.width < 750;

    return Scaffold(
      extendBody: true, // Allow body to extend behind bottom nav
      backgroundColor: Colors.black, // Fallback
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF300000), // Very Deep Red (Subtle)
              Colors.black, // Almost Black
              Colors.black,      // Pure Black
            ],
            stops: [0.0, 0.2, 1.0], // Fades quicky for professional look
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  // Custom AppBar Area
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Jhumo",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                             Get.to(
                              SearchPage(),
                              transition: Transition.fadeIn,
                              duration: Duration(milliseconds: 300),
                            );
                          },
                          icon: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle
                            ),
                            child: Icon(Icons.search_rounded, color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),

                  // Main Content Area
                  Expanded(
                    child: Row(
                      children: [
                        if (!isMobile)
                          Expanded(
                            flex: 2,
                            child: SideBar(),
                          ),
                        Expanded(
                          flex: 5,
                          child: pages[currentPage]['page'],
                        ),
                         if (!isMobile) Expanded(flex: 3, child: SettingPage())
                      ],
                    ),
                  ),
                ],
              ),

              // Floating Mini Player & Bottom Nav Wrapper
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mini Player
                    GetBuilder<AudioController>(
                        init: AudioController(),
                        builder: (context) {
                           if (_audioController.rs == null) return SizedBox();

                          double progress = 0.0;
                          if (_audioController.total.inSeconds > 0) {
                            progress = _audioController.currentPosition.inSeconds / _audioController.total.inSeconds;
                          }
                          progress = progress.clamp(0.0, 1.0);

                          return GestureDetector(
                            onTap: () {
                              Get.to(
                                PlayerPage(
                                  isPlaying: _audioController.rs != null,
                                  result: _audioController.rs!,
                                ),
                                transition: Transition.downToUp,
                                duration: Duration(milliseconds: 400),
                              );
                            },
                            onVerticalDragEnd: (details) {
                               if (details.primaryVelocity! < 0) {
                                  Get.to(
                                    PlayerPage(
                                      isPlaying: _audioController.rs != null,
                                      result: _audioController.rs!,
                                    ),
                                    transition: Transition.downToUp,
                                    duration: Duration(milliseconds: 400),
                                  );
                               }
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              height: 64,
                              decoration: BoxDecoration(
                                color: Color(0xFF1E1E1E).withOpacity(0.9),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Stack(
                                    children: [
                                      // Progress Bar Background
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        height: 2,
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor: Colors.transparent,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          minHeight: 2,
                                        ),
                                      ),

                                      Row(
                                        children: [
                                          // Art
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                    (_audioController.rs?.image != null && _audioController.rs!.image!.isNotEmpty)
                                                        ? _audioController.rs!.image!.last.url!
                                                        : ""
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Info
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _audioController.rs?.name ?? "Unknown",
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  _audioController.rs?.artists?.all?.first.name ?? "Unknown Artist",
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Controls
                                          IconButton(
                                            icon: Icon(
                                              _audioController.isPlay ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                            onPressed: () {
                                              _audioController.onPlayPause();
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.skip_next_rounded, color: Colors.white70, size: 28),
                                            onPressed: () {
                                              _audioController.onNext();
                                            },
                                          ),
                                          SizedBox(width: 8),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),

                    // Bottom Navigation
                    if (isMobile)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8),
                                Colors.black,
                              ],
                              stops: [0.0, 0.3, 1.0]
                          ),
                        ),
                        child: BottomNavigationBar(
                          type: BottomNavigationBarType.fixed,
                          currentIndex: currentPage,
                          backgroundColor: Colors.transparent, // Transparent to show gradient
                          elevation: 0,
                          selectedItemColor: Colors.white,
                          unselectedItemColor: Colors.white38,
                          selectedLabelStyle: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 12),
                          unselectedLabelStyle: TextStyle(fontFamily: 'Inter', fontSize: 12),
                          onTap: (i) {
                            setState(() {
                              currentPage = i;
                            });
                          },
                          items: pages
                              .map((e) => BottomNavigationBarItem(
                                  icon: Icon(e['icon']), label: e['name']))
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
