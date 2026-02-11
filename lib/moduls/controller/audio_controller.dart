import 'dart:math';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:jhumo/main.dart';
import 'package:jhumo/moduls/controller/collaboration_controller.dart';
import 'package:jhumo/moduls/service/youtube_service.dart';
import 'package:jhumo/moduls/service/youtube_audio_source.dart';
import 'package:jhumo/moduls/methods.dart';
import 'package:jhumo/moduls/model/album_song.dart';
import 'package:jhumo/moduls/model/lyrics_model.dart';
import 'package:jhumo/moduls/model/service.dart';
import 'package:jhumo/screens/player_page.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioController extends GetxController {
  Result? rs;
  Duration currentPosition = Duration.zero;
  Duration total = Duration.zero;
  Duration bufferedPosition = Duration.zero;
  int songPos = 0;
  bool isPlay = false;
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
  }

  setLoopMode(LoopMode l) {
    player.setLoopMode(l);
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
    startStreaming();
  }

  setMusicList(List<Result> songs) async {
    print("AudioController: setMusicList called with ${songs.length} songs");
    if (suggestedSong == null) suggestedSong = SuggestedModel();
    suggestedSong!.data = songs;
    rs = songs[0];
    print("AudioController: Playing first song: ${rs?.name}");

    List<AudioSource> l =
        List.generate(suggestedSong!.data!.length, (int index) {
      return YoutubeAudioSource(
          suggestedSong!.data![index].id ?? "${Random().nextInt(1000)}",
          tag: MediaItem(
            id: suggestedSong!.data![index].id ?? "${Random().nextInt(1000)}",
            title: suggestedSong!.data![index].name!,
            artist: suggestedSong!.data![index].artists!.primary != null &&
                    suggestedSong!.data![index].artists!.primary!.isNotEmpty
                ? suggestedSong!.data![index].artists!.primary![0].name!
                : "",
            artUri: Uri.parse(
              (suggestedSong!.data![index].image != null &&
                      suggestedSong!.data![index].image!.isNotEmpty)
                  ? (suggestedSong!.data![index].image!.length > 1
                      ? suggestedSong!.data![index].image![1].url!
                      : suggestedSong!.data![index].image![0].url!)
                  : "https://default_image_url.png",
            ),
            duration: Duration(
              seconds: suggestedSong!.data![index].duration!,
            ),
          ));
    });

    final playlist = ConcatenatingAudioSource(
      children: l,
    );
    try {
      await player.setAudioSource(playlist);
      player.play();
      print("AudioController: Player started playing");
    } catch (e) {
      print("AudioController: Error playing playlist: $e");
    }
    startStreaming();
    Get.to(
        PlayerPage(
          result: suggestedSong!.data!.first,
          isPlaying: true,
        ),
        transition: Transition.downToUp);
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
    // Lyrics not supported by YoutubeExplode directly
    // Keeping method empty or removing logic
  }

  startStreaming() {
    var collaboration = Get.put(CollaborationController());
    player.positionStream.listen((Duration? d) async {
      if (d != null) {
        currentPosition = d;
        await collaboration.syncs(d);
        update();
      }
    });
    _recentStorage.listen(() {
      getRecentSong();
    });
    player.bufferedPositionStream.listen((Duration? d) {
      if (d != null) {
        bufferedPosition = d;
        update();
      }
    });
    player.currentIndexStream.listen((i) {
      if (i != null) {
        songPos = i;

        // SAFETY CHECK: Make sure the index exists in the list!
        if (suggestedSong?.data != null && i < suggestedSong!.data!.length) {
          total = player.duration ?? Duration.zero;
          getLyrics();

          rs = suggestedSong!.data![i]; // Safely update the current song

          // If we reached the end of the list, load more
          if (suggestedSong!.data!.last.id == rs!.id) {
            getSuggestedSong();
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

  getSuggestedSong() async {
    if (suggestedSong != null && suggestedSong!.data!.length > 0) {
      suggestedSong!.data!.clear();
      update();
    }
    try {
      if (rs != null) {
        var results = await _ytService.getSuggestedSongs(rs!.id!);
        if (suggestedSong == null) {
          suggestedSong = SuggestedModel();
          suggestedSong!.data = results;
        } else {
          suggestedSong!.data!.addAll(results);
        }
      }
    } catch (e) {
      print("Error in getting suggested song: $e");
    }

    List<AudioSource> l = [];
    try {
      l = List.generate(suggestedSong!.data!.length, (int index) {
        // SAFE IMAGE LOGIC
        String imageUrl;
        if (suggestedSong!.data![index].image != null &&
            suggestedSong!.data![index].image!.isNotEmpty) {
          imageUrl = suggestedSong!.data![index].image!.last.url ?? "";
        } else {
          imageUrl =
              "https://c.saavncdn.com/191/Kesariya-From-Brahmastra-Hindi-2022-20220717092820-500x500.jpg";
        }

        return YoutubeAudioSource(
            suggestedSong!.data![index].id ?? "${Random().nextInt(1000)}",
            tag: MediaItem(
              id: suggestedSong!.data![index].id ?? "${Random().nextInt(1000)}",
              title: suggestedSong!.data![index].name ?? "Unknown Title",
              artist: (suggestedSong!.data![index].artists?.primary != null &&
                      suggestedSong!.data![index].artists!.primary!.isNotEmpty)
                  ? suggestedSong!.data![index].artists!.primary![0].name ?? ""
                  : "",
              artUri: Uri.parse(imageUrl),
              duration: Duration(
                seconds: suggestedSong!.data![index].duration ?? 0,
              ),
            ));
      });
    } catch (e) {
      print("Error in generating suggested song list: $e");
    }

    // Handle current song (rs) safely as well
    String currentSongImage =
        "https://c.saavncdn.com/191/Kesariya-From-Brahmastra-Hindi-2022-20220717092820-500x500.jpg";

    // SAFE ACCESS to downloadUrl
    if (rs!.downloadUrl != null && rs!.downloadUrl!.isNotEmpty) {
      print(rs!.downloadUrl!.first.url);
    }

    if (rs!.image != null && rs!.image!.isNotEmpty) {
      currentSongImage = rs!.image!.last.url ?? currentSongImage;
    }

    // List<AudioSource> ll = [];
    List<AudioSource> ll = [];

    // TRYING DIRECT URL FOR CURRENT SONG
    print("AudioController: Fetching stream URL for ${rs!.id}...");
    String? streamUrl = await _ytService.getAudioUrl(rs!.id!);
    if (streamUrl != null) {
      print("AudioController: Using DIRECT URI for ${rs!.id}!");
      ll.add(AudioSource.uri(
        Uri.parse(streamUrl),
        // headers: {
        //   'User-Agent':
        //       'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        //   'Referer': 'https://www.youtube.com/',
        // },
        tag: MediaItem(
          id: rs!.id!,
          title: rs!.name ?? "Unknown",
          artist:
              (rs!.artists?.primary != null && rs!.artists!.primary!.isNotEmpty)
                  ? rs!.artists!.primary![0].name!
                  : "Unknown",
          artUri: Uri.parse(currentSongImage),
          duration: Duration(seconds: rs!.duration ?? 0),
        ),
      ));
    } else {
      print(
          "AudioController: Fallback to YoutubeAudioSource (Stream) for ${rs!.id}!");
      // Fallback if URL fails
      ll.add(YoutubeAudioSource(rs!.id!,
          tag: MediaItem(
            id: rs!.id!,
            title: rs!.name ?? "Unknown",
            artist: (rs!.artists?.primary != null &&
                    rs!.artists!.primary!.isNotEmpty)
                ? rs!.artists!.primary![0].name!
                : "Unknown",
            artUri: Uri.parse(currentSongImage),
            duration: Duration(seconds: rs!.duration ?? 0),
          )));
    }

    print(
        "AudioController: Creating ConcatenatingAudioSource with ${ll.length} + ${l.length} sources");

    if (suggestedSong?.data != null) {
      suggestedSong!.data!.insert(0, rs!);
    }
    // ll.addAll(l); // Rename l to dataAudioSources for clarity if desired, but here l is fine
    ll.addAll(l);

    playlist = ConcatenatingAudioSource(children: ll);
    try {
      await player.setAudioSource(playlist!);
      player.play();
      print("AudioController: Player started playing");
    } catch (e, stack) {
      print("AudioController: Error setting audio source or playing: $e");
      print(stack);
    }
    update();
  }

onNext() {
    if (suggestedSong?.data == null || suggestedSong!.data!.isEmpty) return;

    // Find the index of the currently playing song in our suggested list
    int currentIndex = suggestedSong!.data!.indexWhere((song) => song.id == rs?.id);

    // If we found it, and there is a next song available
    if (currentIndex != -1 && currentIndex + 1 < suggestedSong!.data!.length) {
      // Get the next song
      Result nextSong = suggestedSong!.data![currentIndex + 1];

      // Tell the player to play it (this triggers your URL fetching logic automatically)
      setSong(nextSong);
    } else {
      print("End of playlist reached.");
      // Optional: Fetch more suggested songs here or loop back to the start
    }
  }

  onPrevious() {
    if (suggestedSong?.data == null || suggestedSong!.data!.isEmpty) return;

    int currentIndex = suggestedSong!.data!.indexWhere((song) => song.id == rs?.id);

    // If we found it, and there is a previous song available
    if (currentIndex > 0) {
      Result previousSong = suggestedSong!.data![currentIndex - 1];
      setSong(previousSong);
    } else {
      // If we are on the first song, just restart it
      player.seek(Duration.zero);
    }
  }

  setToNext(Result r) {
    if (playlist != null)
      playlist!.insert(
          0,
          YoutubeAudioSource(
            r.id!,
            tag: MediaItem(
              id: r.id!,
              title: r.name!,
              artist: r.artists!.primary![0].name!,
              artUri: Uri.parse(
                r.image![1].url!,
              ),
              duration: Duration(
                seconds: r.duration!,
              ),
              // extras: {"url": r.downloadUrl![2].url!},
            ),
          ));
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
}
