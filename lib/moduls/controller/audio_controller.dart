

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart' hide Data;

import 'package:jhumo/main.dart';
import 'package:jhumo/moduls/controller/collaboration_controller.dart';
import 'package:jhumo/moduls/service/youtube_service.dart';
// Removed youtube_audio_source import


import 'package:jhumo/moduls/model/lyrics_model.dart';
import 'package:jhumo/moduls/model/service.dart' hide Data;
import 'package:jhumo/screens/player_page.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';

class AudioController extends GetxController {
  Result? rs;
  Duration currentPosition = Duration.zero;
  Duration total = Duration.zero;
  Duration bufferedPosition = Duration.zero;
  int songPos = 0;
  bool isPlay = false;
  bool _isMonitoring = false;
  SuggestedModel? suggestedSong;
  GetStorage _recentStorage = GetStorage("recent_songs");
  List _recentSongString = [];
  List<Result> recentSong = [];
  ConcatenatingAudioSource? playlist;
  Lyrics? lyrics;
  YoutubeService _ytService = YoutubeService();
  @override
  void onInit() {
    super.onInit();
    getRecentSong();
    startStreaming();
    player.setLoopMode(LoopMode.off); // Ensure we don't loop a single song
  }

  bool isShuffle = false;

  setLoopMode(LoopMode l) {
    player.setLoopMode(l);
    update();
  }

  toggleShuffle() {
    isShuffle = !isShuffle;
    player.setShuffleModeEnabled(isShuffle);
    update();
  }

  getRecentSong() async {
    _recentSongString = _recentStorage.read('recentSong') ?? [];
    _recentSongString = _recentSongString.toSet().toList();
    while (_recentSongString.length > 20) {
      _recentSongString.removeAt(0);
    }
    recentSong.clear();

    // Optimize: Fetch all songs in parallel then update UI once
    List<Future<Result?>> futures = [];
    for (var id in _recentSongString) {
      futures.add(_ytService.getSong(id));
    }

    var results = await Future.wait(futures);
    for (var song in results) {
      if (song != null) {
        recentSong.add(song);
      }
    }
    update();
  }

  setSong(Result result) {
    print("AudioController: setSong called with ${result.name}");
    rs = result;
    _fetchSong();
    startStreaming(); // Start monitoring when a song is set
  }

  setMusicList(List<Result> songs) async {
    print("AudioController: setMusicList called with ${songs.length} songs");
    if (suggestedSong == null) suggestedSong = SuggestedModel();
    suggestedSong!.data = songs;
    rs = songs[0];
    print("AudioController: Playing first song: ${rs?.name}");

    List<AudioSource> initialSources = [];
    AudioSource? currentSource = await _createAudioSource(rs!);
    if (currentSource != null) initialSources.add(currentSource);

    playlist = ConcatenatingAudioSource(children: initialSources);
    try {
      await player.setAudioSource(playlist!);
      player.play();
      print("AudioController: Player started playing");
    } catch (e) {
      print("AudioController: Error playing playlist: $e");
    }
    startStreaming(); // Start monitoring when a playlist is set
    Get.to(
        PlayerPage(
          result: suggestedSong!.data!.first,
          isPlaying: true,
        ),
        transition: Transition.downToUp);

    // Append the rest sequentially
    if (songs.length > 1) {
      _appendSuggestions(songs.sublist(1), playlist!);
    }
  }

  _fetchSong() async {
    print("AudioController: _fetchSong started for ${rs?.name} (${rs?.id})");
    isPlay = true;
    try {
      await getSuggestedSong();
    } catch (e) {
      print("AudioController: Error in getSuggestedSong: $e");
    }

    try {
      total = player.duration ?? Duration.zero;
    } catch (e) {
      print("AudioController: Error getting duration: $e");
    }

    if ((!_recentSongString.contains(rs!.id!))) {
      _recentSongString.add(rs!.id!);
      _recentStorage.write("recentSong", _recentSongString);
      _recentStorage.save();
    }
    update();
    print("AudioController: _fetchSong completed");
  }

  getLyrics() async {
    print("AudioController: getLyrics() triggered");
    if (rs?.id == null) {
      print("AudioController: Current song (rs) or ID is null. Cannot fetch lyrics.");
      return;
    }

    print("AudioController: Fetching lyrics for ${rs?.name} (${rs?.id})");
    lyrics = null; // Clear previous lyrics
    // update(); // Optional: if you want to show loading state for lyrics

    try {
      String? lyricsText = await _ytService.getLyrics(rs!.id!);
      if (lyricsText != null && lyricsText.isNotEmpty) {
        print("AudioController: Lyrics text received. Updating model.");
        lyrics = Lyrics(
          success: true,
          data: Data(
            lyrics: lyricsText,
            snippet: lyricsText.length > 50 ? lyricsText.substring(0, 50) : lyricsText,
            copyright: "Lyrics provided by YouTube Closed Captions",
          )
        );
        rs?.hasLyrics = true;
      } else {
        print("AudioController: No lyrics found.");
        lyrics = null;
        rs?.hasLyrics = false;
      }
    } catch (e) {
      print("AudioController: Error fetching lyrics: $e");
      lyrics = null;
    }
    update();
  }

