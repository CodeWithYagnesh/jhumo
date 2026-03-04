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
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
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
    {
      "name": "Sync",
      "page": CollaborationPage(),
      "icon": Icons.group_add_rounded
    },
    {
      "name": "Library",
      "page": PlaylistsPage(),
      "icon": Icons.library_music_rounded
    },
    {"name": "Settings", "page": SettingPage(), "icon": Icons.settings_rounded},
  ];

  @override
  void initState() {
    super.initState();
    Get.put(ScreenController());
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = Get.width < 750;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: Stack(
        clipBehavior: Clip.none,
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
                // Custom Top Bar (Only visible on mobile, or integrated into desktop)
                if (isMobile)
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
                                  color:
                                      Color(0xFFFF0055), // Brand Color Accent
                                  shape: BoxShape.circle),
                              child: Image.asset("assets/white_logo.png",
                                  height: 30, width: 30),
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
                            child: Icon(Icons.search_rounded,
                                color: Colors.white, size: 24),
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
                        Container(
                          width: 250, // Fixed width for sidebar like YT Music
                          child: SideBar(),
                        ),
                      Expanded(
                        child: Column(
                          children: [
                            if (!isMobile) _buildDesktopTopBar(),
                            Expanded(
                              child: GetBuilder<ScreenController>(
                                  builder: (pageCtrl) {
                                return pages[pageCtrl.currentScreen]['page'];
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Add padding at the bottom of the main content column so the player doesn't overlap on desktop
                if (!isMobile)
                  GetBuilder<AudioController>(builder: (audioCtrl) {
                    return audioCtrl.rs != null
                        ? SizedBox(height: 90)
                        : SizedBox.shrink();
                  }), // Height of the desktop player only when playing
              ],
            ),
          ),

          // Player & Navigation
          GetBuilder<AudioController>(
              init: AudioController(),
              builder: (context) {
                if (_audioController.rs == null) {
                  // If no song is playing, just show the mobile navigation bar
                  return isMobile
                      ? Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: _buildMobileNavBar(),
                        )
                      : SizedBox.shrink();
                }

                return Positioned(
                  bottom: isMobile ? 20 : 0,
                  left: isMobile ? 20 : 0, // Offset by sidebar width on desktop
                  right: isMobile ? 20 : 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // The Player
                      isMobile
                          ? _buildMobilePlayer(_audioController)
                          : _buildDesktopPlayer(_audioController),

                      // Bottom NavBar for Mobile
                      if (isMobile) _buildMobileNavBar(),
                    ],
                  ),
                );
              }),
        ],
      ),
    );
  }

  // --- RESPONSIVE PLAYER WIDGETS ---

  Widget _buildMobilePlayer(AudioController controller) {
    double progress = 0.0;
    if (controller.total.inSeconds > 0) {
      progress =
          controller.currentPosition.inSeconds / controller.total.inSeconds;
    }
    progress = progress.clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () {
        Get.to(
          () => PlayerPage(
            isPlaying: controller.rs != null,
            result: controller.rs!,
          ),
          transition: Transition.downToUp,
          duration: Duration(milliseconds: 400),
        );
      },
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          Get.to(
            () => PlayerPage(
              isPlaying: controller.rs != null,
              result: controller.rs!,
            ),
            transition: Transition.downToUp,
            duration: Duration(milliseconds: 400),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        height: 70,
        decoration: BoxDecoration(
          color: Color(0xFF252525),
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
              if (controller.rs?.image != null &&
                  controller.rs!.image!.isNotEmpty)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: Image.network(
                      controller.rs!.image!.last.url!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Positioned(
                bottom:
                    -2, // slightly lower to keep the "thin line" look at the bottom
                left: 0,
                right: 0,
                child: Hero(
                  tag: "player_playing_time",
                  child: ProgressBar(
                    progress: controller.currentPosition,
                    total: controller.total,
                    buffered: controller.bufferedPosition,
                    progressBarColor: Color(0xFFFF0055),
                    baseBarColor: Colors.transparent,
                    bufferedBarColor: Colors.transparent,
                    thumbColor: Colors.transparent,
                    thumbRadius: 0,
                    barHeight: 3,
                    timeLabelLocation: TimeLabelLocation.none,
                    onSeek: (duration) {
                      player.seek(duration);
                    },
                  ),
                ),
              ),
              Row(
                children: [
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
                              (controller.rs?.image != null &&
                                      controller.rs!.image!.isNotEmpty)
                                  ? controller.rs!.image!.last.url!
                                  : "",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.rs?.name ?? "Unknown",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          (controller.rs?.artists?.all != null &&
                                  controller.rs!.artists!.all!.isNotEmpty)
                              ? controller.rs!.artists!.all!.first.name ??
                                  "Unknown Artist"
                              : "Unknown Artist",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      controller.isPlay
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                    onPressed: () {
                      controller.onPlayPause();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_next_rounded,
                        color: Colors.white70, size: 30),
                    onPressed: () {
                      controller.onNext();
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
  }

  Widget _buildDesktopPlayer(AudioController controller) {
    double progress = 0.0;
    if (controller.total.inSeconds > 0) {
      progress =
          controller.currentPosition.inSeconds / controller.total.inSeconds;
    }
    progress = progress.clamp(0.0, 1.0);

    String formatDuration(Duration d) {
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
      return "$twoDigitMinutes:$twoDigitSeconds";
    }

    return Container(
      height: 90,
      width: double.infinity,
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E), // Solid dark grey bottom bar

        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Top thin progress bar like YouTube Music (Interactive)

          GestureDetector(
            onTap: () {
              Get.to(
                () => PlayerPage(
                  isPlaying: controller.rs != null,
                  result: controller.rs!,
                ),
                transition: Transition.downToUp,
                duration: Duration(milliseconds: 400),
              );
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Song Info
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        // Skip going to full player on desktop unless needed, maybe just show image
                        Hero(
                          tag: "player_image",
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              image: DecorationImage(
                                image: NetworkImage(
                                  (controller.rs?.image != null &&
                                          controller.rs!.image!.isNotEmpty)
                                      ? controller.rs!.image!.last.url!
                                      : "",
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.rs?.name ?? "Unknown",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                (controller.rs?.artists?.all != null &&
                                        controller.rs!.artists!.all!.isNotEmpty)
                                    ? controller.rs!.artists!.all!.first.name ??
                                        "Unknown Artist"
                                    : "Unknown Artist",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.white60,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Center: Playback Controls
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.shuffle_rounded,
                                  color: controller.isShuffle
                                      ? Color(0xFFFF0055)
                                      : Colors.white54,
                                  size: 24),
                              onPressed: () {
                                controller.toggleShuffle();
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.skip_previous_rounded,
                                  color: Colors.white, size: 36),
                              onPressed: () {
                                controller.onPrevious();
                              },
                            ),
                            SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white),
                              child: IconButton(
                                icon: Icon(
                                  controller.isPlay
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.black,
                                  size: 36,
                                ),
                                onPressed: () {
                                  controller.onPlayPause();
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.skip_next_rounded,
                                  color: Colors.white, size: 36),
                              onPressed: () {
                                controller.onNext();
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.repeat_rounded,
                                  color: Colors.white54,
                                  size: 24), // TODO: toggle repeat state
                              onPressed: () {
                                // controller.toggleRepeat();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Right: Extra Controls (Volume, time)
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "${formatDuration(controller.currentPosition)} / ${formatDuration(controller.total)}",
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                              fontFamily: 'Inter'),
                        ),
                        SizedBox(width: 16),
                        IconButton(
                          icon: Icon(Icons.volume_up_rounded,
                              color: Colors.white70),
                          onPressed: () {},
                        ),
                        GestureDetector(
                          onTap: () {
                            // Open full screen player functionality
                            Get.to(
                              () => PlayerPage(
                                isPlaying: controller.rs != null,
                                result: controller.rs!,
                              ),
                              transition: Transition.downToUp,
                              duration: Duration(milliseconds: 400),
                            );
                          },
                          child: Icon(Icons.open_in_full_rounded,
                              color: Colors.white70, size: 20),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: -5, // slight offset to allow thumb drag region
            left: 0, // Avoid sidebar overlap
            right: 0,

            child: Hero(
              tag: "player_playing_time",
              child: ProgressBar(
                progress: controller.currentPosition,
                total: controller.total,
                buffered: controller.bufferedPosition,
                progressBarColor: Color(0xFFFF0055),
                baseBarColor: Colors.white.withOpacity(0.1),
                bufferedBarColor: Colors.white.withOpacity(0.3),
                thumbColor: Color(0xFFFF0055),
                thumbRadius: 5,
                thumbGlowRadius: 15,
                barHeight: 2,
                timeLabelLocation: TimeLabelLocation.none,
                onSeek: (duration) {
                  player.seek(duration);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTopBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: Container(
              constraints: BoxConstraints(maxWidth: 600),
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  Icon(Icons.search_rounded, color: Colors.white54, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Inter'),
                      decoration: InputDecoration(
                        hintText: "Search for songs, artists, or albums...",
                        hintStyle:
                            TextStyle(color: Colors.white38, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (query) {
                        if (query.trim().isNotEmpty) {
                          Get.to(() => SearchPage(initialQuery: query),
                              transition: Transition.fadeIn,
                              duration: Duration(milliseconds: 300));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 24),
          // Actions
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: Colors.white70),
            onPressed: () {},
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white10,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMobileNavBar() {
    return GetBuilder<ScreenController>(
      builder: (pageCtrl) {
        int currentPage = pageCtrl.currentScreen;
        return Container(
          height: 70,
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Color(0xFF151515).withOpacity(0.95),
            borderRadius: BorderRadius.circular(40),
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
                        pageCtrl.changePage(i);
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: currentPage == i
                              ? Color(0xFFFF0055).withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              pages[i]['icon'],
                              color: currentPage == i
                                  ? Colors.white
                                  : Colors.white54,
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
                                    color: Colors.white),
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
        );
      },
    );
  }
}
