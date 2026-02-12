import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jhumo/components/button.dart';
import 'package:jhumo/components/glass_container.dart';
import 'package:jhumo/moduls/controller/playlist_controller.dart';
import 'package:jhumo/screens/player_page.dart';
import 'package:jhumo/screens/playlist_page.dart';

import '../moduls/controller/audio_controller.dart';
import '../moduls/model/service.dart';
import '../moduls/model/themer.dart';

class PlaylistTlle extends StatelessWidget {
  final String name;
  PlaylistTlle({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlaylistController>(
        init: PlaylistController(),
        builder: (controller) {
          return Container(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Stack(
              children: [
                controller.getPlaylistById(name).isNotEmpty
                    ? Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: Offset(0, 16))
                          ],
                        ),
                        child: Row(
                          children: [
                            for (int i = 0;
                                i <
                                    (controller.getPlaylistById(name).length <=
                                            5
                                        ? controller
                                            .getPlaylistById(name)
                                            .length
                                        : 5);
                                i++) ...[
                              Expanded(
                                  child: Image.network(
                                controller
                                    .getSongById(controller
                                        .getPlaylistById(name)[i]
                                        .toString())
                                    .image![1]
                                    .url!,
                                fit: BoxFit.cover,
                                height: Get.height * 0.2,
                              )),
                            ]
                          ],
                        ),
                      )
                    : Container(),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        // borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Get.to(PlaylistPage(
                            name: name,
                          ));
                        },
                        child: Container(
                          clipBehavior: Clip.hardEdge,
                          padding: EdgeInsets.all(16),
                          alignment: Alignment.bottomLeft,
                          height: Get.height * 0.2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: controller.getPlaylistById(name).length == 0
                                ? DecorationImage(
                                    image: AssetImage("assets/white_logo.png"),
                                  )
                                : null,
                            gradient:
                                controller.getPlaylistById(name).length == 0
                                    ? Get.isDarkMode
                                        ? Themer.gradientDark
                                        : LinearGradient(
                                            colors: Themer.gradientLight.colors,
                                            begin: Alignment.topRight,
                                            end: Alignment.bottomLeft)
                                    : LinearGradient(
                                        colors: [
                                          Get.theme.scaffoldBackgroundColor
                                              .withOpacity(0.0),
                                          Get.theme.scaffoldBackgroundColor
                                        ].reversed.toList(),
                                        begin: Alignment.bottomLeft,
                                        end: Alignment.topRight),
                            boxShadow:
                                controller.getPlaylistById(name).length == 0
                                    ? [
                                        BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 20,
                                            offset: Offset(0, 16))
                                      ]
                                    : [],
                          ),
                          child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              controller.getPlaylistById(name).isNotEmpty
                                  ? GestureDetector(
                                    onTap: () {
                                      List<Result> playlist = controller.getPlaylistById(name);
                                      if (playlist
                                          .isNotEmpty) {
                                        List<Result> results =
                                            List.generate(
                                                playlist.length,
                                                (i) => playlist[i]);

                                        Get.put(AudioController())
                                            .setMusicList(results);
                                        Get.to(
                                            PlayerPage(
                                              result: results[0],
                                              isPlaying: true,
                                            ),
                                            transition:
                                                Transition.downToUp);
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 20, horizontal: 20),
                                      decoration: BoxDecoration(
                                          // boxShadow: [
                                          //   BoxShadow(
                                          //       color: Themer.main.withOpacity(0.5),
                                          //       blurRadius: 30,
                                          //       offset: Offset(0, 10))
                                          // ],
                                          // gradient: Get.isDarkMode
                                          //     ? Themer.gradientLight
                                          //     : Themer.gradientDark,
                                          color: Get.theme.scaffoldBackgroundColor,
                                          borderRadius:
                                              BorderRadius.circular(1000)),
                                      child: Icon(
                                        Icons.play_arrow_outlined,
                                        color: Themer.main,
                                      ),
                                    ),
                                  )
                                  : Container(),
                              controller.getPlaylistById(name).isNotEmpty
?                              SizedBox(width: 16):SizedBox(),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: Get.textTheme.headlineMedium!
                                          .copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${controller.getPlaylistById(name).length.toString()} songs",
                                      style: Get.textTheme.bodySmall!.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton(itemBuilder: (context) {
                                return [
                                  PopupMenuItem(
                                    child: Text("Delete"),
                                    onTap: () {
                                      controller.deletePlaylistById(name);
                                    },
                                  ),
                                ];
                              })
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}
