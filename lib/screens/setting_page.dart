import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jhumo/components/button.dart';
import 'package:jhumo/components/glass_container.dart';
import 'package:jhumo/components/label.dart';
import 'package:jhumo/moduls/controller/theme_controller.dart';
import 'package:jhumo/moduls/data/variable.dart';
import 'package:jhumo/moduls/model/themer.dart';
import 'package:jhumo/screens/about_page.dart';
import 'package:jhumo/screens/intro_page.dart';

class SettingPage extends StatefulWidget {
  SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  var _themeController = Get.put(ThemeController());

  var isDark = Get.isDarkMode.obs;
  Variables _var = Variables();

  @override
  Widget build(BuildContext context) {
    String name = GetStorage("user").read("name") ?? "";
    String lang = GetStorage("user").read("lang") ?? "";
    return Container(
      height: Get.height,
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabelText(text: "Profile"),
              GlassContainer(
                  radius: 15,
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () {
                          var control = TextEditingController();
                          control.text = name;
                          Get.defaultDialog(
                              title: "Edit Name",
                              content: TextField(
                                maxLength: 10,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                controller: control,
                              ),
                              actions: [
                                GestureDetector(
                                  onTap: () {
                                    if (control.text.isEmpty) {
                                      Get.snackbar(
                                          "Error", "Name can't be empty");
                                    } else {
                                      GetStorage("user")
                                          .write("name", control.text);
                                      GetStorage("user").save();
                                      Get.back();
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: _themeController.isDark
                                                  ? Themer.main
                                                  : Themer.dark1,
                                              blurRadius: 20,
                                              offset: Offset(0, 10))
                                        ],
                                        gradient: _themeController.isDark
                                            ? Themer.gradientDark
                                            : Themer.gradientLight,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Save",
                                          style: Get.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ]);
                        },
                        visualDensity: VisualDensity(vertical: -4),
                        title: Text("Name"),
                        subtitle: Text(name),
                        trailing: Icon(Icons.keyboard_arrow_right_outlined),
                      ),
                      Divider(),
                      ListTile(
                        visualDensity: VisualDensity(vertical: -4),
                        title: Text("Language"),
                        subtitle: Text(lang),
                      ),
                    ],
                  )),
              LabelText(text: "Variables"),
              GlassContainer(
                  radius: 15,
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () {
                          var control = TextEditingController();
                          control.text = _var.jioSaavnUrl;
                          Get.defaultDialog(
                              title: "Edit Jio Saavn URL",
                              content: TextField(
                                textCapitalization:
                                    TextCapitalization.sentences,
                                controller: control,
                              ),
                              actions: [
                                GestureDetector(
                                  onTap: () {
                                    if (control.text.isEmpty) {
                                      Get.snackbar(
                                          "Error", "URL can't be empty");
                                    } else {
                                      // remove / from back 
                                      _var.jioSaavnUrl = control.text
                                          .replaceAll(RegExp(r'\/$'), '');
                                      _var.jioSaavnUrl = control.text;
                                      Get.back();
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: _themeController.isDark
                                                  ? Themer.main
                                                  : Themer.dark1,
                                              blurRadius: 20,
                                              offset: Offset(0, 10))
                                        ],
                                        gradient: _themeController.isDark
                                            ? Themer.gradientDark
                                            : Themer.gradientLight,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Save",
                                          style: Get.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ]);
                        },
                        visualDensity: VisualDensity(vertical: -4),
                        title: Text("Jio Saavn URL"),
                        trailing: Icon(Icons.keyboard_arrow_right_outlined),
                        subtitle: Text(_var.jioSaavnUrl),
                      ),
                    ],
                  )),
              SizedBox(height: 20),
              LabelText(text: "Storage"),
              GlassContainer(
                  radius: 15,
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () {
                          Get.defaultDialog(
                              title: "Clear Storage",
                              content: Text(
                                  "Are you sure you want to clear all songs from device storage?"),
                              actions: [
                                TxtButton(
                                    onPressed: () {
                                      GetStorage("recent_songs").erase();
                                      GetStorage("recent_songs").save();
                                      GetStorage("user").erase();
                                      GetStorage("user").save();
                                      GetStorage("playlist").erase();
                                      GetStorage("playlist").save();
                                      GetStorage("favStorage").erase();
                                      GetStorage("favStorage").save();
                                      GetStorage("collaboration_status")
                                          .erase();
                                      GetStorage("collaboration_status").save();
                                      GetStorage("recent_songs").save();
                                      GetStorage("playlistData").erase();
                                      GetStorage("playlistData").save();
                                      GetStorage("playlistName").erase();
                                      GetStorage("playlistName").save();
                                      GetStorage("songData").erase();
                                      GetStorage("songData").save();
                                      GetStorage("theme").erase();
                                      GetStorage("theme").save();
                                      Get.offAll(IntroPage());
                                    },
                                    text: "Delete")
                              ]);
                        },
                        visualDensity: VisualDensity(vertical: -4),
                        title: Text("Clear Storage"),
                        subtitle: Text("Clears all songs from device storage"),
                      ),
                    ],
                  )),
              LabelText(text: "About"),
              GlassContainer(
                  radius: 15,
                  child: ListTile(
                    onTap: () {
                      Get.to(
                        AboutPage(),
                      );
                    },
                    visualDensity: VisualDensity(vertical: -4),
                    title: Text(
                      "About",
                    ),
                    subtitle: Text(
                      "About for app and Developer",
                    ),
                  )),
              LabelText(text: "Appearance"),
              GlassContainer(
                  radius: 15,
                  child: ListTile(
                    // onTap: () {
                    //   Get.to(AboutPage());
                    // },
                    visualDensity: VisualDensity(vertical: -4),
                    title: Text(
                      "Dark mode",
                    ),
                    subtitle: Text(
                      "About for app and Developer",
                    ),
                    trailing: Switch(
                      onChanged: (v) {
                        if (v) {
                          Get.changeTheme(darkTheme);
                        } else {
                          Get.changeTheme(lightTheme);
                        }
                        isDark.value = v;
                        GetStorage("theme").write("mode", v);
                        GetStorage("theme").save();
                      },
                      value: isDark.value,
                    ),
                  )),
              SizedBox(height: 200),
            ],
          ),
        ),
      ),
    );
  }
}
