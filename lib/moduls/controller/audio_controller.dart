import 'dart:math';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jhumo/main.dart';
import 'package:jhumo/moduls/controller/collaboration_controller.dart';
import 'package:jhumo/moduls/data/variable.dart';
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
  Variables _var = Variables();
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
    _recentSongString.forEach((id) async {
      try {
        var response =
            await http.get(Uri.parse("${_var.jioSaavnUrl}/api/songs/$id"));
        SuggestedModel s = suggestedModelFromJson(response.body);
        recentSong.add(s.data![0]);
        update();
      } catch (e) {
        print("Error in getting recent song: $e");
      }
    });
  }

  setSong(Result result) {
    rs = result;
    _fetchSong();
    startStreaming();
  }

  setMusicList(List<Result> songs) async {
    if (suggestedSong == null) suggestedSong = SuggestedModel();
    suggestedSong!.data = songs;
    rs = songs[0];
    List<AudioSource> l =
        List.generate(suggestedSong!.data!.length, (int index) {
      return AudioSource.uri(
          Uri.parse(
            suggestedSong!.data![index].downloadUrl![2].url!,
          ),
          tag: MediaItem(
            id: suggestedSong!.data![index].id ?? "${Random().nextInt(1000)}",
            title: suggestedSong!.data![index].name!,
            artist: suggestedSong!.data![index].artists!.primary != null &&
                    suggestedSong!.data![index].artists!.primary!.isNotEmpty
                ? suggestedSong!.data![index].artists!.primary![0].name!
                : "",
            artUri: Uri.parse(
              suggestedSong!.data![index].image![1].url!,
            ),
            duration: Duration(
              seconds: suggestedSong!.data![index].duration!,
            ),
          ));
    });

    final playlist = ConcatenatingAudioSource(
      children: l,
    );
    await player.setAudioSource(playlist);
    player.play();
    startStreaming();
    Get.to(
        PlayerPage(
          result: suggestedSong!.data!.first,
          isPlaying: true,
        ),
        transition: Transition.downToUp);
  }

  _fetchSong() async {
    isPlay = true;
    await getSuggestedSong();
    total = player.duration!;
    if ((!_recentSongString.contains(rs!.id!))) {
      _recentSongString.add(rs!.id!);
      _recentStorage.write("recentSong", _recentSongString);
      _recentStorage.save();
    }
    update();
  }

  getLyrics() async {
    if (rs!.hasLyrics!) {
      var res = await http
          .get(Uri.parse("${_var.jioSaavnUrl}/api/songs/${rs!.id}/lyrics"));
      lyrics = lyricsFromJson(res.body);
      lyrics!.data!.lyrics = lyrics!.data!.lyrics!.replaceAll("<br>", "\n");
      update();
    }
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
      if (i != null) songPos = i;
      update();
      if (player.audioSource != null) {
        total = player.duration!;
        getLyrics();
        rs = suggestedSong!.data![i!];
        if (suggestedSong!.data!.last == rs) {
          getSuggestedSong();
        }
        if (!_recentSongString.contains(rs!.id!)) {
          _recentSongString.add(rs!.id!);

          _recentSongString = _recentSongString.toSet().toList();
          _recentStorage.write("recentSong", _recentSongString);
          update();
        }
      }
    });

    player.playerStateStream.listen((state) {
      isPlay = state.playing;
      update();
    });
  }

  getSuggestedSong() async {
    if (suggestedSong != null && suggestedSong!.data!.length > 0) {
      suggestedSong!.data!.clear();
      update();
    }
    try {
      if (rs != null) {
        var response = await http.get(Uri.parse(
            "${_var.jioSaavnUrl}/api/songs/${rs!.id}/suggestions?limit=20"));
        if (suggestedSong == null) {
          suggestedSong = suggestedModelFromJson(response.body);
        } else {
          suggestedSong!.data!.addAll(
              suggestedModelFromJson(response.body).data!);
        }
      }
    } catch (e) {
      print("Error in getting suggested song: $e");
    }
    List<AudioSource> l = [];
    try {
      l = List.generate(suggestedSong!.data!.length, (int index) {
        return AudioSource.uri(
            Uri.parse(
              suggestedSong!.data![index].downloadUrl![2].url!,
            ),
            tag: MediaItem(
              id: suggestedSong!.data![index].id ?? "${Random().nextInt(1000)}",
              title: suggestedSong!.data![index].name!,
              artist: suggestedSong!.data![index].artists!.primary != null &&
                      suggestedSong!.data![index].artists!.primary!.isNotEmpty
                  ? suggestedSong!.data![index].artists!.primary![0].name!
                  : "",
              artUri: Uri.parse(
                suggestedSong!.data![index].image![1].url!,
              ),
              duration: Duration(
                seconds: suggestedSong!.data![index].duration!,
              ),
            ));
      });
    } catch (e) {
      print("Error in generating suggested song list: $e");
    }
    List<AudioSource> ll = [
      AudioSource.uri(
          Uri.parse(
            rs!.downloadUrl![2].url!,
          ),
          tag: MediaItem(
            id: rs!.id!,
            title: rs!.name!,
            artist: rs!.artists!.primary![0].name!,
            artUri: Uri.parse(
              rs!.image![1].url!,
            ),
            duration: Duration(
              seconds: rs!.duration!,
            ),
            extras: {"url": rs!.downloadUrl![2].url!},
          ))
    ];
    suggestedSong!.data!.insert(0, rs!);
    ll.addAll(l);

    playlist = ConcatenatingAudioSource(
      children: ll,
    );
    await player.setAudioSource(playlist!);
    player.play();
    update();
  }

  onNext() {
    player.seekToNext();

    rs = suggestedSong!.data![player.currentIndex!];
    update();
  }

  setToNext(Result r) {
    if (playlist != null)
      playlist!.insert(
          0,
          AudioSource.uri(
            Uri.parse(
              r.downloadUrl![2].url!,
            ),
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
              extras: {"url": r.downloadUrl![2].url!},
            ),
          ));
  }

  onPrevious() {
    player.seekToPrevious();
    rs = suggestedSong!.data![player.currentIndex!];
    update();
  }

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
