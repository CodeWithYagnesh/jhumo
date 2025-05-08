import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:jhumo/moduls/data/constants.dart';
import 'package:just_audio/just_audio.dart';

class MyAudioHandler extends BaseAudioHandler {
  final player = AudioPlayer();

  MyAudioHandler() {
    _notifyAudioHandlerAboutPlaybackEvents();
    initialize();
  }

  void initialize() {
    print("foreground ===============");

    double? previousVolume;
    volumeController.removeListener();
    int increaseCount = 0;
    int decreaseCount = 0;
    Timer.periodic(Duration(seconds: 3), (timer) {
      increaseCount = 0;
      decreaseCount = 0;
    });
    volumeController.addListener((volume) async {
      print('CHANGED_VOLUME');

      if (previousVolume != null) {
        if (volume > previousVolume!) {
          increaseCount++;
          decreaseCount = 0; // Reset decrease count
          if (increaseCount >= 5) {
            print('Volume increased 5 times');
            await this.skipToNext().catchError((e) {
              print("IYagnesh_ERROR: $e");
            });
            increaseCount = 0; // Reset increase count
          }
        } else if (volume < previousVolume!) {
          decreaseCount++;
          increaseCount = 0; // Reset increase count
          if (decreaseCount >= 5) {
            print('Volume decreased 5 times');
            await this.skipToPrevious();

            decreaseCount = 0; // Reset decrease count
          }
        }
      }
      previousVolume = volume;
    });
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    player.playbackEventStream.listen((event) {
      playbackState.add(playbackState.value.copyWith(
        playing: player.playing,
        processingState: {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[player.processingState]!,
        updatePosition: player.position,
      ));
    });
  }

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> stop() => player.stop();

  @override
  Future<void> skipToNext() async {
    print("skipToNext");
    if (player.hasNext) {
      await player.seekToNext();
    } else {
      print("No next track available.");
    }
  }

  @override
  Future<void> skipToPrevious() async {
    print("skipToPrevious");
    if (player.hasPrevious) {
      await player.seekToPrevious();
    } else {
      print("No previous track available.");
    }
  }

  Future<void> setAudioSource(String url) async {
    await player.setUrl(url);
  }
}
