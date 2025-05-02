import 'dart:ui';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jhumo/components/label.dart';
import 'package:jhumo/components/popup_menu.dart';
import 'package:jhumo/components/recent_music_tile.dart';
import 'package:jhumo/main.dart';
import 'package:jhumo/moduls/controller/audio_controller.dart';
import 'package:jhumo/moduls/controller/playlist_controller.dart';
import 'package:jhumo/moduls/controller/theme_controller.dart';
import 'package:jhumo/moduls/model/service.dart';
import 'package:jhumo/moduls/model/themer.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DurationState {
  final Duration progress;
  final Duration buffered;
  final Duration total;
  const DurationState(
      {required this.progress, required this.buffered, required this.total});
}

class PlayerPage extends StatelessWidget {
  final Result result;
  final bool isPlaying;
  PlayerPage({super.key, required this.result, this.isPlaying = false});

  var _themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    if (!isPlaying) {
      var _player = Get.put(AudioController());
      _player.getSuggestedSong();
    }
    return GetBuilder<AudioController>(
        init: AudioController(),
        initState: (_) {
          if (!isPlaying) {
            var _player = Get.put(AudioController());
            _player.setSong(result);
          }
        },
        builder: (_player) {
          return GetBuilder(
              init: PlaylistController(),
              builder: (controller) {
                return Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(_player.rs!.image![2].url!),
                          fit: BoxFit.cover)),
                  child: Container(
                    height: Get.height,
                    decoration: BoxDecoration(
                        color:
                            Get.theme.scaffoldBackgroundColor.withOpacity(0.7)),
                    child: Scaffold(
                      backgroundColor: Colors.transparent,
                      appBar: AppBar(
                        title: Text("Playing"),
                        backgroundColor: Colors.transparent,
                        actions: [
                          IconButton(
                              onPressed: () {
                                Get.bottomSheet(
                                  Container(
                                    clipBehavior: Clip.hardEdge,
                                    width: Get.width,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color:
                                              Get.theme.scaffoldBackgroundColor,
                                          strokeAlign:
                                              BorderSide.strokeAlignOutside),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 40, sigmaY: 40),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        // color: Get.theme.scaffoldBackgroundColor.withOpacity(0.2),
                                        child: Column(
                                          children: [
                                            SizedBox(height: 20),
                                            LabelText(
                                              text: "Information",
                                              line: true,
                                            ),
                                            SizedBox(height: 10),
                                            ListTile(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 30,
                                                      vertical: 5),
                                              leading: Icon(Icons.music_note),
                                              title: Text(
                                                "Name",
                                                style: TextStyle(
                                                    color: Themer.main),
                                              ),
                                              subtitle: Text(
                                                result.name.toString(),
                                                style: Get.textTheme.titleLarge!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            ),
                                            ListTile(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 30,
                                                      vertical: 5),
                                              leading: Icon(Icons.person),
                                              title: Text(
                                                "Artist",
                                                style: TextStyle(
                                                    color: Themer.main),
                                              ),
                                              subtitle: Text(
                                                result.artists!.all![0].name
                                                    .toString(),
                                                style: Get.textTheme.titleLarge!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(Icons.album),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 30,
                                                      vertical: 5),
                                              title: Text(
                                                "Album",
                                                style: TextStyle(
                                                    color: Themer.main),
                                              ),
                                              subtitle: Text(
                                                result.album!.name.toString(),
                                                style: Get.textTheme.titleLarge!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                  Icons.watch_later_outlined),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 30,
                                                      vertical: 5),
                                              title: Text(
                                                "Release",
                                                style: TextStyle(
                                                    color: Themer.main),
                                              ),
                                              subtitle: Text(
                                                result.releaseDate.toString(),
                                                style: Get.textTheme.titleLarge!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(Icons.info),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 30,
                                                      vertical: 5),
                                              title: Text(
                                                "Description",
                                                style: TextStyle(
                                                    color: Themer.main),
                                              ),
                                              subtitle: Text(
                                                result.description.toString(),
                                                style: Get.textTheme.titleLarge!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            ),
                                            LabelText(
                                              text: "Download Link",
                                              line: true,
                                            ),
                                            for (int i = 0;
                                                i < result.downloadUrl!.length;
                                                i++) ...[
                                              ListTile(
                                                onTap: () {
                                                  launchUrlString(
                                                      "${result.downloadUrl![i].url}");
                                                },
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 30,
                                                        vertical: 0),
                                                leading: Icon(Icons.link),
                                                title: Text(result
                                                    .downloadUrl![i].quality
                                                    .toString()),
                                              ),
                                            ]
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  barrierColor: Colors.transparent,
                                  isScrollControlled: true,
                                );
                              },
                              icon: Icon(Icons.more_vert))
                        ],
                      ),
                      body: Stack(
                        children: [
                          SafeArea(
                            child: SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 20),
                                    FlipCard(
                                      speed: 1000,
                                      front: Container(),
                                      back: Builder(builder: (context) {
                                        return Container(
                                          clipBehavior: Clip.hardEdge,
                                          height: Get.height * 0.47,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 20, sigmaY: 20),
                                            child: SingleChildScrollView(
                                              padding: EdgeInsets.only(
                                                  top: 30,
                                                  bottom: 30,
                                                  left: 10,
                                                  right: 10),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      _player.rs!.hasLyrics! &&
                                                              _player.lyrics !=
                                                                  null
                                                          ? _player.lyrics!
                                                              .data!.lyrics!
                                                          : "No Lyrics",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: Get.textTheme
                                                          .titleMedium,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                    SizedBox(height: 30),
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(
                                        _player.rs!.name!,
                                        overflow: TextOverflow.ellipsis,
                                        style: Get.textTheme.headlineMedium!
                                            .copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        _player.rs!.label!,
                                        style: Get.textTheme.bodyMedium,
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              controller.onFevClick(result);
                                            },
                                            child: controller.isFav(result)
                                                ? Icon(
                                                    Icons.favorite,
                                                    color: Colors.red,
                                                    size: 30,
                                                  )
                                                : Icon(
                                                    Icons.favorite_border,
                                                    color:
                                                        _themeController.isDark
                                                            ? Themer.light1
                                                            : Themer.dark1,
                                                    size: 30,
                                                  ),
                                          ),
                                          JhumoPopupMenu(rs: _player.rs!)
                                        ],
                                      ),
                                    ),
                                    Text(
                                      _player.rs!.artists!.all![0].name!,
                                      style: Get.textTheme.bodyMedium!,
                                    ),
                                    SizedBox(height: 10),
                                    ProgressBar(
                                      progressBarColor: Themer.main,
                                      bufferedBarColor:
                                          Themer.main.withOpacity(0.5),
                                      thumbColor: Themer.main,
                                      barCapShape: BarCapShape.square,
                                      progress: _player.currentPosition,
                                      total: _player.total,
                                      buffered: _player.bufferedPosition,
                                      onSeek: (value) {
                                        player.seek(value);
                                      },
                                    ),
                                    SizedBox(height: 30),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            // _player.onPrevious();
                                            if(player.loopMode == LoopMode.off){
                                              _player.setLoopMode(LoopMode.all);
                                            }else if(player.loopMode == LoopMode.all){
                                              _player.setLoopMode(LoopMode.one);
                                            }else{
                                              _player.setLoopMode(LoopMode.off);
                                            }
                                          },
                                          child: Icon(
                                            player.loopMode == LoopMode.one
                                                ? Icons.repeat_one_rounded
                                                : Icons.repeat_rounded,
                                            size: 30,
                                            color: player.loopMode !=
                                                    LoopMode.off
                                                ? Get.textTheme.bodyLarge!.color
                                                : Get
                                                    .textTheme.bodyLarge!.color!
                                                    .withOpacity(0.5),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            _player.onPrevious();
                                          },
                                          child: Icon(
                                            Icons.skip_previous_rounded,
                                            size: 40,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            _player.onPlayPause();
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .color!,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              _player.isPlay
                                                  ? Icons.pause_rounded
                                                  : Icons.play_arrow_rounded,
                                              color: Themer.main,
                                              size: 50,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            _player.onNext();
                                          },
                                          child: Icon(
                                            Icons.skip_next_rounded,
                                            size: 40,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            // _player.onPrevious();
                                          },
                                          child: Icon(
                                            Icons.shuffle,
                                            size: 30,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 30),
                                    Text("Playlist",
                                        style: Get.textTheme.titleMedium),
                                    Icon(Icons.keyboard_arrow_down_rounded),
                                    SizedBox(height: 20),
                                    if (_player.suggestedSong != null)
                                      for (int i = 0;
                                          i <
                                              _player
                                                  .suggestedSong!.data!.length;
                                          i++) ...[
                                        GestureDetector(
                                          onTap: () {
                                            if (_player.rs!.id !=
                                                _player.suggestedSong!.data![i]
                                                    .id!)
                                              _player.setSong(_player
                                                  .suggestedSong!.data![i]);
                                          },
                                          child: RecentMusicTile(
                                            isPlayed: _player.rs!.id ==
                                                _player.suggestedSong!.data![i]
                                                    .id!,
                                            rs: _player.suggestedSong!.data![i],
                                          ),
                                        ),
                                      ]
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              });
        });
  }
}
