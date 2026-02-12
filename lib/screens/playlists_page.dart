import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jhumo/moduls/controller/audio_controller.dart';
import 'package:jhumo/moduls/controller/playlist_controller.dart';
import 'package:jhumo/moduls/model/service.dart';
import 'package:jhumo/screens/fav_page.dart';
import 'package:jhumo/screens/player_page.dart';
import 'package:jhumo/screens/playlist_page.dart';

class PlaylistsPage extends StatelessWidget {
  const PlaylistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: GetBuilder<PlaylistController>(
            init: PlaylistController(),
            builder: (controller) {
              return CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: [
                  // App Bar / Header
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Your Library",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _showCreatePlaylistDialog(context, controller),
                            icon: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.add, color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  // Favorites Banner
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: GestureDetector(
                        onTap: () => Get.to(FavPage()),
                        child: _buildFavoritesCard(controller),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        "Playlists",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Playlist Grid
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          String playlistName = controller.playlistName[index];
                          return _buildPlaylistTile(context, controller, playlistName);
                        },
                        childCount: controller.playlistName.length,
                      ),
                    ),
                  ),

                  // Bottom Spacer for MiniPlayer
                  SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            }),
      ),
    );
  }

  Widget _buildFavoritesCard(PlaylistController controller) {
    // Generate collage images
    List<String> images = controller.favSongsResults.take(4).map((e) => e.image?.last.url ?? "").toList();

    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4200FF).withOpacity(0.8),
            Color(0xFFFF0055).withOpacity(0.6),
          ],
        ),
      ),
      child: Stack(
        children: [
            // Background Collage (faded)
            if (images.isNotEmpty)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Wrap(
                      children: images.map((img) =>
                        Container(
                          width: (Get.width - 40) / (images.length > 2 ? 4 : images.length), // simple spread
                          height: 140,
                          child: Image.network(img, fit: BoxFit.cover),
                        )
                      ).toList(),
                    ),
                  ),
                ),
              ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                           BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0,5))
                    ]
                  ),
                  child: Center(child: Icon(Icons.favorite, color: Color(0xFFE91E63), size: 30)),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Your Favorites",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "${controller.favSongsResults.length} Songs",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistTile(BuildContext context, PlaylistController controller, String name) {
    List<Result> songs = controller.getPlaylistById(name) as List<Result>;
    List<String> images = songs.take(4).map((e) => e.image?.last.url ?? "").take(4).toList();

    return GestureDetector(
      onTap: () => Get.to(PlaylistPage(name: name)),
      onLongPress: () => _showDeleteDialog(controller, name),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album Art Grid
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: images.isEmpty
                  ? Center(child: Icon(Icons.music_note, color: Colors.white24, size: 40))
                  : images.length < 4
                      ? Image.network(images[0], fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                      : Column(
                          children: [
                            Expanded(child: Row(children: [
                               Expanded(child: Image.network(images[0], fit: BoxFit.cover)),
                               Expanded(child: Image.network(images[1], fit: BoxFit.cover)),
                            ])),
                            Expanded(child: Row(children: [
                               Expanded(child: Image.network(images[2], fit: BoxFit.cover)),
                               Expanded(child: Image.network(images[3], fit: BoxFit.cover)),
                            ])),
                          ],
                        ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          Text(
            "${songs.length} Songs",
            style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, PlaylistController controller) {
    TextEditingController _txt = TextEditingController();
    Get.defaultDialog(
      title: "New Playlist",
      titleStyle: TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.bold),
      backgroundColor: Color(0xFF1E1E1E),
      radius: 20,
      content: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _txt,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Playlist Name",
                hintStyle: TextStyle(color: Colors.white30),
                border: InputBorder.none,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text("Cancel", style: TextStyle(color: Colors.white54)),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (_txt.text.isNotEmpty && !controller.playlistName.contains(_txt.text)) {
                      controller.createPlayList(_txt.text);
                      Get.back();
                    }
                  },
                  child: Text("Create", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showDeleteDialog(PlaylistController controller, String name) {
     Get.defaultDialog(
      title: "Delete Playlist?",
      titleStyle: TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.bold),
      middleText: "Are you sure you want to delete '$name'?",
      middleTextStyle: TextStyle(color: Colors.white70),
      backgroundColor: Color(0xFF1E1E1E),
      radius: 20,
      confirm: ElevatedButton(
         style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
         onPressed: () {
            controller.deletePlaylistById(name);
            Get.back();
         },
         child: Text("Delete", style: TextStyle(color: Colors.white)),
      ),
      cancel: TextButton(
         onPressed: () => Get.back(),
         child: Text("Cancel", style: TextStyle(color: Colors.white54)),
      ),
     );
  }
}
