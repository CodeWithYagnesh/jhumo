
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jhumo/components/glass_container.dart';
import 'package:jhumo/components/playlist_tlle.dart';
import 'package:jhumo/components/recent_music_tile.dart';
import 'package:jhumo/moduls/controller/audio_controller.dart';
import 'package:jhumo/moduls/controller/playlist_controller.dart';
import 'package:jhumo/moduls/methods.dart';
import 'package:jhumo/moduls/model/service.dart';
import 'package:jhumo/moduls/model/themer.dart';
import 'package:jhumo/screens/player_page.dart';

class PlaylistPage extends StatelessWidget {
  final String name;
  PlaylistPage({super.key, required this.name});

  var current = 0.obs;

  PlaylistController playlistController = Get.put(PlaylistController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: PlaylistController(),
        builder: (controller) {
          List<dynamic> songIds = controller.getPlaylistById(name);

          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  // stretch: true,
                  onStretchTrigger: () async {
                    // Triggers when stretching
                  },
                  // [stretchTriggerOffset] describes the amount of overscroll that must occur
                  // to trigger [onStretchTrigger]
                  //
                  // Setting [stretchTriggerOffset] to a value of 300.0 will trigger
                  // [onStretchTrigger] when the user has overscrolled by 300.0 pixels.
                  stretchTriggerOffset: 300.0,
                  expandedHeight: 400.0,
                  pinned: true, floating: true,

                  bottom: songIds.isNotEmpty
                      ? PreferredSize(
                          preferredSize: Size.fromHeight(70),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      name,
                                      overflow: TextOverflow.ellipsis,
                                      style: Get.textTheme.displaySmall!
                                          .copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "${controller.getPlaylistById(name).length} Songs",
                                      overflow: TextOverflow.ellipsis,
                                      style: Get.textTheme.bodySmall!.copyWith(
                                          color: Get.textTheme.bodySmall!.color!
                                              .withOpacity(0.5),
                                          fontSize: 15),
                                    ),
                                    // Text(
                                    //   r.artist.toString(),
                                    //   overflow: TextOverflow.ellipsis,
                                    //   style: Get.textTheme.bodySmall!.copyWith(
                                    //       color: Get.textTheme.bodySmall!.color!.withOpacity(0.5),
                                    //       fontSize: 7),
                                    // ),
                                  ],
                                ),
                                Transform.translate(
                                  offset: Offset(0, 30),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (songIds.isNotEmpty) {
                                        print("hello");
                                        List<Result> results = List.generate(
                                            songIds.length,
                                            (i) => controller
                                                .getSongById(songIds[i]));

                                        Get.put(AudioController())
                                            .setMusicList(results);
                                        Get.to(
                                            PlayerPage(
                                              result: results[0],
                                              isPlaying: true,
                                            ),
                                            transition: Transition.downToUp);
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 20, horizontal: 20),
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                color:
                                                    Themer.main.withOpacity(0.5),
                                                blurRadius: 30,
                                                offset: Offset(0, 10))
                                          ],
                                          gradient: Get.isDarkMode
                                              ? Themer.gradientDark
                                              : Themer.gradientLight,
                                          borderRadius:
                                              BorderRadius.circular(1000)),
                                      child: Icon(
                                        Icons.play_arrow_outlined,
                                        color: Themer.light,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : null,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: EdgeInsets.only(left: 10),
                    // title: Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   mainAxisSize: MainAxisSize.min,
                    //   children: [
                    //     Text(
                    //       name,
                    //       overflow: TextOverflow.ellipsis,
                    //       style: Get.textTheme.titleLarge!
                    //           .copyWith(fontWeight: FontWeight.bold),
                    //     ),
                    //     Text(
                    //       "${controller.getPlaylistById(name).length} Songs",
                    //       overflow: TextOverflow.ellipsis,
                    //       style: Get.textTheme.bodySmall!.copyWith(
                    //           color: Get.textTheme.bodySmall!.color!
                    //               .withOpacity(0.5),
                    //           fontSize: 10),
                    //     ),
                    //     // Text(
                    //     //   r.artist.toString(),
                    //     //   overflow: TextOverflow.ellipsis,
                    //     //   style: Get.textTheme.bodySmall!.copyWith(
                    //     //       color: Get.textTheme.bodySmall!.color!.withOpacity(0.5),
                    //     //       fontSize: 7),
                    //     // ),
                    //   ],
                    // ),
                    background: Container(
                      // decoration: BoxDecoration(
                      //     image: DecorationImage(
                      //         image: NetworkImage(r.image![2].url!),
                      //         fit: BoxFit.cover)),
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                              Get.theme.scaffoldBackgroundColor,
                              // Get.theme.scaffoldBackgroundColor.withOpacity(0),
                              // Get.theme.scaffoldBackgroundColor.withOpacity(0),
                              Themer.main,
                              Themer.main,
                            ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter)),
                        child: controller.getPlaylistById(name).isEmpty
                            ? Image.asset("assets/white_logo.png")
                            : Stack(
                                children: [
                                  Row(
                                    children: [
                                      for (int i = 0;
                                          i <
                                              (controller
                                                          .getPlaylistById(name)
                                                          .length <=
                                                      5
                                                  ? controller
                                                      .getPlaylistById(name)
                                                      .length
                                                  : 5);
                                          i++) ...[
                                        Expanded(
                                            child: Container(
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: NetworkImage(
                                                    controller
                                                        .getSongById(controller
                                                            .getPlaylistById(
                                                                name)[i]
                                                            .toString())
                                                        .image![2]
                                                        .url!,
                                                  ),
                                                  fit: BoxFit.cover)),
                                        )),
                                      ]
                                    ],
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            colors: [
                                          Get.theme.scaffoldBackgroundColor,
                                          Colors.transparent
                                        ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter)),
                                  )
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                      // [
                      //   SizedBox(height: 30),
                      //   for (int i = 0; i < pl.data!.songs!.length; i++)
                      //     Builder(builder: (context) {
                      //       Result r = Result.fromJson(pl.data!.songs![i].toJson());
                      //       return GestureDetector(
                      //           onTap: () {
                      //             Get.to(
                      //                 PlayerPage(
                      //                   result: r,
                      //                 ),
                      //                 transition: Transition.downToUp);
                      //           },
                      //           child: RecentMusicTile(
                      //             rs: r,
                      //           ));
                      //     })
                      // ],
                      [
                        SizedBox(height: 20),
                        for (int i = 0; i < songIds.length; i++) ...[
                          Builder(builder: (context) {
                            return GestureDetector(
                              onTap: () {
                                Get.to(PlayerPage(
                                    result:
                                        controller.getSongById(songIds[i])));
                              },
                              child: RecentMusicTile(
                                rs: controller.getSongById(songIds[i]),
                              ),
                            );
                          })
                        ]
                      ]),
                )
              ],
            ),
          );
        });
  }
}
