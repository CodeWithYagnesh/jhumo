import 'dart:async';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:jhumo/main.dart';
import 'package:jhumo/moduls/controller/audio_controller.dart';
import 'package:jhumo/moduls/model/collaboration_model.dart';
import 'package:jhumo/moduls/model/service.dart';
import 'package:jhumo/moduls/service/youtube_service.dart';
import 'package:jhumo/screens/player_page.dart';

class CollaborationController extends GetxController {
  GetStorage storage = GetStorage("collaboration_status");
  bool status = false;
  String songIdd = "";
  String id = "";
  Duration? durationn;
  int timeDuration = 500;
  // lazy load to avoid circular dependency
  AudioController get _audioController => Get.find<AudioController>();
  StreamSubscription<DatabaseEvent>? autoSync;
  String? code;
  YoutubeService _ytService = YoutubeService();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    onAdminSync();
    streaming();
  }

  onClientSync(String code) async {
    this.code = code;
    clientAutoSync();

    if (code == id) {
      return;
    }
    var ref = await FirebaseDatabase.instance.ref("collaboration/$code").get();

    CollaborationModel c =
        CollaborationModel.fromJson(ref.value as Map<dynamic, dynamic>);
    c.duration =
        Duration(milliseconds: c.duration!.inMilliseconds + timeDuration);

    if (_audioController.rs == null ||
        (_audioController.rs != null && c.songId != _audioController.rs!.id)) {
      var song = await _ytService.getSong(c.songId!);
      if (song != null) {
        Get.to(() => PlayerPage(result: song), transition: Transition.downToUp);
        player.seek(c.duration);
        return;
      }
    }
    if (_audioController.rs != null) {
      player.seek(c.duration);
      return;
    }
  }

  timeDurationSet(int value, String code) {
    timeDuration = value;
    update();
    onClientSync(code);
  }

  clientAutoSync() async {
    if (code != null) {
      autoSync = FirebaseDatabase.instance
          .ref("collaboration/$code")
          .onValue
          .listen((v) async {
        // "this is changed".toPrint;
        // v.snapshot.value!.toPrint;
        CollaborationModel c = CollaborationModel.fromJson(
            v.snapshot.value as Map<dynamic, dynamic>);
        if (_audioController.rs == null ||
            (_audioController.rs != null &&
                c.songId != _audioController.rs!.id)) {
          var song = await _ytService.getSong(c.songId!);
          if (song != null) {
            Get.to(() => PlayerPage(result: song),
                transition: Transition.downToUp);
            return;
          }
        }
        // if (_audioController.rs != null) {
        //   return;
        // }
      });
      autoSync!.pause();
    }
  }

  onAutoSyncClick(bool value) {
    print(value);
    if (value) {
      autoSync!.resume();
      return true;
    } else {
      autoSync!.pause();
      return false;
    }
  }

  getId() async {
    id = storage.read("collaboration_id") ?? "";
    if (id == "") {
      var device = DeviceInfoPlugin();
      var data = await device.deviceInfo;

      // print(data.data["id"]);
      id = data.data["id"].toString();
      if (id == "null") {
        id = Random().nextInt(1000000).toString();
      }

      storage.write("collaboration_id", id);
      storage.save();
    }
    id = id.replaceAll(".", "");
  }

  onAdminSync() async {
    status = storage.read("status") ?? false;
    await getId();
    id = id.replaceAll(".", "");
    update();
  }

  syncs(Duration d) async {
    if (status) {
      await getId();
      // id.toPrint;
      AudioController audioController = Get.put(AudioController());
      songIdd = audioController.rs!.id.toString();

      // durationn = player.!;
      CollaborationModel c = CollaborationModel(
        id: id,
        songId: songIdd,
        duration: d,
      );

      await FirebaseDatabase.instance.ref("collaboration/$id").set(c.toJson());
      // update();
    }
  }

  streaming() {
    storage.listen(() async {
      status = storage.read("status") ?? false;
      // status.toPrint;
      if (status) {
        CollaborationModel c = CollaborationModel(
          id: id,
          songId: songIdd,
          duration: durationn,
        );
      }
      update();
    });
  }

  setStatusOfSync(bool status) {
    storage.write("status", status);
    this.status = status;
    storage.save();
    update();
  }
}
