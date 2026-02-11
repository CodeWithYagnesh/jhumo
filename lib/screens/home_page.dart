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

class HomePage extends StatelessWidget {
  HomePage({super.key});
  var audioController = Get.put(AudioController());
  var _themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    String name = GetStorage("user").read("name") ?? "";
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
            // gradient: _themeController.isDark
            //     ? LinearGradient(
            //         colors: [Themer.main, Themer.dark],
            //         begin: Alignment.topCenter,
            //         end: Alignment.bottomCenter)
            //     : LinearGradient(
            //         colors: [Themer.main, Themer.light],
            //         begin: Alignment.topCenter,
            //         end: Alignment.bottomCenter),

            ),
        // padding: EdgeInsets.only(left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Hi, there ",
                        style: Get.textTheme.displayMedium!
                            .copyWith(fontWeight: FontWeight.w900),
                      ),
                      // GradientText(
                      //   "$name",
                      //   style: Get.textTheme.displaySmall!
                      //       .copyWith(fontWeight: FontWeight.bold),
                      //   colors: _themeController.isDark
                      //       ? Themer.gradientDark.colors
                      //       : Themer.gradientLight.colors,
                      // ),
                      Text(
                        "!",
                        style: Get.textTheme.displaySmall,
                      ),
                    ],
                  ),
                  Text(
                    name.toUpperCase(),
                    style: Get.textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold, color: Themer.main),
                  ),
                ],
              ),
            ),

            GetBuilder<AudioController>(
                init: AudioController(),
                builder: (context) {
                  if (audioController.recentSong.length == 0) {
                    return SizedBox();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SizedBox(height: 20),
                      LabelText(
                        text: "Recently Played",
                        line: true,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: GlassContainer(
                          child: Container(
                            height: Get.height * 0.36,
                            child: Row(
                              children: [
                                GridView.builder(
                                    padding: EdgeInsets.symmetric(),
                                    addAutomaticKeepAlives: true,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 4,
                                            childAspectRatio: 1 / 5),
                                    itemCount:
                                        audioController.recentSong.length <= 20
                                            ? audioController.recentSong.length
                                            : 20,
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          Get.to(
                                              PlayerPage(
                                                result: audioController
                                                    .recentSong[index],
                                              ),
                                              transition: Transition.downToUp);
                                        },
                                        child: RecentMusicTile(
                                            rs: audioController
                                                .recentSong[index]),
                                      );
                                    }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
            GetBuilder<MusicController>(
              init: MusicController(),
              builder: (_) {
                if (_.ss.length == 0) {
                  return Center(child: CircularProgressIndicator());
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < _.ss.length; i++) ...[
                      LabelText(
                        text: _.strs[i],
                        line: true,
                      ),
                      Container(
                        height: 200,
                        child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _.ss[i].data!.results!.length,
                            scrollDirection: Axis.horizontal,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              // Get a safe reference to the result
                              var result = _.ss[i].data?.results?[index];

                              if (result == null) return const SizedBox();

                              return GestureDetector(
                                onTap: () {
                                  Get.to(PlayerPage(result: result),
                                      transition: Transition.downToUp);
                                },
                                child: MusicTile(rs: result),
                              );
                            }),
                      ),
                    ],
                  ],
                );
              },
            ),
            SizedBox(height: 50),
            GetBuilder<AudioController>(
                init: AudioController(),
                builder: (_) {
                  return audioController.rs != null
                      ? const SizedBox(height: 100)
                      : Container();
                })
          ],
        ),
      ),
    );
  }
}