  startStreaming() {
    if (_isMonitoring) return; // Prevent duplicate listeners

    var collaboration = Get.put(CollaborationController());
    player.positionStream.listen((Duration? d) {
      if (d != null) {
        currentPosition = d;
        // Optimization: Do NOT await this and only call if collaboration is active
        if (collaboration.status) {
             collaboration.syncs(d);
        }
        update();
      }
    });

    _isMonitoring = true; // Mark as monitoring

    _recentStorage.listen(() {
      getRecentSong();
    });
    player.bufferedPositionStream.listen((Duration? d) {
      if (d != null) {
        bufferedPosition = d;
        update();
      }
    });
    player.durationStream.listen((Duration? d) {
      if (d != null) {
        total = d;
        update();
      }
    });

    player.currentIndexStream.listen((i) {
      if (i != null) {
        songPos = i;

        if (suggestedSong?.data != null && i < suggestedSong!.data!.length) {
          getLyrics();
          rs = suggestedSong!.data![i]; // Safely update the current song

          // Fallback total duration from metadata if player duration is not yet available
          if (rs?.duration != null && rs!.duration! > 0) {
            total = Duration(seconds: rs!.duration!);
          }

          // Load more songs when we are near the end of the playlist (e.g., 2 songs left)
          if (i >= suggestedSong!.data!.length - 2) {
             // We need to fetch suggestions based on the LAST song in the list, not necessarily the current one.
             // But usually it's fine to fetch based on current playing song if it's new.
             // To avoid loop, checks are needed.
             // For now, let's just use the current song to fetch more.
             // But we need to make sure we don't re-fetch for the same song or cause infinite loop.
             // A simple check is "if we are at the last song, proceed" logic might be too late.
             // Let's stick to the user's logic: if `suggestedSong!.data!.last.id == rs!.id`
             /*
             // Logic from user's code:
             if (suggestedSong!.data!.last.id == rs!.id) {
                getSuggestedSong();
             }
             */
             // IMPROVED LOGIC: If we are close to the end, fetch more.
             loadMoreSuggestions();
          }

          // Add to recent history
          if (!_recentSongString.contains(rs!.id!)) {
            _recentSongString.add(rs!.id!);
            _recentSongString = _recentSongString.toSet().toList();
            _recentStorage.write("recentSong", _recentSongString);
          }
        }
      }
      update(); // Update the UI once everything is safely set
    });

    player.playerStateStream.listen((state) {
      isPlay = state.playing;
      update();
    });
  }

  // In AudioController.dart

  // Initial fetch for a new song (clears previous playlist logic effectively as we start fresh)
  getSuggestedSong() async {
    print("AudioController: getSuggestedSong (Initial) called for ${rs?.name}");

    List<Result> newSuggestions = [];
    try {
      if (rs != null) {
        newSuggestions = await _ytService.getSuggestedSongs(rs!.id!);
      }
    } catch (e) {
      print("AudioController: Error fetching suggestions: $e");
    }

    if (suggestedSong == null) {
      suggestedSong = SuggestedModel();
    }

    // RESET the list with current song + new suggestions
    suggestedSong!.data = [rs!, ...newSuggestions];

    List<AudioSource> initialSources = [];
    AudioSource? currentSongSource = await _createAudioSource(rs!);
    if (currentSongSource != null) {
        initialSources.add(currentSongSource);
    }

    playlist = ConcatenatingAudioSource(children: initialSources);

    try {
      await player.setAudioSource(playlist!);
      player.play();
      print("AudioController: Player started playing new playlist");
    } catch (e) {
      print("AudioController: Error playing new playlist: $e");
    }

    update();

    if (newSuggestions.isNotEmpty) {
      _appendSuggestions(newSuggestions, playlist!);
    }
  }

  bool _isLoadingMore = false;

  loadMoreSuggestions() async {
    if (_isLoadingMore) return;
    if (suggestedSong?.data == null || suggestedSong!.data!.isEmpty) return;

    _isLoadingMore = true;
    print("AudioController: Loading more suggestions...");

    try {
      var lastSong = suggestedSong!.data!.last;
      var newSuggestions = await _ytService.getSuggestedSongs(lastSong.id!);

      if (newSuggestions.isNotEmpty) {
          suggestedSong!.data!.addAll(newSuggestions);
          if (playlist != null) {
              _appendSuggestions(newSuggestions, playlist!);
          }
      }
    } catch (e) {
        print("AudioController: Error loading more suggestions: $e");
    } finally {
        _isLoadingMore = false;
        update();
    }
  }

