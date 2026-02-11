import 'dart:ui';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jhumo/components/label.dart';
import 'package:jhumo/components/popup_menu.dart';
import 'package:jhumo/components/recent_music_tile.dart';
import 'package:jhumo/main.dart'; // Ensure this import is correct for your project structure
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

  // Helper to safely get the highest quality image
  String getSafeImage(Result? item) {
    if (item?.image == null || item!.image!.isEmpty) {
      return "https://c.saavncdn.com/191/Kesariya-From-Brahmastra-Hindi-2022-20220717092820-500x500.jpg"; // Placeholder
    }
    // Try to get the last image (usually highest quality), otherwise the first
    return item.image!.last.url ?? item.image!.first.url ?? "";
  }

  @override
  Widget build(BuildContext context) {
  // if (!isPlaying) {
  //   var _player = Get.put(AudioController());
  //   _player.getSuggestedSong(); // <--- THIS CAUSES THE CRASH
  // }
    return GetBuilder<AudioController>(
        init: AudioController(),
        initState: (_) {
          if (!isPlaying) {
            var _player = Get.put(AudioController());
            _player.setSong(result);
          }
        },
        builder: (_player) {
          // SAFE GUARD: If _player.rs is null, show a loader instead of crashing
          if (_player.rs == null) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }

          return GetBuilder<PlaylistController>( // Typed GetBuilder
              init: PlaylistController(),
              builder: (controller) {
                return Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(getSafeImage(_player.rs)),
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
                                        child: Column(
                                          children: [
                                            SizedBox(height: 20),
                                            LabelText(
                                              text: "Information",
                                              line: true,
                                            ),
                                            SizedBox(height: 10),
                                            // ... (Keep your ListTile implementations, they are mostly safe if result isn't null)
                                            // SAFETY CHECK FOR DOWNLOAD URLS
                                            if (result.downloadUrl != null)
                                              for (int i = 0; i < result.downloadUrl!.length; i++) ...[
                                                ListTile(
                                                  onTap: () {
                                                    if (result.downloadUrl![i].url != null) {
                                                      launchUrlString("${result.downloadUrl![i].url}");
                                                    }
                                                  },
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 30),
                                                  leading: Icon(Icons.link),
                                                  title: Text(result.downloadUrl![i].quality.toString()),
                                                )
                                              ],
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
                                      front: Container(), // Consider putting the artwork here for the "Front" view
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
                                              padding: EdgeInsets.all(30),
                                              child: Center(
                                                  child: Text(
                                                (_player.rs?.hasLyrics == true && _player.lyrics?.data?.lyrics != null)
                                                    ? _player.lyrics!.data!.lyrics!
                                                    : "No Lyrics Available",
                                                textAlign: TextAlign.center,
                                                style: Get.textTheme.titleMedium,
                                              )),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                    SizedBox(height: 30),
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(
                                        _player.rs?.name ?? "Unknown Title",
                                        overflow: TextOverflow.ellipsis,
                                        style: Get.textTheme.headlineMedium!
                                            .copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        _player.rs?.label ?? "Unknown Label",
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
                                                ? Icon(Icons.favorite, color: Colors.red, size: 30)
                                                : Icon(Icons.favorite_border,
                                                    color: _themeController.isDark
                                                        ? Themer.light1
                                                        : Themer.dark1,
                                                    size: 30),
                                          ),
                                          JhumoPopupMenu(rs: _player.rs!)
                                        ],
                                      ),
                                    ),
                                    Text(
                                      _player.rs?.artists?.all?.first.name ?? "Unknown Artist",
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
                                    // ... Control Buttons (Keep your existing Row of controls)
                                    // Ensure logic like `_player.onNext()` is safe inside AudioController
                                     Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // Loop Button
                                        GestureDetector(
                                          onTap: () {
                                            if (player.loopMode == LoopMode.off) {
                                              _player.setLoopMode(LoopMode.all);
                                            } else if (player.loopMode == LoopMode.all) {
                                              _player.setLoopMode(LoopMode.one);
                                            } else {
                                              _player.setLoopMode(LoopMode.off);
                                            }
                                          },
                                          child: Icon(
                                            player.loopMode == LoopMode.one
                                                ? Icons.repeat_one_rounded
                                                : Icons.repeat_rounded,
                                            size: 30,
                                            color: player.loopMode != LoopMode.off
                                                ? Get.textTheme.bodyLarge!.color
                                                : Get.textTheme.bodyLarge!.color!.withOpacity(0.5),
                                          ),
                                        ),
                                        // Prev Button
                                        GestureDetector(
                                          onTap: () => _player.onPrevious(),
                                          child: Icon(Icons.skip_previous_rounded, size: 40),
                                        ),
                                        // Play/Pause
                                        GestureDetector(
                                          onTap: () => _player.onPlayPause(),
                                          child: Container(
                                            padding: EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).textTheme.bodyLarge!.color!,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              _player.isPlay ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                              color: Themer.main,
                                              size: 50,
                                            ),
                                          ),
                                        ),
                                        // Next Button
                                        GestureDetector(
                                          onTap: () => _player.onNext(),
                                          child: Icon(Icons.skip_next_rounded, size: 40),
                                        ),
                                        // Shuffle
                                        GestureDetector(
                                          onTap: () {}, // Add shuffle logic if needed
                                          child: Icon(Icons.shuffle, size: 30),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 30),
                                    Text("Playlist",
                                        style: Get.textTheme.titleMedium),
                                    Icon(Icons.keyboard_arrow_down_rounded),
                                    SizedBox(height: 20),
                                    if (_player.suggestedSong?.data != null)
                                      for (int i = 0; i < _player.suggestedSong!.data!.length; i++) ...[
                                        GestureDetector(
                                          onTap: () {
                                            // Check specifically if ID is valid
                                            if (_player.rs?.id != null && _player.suggestedSong!.data![i].id != null) {
                                               if (_player.rs!.id != _player.suggestedSong!.data![i].id) {
                                                  _player.setSong(_player.suggestedSong!.data![i]);
                                               }
                                            }
                                          },
                                          child: RecentMusicTile(
                                            isPlayed: _player.rs?.id == _player.suggestedSong!.data![i].id,
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
