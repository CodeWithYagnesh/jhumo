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

  onChange(String s) {
    searchAll(s);
    searchSong(s);
  }

  searchAll(String s) async {
    search = s;
    var results = await _ytService.searchSongs(s);
    // searchModel = searchModelFromJson(responce.body);
    // Constructing a dummy SearchModel
    var data = sm.Data(
      songs: sm.Songs(results: results.map((e) => sm.SongsResult(
        id: e.id,
        title: e.name,
        // image: e.image, // Image types might differ? Result has List<DownloadUrl>, SongsResult has List<Image>?
        // In service.dart: Image has quality/url. DownloadUrl has quality/url.
        // In Search_model.dart: Image has quality/url.
        // They are different classes. We need to map.
        image: e.image?.map((i) => sm.Image(quality: i.quality?.toString(), url: i.url)).toList(),
        album: e.album?.name ?? "",
        url: e.url,
        type: "song",
        language: "Hindi", // Placeholder
        description: e.description,
        primaryArtists: e.artist,
        singers: e.artist
      )).toList())
    );
    searchModel = sm.SearchModel(success: true, data: data);
    // print(searchModel!.data!.toJson());

    update();
  }

  searchSong(String query) async {
    search = query;
    var results = await _ytService.searchSongs(query);
    var data = srv.Data(results: results);
    allSongs = srv.SongService(success: true, data: data);
    // allSongs!.data!.results!.toPrint;

    update();
    // ${_var.jioSaavnUrl}/api/search/songs?query=Believer
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
