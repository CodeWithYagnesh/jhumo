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
import 'package:jhumo/screens/side_bar.dart';

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
                body: Center(
                    child: CircularProgressIndicator(color: Colors.white)));
          }

          return GetBuilder<PlaylistController>(
              init: PlaylistController(),
              builder: (controller) {
                return Stack(children: [
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
                      filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                      child: Container(color: Colors.black.withOpacity(0.55)),
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
                          Colors.black.withOpacity(0.35),
                          Colors.black.withOpacity(0.75),
                          Colors.black.withOpacity(1.0),
                        ],
                      ),
                    ),
                  ),

                  // 3. Main Content
                  GestureDetector(
                    onVerticalDragEnd: (details) {
                      // Detect swipe down (positive velocity)
                      if (details.primaryVelocity != null &&
                          details.primaryVelocity! > 500) {
                        Get.back();
                      }
                    },
                    child: Scaffold(
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
                          icon: Icon(Icons.keyboard_arrow_down,
                              color: Colors.white, size: 30),
                          onPressed: () => Get.back(),
                        ),
                        actions: [
                          IconButton(
                            icon: Icon(Icons.more_horiz,
                                color: Colors.white, size: 30),
                            onPressed: () {
                              _showBottomSheet(_player, controller);
                            },
                          ),
                        ],
                      ),
                      body: SafeArea(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth >= 800) {
                              return _buildDesktopLayout(_player, controller, context);
                            } else {
                              return _buildMobileLayout(_player, controller, context);
                            }
                          },
                        ),
                      ),
                    ),
                  )
                ]);
              });
        });
  }

  void _showBottomSheet(AudioController _player, PlaylistController plController) {
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
              title: Text("Song Details",
                  style: TextStyle(color: Colors.white, fontFamily: 'Inter')),
              onTap: () {
                // Show details implementation
              },
            ),
            Divider(color: Colors.white12),

            // 2. Add to Playlist
            ListTile(
              leading: Icon(Icons.playlist_add, color: Colors.white),
              title: Text("Add to Playlist",
                  style: TextStyle(color: Colors.white, fontFamily: 'Inter')),
              onTap: () {
                Get.back(); // Close bottom sheet
                // Show Playlist Selection Dialog
                Get.defaultDialog(
                  title: "Add to Playlist",
                  titleStyle: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold),
                  backgroundColor: Color(0xFF1E1E1E),
                  radius: 20,
                  content: Container(
                    height: 200, // Limit height
                    width: 300,
                    child: GetBuilder<PlaylistController>(
                      init: PlaylistController(),
                      builder: (plControllerInternal) {
                        if (plControllerInternal.playlistName.isEmpty) {
                          return Center(
                              child: Text("No playlists found.",
                                  style: TextStyle(color: Colors.white54)));
                        }
                        return ListView.builder(
                          itemCount: plControllerInternal.playlistName.length,
                          itemBuilder: (context, index) {
                            String pName =
                                plControllerInternal.playlistName[index];
                            return ListTile(
                              leading: Icon(Icons.queue_music,
                                  color: Colors.white70),
                              title: Text(pName,
                                  style: TextStyle(color: Colors.white)),
                              onTap: () {
                                plControllerInternal.addToPlaylist(
                                    pName, _player.rs!);
                                Get.back();
                                Get.snackbar(
                                    "Added", "Song added to $pName",
                                    backgroundColor: Colors.white,
                                    colorText: Colors.black,
                                    snackPosition: SnackPosition.BOTTOM,
                                    margin: EdgeInsets.all(20));
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
              title: Text("Download",
                  style: TextStyle(color: Colors.white, fontFamily: 'Inter')),
              onTap: () {
                Get.back(); // Close bottom sheet
                Get.put(AudioController()).downloadCurrentSong();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtwork(AudioController _player, double cardSize) {
    return Hero(
      tag: "player_image",
      child: FlipCard(
        speed: 600,
        front: Container(
          height: cardSize,
          width: cardSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 40,
                spreadRadius: 5,
                offset: Offset(0, 20),
              )
            ],
            image: DecorationImage(
              image: NetworkImage(getSafeImage(_player.rs)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        back: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              height: cardSize,
              width: cardSize,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      (_player.rs?.hasLyrics == true &&
                              _player.lyrics?.data?.lyrics != null)
                          ? _player.lyrics!.data!.lyrics!
                          : "Lyrics not available",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 16,
                        height: 1.8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndArtist(AudioController _player, PlaylistController controller, {bool isDesktop = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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
                  fontSize: isDesktop ? 34 : 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 8),
              Text(
                (_player.rs?.artists?.all != null &&
                        _player.rs!.artists!.all!.isNotEmpty)
                    ? _player.rs!.artists!.all!.first.name ?? "Unknown Artist"
                    : "Unknown Artist",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isDesktop ? 20 : 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.7),
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
            padding: EdgeInsets.all(12),
            child: controller.isFav(result)
                ? Icon(Icons.favorite, color: Color(0xFFE91E63), size: 32)
                : Icon(Icons.favorite_border, color: Colors.white, size: 32),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(AudioController _player) {
    return Hero(
      tag: "player_playing_time",
      child: ProgressBar(
        progress: _player.currentPosition,
        total: _player.total,
        buffered: _player.bufferedPosition,
        progressBarColor: Color(0xFFFF0055),
        baseBarColor: Colors.white.withOpacity(0.2),
        bufferedBarColor: Colors.white.withOpacity(0.35),
        thumbColor: Color(0xFFFF0055),
        thumbRadius: 7,
        thumbGlowRadius: 18,
        barHeight: 4,
        timeLabelPadding: 10,
        timeLabelTextStyle: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        onSeek: (duration) {
          player.seek(duration);
        },
      ),
    );
  }

  Widget _buildControls(AudioController _player, {bool isDesktop = false}) {
    double buttonSize = isDesktop ? 60 : 90;
    double iconSize = isDesktop ? 34 : 52;
    double skipIconSize = isDesktop ? 34 : 48;

    return Row(
      mainAxisAlignment: isDesktop ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            icon: Icon(Icons.shuffle,
                color: _player.isShuffle
                    ? Color(0xFFFF0055)
                    : Colors.white.withOpacity(0.6),
                size: 24),
            onPressed: () {
              _player.toggleShuffle();
            }),
        if (isDesktop) SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.skip_previous_rounded,
              color: Colors.white.withOpacity(0.9), size: skipIconSize),
          onPressed: () => _player.onPrevious(),
        ),
        if (isDesktop) SizedBox(width: 8),

        // PLAY/PAUSE Button (Ultra-Minimal Modern Style)
        GestureDetector(
          onTap: () => _player.onPlayPause(),
          child: Container(
            height: buttonSize,
            width: buttonSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: isDesktop ? [] : [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 4))
              ],
            ),
            child: Icon(
              _player.isPlay ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.black87,
              size: iconSize,
            ),
          ),
        ),
        if (isDesktop) SizedBox(width: 8),

        IconButton(
          icon: Icon(Icons.skip_next_rounded,
              color: Colors.white.withOpacity(0.9), size: skipIconSize),
          onPressed: () => _player.onNext(),
        ),
        if (isDesktop) SizedBox(width: 8),
        IconButton(
          icon: Icon(
            player.loopMode == LoopMode.one
                ? Icons.repeat_one_rounded
                : Icons.repeat_rounded,
            size: 24,
            color: player.loopMode != LoopMode.off
                ? Color(0xFFFF0055)
                : Colors.white.withOpacity(0.6),
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
    );
  }

  Widget _buildQueueTile(Result song, bool isPlaying, AudioController _player, {bool isMobile = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          int mappedIndex = _player.playlist?.children.indexWhere((src) {
                return (src as UriAudioSource).tag.id == song.id;
              }) ??
              -1;
          if (mappedIndex != -1) {
            player.seek(Duration.zero, index: mappedIndex);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isPlaying ? Colors.white.withOpacity(0.08) : Colors.transparent,
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  getSafeImage(song),
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.white10, width: 48, height: 48),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.name ?? "Unknown Title",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isPlaying ? Colors.white : Colors.white.withOpacity(0.85),
                        fontSize: 15,
                        fontWeight: isPlaying ? FontWeight.w700 : FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      (song.artists?.all != null && song.artists!.all!.isNotEmpty)
                          ? song.artists!.all!.first.name ?? ""
                          : "Unknown Artist",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              if (isPlaying)
                Icon(Icons.equalizer_rounded, color: Colors.white, size: 20)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpNext(AudioController _player, {bool isMobile = false}) {
    if (_player.suggestedSong?.data == null || _player.suggestedSong!.data!.isEmpty) {
      return const SizedBox.shrink();
    }

    if (!isMobile) {
      // Desktop minimal view (if needed, though desktop usually has the side panel)
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white.withOpacity(0.5)),
          Text("UP NEXT", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, letterSpacing: 1)),
          SizedBox(height: 10),
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
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      );
    }

    // Full Mobile Up Next List
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 12),
          child: Row(
            children: [
              Icon(Icons.queue_music_rounded, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text(
                "Up Next",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // We use a Column here since it's inside a SingleChildScrollView
        // This avoids nested scrolling issues while still being relatively efficient for lists of this size
        for (var i = 0; i < _player.suggestedSong!.data!.length; i++)
          _buildQueueTile(_player.suggestedSong!.data![i], i == _player.songPos, _player, isMobile: true),
      ],
    );
  }

  Widget _buildMobileLayout(AudioController _player, PlaylistController controller, BuildContext context) {
    double cardSize = (Get.width < 750) ? Get.width * 0.85 : Get.height * 0.5;
    if (cardSize > 400) cardSize = 400;

    return Column(
      children: [
        // Swipe handle indicator
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 0),
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2.5),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    _buildArtwork(_player, cardSize),
                    SizedBox(height: 40),
                    _buildTitleAndArtist(_player, controller),
                    SizedBox(height: 30),
                    _buildProgressBar(_player),
                    SizedBox(height: 20),
                    _buildControls(_player),
                    SizedBox(height: 30),
                    _buildUpNext(_player, isMobile: true),
                    SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopPlaylist(AudioController _player) {
    if (_player.suggestedSong?.data == null || _player.suggestedSong!.data!.isEmpty) {
      return Container(width: 400, child: Center(child: CircularProgressIndicator(color: Colors.white)));
    }
    return Container(
      width: 400,
      decoration: BoxDecoration(
        // color: Colors.black.withOpacity(0.2), // Very subtle, clean background
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 32.0, top: 40.0, bottom: 20.0, right: 32.0),
            child: Row(
              children: [
                Icon(Icons.queue_music_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Text(
                  "Up Next",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 24),
              physics: const BouncingScrollPhysics(),
              itemCount: _player.suggestedSong!.data!.length,
              itemBuilder: (context, index) {
                var song = _player.suggestedSong!.data![index];
                bool isPlaying = song.id == _player.rs?.id;
                return _buildQueueTile(song, isPlaying, _player);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopBottomBar(AudioController _player, PlaylistController controller, BuildContext context) {
    double progress = 0.0;
    if (_player.total.inSeconds > 0) {
      progress = _player.currentPosition.inSeconds / _player.total.inSeconds;
    }
    progress = progress.clamp(0.0, 1.0);

    String formatDuration(Duration d) {
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
      return "$twoDigitMinutes:$twoDigitSeconds";
    }

    return Container(
      height: 90,
      width: double.infinity,
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E), // Solid dark grey bottom bar
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
           // Top thin progress bar like YouTube Music (Interactive)
           Positioned(
              top: -5, // slight offset to allow thumb drag region
              left: 0, // Avoid sidebar overlap
              right: 0,
              child: ProgressBar(
                progress: _player.currentPosition,
                total: _player.total,
                buffered: _player.bufferedPosition,
                progressBarColor: Color(0xFFFF0055),
                baseBarColor: Colors.white.withOpacity(0.1),
                bufferedBarColor: Colors.white.withOpacity(0.3),
                thumbColor: Color(0xFFFF0055),
                thumbRadius: 5,
                thumbGlowRadius: 15,
                barHeight: 2,
                timeLabelLocation: TimeLabelLocation.none,
                onSeek: (duration) {
                  player.seek(duration);
                },
              ),
           ),

           Padding(
             padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 // Left: Song Info
                 Expanded(
                   flex: 1,
                   child: Row(
                     children: [
                       Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              image: DecorationImage(
                                image: NetworkImage(
                                  getSafeImage(_player.rs)
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                       ),
                       SizedBox(width: 16),
                       Expanded(
                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               _player.rs?.name ?? "Unknown",
                               maxLines: 1,
                               overflow: TextOverflow.ellipsis,
                               style: TextStyle(
                                 fontFamily: 'Inter',
                                 color: Colors.white,
                                 fontWeight: FontWeight.w600,
                                 fontSize: 16,
                               ),
                             ),
                             SizedBox(height: 4),
                             Text(
                               (_player.rs?.artists?.all != null && _player.rs!.artists!.all!.isNotEmpty)
                                   ? _player.rs!.artists!.all!.first.name ?? "Unknown Artist"
                                   : "Unknown Artist",
                               maxLines: 1,
                               overflow: TextOverflow.ellipsis,
                               style: TextStyle(
                                 fontFamily: 'Inter',
                                 color: Colors.white60,
                                 fontSize: 14,
                               ),
                             ),
                           ],
                         ),
                       ),
                     ],
                   ),
                 ),

                 // Center: Playback Controls
                 Expanded(
                   flex: 2,
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           IconButton(
                             icon: Icon(Icons.shuffle_rounded, color: _player.isShuffle ? Color(0xFFFF0055) : Colors.white54, size: 24),
                             onPressed: () {
                               _player.toggleShuffle();
                             },
                           ),
                           IconButton(
                             icon: Icon(Icons.skip_previous_rounded, color: Colors.white, size: 36),
                             onPressed: () {
                               _player.onPrevious();
                             },
                           ),
                           SizedBox(width: 8),
                           Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white
                              ),
                              child: IconButton(
                               icon: Icon(
                                 _player.isPlay ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                 color: Colors.black,
                                 size: 36,
                               ),
                               onPressed: () {
                                 _player.onPlayPause();
                               },
                             ),
                           ),
                           SizedBox(width: 8),
                           IconButton(
                             icon: Icon(Icons.skip_next_rounded, color: Colors.white, size: 36),
                             onPressed: () {
                               _player.onNext();
                             },
                           ),
                           IconButton(
                             icon: Icon(
                               player.loopMode == LoopMode.one
                                   ? Icons.repeat_one_rounded
                                   : Icons.repeat_rounded,
                               size: 24,
                               color: player.loopMode != LoopMode.off
                                   ? Color(0xFFFF0055)
                                   : Colors.white.withOpacity(0.6),
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
                     ],
                   ),
                 ),

                 // Right: Extra Controls (Lyrics, Volume, time)
                 Expanded(
                   flex: 1,
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.end,
                     children: [
                       Text(
                         "${formatDuration(_player.currentPosition)} / ${formatDuration(_player.total)}",
                         style: TextStyle(color: Colors.white54, fontSize: 13, fontFamily: 'Inter'),
                       ),
                       SizedBox(width: 16),
                       IconButton(
                          icon: const Icon(Icons.lyrics_outlined, color: Colors.white70),
                          tooltip: 'Lyrics',
                          onPressed: () {
                              _showBottomSheet(_player, controller);
                          },
                       ),
                       IconButton(
                         icon: Icon(Icons.volume_up_rounded, color: Colors.white70),
                         onPressed: () {},
                       ),
                     ],
                   ),
                 )
               ],
             ),
           )
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(AudioController _player, PlaylistController controller, BuildContext context) {
    double artworkSize = Get.height * 0.55;
    if (artworkSize > 500) artworkSize = 500;
    if (artworkSize < 300) artworkSize = 300;

    return Column(
      children: [
        // Main Area (Left Sidebar + Center Artwork + Right Playlist)
        Expanded(
          child: Row(
            children: [
              Container(
                width: 250, // Mirroring the width of SideBar on main_page
                color: Colors.transparent, // Optional subtle sidebar background
                child: SideBar(),
              ),
              Expanded(
                child: Center(
                  child: _buildArtwork(_player, artworkSize),
                ),
              ),
              _buildDesktopPlaylist(_player),
              SizedBox(width:16),
            ],
          ),
        ),
        // Bottom Player Bar
        _buildDesktopBottomBar(_player, controller, context),
      ],
    );
  }
}
