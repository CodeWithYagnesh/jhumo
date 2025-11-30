import 'package:get_storage/get_storage.dart';

class Variables {
  String _jioSaavnUrl = "";
  List<String> _strs = [
    "Gujarati",
    "Romantic",
    "Hindi",
    "English",
    "Motivated"
  ];
  Variables() {
    _jioSaavnUrl = GetStorage("env").read("URL") ?? "https://jiosavan-api2.vercel.app";
    _strs = GetStorage("env").read("strs") ?? _strs;
  }

  List<String> get strs {
    return _strs;
  }

  set strs(List<String> strs) {
    _strs = strs;
    GetStorage("env").write("strs", strs);
  }

  set jioSaavnUrl(String url) {
    _jioSaavnUrl = url;
    GetStorage("env").write("URL", url);
  }

  String get jioSaavnUrl {
    return _jioSaavnUrl;
  }
}
