import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:jhumo/moduls/service/youtube_service.dart';

class YoutubeAudioSource extends StreamAudioSource {
  final String videoId;
  final YoutubeService _service = YoutubeService();

  YoutubeAudioSource(this.videoId, {dynamic tag}) : super(tag: tag);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
     try {
      print("YoutubeAudioSource: Requesting stream for $videoId (Range: $start-$end)");
      var info = await _service.getAudioStreamInfo(videoId);

      var client = http.Client();
      var request = http.Request('GET', Uri.parse(info.url));
      if (start != null || end != null) {
        request.headers['Range'] = 'bytes=${start ?? 0}-${end ?? ""}';
      }

      var response = await client.send(request);
      int contentLength = response.contentLength ?? 0;

      // Let just_audio handle source length if valid
      int? sourceLength;
      if (contentLength > 0 && start == null && end == null) {
         sourceLength = contentLength;
      }

      return StreamAudioResponse(
        sourceLength: sourceLength,
        contentLength: contentLength > 0 ? contentLength : null,
        offset: start ?? 0,
        stream: response.stream,
        contentType: response.headers['content-type'] ?? 'audio/mpeg',
      );
    } catch (e) {
      print("Error in YoutubeAudioSource for $videoId: $e");
      throw Exception("Failed to load audio stream for $videoId: $e");
    }
  }
}
