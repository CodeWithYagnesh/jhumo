import 'package:get/get.dart';
import 'package:jhumo/moduls/data/variable.dart';
import 'package:jhumo/moduls/model/Search_model.dart' as sm;
import 'package:jhumo/moduls/service/youtube_service.dart';
import 'package:jhumo/moduls/methods.dart';
import 'package:jhumo/moduls/model/service.dart' as srv;

class SearchControl extends GetxController {
  sm.SearchModel? searchModel;
  String search = "";
  srv.SongService? allSongs;
  // SongService? allSongs;
  SearchControl(this.search);
  YoutubeService _ytService = YoutubeService();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  List<String> suggestions = [];
  bool isSubmitted = false;

  onChange(String s) {
    if (s.isEmpty) {
      suggestions = [];
      isSubmitted = false;
      update();
      return;
    }
    isSubmitted = false; // User is typing, show suggestions
    fetchSuggestions(s);
  }

  fetchSuggestions(String query) async {
    suggestions = await _ytService.getSearchSuggestions(query);
    update();
  }

  searchSong(String query) async {
    search = query;
    isSubmitted = true; // User submitted, show results
    update(); // Update UI to show loading or clear previous results while fetching

    var results = await _ytService.searchSongs(query);
    var data = srv.Data(results: results);
    allSongs = srv.SongService(success: true, data: data);

    update();
  }

  searchArtist(String s) async {
    // ${_var.jioSaavnUrl}/api/search/artists?query=Adele
    search = s;
    // YoutubeExplode doesn't have a direct "search artists" that returns Artist objects cleanly matching the API.
    // For now we can search for the artist name and return songs, or just skip artist search specific logic if it expects structure we can't easily fake.
    // However, let's try to search and return something.
    var results = await _ytService.searchSongs(s); // Just searching songs for now as fallback
     // If the UI expects "Artists" result, we might need to adapt.
     // But `searchArtist` method in `SearchControl` doesn't seem to set any `allArtists` variable in the code I saw?
     // It just calls `update()`.
     // Ah, I see `searchArtist` in the view_file output but `SearchControl` class def line 53 seems to end abruptly or I missed where it stores data.
     // In the file view earlier:
     /*
      searchArtist(String s) async {
        // ...
        var responce = await http ...
        // It doesn't seem to assign the response to anything!
        // Just update().
      }
     */
     // So I might just comment it out or make it a no-op if it was incomplete.
     // OR maybe I missed a line in view_file.
     // Let's just assuming it does nothing for now or assign to a variable if I find it.
     // Wait, I don't see any variable for artists in `SearchControl` class definition provided.
     // `SearchModel? searchModel;`, `String search`, `SongService? allSongs`.
     // So `searchArtist` might be doing nothing meaningful or I missed something.
     // I'll just make it search songs to be safe or leave it empty.

     // actually let's just properly replace the http call with a no-op comment or reusing searchSongs if appropriate.
     // The prompt asked to replace JioSaavn.

     // I will leave it as "searchSongs" but not assign to anything since the original didn't seem to assign either?
     // Wait, let's look at `SearchControl` again.

    // Original:
    // searchArtist(String s) async {
    //   search = s;
    //   var responce = await http.get(Uri.parse("${_var.jioSaavnUrl}/api/search/artists?query=$search&limit=100"));
    //   update();
    // }

    // It seems it really does nothing with the response. I'll just remove the http call.


    update();
  }
}