  _appendSuggestions(List<Result> suggestions, ConcatenatingAudioSource currentPlaylist) async {
    for (var song in suggestions) {
      try {
        // Stop appending if the player has moved on to a completely new playlist
        // or if the current playlist is disposed
        if (playlist != currentPlaylist) {
          print("AudioController: Playlist changed, stopping background fetch.");
          break;
        }

        AudioSource? source = await _createAudioSource(song);

        // Double check after await
        if (playlist == currentPlaylist && source != null) {
          await currentPlaylist.add(source);
          print("AudioController: Appended ${song.name} to playlist.");
        }
      } catch (e) {
        print("AudioController: Caught safe error during playlist append: $e");
        // Usually happens on Web if the stream is closed mid-operation
        break;
      }
    }
  }

  Future<AudioSource?> _createAudioSource(Result song) async {
      String imageUrl = _getImageUrl(song);
      String? streamUrl = await _ytService.getAudioUrl(song.id!);

      if (streamUrl != null) {
           return AudioSource.uri(
            Uri.parse(streamUrl),
            tag: MediaItem(
              id: song.id!,
              title: song.name ?? "Unknown Title",
              artist: (song.artists?.primary != null && song.artists!.primary!.isNotEmpty)
                  ? song.artists!.primary![0].name!
                  : "Unknown Artist",
              artUri: Uri.parse(imageUrl),
              duration: Duration(seconds: song.duration ?? 0),
            ),
          );
      }
      return null;
  }

  String _getImageUrl(Result song) {
      if (song.image != null && song.image!.isNotEmpty) {
          return song.image!.last.url ?? "https://c.saavncdn.com/191/Kesariya-From-Brahmastra-Hindi-2022-20220717092820-500x500.jpg";
      }
      return "https://c.saavncdn.com/191/Kesariya-From-Brahmastra-Hindi-2022-20220717092820-500x500.jpg";
  }

onNext() {
    if (suggestedSong?.data == null || suggestedSong!.data!.isEmpty) return;

    // Just seek to next. If it's valid, the index listener will update state.
    if (player.hasNext) {
       player.seekToNext();
    } else {
       print("AudioController: No next song in player.");
    }
  }

  onPrevious() {
    if (player.hasPrevious) {
       player.seekToPrevious();
    } else {
       player.seek(Duration.zero);
    }
  }

  setToNext(Result r) {
    if (playlist != null) {
      _createAudioSource(r).then((source) {
         try {
           if (source != null && playlist != null) {
              int insertIndex = (player.currentIndex ?? 0) + 1;
              if (insertIndex > playlist!.length) insertIndex = playlist!.length;
              playlist!.insert(insertIndex, source);
              print("AudioController: Set to play next: ${r.name}");
           }
         } catch (e) {
           print("AudioController: Error inserting song: $e");
         }
      });
    }
  }

  // onPrevious() {
  //   player.seekToPrevious();
  //   rs = suggestedSong!.data![player.currentIndex!];
  //   update();
  // }

  onPlayPause() {
    if (isPlay) {
      player.pause();
      isPlay = false;
      update();
    } else {
      player.play();
      isPlay = true;
      update();
    }
  }

  downloadCurrentSong() async {
    if (rs == null || rs!.id == null) {
      Get.snackbar("Error", "No song selected", colorText: Colors.white, backgroundColor: Colors.red);
      return;
    }

    // 1. UI Feedback
    Get.snackbar("Downloading...", "Starting download for ${rs!.name}", showProgressIndicator: true,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFF1E1E1E),
      colorText: Colors.white,
      margin: EdgeInsets.all(20),
      duration: Duration(seconds: 3)
    );

    try {
      // 2. Get Audio URL
      String? audioUrl = await _ytService.getAudioUrl(rs!.id!);
      if (audioUrl == null) {
        Get.snackbar("Failed", "Could not get audio stream.", backgroundColor: Colors.redAccent, colorText: Colors.white);
        return;
      }

      // 3. Directory
      Directory? dir;
      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory();
        // /storage/emulated/0/Android/data/com.example.jhumo/files
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      if (dir == null) {
         Get.snackbar("Error", "Storage directory not found.", backgroundColor: Colors.redAccent, colorText: Colors.white);
         return;
      }

      // 4. File Path
      String sanitizedName = rs!.name!.replaceAll(RegExp(r'[^\w\s]+'), '').trim();
      String fileName = "$sanitizedName.m4a";
      String savePath = "${dir.path}/$fileName";
      print("Downloading to $savePath");

      // 5. Download using Dio
      await Dio().download(audioUrl, savePath);

      Get.snackbar("Success", "Downloaded to ${dir.path}",
        backgroundColor: Colors.green, colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM, margin: EdgeInsets.all(20),
        duration: Duration(seconds: 4)
      );

    } catch (e) {
      Get.snackbar("Error", "Download failed: $e", backgroundColor: Colors.red, colorText: Colors.white);
      print("Download Error: $e");
    }
  }

}
