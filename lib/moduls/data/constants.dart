import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:volume_controller/volume_controller.dart';

final String CHANNEL = "FOREGROUND_SVC";

final VolumeController volumeController = VolumeController.instance;






var service = FlutterBackgroundService();