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
      padding: EdgeInsets.only(bottom: 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(16, 10, 16, 10), // Reduced from 20
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text(
          //         "Hello",
          //         style: TextStyle(
          //           fontFamily: 'Inter',
          //           fontSize: 14,
          //           color: Colors.white70,
          //           fontWeight: FontWeight.w500,
          //         ),
          //       ),
          //       Text(
          //         name.isNotEmpty ? name : "Music Lover",
          //         style: TextStyle(
          //           fontFamily: 'Inter',
          //           fontSize: 26, // Reduced from 28
          //           color: Colors.white,
          //           fontWeight: FontWeight.bold,
          //           letterSpacing: -0.5,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          // Recently Played
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Reduced padding
                      child: Text(
                        "Recently Played",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 160, // Reduced from 180
                      child: ListView.separated(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: audioController.recentSong.length > 10
                            ? 10
                            : audioController.recentSong.length,
                        separatorBuilder: (c, i) => SizedBox(width: 12), // Reduced separator
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
                                  height: 110, // Reduced from 120
                                  width: 110,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12), // Tighter radius

                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: Offset(0, 4)
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
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 6),
                                SizedBox(
                                  width: 110,
                                  child: Text(
                                    song.name ?? "Unknown",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      color: Colors.white,
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

          SizedBox(height: 10), // Reduced from 20

          // Recommended Sections
          GetBuilder<MusicController>(
            init: MusicController(),
            builder: (_) {
              if (_.ss.isEmpty) {
                return Center(child: CircularProgressIndicator(strokeWidth: 2));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < _.ss.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Reduced
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _.strs[i],
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white54)
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 190, // Reduced from 200
                      child: ListView.separated(
                          physics: BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _.ss[i].data!.results!.length,
                          scrollDirection: Axis.horizontal,
                          separatorBuilder: (c, i) => SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            var result = _.ss[i].data?.results?[index];

                            if (result == null) return const SizedBox();

                            return GestureDetector(
                              onTap: () {
                                Get.to(PlayerPage(result: result),
                                    transition: Transition.downToUp);
                              },
                              child: Container(
                                width: 130, // Reduced from 140
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                     Container(
                                        height: 130, // Square aspect
                                        width: 130,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
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
                                     SizedBox(height: 6),
                                     Text(
                                        result.name ?? "",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13
                                        ),
                                     ),
                                     Text(
                                        result.artists?.all?.first.name ?? "",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          color: Colors.white60,
                                          fontSize: 11
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
        ],
      ),
    );
  }
}
