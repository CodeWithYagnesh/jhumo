import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jhumo/moduls/controller/audio_controller.dart';
import 'package:jhumo/moduls/controller/theme_controller.dart';
import 'package:jhumo/moduls/controller/music_controller.dart';
import 'package:jhumo/moduls/model/service.dart';
import 'package:jhumo/screens/player_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  var audioController = Get.put(AudioController());
  var _themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    bool isMobile = Get.width < 750;
    String name = GetStorage("user").read("name") ?? "";
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets
          .zero, // Remove default padding to allow gradient to touch top
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Premium Hero Banner
          _buildHeroBanner(),

          // 2. Recently Played Section
          GetBuilder<AudioController>(
              init: AudioController(),
              builder: (context) {
                if (audioController.recentSong.isEmpty) {
                  return SizedBox();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Text(
                        "Recently Played",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: CarouselView(
                        onTap: (index) {
                          var song = audioController.recentSong[index];
                          Get.to(
                              PlayerPage(
                                result: song,
                              ),
                              transition: Transition.downToUp);
                        },
                        itemExtent: isMobile ? Get.width * 0.8 : 160,
                        backgroundColor: Colors.transparent,
                        shrinkExtent: 50,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        children: List.generate(
                          audioController.recentSong.length > 10
                              ? 10
                              : audioController.recentSong.length,
                          (index) {
                            var song = audioController.recentSong[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.4),
                                            blurRadius: 12,
                                            offset: Offset(0, 6))
                                      ],
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            (song.image != null &&
                                                    song.image!.isNotEmpty)
                                                ? song.image!.last.url!
                                                : ""),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: 5, sigmaY: 5),
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.1),
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: Colors.white24,
                                                        width: 1)),
                                                child: Icon(
                                                    Icons.play_arrow_rounded,
                                                    color: Colors.white,
                                                    size: 28),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  song.name ?? "Unknown",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 8), // Padding for the bottom
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }),

          SizedBox(height: 10),

          // 3. Recommended & Categories
          GetBuilder<MusicController>(
            init: MusicController(),
            builder: (_) {
              if (_.ss.isEmpty) {
                return Container(
                  height: 200,
                  child: Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xffCA2828))),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < _.ss.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _.strs[i],
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                          // Optional "See More" could go here
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 260,
                      child: CarouselView(
                        onTap: (index) {
                          var result = _.ss[i].data?.results?[index];
                          Get.to(PlayerPage(result: result!),
                              transition: Transition.downToUp);
                        },
                        itemExtent: isMobile ? Get.width * 0.80 : 210,
                        shrinkExtent: 50,
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        children: List.generate(_.ss[i].data!.results!.length,
                            (index) {
                          var result = _.ss[i].data?.results?[index];

                          if (result == null) return const SizedBox();

                          return GestureDetector(

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.4),
                                            blurRadius: 15,
                                            offset: Offset(0, 8))
                                      ],
                                      image: DecorationImage(
                                          image: NetworkImage(
                                              (result.image != null &&
                                                      result.image!.isNotEmpty)
                                                  ? result.image!.last.url!
                                                  : ""),
                                          fit: BoxFit.cover),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          right: 10,
                                          bottom: 10,
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFFF0055)
                                                  .withOpacity(0.9),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                                Icons.play_arrow_rounded,
                                                color: Colors.white,
                                                size: 24),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  result.name ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  (result.artists?.all != null &&
                                          result.artists!.all!.isNotEmpty)
                                      ? result.artists!.all!.first.name ?? ""
                                      : "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      color: Colors.white54,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13),
                                ),
                                SizedBox(height: 8),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),

          SizedBox(height: 120), // Bottom padding for mini-player
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      height: 220,
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [Color(0xFFFF0055), Color(0xFF8000FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF0055).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.music_note_rounded,
                size: 200, color: Colors.white.withOpacity(0.1)),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "PREMIUM SELECTION",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Discover the New\nSound of Jhumo",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    try {
                      var musicController = Get.find<MusicController>();
                      var audioController = Get.find<AudioController>();

                      List<Result> allSongs = [];
                      for (var service in musicController.ss) {
                        if (service.data?.results != null) {
                          allSongs.addAll(service.data!.results!);
                        }
                      }

                      if (allSongs.isNotEmpty) {
                        allSongs.shuffle();
                        audioController.setMusicList(allSongs);
                      } else {
                        Get.snackbar("Notice",
                            "Preparing your mix... please try again in a moment.",
                            colorText: Colors.white,
                            backgroundColor: Colors.black54);
                      }
                    } catch (e) {
                      print("Error in Play Mix: $e");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFFFF0055),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Play Mix",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }
}
