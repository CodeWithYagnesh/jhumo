import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jhumo/moduls/controller/page_controller.dart';

class SideBar extends StatelessWidget {
  SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    String name = GetStorage("user").read("name") ?? "";

    return Container(
      width: 250,
      color: Colors.transparent, // YouTube Music sidebar dark code
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Area
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                      color: Color(0xFFFF0055), // Brand Accent
                      shape: BoxShape.circle),
                  child: Image.asset("assets/white_logo.png",
                      height: 24, width: 24),
                ),
                SizedBox(width: 12),
                Text(
                  "Jhumo",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // Navigation Links
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: GetBuilder(
                  init: ScreenController(),
                  builder: (controller) {

                    // Helper builder for desktop nav item
                    Widget navItem({required IconData icon, required String label, required int index}) {
                       bool isSelected = controller.currentScreen == index;
                       return InkWell(
                         onTap: () {
                           controller.changePage(index);
                         },
                         borderRadius: BorderRadius.circular(12),
                         child: AnimatedContainer(
                           duration: Duration(milliseconds: 200),
                           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                           margin: EdgeInsets.only(bottom: 4),
                           decoration: BoxDecoration(
                             color: isSelected ? Color(0xFFFF0055).withOpacity(0.15) : Colors.transparent,
                             borderRadius: BorderRadius.circular(12),
                             border: isSelected ? Border.all(color: Color(0xFFFF0055).withOpacity(0.3)) : Border.all(color: Colors.transparent),
                           ),
                           child: Row(
                             children: [
                               Icon(
                                 icon,
                                 color: isSelected ? Color(0xFFFF0055) : Colors.white70,
                                 size: 24,
                               ),
                               SizedBox(width: 16),
                               Text(
                                 label,
                                 style: TextStyle(
                                   fontFamily: 'Inter',
                                   color: isSelected ? Colors.white : Colors.white70,
                                   fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                   fontSize: 15
                                 )
                               )
                             ],
                           )
                         )
                       );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        navItem(icon: Icons.home_filled, label: "Home", index: 0),
                        navItem(icon: Icons.group_add_rounded, label: "Collaboration", index: 1),
                        navItem(icon: Icons.library_music_rounded, label: "Library", index: 2),
                        navItem(icon: Icons.settings_rounded, label: "Settings", index: 3), // Replaced Favorite with Settings/Library index matching pages list

                        // SizedBox(height: 24),
                        // Divider(color: Colors.white.withOpacity(0.1)),
                        // SizedBox(height: 16),

                        // Playlists Section Header
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                        //   child: Row(
                        //      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //      children: [
                        //         Text(
                        //           "PLAYLISTS",
                        //           style: TextStyle(
                        //             fontFamily: 'Inter',
                        //             fontWeight: FontWeight.bold,
                        //             fontSize: 12,
                        //             letterSpacing: 1.0,
                        //             color: Colors.white54
                        //           )
                        //         ),
                        //         Icon(Icons.add_rounded, color: Colors.white54, size: 18)
                        //      ]
                        //   ),
                        // ),

                        // // Demo Playlist Items
                        // _playlistItem("Liked Songs"),
                        // _playlistItem("Workout Hits"),
                        // _playlistItem("Acoustic Chill"),
                      ],
                    );
                  }),
            ),
          ),

          // Bottom User Profile Area
        ],
      ),
    );
  }

  Widget _playlistItem(String title) {
     return InkWell(
       onTap: () {},
       child: Padding(
         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
         child: Text(
           title,
           style: TextStyle(
             fontFamily: 'Inter',
             color: Colors.white70,
             fontSize: 14
           )
         ),
       ),
     );
  }
}
