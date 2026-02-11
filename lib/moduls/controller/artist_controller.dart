import 'dart:math';

import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:jhumo/moduls/service/youtube_service.dart';
import 'package:jhumo/moduls/data/variable.dart';
import 'package:jhumo/moduls/model/service.dart';

class ArtistController extends GetxController {
  SongService? service;
  @override
  onInit() {
    super.onInit();
    fetchData();
  }

  fetchData() async {
    YoutubeService _ytService = YoutubeService();
    // String random = String.fromCharCode(Random().nextInt(26) + 97);
    // Youtube search for random character might be weird, let's search for a generic term or keep random char if it works.
    // Searching for single letter 'a', 'b' etc on youtube usually returns lists of songs/videos.
    String random = String.fromCharCode(Random().nextInt(26) + 97);
    var results = await _ytService.searchSongs(random);
    var data = Data(results: results);
    service = SongService(success: true, data: data);
    update();
  }
}
