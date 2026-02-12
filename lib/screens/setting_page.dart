import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jhumo/moduls/controller/theme_controller.dart';
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

  @override
  Widget build(BuildContext context) {
    String name = GetStorage("user").read("name") ?? "User";
    String lang = GetStorage("user").read("lang") ?? "English";

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(24),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Settings",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 28, // Reduced from 32
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                SizedBox(height: 32),

                // Profile Section (Google Style Large Header)
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                        child: Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _showEditNameDialog(name),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.edit, size: 16, color: Colors.white54),
                          ],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        lang,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),

                // Settings Groups
                _buildSettingsGroup(
                  title: "General",
                  children: [
                    _buildSettingsTile(
                      icon: Icons.dark_mode_rounded,
                      title: "Dark Mode",
                      trailing: Switch.adaptive(
                        value: isDark.value,
                        activeColor: Colors.white,
                        onChanged: (v) {
                           if (v) {
                            Get.changeTheme(darkTheme);
                          } else {
                            Get.changeTheme(lightTheme);
                          }
                          isDark.value = v;
                          GetStorage("theme").write("mode", v);
                          GetStorage("theme").save();
                        }
                      ),
                    ),
                  ],
                ),

                _buildSettingsGroup(
                  title: "Storage",
                  children: [
                    _buildSettingsTile(
                      icon: Icons.delete_outline_rounded,
                      title: "Clear Cache & Data",
                      subtitle: "Delete all songs and reset app data",
                      onTap: _showClearStorageDialog,
                      isDestructive: true,
                    ),
                  ],
                ),

                _buildSettingsGroup(
                  title: "About",
                  children: [
                     _buildSettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: "About Jhumo",
                      subtitle: "Version 1.0.0",
                      onTap: () => Get.to(AboutPage()),
                    ),
                  ],
                ),

                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white70, size: 24),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: isDestructive ? Colors.redAccent : Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing
              else if (onTap != null) Icon(Icons.chevron_right_rounded, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditNameDialog(String currentName) {
    TextEditingController control = TextEditingController(text: currentName);
    Get.defaultDialog(
      title: "Edit Name",
      titleStyle: TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.bold),
      backgroundColor: Color(0xFF1E1E1E),
      radius: 20,
      content: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
           color: Colors.white.withOpacity(0.05),
           borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: control,
          style: TextStyle(color: Colors.white),
          maxLength: 10,
          decoration: InputDecoration(
             border: InputBorder.none,
             counterText: "",
             hintText: "Enter Name",
             hintStyle: TextStyle(color: Colors.white30)
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text("Cancel", style: TextStyle(color: Colors.white54))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
          onPressed: () {
            if (control.text.isNotEmpty) {
              GetStorage("user").write("name", control.text);
              GetStorage("user").save();
              Get.back();
              setState((){}); // Refresh UI
            } else {
              Get.snackbar("Error", "Name can't be empty", colorText: Colors.white);
            }
          },
          child: Text("Save", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        )
      ]
    );
  }

  void _showClearStorageDialog() {
    Get.defaultDialog(
      title: "Clear Storage",
      titleStyle: TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.bold),
      middleText: "Are you sure you want to delete all songs and reset app data? This action cannot be undone.",
      middleTextStyle: TextStyle(color: Colors.white70),
      backgroundColor: Color(0xFF1E1E1E),
      radius: 20,
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
        onPressed: () {
          GetStorage("recent_songs").erase();
          GetStorage("recent_songs").save();
          GetStorage("user").erase();
          GetStorage("user").save();
          GetStorage("playlist").erase();
          GetStorage("playlist").save();
          GetStorage("favStorage").erase();
          GetStorage("favStorage").save();
          GetStorage("collaboration_status").erase();
          GetStorage("collaboration_status").save();
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
        child: Text("Delete All", style: TextStyle(color: Colors.white)),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: Text("Cancel", style: TextStyle(color: Colors.white54)),
      ),
    );
  }
}
