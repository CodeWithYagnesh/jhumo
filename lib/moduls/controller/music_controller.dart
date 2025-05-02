import 'package:get/get.dart';
import 'package:jhumo/moduls/data/variable.dart';
import 'package:jhumo/moduls/model/service.dart';
import 'package:http/http.dart' as http;

class MusicController extends GetxController {
  List<SongService> ss = [];
  List<String> strs = [];
  @override
  onInit() {
    super.onInit();
    fetchData();
  }

  Variables _var = Variables();

  fetchData() async {
    strs = _var.strs;
    for (var i = 0; i < strs.length; i++) {
      var response = await http.get(
          Uri.parse("${_var.jioSaavnUrl}/api/search/songs?query=${strs[i]}"));
      ss.add(serviceFromJson(response.body));
      update();
    }
  }
}
