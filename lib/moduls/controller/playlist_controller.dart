import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jhumo/moduls/data/variable.dart';
import 'package:jhumo/moduls/methods.dart';
import 'package:jhumo/moduls/model/service.dart';
import 'package:http/http.dart' as http;

class PlaylistController extends GetxController {
  GetStorage favoriteStorage = GetStorage("favStorage");
  GetStorage playlistDataStorage = GetStorage("playlistData");
  GetStorage playlistNameStorage = GetStorage("playlistName");
  GetStorage songData = GetStorage("songData");
  List<Result> favSongsResults = [];
  List<dynamic> playlistName = [];
  List<Map<String, dynamic>> playlist = [];
  Variables _var = Variables();

  addToPlaylist(String name, Result rs) {
    List li = playlistDataStorage.read(name) ?? [];
    if (!li.contains(rs.id)) {
      li.add(rs.id);

      playlistDataStorage.write(name, li);
      playlistDataStorage.save();
      songData.write(rs.id!, rs.toJson());
      songData.save();
    }
  }

  removeFromPlaylist(String name, Result rs) {
    List li = playlistDataStorage.read(name) ?? [];
    li.remove(rs.id);
    playlistDataStorage.write(name, li);
    playlistDataStorage.save();
    update();
  }

  createPlayList(String name) {
    playlistName.add(name);
    playlistName = playlistName.toSet().toList();
    playlistNameStorage.write("name", playlistName);
    playlistNameStorage.save();
    update();
  }

  deletePlaylistById(String name) {
    playlistName.remove(name);
    playlistNameStorage.write("name", playlistName);
    playlistNameStorage.save();
    update();
  }

  Result getSongById(String id) {
    Map<String, dynamic> r = songData.read(id) ?? {};
    Result rs = Result.fromJson(r);
    return rs;
  }

  isFav(Result r) {
    List fav = favoriteStorage.read("fav") ?? [];
    return fav.contains(r.id);
  }

  List getPlaylistById(String id) {
    List li = playlistDataStorage.read(id) ?? [];
    return li;
  }

  getPlaylists() {
    playlistName = playlistNameStorage.read("name") ?? [];
    update();
  }

  onFevClick(Result r) {
    List fav = favoriteStorage.read("fav") ?? [];

    if (fav.contains(r.id)) {
      removeFromFev(r);
    } else {
      addToFev(r);
    }
    update();
  }

  addToFev(Result r) {
    List fav = favoriteStorage.read("fav") ?? [];
    fav.add(r.id!);
    favoriteStorage.write("fav", fav);
    favoriteStorage.save();
    getFavList();
    update();
  }

  removeFromFev(Result r) {
    List fav = favoriteStorage.read("fav") ?? [];
    fav.remove(r.id!);
    favoriteStorage.write("fav", fav);
    favSongsResults.removeWhere((element) => element.id == r.id);
    favoriteStorage.save();
    getFavList();
    update();
  }

  getFavList() async {
    List fav = favoriteStorage.read("fav") ?? [];
    favSongsResults.clear();
    for (var i = 0; i < fav.length; i++) {
      var responce =
          await http.get(Uri.parse("${_var.jioSaavnUrl}/api/songs/${fav[i]}"));
      SuggestedModel s = suggestedModelFromJson(responce.body);
      favSongsResults.add(s.data![0]);
    }
    update();
  }

  // addPlaylist(String id) {
  //   playlistsId.add(id);
  //   playlistsId.toPrint;
  //   storage.write(OFFLINE_PLAYLIST, playlistsId);
  //   storage.save();
  // }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getPlaylists();
    getFavList();
  }
}
