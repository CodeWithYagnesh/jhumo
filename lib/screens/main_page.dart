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
    {"name": "Sync", "page": CollaborationPage(), "icon": Icons.group_add_rounded},
    {"name": "Library", "page": PlaylistsPage(), "icon": Icons.library_music_rounded},
    {"name": "Settings", "page": SettingPage(), "icon": Icons.settings_rounded},
  ];

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    bool isMobile = Get.width < 750;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A1A1A), // Dark Grey/Black
                  Colors.black,
                ],
                stops: [0.0, 0.5],
              ),
            ),
          ),

          // Main Content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Custom Top Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Row(
                         children: [
                           Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Color(0xFFFF0055), // Brand Color Accent
                                shape: BoxShape.circle
                              ),
                              child: Image.asset("assets/white_logo.png", height: 30, width: 30),
                           ),
                           SizedBox(width: 12),
                           Text(
                            "Jhumo",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w900, // Thicker
                              fontSize: 26,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                         ],
                       ),
                      IconButton(
                        onPressed: () {
                          Get.to(() => SearchPage(),
                              transition: Transition.fadeIn,
                              duration: Duration(milliseconds: 300));
                        },
                        icon: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.search_rounded, color: Colors.white, size: 24),
                        ),
                      )
                    ],
                  ),
                ),

                // Page Content
                Expanded(
                  child: Row(
                    children: [
                      if (!isMobile)
                        Expanded(flex: 2, child: SideBar()),
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
          ),

          // Floating Player & Navigation Stack
          Positioned(
            bottom: 20, // Floating feeling
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Mini Player (Floating Card)
                GetBuilder<AudioController>(
                    init: AudioController(),
                    builder: (context) {
                      if (_audioController.rs == null) return SizedBox();

                      // Calculate Progress
                      double progress = 0.0;
                      if (_audioController.total.inSeconds > 0) {
                        progress = _audioController.currentPosition.inSeconds /
                            _audioController.total.inSeconds;
                      }
                      progress = progress.clamp(0.0, 1.0);

                      return GestureDetector(
                        onTap: () {
                          Get.to(
                            () => PlayerPage(
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
                              () => PlayerPage(
                                isPlaying: _audioController.rs != null,
                                result: _audioController.rs!,
                              ),
                              transition: Transition.downToUp,
                              duration: Duration(milliseconds: 400),
                            );
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12), // Space between player and nav
                          height: 70, // Slightly taller
                          decoration: BoxDecoration(
                            color: Color(0xFF252525), // Distinct from nav bar
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                // Background Art Blur (Optional, subtle touch)
                                if (_audioController.rs?.image != null && _audioController.rs!.image!.isNotEmpty)
                                   Positioned.fill(
                                      child: Opacity(
                                        opacity: 0.1,
                                        child: Image.network(
                                          _audioController.rs!.image!.last.url!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                   ),

                                // Progress Bar (Bottom Line)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  height: 3,
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.transparent,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF0055)), // Accent Color
                                    minHeight: 3,
                                  ),
                                ),

                                Row(
                                  children: [
                                    // Album Art
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Hero(
                                        tag: "player_image",
                                        child: Container(
                                          width: 54,
                                          height: 54,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                (_audioController.rs?.image != null &&
                                                        _audioController.rs!.image!.isNotEmpty)
                                                    ? _audioController.rs!.image!.last.url!
                                                    : "",
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Title & Artist
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
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15, // Slightly bigger
                                            ),
                                          ),
                                          Text(
                                            (_audioController.rs?.artists?.all != null && _audioController.rs!.artists!.all!.isNotEmpty)
                                                ? _audioController.rs!.artists!.all!.first.name ?? "Unknown Artist"
                                                : "Unknown Artist",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Colors.white60, // Better contrast
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Controls
                                    IconButton(
                                      icon: Icon(
                                        _audioController.isPlay
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 34,
                                      ),
                                      onPressed: () {
                                        _audioController.onPlayPause();
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.skip_next_rounded,
                                          color: Colors.white70, size: 30),
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
                      );
                    }),

                // 2. Floating Navigation Bar (Pill Shape)
                if (isMobile)
                  Container(
                    height: 70,
                    margin: EdgeInsets.only(bottom: 10), // Lift from bottom edge
                    decoration: BoxDecoration(
                      color: Color(0xFF151515).withOpacity(0.95), // Frosted Glass effect
                      borderRadius: BorderRadius.circular(40), // Pill Shape
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [
                         BoxShadow(
                           color: Colors.black.withOpacity(0.4),
                           blurRadius: 20,
                           offset: Offset(0, 10),
                         )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (int i = 0; i < pages.length; i++)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    currentPage = i;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: currentPage == i
                                        ? Color(0xFFFF0055).withOpacity(0.2) // Active State
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row( // Optional: Show text only on active
                                     children: [
                                       Icon(
                                         pages[i]['icon'],
                                         color: currentPage == i ? Colors.white : Colors.white54,
                                         size: 26,
                                       ),
                                       if (currentPage == i) ...[
                                         SizedBox(width: 8),
                                         Text(
                                           pages[i]['name'],
                                           style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.white
                                           ),
                                         )
                                       ]
                                     ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
