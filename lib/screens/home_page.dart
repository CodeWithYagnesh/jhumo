import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:jhumo/components/album_tile.dart';
import 'package:jhumo/components/artist_tile.dart';
import 'package:jhumo/components/glass_container.dart';
import 'package:jhumo/components/label.dart';
import 'package:jhumo/components/music_tile.dart';
import 'package:jhumo/components/recent_music_tile.dart';
import 'package:jhumo/moduls/controller/artist_controller.dart';
import 'package:jhumo/moduls/controller/audio_controller.dart';
import 'package:jhumo/moduls/controller/theme_controller.dart';
import 'package:jhumo/moduls/methods.dart';
import 'package:jhumo/moduls/controller/music_controller.dart';
import 'package:jhumo/moduls/controller/populer_controller.dart';
import 'package:jhumo/moduls/model/artists_song.dart';
import 'package:jhumo/moduls/model/themer.dart';
import 'package:jhumo/screens/opened_artist_page.dart';
import 'package:jhumo/screens/opened_playlist_page.dart';
import 'package:jhumo/screens/player_page.dart';
import 'package:jhumo/screens/playlists_page.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:jhumo/components/album_tile.dart';
import 'package:jhumo/components/artist_tile.dart';
import 'package:jhumo/components/glass_container.dart';
import 'package:jhumo/components/label.dart'; // Ensure this component is compatible or replace usage
import 'package:jhumo/components/music_tile.dart';
import 'package:jhumo/components/recent_music_tile.dart';
import 'package:jhumo/moduls/controller/artist_controller.dart';
import 'package:jhumo/moduls/controller/audio_controller.dart';
import 'package:jhumo/moduls/controller/theme_controller.dart';
import 'package:jhumo/moduls/methods.dart';
import 'package:jhumo/moduls/controller/music_controller.dart';
import 'package:jhumo/moduls/controller/populer_controller.dart';
import 'package:jhumo/moduls/model/artists_song.dart';
import 'package:jhumo/moduls/model/themer.dart';
import 'package:jhumo/screens/opened_artist_page.dart';
import 'package:jhumo/screens/opened_playlist_page.dart';
import 'package:jhumo/screens/player_page.dart';
import 'package:jhumo/screens/playlists_page.dart';
// import 'package:simple_gradient_text/simple_gradient_text.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  var audioController = Get.put(AudioController());
  var _themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    String name = GetStorage("user").read("name") ?? "";
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.zero, // Remove default padding to allow gradient to touch top
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Red Gradient Header & Greeting
          // Container(
          //   width: double.infinity,
          //   padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), // Top padding for status bar
          //   // decoration: BoxDecoration(
          //   //   gradient: LinearGradient(
          //   //     begin: Alignment.topCenter,
          //   //     end: Alignment.bottomCenter,
          //   //     colors: [
          //   //       Color(0xffCA2828).withOpacity(0.8), // Themer.main
          //   //       Color(0xffCA2828).withOpacity(0.4),
          //   //       Colors.transparent,
          //   //     ],
          //   //     stops: [0.0, 0.6, 1.0],
          //   //   ),
          //   // ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               Text(
          //                 _greeting(),
          //                 style: TextStyle(
          //                   fontFamily: 'Inter',
          //                   fontSize: 14,
          //                   color: Colors.white70,
          //                   fontWeight: FontWeight.w500,
          //                   letterSpacing: 0.5,
          //                 ),
          //               ),
          //               SizedBox(height: 4),
          //               Text(
          //                 name.isNotEmpty ? name : "Music Lover",
          //                 style: TextStyle(
          //                   fontFamily: 'Inter',
          //                   fontSize: 24, // Professional size
          //                   color: Colors.white,
          //                   fontWeight: FontWeight.w700,
          //                   letterSpacing: -0.5,
          //                 ),
          //               ),
          //             ],
          //           ),
          //           // Optional Profile or Settings Icon
          //           Container(
          //             padding: EdgeInsets.all(2),
          //             decoration: BoxDecoration(
          //               shape: BoxShape.circle,
          //               border: Border.all(color: Colors.white24),
          //             ),
          //             child: CircleAvatar(
          //               radius: 20,
          //               backgroundColor: Colors.white10,
          //               child: Icon(Icons.person, color: Colors.white),
          //             ),
          //           )
          //         ],
          //       ),
          //     ],
          //   ),
          // ),

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
                      height: 160,
                      child: ListView.separated(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: audioController.recentSong.length > 10
                            ? 10
                            : audioController.recentSong.length,
                        separatorBuilder: (c, i) => SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          var song = audioController.recentSong[index];
                          return GestureDetector(
                            onTap: () {
                              Get.to(
                                  PlayerPage(
                                    result: song,
                                  ),
                                  transition: Transition.downToUp);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 110,
                                  width: 110,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16), // Modern radius
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: Offset(0, 5)
                                      )
                                    ],
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        (song.image != null && song.image!.isNotEmpty)
                                            ? song.image!.last.url!
                                            : ""
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.4),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white24, width: 1.5)
                                      ),
                                      child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                SizedBox(
                                  width: 110,
                                  child: Text(
                                    song.name ?? "Unknown",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xffCA2828))),
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
                      height: 190,
                      child: ListView.separated(
                          physics: BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _.ss[i].data!.results!.length,
                          scrollDirection: Axis.horizontal,
                          separatorBuilder: (c, i) => SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            var result = _.ss[i].data?.results?[index];

                            if (result == null) return const SizedBox();

                            return GestureDetector(
                              onTap: () {
                                Get.to(PlayerPage(result: result),
                                    transition: Transition.downToUp);
                              },
                              child: Container(
                                width: 140,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                     Container(
                                        height: 140,
                                        width: 140,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: Offset(0, 4)
                                            )
                                          ],
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              (result.image != null && result.image!.isNotEmpty)
                                                  ? result.image!.last.url!
                                                  : ""
                                            ),
                                            fit: BoxFit.cover
                                          )
                                        ),
                                     ),
                                     SizedBox(height: 8),
                                     Text(
                                        result.name ?? "",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14
                                        ),
                                     ),
                                     SizedBox(height: 2),
                                     Text(
                                        (result.artists?.all != null && result.artists!.all!.isNotEmpty)
                                            ? result.artists!.all!.first.name ?? ""
                                            : "",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          color: Colors.white54,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12
                                        ),
                                     ),
                                  ],
                                ),
                              ),
                            );
                          }),
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
