import 'package:get_storage/get_storage.dart';

class Variables {

  List<String> _strs = [
    "Latest Hindi Hits songs",
    "Gujarati Superhits songs",
    "Romantic Melodies songs",
    "Trending Now songs",
    "Party Anthems songs",
    "Lo-Fi Beats songs"
  ];
  Variables() {

    _strs = GetStorage("env").read("strs") ?? _strs;
  }

  List<String> get strs {
    return _strs;
  }

  set strs(List<String> strs) {
    _strs = strs;
    GetStorage("env").write("strs", strs);
  }




}
