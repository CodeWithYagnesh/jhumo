import 'package:get/get.dart';
import 'package:jhumo/moduls/data/variable.dart';
import 'package:jhumo/moduls/model/service.dart';
import 'package:jhumo/moduls/service/youtube_service.dart';

class MusicController extends GetxController {
  List<SongService> ss = [];
  List<String> strs = [];
  @override
  onInit() {
    super.onInit();
    fetchData();
  }

  YoutubeService _ytService = YoutubeService();
  Variables _var = Variables();

  fetchData() async {
    strs = _var.strs;
    for (var i = 0; i < strs.length; i++) {
      var results = await _ytService.searchSongs(strs[i]);
      // Assuming existing UI expects a `SongService` structure or similar wrapper,
      // but `searchSongs` returns List<Result>.
      // The `ss` list is List<SongService>. `SongService` has a `data` field which is `Data`.
      // `Data` has `results` which is `List<Result>`.
      // We need to wrap the results in a structure that matches `ss` if we want to keep `ss` as `List<SongService>`.

      // Creating a dummy SongService wrapper to match existing structure
      var data = Data(results: results);
      var service = SongService(success: true, data: data);
      ss.add(service);
      update();
    }
  }
}
