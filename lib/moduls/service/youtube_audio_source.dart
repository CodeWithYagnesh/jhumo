import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:jhumo/moduls/service/youtube_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeAudioSource extends StreamAudioSource {
  final String videoId;
  final YoutubeService _service = YoutubeService();

  YoutubeAudioSource(this.videoId, {dynamic tag}) : super(tag: tag);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
     try {
      print("YoutubeAudioSource: Requesting stream for $videoId (Range: $start-$end)");
      var info = await _service.getAudioStreamInfo(videoId);
      var stream = await _service.getStream(info, start: start, end: end);

      return StreamAudioResponse(
        sourceLength: info.size.totalBytes,
        contentLength: info.size.totalBytes,
        offset: start ?? 0,
        stream: stream,
        contentType: info.container.name == 'm4a' ? 'audio/mp4' : 'audio/${info.container.name}',
      );
    } catch (e) {
      print("Error in YoutubeAudioSource for $videoId: $e");
      // Return a 404 or similar error response if possible, or rethrow.
      // Since we can't easily return an HTTP error code here, we rethrow.
      throw Exception("Failed to load audio stream for $videoId: $e");
    }
  }
}
