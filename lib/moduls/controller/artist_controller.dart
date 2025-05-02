import 'dart:math';

import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:http/http.dart' as http;
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
    Variables _var = Variables();
    String random = String.fromCharCode(Random().nextInt(26) + 97);
    // print(random);
    var response = await http
        .get(Uri.parse("${_var.jioSaavnUrl}/api/search/artists?query=$random"));
    service = serviceFromJson(response.body);
    // print(service!.success);
    update();
  }
}
