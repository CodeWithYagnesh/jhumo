import 'package:get/get.dart';
import 'package:jhumo/moduls/data/variable.dart';
import 'package:jhumo/moduls/model/Search_model.dart';
import 'package:http/http.dart' as http;
import 'package:jhumo/moduls/methods.dart';
import 'package:jhumo/moduls/model/service.dart';

class SearchControl extends GetxController {
  SearchModel? searchModel;
  String search = "";
  SongService? allSongs;
  // SongService? allSongs;
  SearchControl(this.search);
    Variables _var = Variables();

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
    var responce =
        await http.get(Uri.parse("${_var.jioSaavnUrl}/api/search?query=$search&limit=100"));
    // print(responce.body);
    searchModel = searchModelFromJson(responce.body);
    // print(searchModel!.data!.toJson());

    update();
  }

  searchSong(String s) async {
    search = s;
    var responce = await http
        .get(Uri.parse("${_var.jioSaavnUrl}/api/search/songs?query=$search&limit=100"));
    allSongs = serviceFromJson(responce.body);
    // allSongs!.data!.results!.toPrint;

    update();
    // ${_var.jioSaavnUrl}/api/search/songs?query=Believer
  }

  searchArtist(String s) async {
    // ${_var.jioSaavnUrl}/api/search/artists?query=Adele
    search = s;
    var responce = await http
        .get(Uri.parse("${_var.jioSaavnUrl}/api/search/artists?query=$search&limit=100"));


    update();
  }
}
