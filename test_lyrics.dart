import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() async {
  var yt = YoutubeExplode();
  var videoId = "BddP6PYo2gs"; // Kesariya

  print("Fetching lyrics/captions for $videoId...");
  try {
    var manifest = await yt.videos.closedCaptions.getManifest(videoId);
    print("Found ${manifest.tracks.length} caption tracks.");

    for (var track in manifest.tracks) {
      print("- Language: ${track.language.name} (${track.language.code})");
    }

    if (manifest.tracks.isNotEmpty) {
      var trackInfo = manifest.getByLanguage('en');
      // specific track or first
      var track = manifest.tracks.first;

      print("Fetching captions for ${track.language.name}...");

      var captionManifest = await yt.videos.closedCaptions.get(track);

      // The result of .get(track) is ClosedCaptionTrack
      // It has a .captions property which is a List<ClosedCaption>

      var sb = StringBuffer();
      for (var caption in captionManifest.captions) {
        sb.writeln(caption.text);
      }

      print("--- LYRICS/CAPTIONS ---");
      var text = sb.toString();
      if (text.length > 500) {
         print(text.substring(0, 500) + "...");
      } else {
         print(text);
      }

    } else {
      print("No captions found.");
    }
  } catch (e) {
    print("Error: $e");
  } finally {
    yt.close();
  }
}
