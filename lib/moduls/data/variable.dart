import 'package:get_storage/get_storage.dart';

class Variables {

  List<String> _strs = [
    "Gujarati",
    "Romantic",
    "Hindi",
    "English",
    "Motivated"
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
