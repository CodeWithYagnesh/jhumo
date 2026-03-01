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
      color: Color(0xFF151515), // YouTube Music sidebar dark code
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
                           // Try to update main page's current state if possible, or use a global route
                           // Since MainPage handles its own state (currentPage),
                           // we should probably navigate via Get material routing or event bus
                           // For now, let's assume ScreenController is used in MainPage (which we didn't hook up earlier)
                           // Let's hook up the ScreenController in the updated sidebar navigation!
                           controller.changePage(index);

                           // Note: MainPage currently uses a local `currentPage`.
                           // For a true global sidebar, MainPage needs to listen to ScreenController.
                           // We will fix that connection shortly.
                         },
                         borderRadius: BorderRadius.circular(8),
                         child: Container(
                           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                           margin: EdgeInsets.only(bottom: 4),
                           decoration: BoxDecoration(
                             color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
                             borderRadius: BorderRadius.circular(8)
                           ),
                           child: Row(
                             children: [
                               Icon(icon, color: isSelected ? Colors.white : Colors.white70, size: 24),
                               SizedBox(width: 16),
                               Text(
                                 label,
                                 style: TextStyle(
                                   fontFamily: 'Inter',
                                   color: isSelected ? Colors.white : Colors.white70,
                                   fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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

                        SizedBox(height: 24),
                        Divider(color: Colors.white.withOpacity(0.1)),
                        SizedBox(height: 16),

                        // Playlists Section Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                          child: Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                                Text(
                                  "PLAYLISTS",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 1.0,
                                    color: Colors.white54
                                  )
                                ),
                                Icon(Icons.add_rounded, color: Colors.white54, size: 18)
                             ]
                          ),
                        ),

                        // Demo Playlist Items
                        _playlistItem("Liked Songs"),
                        _playlistItem("Workout Hits"),
                        _playlistItem("Acoustic Chill"),
                      ],
                    );
                  }),
            ),
          ),

          // Bottom User Profile Area
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
               border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))
            ),
            child: Row(
               children: [
                  CircleAvatar(
                     radius: 18,
                     backgroundColor: Color(0xFF333333),
                     child: Icon(Icons.person, color: Colors.white, size: 20)
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                           name.isNotEmpty ? name : "User",
                           style: TextStyle(
                             fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14
                           )
                         ),
                         Text(
                           "Free Plan",
                           style: TextStyle(
                             fontFamily: 'Inter', color: Colors.white54, fontSize: 12
                           )
                         )
                      ]
                    ),
                  )
               ]
            ),
          )
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
