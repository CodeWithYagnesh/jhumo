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
      return "";
    }
    // Try to get the last image (usually highest quality), otherwise the first
    if (item.image!.isNotEmpty) {
      return item.image!.last.url ?? item.image!.first.url ?? "";
    }
    return "";
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
                          image: getSafeImage(_player.rs).isNotEmpty
                              ? NetworkImage(getSafeImage(_player.rs))
                              : AssetImage("assets/ph_song.jpg") as ImageProvider,
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
                                      Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF1E1E1E),
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                        ),
                                        child: Wrap(
                                          children: [
                                            // 1. Song Details
                                            ListTile(
                                              leading: Icon(Icons.info_outline, color: Colors.white),
                                              title: Text("Song Details", style: TextStyle(color: Colors.white, fontFamily: 'Inter')),
                                              onTap: () {
                                                // Show details implementation
                                              },
                                            ),
                                            Divider(color: Colors.white12),

                                            // 2. Add to Playlist
                                            ListTile(
                                              leading: Icon(Icons.playlist_add, color: Colors.white),
                                              title: Text("Add to Playlist", style: TextStyle(color: Colors.white, fontFamily: 'Inter')),
                                              onTap: () {
                                                Get.back(); // Close bottom sheet
                                                // Show Playlist Selection Dialog
                                                Get.defaultDialog(
                                                  title: "Add to Playlist",
                                                  titleStyle: TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.bold),
                                                  backgroundColor: Color(0xFF1E1E1E),
                                                  radius: 20,
                                                  content: Container(
                                                    height: 200, // Limit height
                                                    width: 300,
                                                    child: GetBuilder<PlaylistController>(
                                                      init: PlaylistController(),
                                                      builder: (plController) {
                                                        if (plController.playlistName.isEmpty) {
                                                           return Center(child: Text("No playlists found.", style: TextStyle(color: Colors.white54)));
                                                        }
                                                        return ListView.builder(
                                                          itemCount: plController.playlistName.length,
                                                          itemBuilder: (context, index) {
                                                            String pName = plController.playlistName[index];
                                                            return ListTile(
                                                              leading: Icon(Icons.queue_music, color: Colors.white70),
                                                              title: Text(pName, style: TextStyle(color: Colors.white)),
                                                              onTap: () {
                                                                 plController.addToPlaylist(pName, _player.rs!);
                                                                 Get.back();
                                                                 Get.snackbar("Added", "Song added to $pName",
                                                                    backgroundColor: Colors.white, colorText: Colors.black, snackPosition: SnackPosition.BOTTOM, margin: EdgeInsets.all(20));
                                                              },
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            // 3. Download
                                            ListTile(
                                              leading: Icon(Icons.download_rounded, color: Colors.white),
                                              title: Text("Download", style: TextStyle(color: Colors.white, fontFamily: 'Inter')),
                                              onTap: () {
                                                Get.back(); // Close bottom sheet
                                                Get.put(AudioController()).downloadCurrentSong();
                                              },
                                            ),
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
                                                (_player.rs?.artists?.all != null && _player.rs!.artists!.all!.isNotEmpty)
                                                    ? _player.rs!.artists!.all!.first.name ?? "Unknown Artist"
                                                    : "Unknown Artist",
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
                                                color: _player.isShuffle ? Color(0xFFFF0055) : Colors.white.withOpacity(0.5), size: 22),
                                            onPressed: () {
                                              _player.toggleShuffle();
                                            }
                                        ),
                                        IconButton(
                                            icon: Icon(Icons.skip_previous_rounded,
                                                color: Colors.white, size: 38),
                                            onPressed: () => _player.onPrevious(),
                                        ),

                                        // PLAY/PAUSE Button (Enhanced)
                                        GestureDetector(
                                          onTap: () => _player.onPlayPause(),
                                          child: Container(
                                            height: 80, // Slightly larger
                                            width: 80,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFFFF0055),
                                                  Color(0xFFFF0055).withOpacity(0.8)
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color(0xFFFF0055).withOpacity(0.4),
                                                  blurRadius: 20,
                                                  spreadRadius: 2,
                                                  offset: Offset(0, 8)
                                                )
                                              ],
                                            ),
                                            child: Icon(
                                              _player.isPlay ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                              color: Colors.white,
                                              size: 44,
                                            ),
                                          ),
                                        ),

                                        IconButton(
                                            icon: Icon(Icons.skip_next_rounded,
                                                color: Colors.white, size: 38),
                                            onPressed: () => _player.onNext(),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            player.loopMode == LoopMode.one
                                                ? Icons.repeat_one_rounded
                                                : Icons.repeat_rounded,
                                            size: 22,
                                            color: player.loopMode != LoopMode.off
                                                ? Color(0xFFFF0055)
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
