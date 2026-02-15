import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() async {
  var yt = YoutubeExplode();
  var query = "lofi hip hop";

  print("Searching for '$query' playlists...");
  try {
    var results = await yt.search.searchContent(query, filter: TypeFilters.playlist);
    print("Found ${results.length} results.");
    for (var item in results) {
      dynamic result = item;
      print("Type: ${result.runtimeType}");
      try {
         print("- [Playlist] ${result.title} (ID: ${result.id})");
      } catch (e) {
         print("  Error accessing properties: $e");
      }
    }
  } catch (e) {
    print("Error: $e");
  } finally {
    yt.close();
  }
}
