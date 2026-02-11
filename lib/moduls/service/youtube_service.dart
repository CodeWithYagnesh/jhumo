import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:jhumo/moduls/model/service.dart';


// ... (existing helper methods)

class YoutubeService {
  static final YoutubeService _instance = YoutubeService._internal();
  factory YoutubeService() => _instance;
  YoutubeService._internal();

  final YoutubeExplode _yt = YoutubeExplode();

  Future<List<Result>> searchSongs(String query) async {
    try {
      var searchResults = await _yt.search.search(query);
      return searchResults.map((e) => _mapVideoToResult(e)).toList();
    } catch (e) {
      print("Error searching songs: $e");
      return [];
    }
  }

  Future<List<Result>> getSuggestedSongs(String videoId) async {
    try {
      var video = await _yt.videos.get(videoId);
      var relatedVideos = await _yt.videos
          .getRelatedVideos(video)
          .then((value) => value!.toList());
      if (relatedVideos != null && relatedVideos.isNotEmpty) {
        return relatedVideos.map((e) => _mapVideoToResult(e)).toList();
      }
      return [];
    } catch (e) {
      print("Error getting suggested songs: $e");
      return [];
    }
  }

  Future<Result?> getSong(String id) async {
    try {
      var video = await _yt.videos.get(id);
      return _mapVideoToResult(video);
    } catch (e) {
      print("Error getting song: $e");
      return null;
    }
  }

  Future<StreamInfo> getAudioStreamInfo(String videoId) async {
    var manifest = await _yt.videos.streamsClient.getManifest(videoId);
    // Try Muxed first (more reliable against 403s)
    var muxedStreams = manifest.muxed.sortByVideoQuality();
    if (muxedStreams.isNotEmpty) {
      return muxedStreams.first; // Lowest quality video with audio
    }
    // Fallback to audio only
    return manifest.audioOnly.withHighestBitrate();
  }

  Future<Stream<List<int>>> getStream(StreamInfo info, {int? start, int? end}) async {
    // Standard YoutubeExplode get() doesn't support start/end efficiently for seeking
    // So we use a direct HTTP request with Range header.

    var client = http.Client();
    var request = http.Request('GET', Uri.parse(info.url.toString()));

    if (start != null || end != null) {
      String range = 'bytes=${start ?? 0}-${end ?? ""}';
      request.headers['Range'] = range;
      print("YoutubeService: Requesting Range: $range");
    }

    try {
      var response = await client.send(request);

      if (response.statusCode == 200 || response.statusCode == 206) {
        return response.stream;
      } else {
        print("YoutubeService: HTTP ${response.statusCode} for stream");
         // Fallback to library getter if direct fail (though library might not seek)
        return _yt.videos.streamsClient.get(info);
      }
    } catch (e) {
      print("YoutubeService: Error fetching stream with range: $e");
      return _yt.videos.streamsClient.get(info);
    }
  }

  Future<String?> getAudioUrl(String videoId) async {
    print("YoutubeService: getting audio url for $videoId");
    try {
      var manifest = await _yt.videos.streamsClient.getManifest(videoId);

      // THE 403 FIX: Use Muxed instead of AudioOnly
      // Since audioOnly streams return 403, we grab a muxed (video+audio) stream.
      // just_audio will automatically extract and play just the audio.

      var muxedStreams = manifest.muxed.sortByVideoQuality();

      if (muxedStreams.isNotEmpty) {
        // Grab the lowest quality video (usually 360p mp4 - itag 18) to save bandwidth
        var safeStream = muxedStreams.first;
        print(
            "YoutubeService: Bypassing 403 with Muxed stream: ${safeStream.url}");
        return safeStream.url.toString();
      }

      // Desperate fallback just in case
      var audioStream = manifest.audioOnly.withHighestBitrate();
      return audioStream.url.toString();
    } catch (e) {
      print("Error fetching stream: $e");
      return null;
    }
  }

  Result _mapVideoToResult(dynamic video) {
    String id = video.id.value;
    String title = video.title;
    String author = video.author;
    int duration = video.duration?.inSeconds ?? 0;

    return Result(
      id: id,
      name: title,
      title: title,
      artist: author,
      artists:
          Artists(primary: [All(name: author, role: Role.PRIMARY_ARTISTS)]),
      duration: duration,
      image: [
        DownloadUrl(
            url: video.thumbnails.lowResUrl,
            quality: Quality.THE_50_X50), // Low
        DownloadUrl(
            url: video.thumbnails.mediumResUrl,
            quality: Quality.THE_150_X150), // Medium
        DownloadUrl(
            url: video.thumbnails.highResUrl,
            quality: Quality.THE_500_X500), // High
      ],
      downloadUrl: [DownloadUrl(url: "", quality: Quality.THE_320_KBPS)],
      hasLyrics: false,
    );
  }

  void dispose() {
    _yt.close();
  }
}
