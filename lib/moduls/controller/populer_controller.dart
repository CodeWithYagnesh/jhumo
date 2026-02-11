import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jhumo/moduls/service/youtube_service.dart';
import 'package:jhumo/moduls/data/variable.dart';
import 'package:jhumo/moduls/model/service.dart' as s;

class PopulerController extends GetxController {
  s.SongService? service;
  @override
  onInit() {
    super.onInit();
    fetchData();
  }
  YoutubeService _ytService = YoutubeService();


  fetchData() async {
    var _storage = GetStorage("user").read("lang");
    var results = await _ytService.searchSongs("$_storage popular");
    var data = s.Data(results: results);
    service = s.SongService(success: true, data: data);
    // print(service!.success);
    update();
  }
}
