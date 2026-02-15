import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jhumo/moduls/data/variable.dart';
import 'package:jhumo/moduls/model/Search_model.dart' as sm;
import 'package:jhumo/moduls/service/youtube_service.dart';
import 'package:jhumo/moduls/methods.dart';
import 'package:jhumo/moduls/model/service.dart' as srv;

class SearchControl extends GetxController {
  sm.SearchModel? searchModel;
  String search = "";
  srv.SongService? allSongs;

  SearchControl(this.search);
  YoutubeService _ytService = YoutubeService();

  // History Management
  RxList<String> history = <String>[].obs;
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  void loadHistory() {
    List<dynamic>? stored = box.read<List<dynamic>>('search_history');
    if (stored != null) {
      history.value = stored.cast<String>();
    }
  }

  void addToHistory(String query) {
    if (query.trim().isEmpty) return;
    if (history.contains(query)) {
      history.remove(query);
    }
    history.insert(0, query);
    if (history.length > 10) {
      history.removeLast();
    }
    box.write('search_history', history.toList());
  }

  void removeFromHistory(String query) {
    history.remove(query);
    box.write('search_history', history.toList());
    update();
  }

  void clearHistory() {
    history.clear();
    box.remove('search_history');
    update();
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
    addToHistory(query); // Add to history
    update();

    var results = await _ytService.searchSongs(query);
    var data = srv.Data(results: results);
    allSongs = srv.SongService(success: true, data: data);

    // Also search for playlists
    searchPlaylists(query);

    update();
  }

  List<srv.Result> playlistResults = [];
  bool isPlaylistLoading = false;

  searchPlaylists(String query) async {
    print("SearchControl: Calling searchPlaylists for '$query'");
    isPlaylistLoading = true;
    playlistResults = []; // Clear previous results
    update();

    playlistResults = await _ytService.searchPlaylists(query);
    print("SearchControl: playlistResults length: ${playlistResults.length}");

    isPlaylistLoading = false;
    update();
  }

  searchArtist(String s) async {
    // Deprecated / Not used for now
    update();
  }
}
