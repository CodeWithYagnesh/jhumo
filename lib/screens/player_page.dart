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
    return GetBuilder<AudioController>(
        init: AudioController(),
        initState: (_) {
          if (!isPlaying) {
            var _player = Get.put(AudioController());
            _player.setSong(result);
          }
        },
        builder: (_player) {
          if (_player.rs == null) {
            return const Scaffold(
                backgroundColor: Colors.black,
                body: Center(child: CircularProgressIndicator(color: Colors.white)));
          }

          return GetBuilder<PlaylistController>(
              init: PlaylistController(),
              builder: (controller) {
                return Stack(
                  children: [
                    // 1. Blurred Background Image
                    Container(
                      height: Get.height,
                      width: Get.width,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(getSafeImage(_player.rs)),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Container(color: Colors.black.withOpacity(0.5)),
                      ),
                    ),

                    // 2. Gradient Overlay for readability
                    Container(
                      height: Get.height,
                      width: Get.width,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.2),
                            Colors.black.withOpacity(0.6),
                            Colors.black.withOpacity(0.9),
                          ],
                        ),
                      ),
                    ),

                    // 3. Main Content
                    Scaffold(
                      backgroundColor: Colors.transparent,
                      appBar: AppBar(
                        centerTitle: true,
                        title: Text(
                          "NOW PLAYING",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Colors.white70,
                          ),
                        ),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        leading: IconButton(
                          icon: Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 30),
                          onPressed: () => Get.back(),
                        ),
                        actions: [
                          IconButton(
                            icon: Icon(Icons.more_horiz, color: Colors.white, size: 30),
                            onPressed: () {
                                // Existing Bottom Sheet Logic...
                                Get.bottomSheet(
                                  // ... (Keep existing implementation for brevity or refine if needed)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFF1E1E1E),
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                    ),
                                    child: Wrap(
                                      children: [
                                        ListTile(
                                          leading: Icon(Icons.info_outline, color: Colors.white),
                                          title: Text("Song Details", style: TextStyle(color: Colors.white)),
                                        ),
                                        // Add other options here
                                      ],
                                    ),
                                  ),
                                );
                            },
                          ),
                        ],
                      ),
                      body: SafeArea(
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                physics: BouncingScrollPhysics(),
                                padding: EdgeInsets.symmetric(horizontal: 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 20),

                                    // ALBUM ARTWORK
                                    FlipCard(
                                      speed: 500,
                                      front: Container(
                                        height: Get.width * 0.85,
                                        width: Get.width * 0.85,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.4),
                                              blurRadius: 20,
                                              offset: Offset(0, 10),
                                            )
                                          ],
                                          image: DecorationImage(
                                            image: NetworkImage(getSafeImage(_player.rs)),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      back: Container(
                                        height: Get.width * 0.85,
                                        width: Get.width * 0.85,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: SingleChildScrollView(
                                              child: Text(
                                                (_player.rs?.hasLyrics == true && _player.lyrics?.data?.lyrics != null)
                                                    ? _player.lyrics!.data!.lyrics!
                                                    : "Lyrics not available",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  color: Colors.white.withOpacity(0.9),
                                                  fontSize: 16,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 40),

                                    // TITLE & ARTIST ROW
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _player.rs?.name ?? "Unknown Title",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: 6),
                                              Text(
                                                _player.rs?.artists?.all?.first.name ?? "Unknown Artist",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white.withOpacity(0.6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            controller.onFevClick(result);
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(12), // Touch target
                                            child: controller.isFav(result)
                                                ? Icon(Icons.favorite, color: Color(0xFFE91E63), size: 28)
                                                : Icon(Icons.favorite_border, color: Colors.white, size: 28),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 30),

                                    // PROGRESS BAR
                                    ProgressBar(
                                      progress: _player.currentPosition,
                                      total: _player.total,
                                      buffered: _player.bufferedPosition,
                                      progressBarColor: Colors.white,
                                      baseBarColor: Colors.white.withOpacity(0.15),
                                      bufferedBarColor: Colors.white.withOpacity(0.3),
                                      thumbColor: Colors.white,
                                      thumbRadius: 6,
                                      thumbGlowRadius: 12,
                                      barHeight: 4,
                                      timeLabelTextStyle: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      onSeek: (duration) {
                                        player.seek(duration);
                                      },
                                    ),

                                    SizedBox(height: 20),

                                    // CONTROLS ROW
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        IconButton(
                                            icon: Icon(Icons.shuffle,
                                                color: _player.isShuffle ? Colors.white : Colors.white.withOpacity(0.5), size: 22),
                                            onPressed: () {
                                              _player.toggleShuffle();
                                            }
                                        ),
                                        IconButton(
                                            icon: Icon(Icons.skip_previous_rounded,
                                                color: Colors.white, size: 36),
                                            onPressed: () => _player.onPrevious(),
                                        ),

                                        // PLAY/PAUSE Button
                                        GestureDetector(
                                          onTap: () => _player.onPlayPause(),
                                          child: Container(
                                            height: 72,
                                            width: 72,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.white.withOpacity(0.2),
                                                  blurRadius: 15,
                                                  spreadRadius: 2,
                                                )
                                              ],
                                            ),
                                            child: Icon(
                                              _player.isPlay ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                              color: Colors.black,
                                              size: 40,
                                            ),
                                          ),
                                        ),

                                        IconButton(
                                            icon: Icon(Icons.skip_next_rounded,
                                                color: Colors.white, size: 36),
                                            onPressed: () => _player.onNext(),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            player.loopMode == LoopMode.one
                                                ? Icons.repeat_one_rounded
                                                : Icons.repeat_rounded,
                                            size: 22,
                                            color: player.loopMode != LoopMode.off
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.5),
                                          ),
                                          onPressed: () {
                                              if (player.loopMode == LoopMode.off) {
                                                _player.setLoopMode(LoopMode.all);
                                              } else if (player.loopMode == LoopMode.all) {
                                                _player.setLoopMode(LoopMode.one);
                                              } else {
                                                _player.setLoopMode(LoopMode.off);
                                              }
                                          },
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 40),

                                    // UP NEXT / LYRICS HINT
                                    Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white.withOpacity(0.5)),
                                    Text("UP NEXT", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, letterSpacing: 1)),
                                    SizedBox(height: 10),

                                    // MINIMAL NEXT SONG PREVIEW
                                    if (_player.suggestedSong?.data != null && _player.suggestedSong!.data!.length > 1)
                                       Container(
                                         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                         decoration: BoxDecoration(
                                           color: Colors.white.withOpacity(0.05),
                                           borderRadius: BorderRadius.circular(12),
                                         ),
                                         child: Text(
                                             "Next: ${_player.suggestedSong!.data![(_player.songPos + 1) % _player.suggestedSong!.data!.length].name}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(color: Colors.white70, fontSize: 12),
                                         ),
                                       ),

                                    SizedBox(height: 40),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              });
        });
  }
}
